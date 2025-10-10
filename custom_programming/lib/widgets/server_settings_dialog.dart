// lib/widgets/server_settings_dialog.dart
import 'package:custom_programming/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/compiler_bloc/compiler_bloc.dart';
import '../services/compiler_api_service.dart';

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({Key? key}) : super(key: key);

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  bool _isConnecting = false;
  String? _connectionStatus;
  Color _statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    final currentUrl = context.read<CompilerBloc>().state.serverUrl;
    final uri = Uri.parse(currentUrl);
    
    _hostController = TextEditingController(text: uri.host);
    _portController = TextEditingController(text: uri.port.toString());
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _testConnection() async {
    if (_hostController.text.isEmpty || _portController.text.isEmpty) {
      _showStatus('Please enter both host and port', Colors.orange);
      return;
    }

    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Testing connection...';
      _statusColor = Colors.blue;
    });

    try {
      final host = _hostController.text.trim();
      final port = int.tryParse(_portController.text.trim());

      if (port == null || port < 1 || port > 65535) {
        _showStatus('Invalid port number', Colors.red);
        return;
      }

      final apiService = CompilerApiService(host: host, port: port);
      final result = await apiService.testConnection();

      if (result.isConnected) {
        _showStatus('✅ Connected successfully!', Colors.green);
        
        // Update bloc with new server config
        if (mounted) {
          context.read<CompilerBloc>().add(UpdateServerConfig(host, port));
        }
      } else {
        _showStatus('❌ ${result.message}', Colors.red);
      }
      
      apiService.dispose();
    } catch (e) {
      _showStatus('❌ Connection failed: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _showStatus(String message, Color color) {
    if (mounted) {
      setState(() {
        _connectionStatus = message;
        _statusColor = color;
      });
    }
  }

  void _discoverServers() async {
    setState(() {
      _connectionStatus = 'Discovering servers...';
      _statusColor = Colors.blue;
    });

    try {
      final ips = await NetworkConfig.discoverLocalIPs();
      if (ips.isNotEmpty) {
        final deviceIP = ips.first;
        final suggestedIP = NetworkConfig.generateServerIP(deviceIP);
        
        _hostController.text = suggestedIP;
        _showStatus('Suggested server IP: $suggestedIP', Colors.orange);
      } else {
        _showStatus('No network interfaces found', Colors.orange);
      }
    } catch (e) {
      _showStatus('Discovery failed: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.settings, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Server Settings'),
        ],
      ),
      content: SizedBox(
        
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Configure the Python compiler server connection:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Host input
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Server IP Address',
                hintText: '192.168.100.13',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            
            // Port input
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '5000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Connection status
            if (_connectionStatus != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  _connectionStatus!,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isConnecting ? null : _discoverServers,
                    icon: const Icon(Icons.search, size: 18, color: AppColors.primary,),
                    label: const Text('Auto', style: TextStyle(color: AppColors.primary),),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isConnecting ? null : _testConnection,
                    icon: _isConnecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi, size: 18, color: AppColors.primary,),
                    label: Text(_isConnecting ? 'Connecting...' : 'Connect', style: TextStyle(color: AppColors.primary),),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Setup Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Run server: python server.py\n'
                    '2. Note the IP address shown\n'
                    '3. Enter the IP and port here\n'
                    '4. Test connection',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: AppColors.primary),),
        ),
      ],
    );
  }
}

// Connection status widget for main screen
class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final String serverUrl;
  final VoidCallback? onSettings;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
    required this.serverUrl,
    this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected 
              ? Colors.green.withOpacity(0.3) 
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? '' : '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
          if (onSettings != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onSettings,
              child: Icon(
                Icons.settings,
                size: 14,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Examples dialog
class ExamplesDialog extends StatelessWidget {
  final List<CodeExample> examples;
  final Function(CodeExample) onExampleSelected;

  const ExamplesDialog({
    Key? key,
    required this.examples,
    required this.onExampleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categorizedExamples = <String, List<CodeExample>>{};
    
    for (final example in examples) {
      categorizedExamples.putIfAbsent(example.category, () => []).add(example);
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Example Programs'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: categorizedExamples.isEmpty
            ? const Center(child: Text('No examples available'))
            : ListView(
                children: categorizedExamples.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((example) {
                      return ListTile(
                        title: Text(example.filename),
                        subtitle: Text(example.description),
                        trailing: const Icon(Icons.code),
                        onTap: () {
                          Navigator.of(context).pop();
                          onExampleSelected(example);
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: AppColors.primary),),
        ),
      ],
    );
  }
}