// lib/services/compiler_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CompilerApiService {
  static const String defaultHost = '192.168.100.13'; // Change this to your server IP
  static const int defaultPort = 5000;
  
  late String _baseUrl;
  late http.Client _client;
  
  CompilerApiService({String? host, int? port}) {
    final serverHost = host ?? defaultHost;
    final serverPort = port ?? defaultPort;
    _baseUrl = 'http://$serverHost:$serverPort';
    _client = http.Client();
  }
  
  /// Test connection to the server
  Future<ServerConnectionResult> testConnection() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServerConnectionResult(
          isConnected: true,
          message: data['message'] ?? 'Connected successfully',
          serverInfo: data,
        );
      } else {
        return ServerConnectionResult(
          isConnected: false,
          message: 'Server returned status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ServerConnectionResult(
        isConnected: false,
        message: 'Connection failed: ${e.toString()}',
        error: e.toString(),
      );
    }
  }
  
  /// Compile C++ code on the server
  Future<CompilationResult> compileCode({
    required String code,
    String? filename,
    bool showGeneratedCode = false,
    bool verbose = false,
  }) async {
    try {
      final requestBody = {
        'code': code,
        'filename': filename ?? 'mobile_input.cpp',
        'show_generated_code': showGeneratedCode,
        'verbose': verbose,
      };
      
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/compile'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      
      return CompilationResult(
        success: data['success'] ?? false,
        output: data['execution_output'] ?? '',
        error: data['error'],
        details: List<String>.from(data['details'] ?? []),
        compilationOutput: data['output'] ?? '',
        generatedCode: data['generated_code'],
        serverInfo: data['server_info'],
        compilationPhases: List<String>.from(data['compilation_phases'] ?? []),
      );
    } catch (e) {
      return CompilationResult(
        success: false,
        output: '',
        error: 'Network error: ${e.toString()}',
        details: [e.toString()],
      );
    }
  }
  
  /// Get example programs from the server
  Future<ExamplesResult> getExamples() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/examples'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final examplesList = List<Map<String, dynamic>>.from(data['examples'] ?? []);
        
        final examples = examplesList.map((e) => CodeExample(
          filename: e['filename'] ?? '',
          code: e['code'] ?? '',
          description: e['description'] ?? '',
          category: e['category'] ?? 'general',
        )).toList();
        
        return ExamplesResult(
          success: data['success'] ?? false,
          examples: examples,
          count: data['count'] ?? 0,
        );
      } else {
        return ExamplesResult(
          success: false,
          examples: [],
          count: 0,
          error: 'Failed to fetch examples: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ExamplesResult(
        success: false,
        examples: [],
        count: 0,
        error: 'Network error: ${e.toString()}',
      );
    }
  }
  
  /// Get server information
  Future<ServerInfoResult> getServerInfo() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/server-info'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServerInfoResult(
          success: true,
          serverInfo: data,
        );
      } else {
        return ServerInfoResult(
          success: false,
          error: 'Failed to get server info: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ServerInfoResult(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }
  
  /// Update server URL (for connecting to different servers)
  void updateServerUrl({required String host, required int port}) {
    _baseUrl = 'http://$host:$port';
  }
  
  /// Get current server URL
  String get serverUrl => _baseUrl;
  
  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

// Data classes for API responses

class ServerConnectionResult {
  final bool isConnected;
  final String message;
  final String? error;
  final Map<String, dynamic>? serverInfo;
  
  const ServerConnectionResult({
    required this.isConnected,
    required this.message,
    this.error,
    this.serverInfo,
  });
}

class CompilationResult {
  final bool success;
  final String output;
  final String? error;
  final List<String> details;
  final String compilationOutput;
  final String? generatedCode;
  final Map<String, dynamic>? serverInfo;
  final List<String> compilationPhases;
  
  const CompilationResult({
    required this.success,
    required this.output,
    this.error,
    required this.details,
    this.compilationOutput = '',
    this.generatedCode,
    this.serverInfo,
    this.compilationPhases = const [],
  });
  
  /// Get formatted output for display
  String get formattedOutput {
    final buffer = StringBuffer();
    
    if (success) {
      buffer.writeln('✅ Compilation Successful');
      if (compilationOutput.isNotEmpty) {
        buffer.writeln('\\nCompilation Details:');
        buffer.writeln(compilationOutput);
      }
      if (output.isNotEmpty) {
        buffer.writeln('\\n📄 Program Output:');
        buffer.writeln('-' * 30);
        buffer.writeln(output);
        buffer.writeln('-' * 30);
      }
    } else {
      buffer.writeln('❌ Compilation Failed');
      if (error != null) {
        buffer.writeln('\\nError: $error');
      }
      if (details.isNotEmpty) {
        buffer.writeln('\\nDetails:');
        for (final detail in details) {
          buffer.writeln('• $detail');
        }
      }
      if (compilationOutput.isNotEmpty) {
        buffer.writeln('\\nCompiler Output:');
        buffer.writeln(compilationOutput);
      }
    }
    
    return buffer.toString();
  }
}

class CodeExample {
  final String filename;
  final String code;
  final String description;
  final String category;
  
  const CodeExample({
    required this.filename,
    required this.code,
    required this.description,
    required this.category,
  });
}

class ExamplesResult {
  final bool success;
  final List<CodeExample> examples;
  final int count;
  final String? error;
  
  const ExamplesResult({
    required this.success,
    required this.examples,
    required this.count,
    this.error,
  });
}

class ServerInfoResult {
  final bool success;
  final Map<String, dynamic>? serverInfo;
  final String? error;
  
  const ServerInfoResult({
    required this.success,
    this.serverInfo,
    this.error,
  });
}

// Network configuration helper
class NetworkConfig {
  static Future<List<String>> discoverLocalIPs() async {
    final List<String> ips = [];
    
    try {
      for (final interface in await NetworkInterface.list()) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            ips.add(addr.address);
          }
        }
      }
    } catch (e) {
      print('Error discovering IPs: $e');
    }
    
    return ips;
  }
  
  static String generateServerIP(String deviceIP) {
    // Generate potential server IP based on device IP
    // Assumes server is on same network
    final parts = deviceIP.split('.');
    if (parts.length == 4) {
      // Common router IPs
      final baseIP = '${parts[0]}.${parts[1]}.${parts[2]}';
      return '$baseIP.1'; // Often the router IP
    }
    return '192.168.100.13';
  }
}