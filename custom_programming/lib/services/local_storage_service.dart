// lib/services/local_storage_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _codeFilesBoxName = 'code_files';
  static const String _settingsBoxName = 'app_settings';
  static const String _recentFilesKey = 'recent_files';
  static const String _serverConfigKey = 'server_config';
  static const String _compilerSettingsKey = 'compiler_settings';
  static const String _editorSettingsKey = 'editor_settings';
  
  late Box<CodeFile> _codeFilesBox;
  late Box<dynamic> _settingsBox;
  late SharedPreferences _prefs;
  
  static LocalStorageService? _instance;
  
  LocalStorageService._();
  
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }
  
  /// Initialize local storage
  Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CodeFileAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ServerConfigAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CompilerSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(EditorSettingsAdapter());
      }
      
      // Open boxes
      _codeFilesBox = await Hive.openBox<CodeFile>(_codeFilesBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      debugPrint('✅ Local storage initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing local storage: $e');
      rethrow;
    }
  }
  
  /// Save C++ code file
  Future<bool> saveCodeFile(String filename, String code, {String? description}) async {
    try {
      final codeFile = CodeFile(
        filename: filename,
        code: code,
        description: description ?? '',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        size: code.length,
      );
      
      await _codeFilesBox.put(filename, codeFile);
      await _addToRecentFiles(filename);
      
      debugPrint('✅ Saved file: $filename (${code.length} chars)');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving file $filename: $e');
      return false;
    }
  }
  
  /// Load C++ code file
  Future<CodeFile?> loadCodeFile(String filename) async {
    try {
      final codeFile = _codeFilesBox.get(filename);
      if (codeFile != null) {
        await _addToRecentFiles(filename);
        debugPrint('✅ Loaded file: $filename');
        return codeFile;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading file $filename: $e');
      return null;
    }
  }
  
  /// Get all saved files
  Future<List<CodeFile>> getAllCodeFiles() async {
    try {
      final files = _codeFilesBox.values.toList();
      files.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      return files;
    } catch (e) {
      debugPrint('❌ Error getting all files: $e');
      return [];
    }
  }
  
  /// Delete code file
  Future<bool> deleteCodeFile(String filename) async {
    try {
      await _codeFilesBox.delete(filename);
      await _removeFromRecentFiles(filename);
      debugPrint('✅ Deleted file: $filename');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting file $filename: $e');
      return false;
    }
  }
  
  /// Get recent files
  Future<List<String>> getRecentFiles() async {
    try {
      final recentFiles = _prefs.getStringList(_recentFilesKey) ?? [];
      return recentFiles;
    } catch (e) {
      debugPrint('❌ Error getting recent files: $e');
      return [];
    }
  }
  
  /// Add to recent files
  Future<void> _addToRecentFiles(String filename) async {
    try {
      final recentFiles = _prefs.getStringList(_recentFilesKey) ?? [];
      recentFiles.remove(filename); // Remove if already exists
      recentFiles.insert(0, filename); // Add to beginning
      
      // Keep only last 10 files
      if (recentFiles.length > 10) {
        recentFiles.removeRange(10, recentFiles.length);
      }
      
      await _prefs.setStringList(_recentFilesKey, recentFiles);
    } catch (e) {
      debugPrint('❌ Error adding to recent files: $e');
    }
  }
  
  /// Remove from recent files
  Future<void> _removeFromRecentFiles(String filename) async {
    try {
      final recentFiles = _prefs.getStringList(_recentFilesKey) ?? [];
      recentFiles.remove(filename);
      await _prefs.setStringList(_recentFilesKey, recentFiles);
    } catch (e) {
      debugPrint('❌ Error removing from recent files: $e');
    }
  }
  
  /// Save server configuration
  Future<void> saveServerConfig(ServerConfig config) async {
    try {
      await _settingsBox.put(_serverConfigKey, config);
      debugPrint('✅ Server config saved');
    } catch (e) {
      debugPrint('❌ Error saving server config: $e');
    }
  }
  
  /// Load server configuration
  Future<ServerConfig> loadServerConfig() async {
    try {
      final config = _settingsBox.get(_serverConfigKey);
      if (config is ServerConfig) {
        return config;
      }
      return ServerConfig.defaultConfig();
    } catch (e) {
      debugPrint('❌ Error loading server config: $e');
      return ServerConfig.defaultConfig();
    }
  }
  
  /// Save compiler settings
  Future<void> saveCompilerSettings(CompilerSettings settings) async {
    try {
      await _settingsBox.put(_compilerSettingsKey, settings);
      debugPrint('✅ Compiler settings saved');
    } catch (e) {
      debugPrint('❌ Error saving compiler settings: $e');
    }
  }
  
  /// Load compiler settings
  Future<CompilerSettings> loadCompilerSettings() async {
    try {
      final settings = _settingsBox.get(_compilerSettingsKey);
      if (settings is CompilerSettings) {
        return settings;
      }
      return CompilerSettings.defaultSettings();
    } catch (e) {
      debugPrint('❌ Error loading compiler settings: $e');
      return CompilerSettings.defaultSettings();
    }
  }
  
  /// Save editor settings
  Future<void> saveEditorSettings(EditorSettings settings) async {
    try {
      await _settingsBox.put(_editorSettingsKey, settings);
      debugPrint('✅ Editor settings saved');
    } catch (e) {
      debugPrint('❌ Error saving editor settings: $e');
    }
  }
  
  /// Load editor settings
  Future<EditorSettings> loadEditorSettings() async {
    try {
      final settings = _settingsBox.get(_editorSettingsKey);
      if (settings is EditorSettings) {
        return settings;
      }
      return EditorSettings.defaultSettings();
    } catch (e) {
      debugPrint('❌ Error loading editor settings: $e');
      return EditorSettings.defaultSettings();
    }
  }
  
  /// Export code file to device storage
  Future<String?> exportCodeFile(String filename) async {
    try {
      final codeFile = await loadCodeFile(filename);
      if (codeFile == null) return null;
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(codeFile.code);
      
      debugPrint('✅ Exported file: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ Error exporting file: $e');
      return null;
    }
  }
  
  /// Import code file from device storage
  Future<bool> importCodeFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      
      final code = await file.readAsString();
      final filename = file.path.split('/').last;
      
      return await saveCodeFile(filename, code, description: 'Imported file');
    } catch (e) {
      debugPrint('❌ Error importing file: $e');
      return false;
    }
  }
  
  /// Clear all data (for debugging/reset)
  Future<void> clearAll() async {
    try {
      await _codeFilesBox.clear();
      await _settingsBox.clear();
      await _prefs.clear();
      debugPrint('✅ All data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }
  
  /// Get storage statistics
  Future<StorageStats> getStorageStats() async {
    try {
      final totalFiles = _codeFilesBox.length;
      final totalSize = _codeFilesBox.values.fold(0, (sum, file) => sum + file.size);
      final recentFiles = await getRecentFiles();
      
      return StorageStats(
        totalFiles: totalFiles,
        totalSize: totalSize,
        recentFilesCount: recentFiles.length,
        lastAccess: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error getting storage stats: $e');
      return StorageStats.empty();
    }
  }
}

// Data Models
@HiveType(typeId: 0)
class CodeFile extends HiveObject {
  @HiveField(0)
  final String filename;
  
  @HiveField(1)
  final String code;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime lastModified;
  
  @HiveField(5)
  final int size;
  
  CodeFile({
    required this.filename,
    required this.code,
    required this.description,
    required this.createdAt,
    required this.lastModified,
    required this.size,
  });
  
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(lastModified);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }
}

@HiveType(typeId: 1)
class ServerConfig extends HiveObject {
  @HiveField(0)
  final String host;
  
  @HiveField(1)
  final int port;
  
  @HiveField(2)
  final bool autoConnect;
  
  @HiveField(3)
  final int timeout;
  
  ServerConfig({
    required this.host,
    required this.port,
    required this.autoConnect,
    required this.timeout,
  });
  
  factory ServerConfig.defaultConfig() => ServerConfig(
    host: '192.168.100.13',
    port: 5000,
    autoConnect: true,
    timeout: 30,
  );
  
  String get url => 'http://$host:$port';
}

@HiveType(typeId: 2)
class CompilerSettings extends HiveObject {
  @HiveField(0)
  final bool showGeneratedCode;
  
  @HiveField(1)
  final bool verboseOutput;
  
  @HiveField(2)
  final bool autoCompile;
  
  @HiveField(3)
  final int compilerTimeout;
  
  CompilerSettings({
    required this.showGeneratedCode,
    required this.verboseOutput,
    required this.autoCompile,
    required this.compilerTimeout,
  });
  
  factory CompilerSettings.defaultSettings() => CompilerSettings(
    showGeneratedCode: false,
    verboseOutput: false,
    autoCompile: false,
    compilerTimeout: 30,
  );
}

@HiveType(typeId: 3)
class EditorSettings extends HiveObject {
  @HiveField(0)
  final double fontSize;
  
  @HiveField(1)
  final String theme;
  
  @HiveField(2)
  final bool lineNumbers;
  
  @HiveField(3)
  final bool wordWrap;
  
  @HiveField(4)
  final int tabSize;
  
  EditorSettings({
    required this.fontSize,
    required this.theme,
    required this.lineNumbers,
    required this.wordWrap,
    required this.tabSize,
  });
  
  factory EditorSettings.defaultSettings() => EditorSettings(
    fontSize: 14.0,
    theme: 'dark',
    lineNumbers: true,
    wordWrap: true,
    tabSize: 4,
  );
}

class StorageStats {
  final int totalFiles;
  final int totalSize;
  final int recentFilesCount;
  final DateTime lastAccess;
  
  StorageStats({
    required this.totalFiles,
    required this.totalSize,
    required this.recentFilesCount,
    required this.lastAccess,
  });
  
  factory StorageStats.empty() => StorageStats(
    totalFiles: 0,
    totalSize: 0,
    recentFilesCount: 0,
    lastAccess: DateTime.now(),
  );
  
  String get formattedTotalSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Generate Hive Adapters
class CodeFileAdapter extends TypeAdapter<CodeFile> {
  @override
  final int typeId = 0;

  @override
  CodeFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CodeFile(
      filename: fields[0] as String,
      code: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
      lastModified: fields[4] as DateTime,
      size: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CodeFile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.filename)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.lastModified)
      ..writeByte(5)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServerConfigAdapter extends TypeAdapter<ServerConfig> {
  @override
  final int typeId = 1;

  @override
  ServerConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerConfig(
      host: fields[0] as String,
      port: fields[1] as int,
      autoConnect: fields[2] as bool,
      timeout: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ServerConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.host)
      ..writeByte(1)
      ..write(obj.port)
      ..writeByte(2)
      ..write(obj.autoConnect)
      ..writeByte(3)
      ..write(obj.timeout);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompilerSettingsAdapter extends TypeAdapter<CompilerSettings> {
  @override
  final int typeId = 2;

  @override
  CompilerSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompilerSettings(
      showGeneratedCode: fields[0] as bool,
      verboseOutput: fields[1] as bool,
      autoCompile: fields[2] as bool,
      compilerTimeout: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CompilerSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.showGeneratedCode)
      ..writeByte(1)
      ..write(obj.verboseOutput)
      ..writeByte(2)
      ..write(obj.autoCompile)
      ..writeByte(3)
      ..write(obj.compilerTimeout);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompilerSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EditorSettingsAdapter extends TypeAdapter<EditorSettings> {
  @override
  final int typeId = 3;

  @override
  EditorSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EditorSettings(
      fontSize: fields[0] as double,
      theme: fields[1] as String,
      lineNumbers: fields[2] as bool,
      wordWrap: fields[3] as bool,
      tabSize: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EditorSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fontSize)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.lineNumbers)
      ..writeByte(3)
      ..write(obj.wordWrap)
      ..writeByte(4)
      ..write(obj.tabSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}