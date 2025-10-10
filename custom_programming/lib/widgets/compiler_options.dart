// widgets/compiler_options.dart
import 'package:custom_programming/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/local_storage_service.dart';
import '../bloc/compiler_bloc/compiler_bloc.dart';
import '../widgets/server_settings_dialog.dart';

class CompilerOptionsWidget extends StatefulWidget {
  const CompilerOptionsWidget({super.key});

  @override
  State<CompilerOptionsWidget> createState() => _CompilerOptionsWidgetState();
}

class _CompilerOptionsWidgetState extends State<CompilerOptionsWidget> {
  // Compiler Settings
  bool _showGeneratedCode = false;
  bool _verboseOutput = false;
  bool _autoCompile = false;
  int _compilerTimeout = 30;
  
  // Editor Settings
  double _fontSize = 14.0;
  String _theme = 'dark';
  bool _lineNumbers = true;
  bool _wordWrap = true;
  int _tabSize = 4;
  
  // Server Settings
  String _serverHost = '192.168.100.13';
  int _serverPort = 5000;
  bool _autoConnect = true;
  int _networkTimeout = 30;
  
  bool _isLoading = true;
  StorageStats? _storageStats;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);
      
      // Load all settings
      final compilerSettings = await LocalStorageService.instance.loadCompilerSettings();
      final editorSettings = await LocalStorageService.instance.loadEditorSettings();
      final serverConfig = await LocalStorageService.instance.loadServerConfig();
      final storageStats = await LocalStorageService.instance.getStorageStats();
      
      setState(() {
        // Compiler settings
        _showGeneratedCode = compilerSettings.showGeneratedCode;
        _verboseOutput = compilerSettings.verboseOutput;
        _autoCompile = compilerSettings.autoCompile;
        _compilerTimeout = compilerSettings.compilerTimeout;
        
        // Editor settings
        _fontSize = editorSettings.fontSize;
        _theme = editorSettings.theme;
        _lineNumbers = editorSettings.lineNumbers;
        _wordWrap = editorSettings.wordWrap;
        _tabSize = editorSettings.tabSize;
        
        // Server settings
        _serverHost = serverConfig.host;
        _serverPort = serverConfig.port;
        _autoConnect = serverConfig.autoConnect;
        _networkTimeout = serverConfig.timeout;
        
        _storageStats = storageStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveCompilerSettings() async {
    final settings = CompilerSettings(
      showGeneratedCode: _showGeneratedCode,
      verboseOutput: _verboseOutput,
      autoCompile: _autoCompile,
      compilerTimeout: _compilerTimeout,
    );
    await LocalStorageService.instance.saveCompilerSettings(settings);
  }

  Future<void> _saveEditorSettings() async {
    final settings = EditorSettings(
      fontSize: _fontSize,
      theme: _theme,
      lineNumbers: _lineNumbers,
      wordWrap: _wordWrap,
      tabSize: _tabSize,
    );
    await LocalStorageService.instance.saveEditorSettings(settings);
  }

  Future<void> _saveServerSettings() async {
    final config = ServerConfig(
      host: _serverHost,
      port: _serverPort,
      autoConnect: _autoConnect,
      timeout: _networkTimeout,
    );
    await LocalStorageService.instance.saveServerConfig(config);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with connection status
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // Server Configuration
          _buildServerSection(),
          
          const SizedBox(height: 16),
          
          // Compiler Options
          _buildCompilerSection(),
          
          const SizedBox(height: 16),
          
          // Editor Settings
          _buildEditorSection(),
          
          const SizedBox(height: 16),
          
          // Storage Management
          _buildStorageSection(),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<CompilerBloc, CompilerState>(
      builder: (context, state) {
        return Row(
          children: [
            const Icon(Icons.settings, color: Color(0xFF6366F1), size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Settings & Options',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
            ConnectionStatusWidget(
              isConnected: state.isServerConnected,
              serverUrl: state.serverUrl,
              onSettings: () => _showAdvancedServerSettings(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServerSection() {
    return _buildOptionCard(
      'Server Configuration',
      Icons.wifi,
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _serverHost,
                  decoration: const InputDecoration(
                    labelText: 'Server IP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.computer),
                  ),
                  onChanged: (value) {
                    _serverHost = value;
                    _saveServerSettings();
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: _serverPort.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.router),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final port = int.tryParse(value);
                    if (port != null && port > 0 && port < 65536) {
                      _serverPort = port;
                      _saveServerSettings();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSwitchOption('Auto-connect on startup', _autoConnect, (value) async {
            setState(() => _autoConnect = value);
            await _saveServerSettings();
          }),
          _buildSliderOption(
            'Network Timeout',
            _networkTimeout.toDouble(),
            5.0,
            60.0,
            '${_networkTimeout}s',
            (value) async {
              setState(() => _networkTimeout = value.round());
              await _saveServerSettings();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<CompilerBloc>().add(TestConnection()),
                  icon: const Icon(Icons.wifi, size: 18, color: AppColors.primary),
                  label: const Text('Test', style: TextStyle(color: AppColors.primary),),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAdvancedServerSettings,
                  icon: const Icon(Icons.settings, size: 18, color: AppColors.primary),
                  label: const Text('Advanced', style: TextStyle(color: AppColors.primary),),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompilerSection() {
    return _buildOptionCard(
      'Compiler Options',
      Icons.code,
      Column(
        children: [
          _buildSwitchOption('Show Generated Code', _showGeneratedCode, (value) async {
            setState(() => _showGeneratedCode = value);
            await _saveCompilerSettings();
          }),
          _buildSwitchOption('Verbose Output', _verboseOutput, (value) async {
            setState(() => _verboseOutput = value);
            await _saveCompilerSettings();
          }),
          _buildSwitchOption('Auto-compile on Save', _autoCompile, (value) async {
            setState(() => _autoCompile = value);
            await _saveCompilerSettings();
          }),
          _buildSliderOption(
            'Compilation Timeout',
            _compilerTimeout.toDouble(),
            5.0,
            120.0,
            '${_compilerTimeout}s',
            (value) async {
              setState(() => _compilerTimeout = value.round());
              await _saveCompilerSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditorSection() {
    return _buildOptionCard(
      'Editor Settings',
      Icons.edit,
      Column(
        children: [
          _buildSliderOption(
            'Font Size',
            _fontSize,
            10.0,
            24.0,
            '${_fontSize.toInt()}px',
            (value) async {
              setState(() => _fontSize = value);
              await _saveEditorSettings();
            },
          ),
          Row(
            children: [
              const Text('Theme: '),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _theme,
                  isExpanded: true,
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      setState(() => _theme = newValue);
                      await _saveEditorSettings();
                    }
                  },
                  items: ['dark', 'light', 'auto']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSwitchOption('Show Line Numbers', _lineNumbers, (value) async {
            setState(() => _lineNumbers = value);
            await _saveEditorSettings();
          }),
          _buildSwitchOption('Word Wrap', _wordWrap, (value) async {
            setState(() => _wordWrap = value);
            await _saveEditorSettings();
          }),
          _buildSliderOption(
            'Tab Size',
            _tabSize.toDouble(),
            2.0,
            8.0,
            '$_tabSize spaces',
            (value) async {
              setState(() => _tabSize = value.round());
              await _saveEditorSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection() {
    return _buildOptionCard(
      'Storage Management',
      Icons.storage,
      Column(
        children: [
          if (_storageStats != null) ...[
            _buildInfoRow('Total Files', '${_storageStats!.totalFiles}'),
            _buildInfoRow('Storage Used', _storageStats!.formattedTotalSize),
            _buildInfoRow('Recent Files', '${_storageStats!.recentFilesCount}'),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _refreshStorageStats,
                  icon: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
                  label: const Text('Refresh', style: TextStyle(color: AppColors.primary,),),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showClearDataDialog,
                  icon: const Icon(Icons.delete_forever, size: 18, color: Colors.red),
                  label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetAllSettings,
            icon: const Icon(Icons.restore),
            label: const Text('Reset All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _loadSettings,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            label: const Text('Reload Settings', style: TextStyle(color: AppColors.primary),),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(String title, IconData icon, Widget content) {
    return Card(
      color: Colors.grey[100],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchOption(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSliderOption(
    String title,
    double value,
    double min,
    double max,
    String displayValue,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            const Spacer(),
            Text(displayValue, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAdvancedServerSettings() {
    showDialog(
      context: context,
      builder: (context) => const ServerSettingsDialog(),
    );
  }

  Future<void> _refreshStorageStats() async {
    final stats = await LocalStorageService.instance.getStorageStats();
    setState(() => _storageStats = stats);
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all saved files, settings, and app data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primary),),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await LocalStorageService.instance.clearAll();
              await _loadSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ All data cleared'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Clear All Data', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllSettings() async {
    // Reset to defaults
    await LocalStorageService.instance.saveCompilerSettings(CompilerSettings.defaultSettings());
    await LocalStorageService.instance.saveEditorSettings(EditorSettings.defaultSettings());
    await LocalStorageService.instance.saveServerConfig(ServerConfig.defaultConfig());
    
    // Reload settings
    await _loadSettings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ All settings reset to default'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}