// screens/compiler_screen.dart
import 'package:custom_programming/bloc/compiler_bloc/compiler_bloc.dart';
import 'package:custom_programming/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/code_editor.dart';
import '../widgets/output_panel.dart';
import '../widgets/compiler_options.dart';
import '../widgets/server_settings_dialog.dart';
import '../widgets/file_manager_dialog.dart';
import '../services/local_storage_service.dart';
import '../services/custom_language_service.dart';
import 'language_designer_screen.dart';
import 'language_manager_screen.dart';


class CompilerScreen extends StatefulWidget {
  const CompilerScreen({super.key});

  @override
  State<CompilerScreen> createState() => _CompilerScreenState();
}

class _CompilerScreenState extends State<CompilerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();
  
  String? _currentFilename;
  bool _hasUnsavedChanges = false;
  int _originalCodeHash = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Listen to code changes
    _codeController.addListener(_onCodeChanged);
    
    // Load saved settings
    _loadEditorSettings();
    
    // Initialize custom language service
    CustomLanguageService.instance.initialize();
  }
  
  void _onCodeChanged() {
    final currentHash = _codeController.text.hashCode;
    setState(() {
      _hasUnsavedChanges = currentHash != _originalCodeHash;
    });
  }
  
  Future<void> _loadEditorSettings() async {
    try {
      final settings = await LocalStorageService.instance.loadEditorSettings();
      // Apply editor settings here if needed
      debugPrint('Loaded editor settings: font size ${settings.fontSize}');
    } catch (e) {
      debugPrint('Error loading editor settings: $e');
    }
  }
  
  void _setCurrentFile(String? filename, String code) {
    setState(() {
      _currentFilename = filename;
      _originalCodeHash = code.hashCode;
      _hasUnsavedChanges = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompilerBloc, CompilerState>(
      listener: (context, state) {
        if (state.activeTab != _tabController.index) {
          _tabController.animateTo(state.activeTab);
        }
        
        // Initialize code editor when app starts
        if (state is CompilerInitial && _codeController.text.isEmpty) {
          _codeController.text = state.initialCode;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Tab Bar
            _buildTabBar(),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Editor Tab
                  CodeEditorWidget(controller: _codeController),
                  // Output Tab
                  const OutputPanelWidget(),
                  // Settings Tab
                  const CompilerOptionsWidget(),
                ],
              ),
            ),
          ],
        ),
        // Floating Action Button for compilation
        floatingActionButton: _buildFAB(context),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          // const Icon(Icons.code, color: Colors.blue),
          // const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text(
                      'Compiler',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (_hasUnsavedChanges) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                Builder(
                  builder: (context) {
                    final activeLanguage = CustomLanguageService.instance.activeLanguage;
                    if (activeLanguage != null) {
                      return Text(
                        '${activeLanguage.name} Language',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    } else if (_currentFilename != null) {
                      return Text(
                        _currentFilename!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const Text(
                      'Standard C++',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 2,
      actions: [
        // Connection status
        BlocBuilder<CompilerBloc, CompilerState>(
          builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: ConnectionStatusWidget(
          isConnected: state.isServerConnected,
          serverUrl: state.serverUrl,
          onSettings: () => _showServerSettings(context),
            ),
          ),
        );
          },
        ),
        IconButton(
          icon: const Icon(Icons.folder_open, color: AppColors.primary),
          onPressed: () => _showLoadDialog(context),
          tooltip: 'Load File',
        ),
        IconButton(
          icon: const Icon(Icons.save, color: AppColors.primary),
          onPressed: () => _showSaveDialog(context),
          tooltip: 'Save File',
        ),
        // IconButton(
        //   icon: const Icon(Icons.language, color: Colors.blue),
        //   onPressed: () => _navigateToLanguageManager(context),
        //   tooltip: 'Custom Languages',
        // ),
        IconButton(
          icon: const Icon(Icons.cloud_download, color: AppColors.primary),
          onPressed: () => _loadExamples(context),
          tooltip: 'Load Examples',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.primary),
          color: Colors.white, // Changed background color
          onSelected: (value) {
        _handleMenuSelection(value, context);
          },
          itemBuilder: (BuildContext context) {
        
        return {'Language Manager', 'Create Language', 'Server Settings', 'Reconnect', 'Export File', 'Share Code', 'Clear Code', 'About'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Row(
          children: [
            Icon(_getMenuIcon(choice), size: 18),
            const SizedBox(width: 8),
            Text(choice),
          ],
            ),
          );
        }).toList();
          },
        ),
      ],
      
    );
  }

  IconData _getMenuIcon(String choice) {
    switch (choice) {
      case 'Language Manager': return Icons.language;
      case 'Create Language': return Icons.add_circle;
      case 'Server Settings': return Icons.settings;
      case 'Reconnect': return Icons.refresh;
      case 'Export File': return Icons.download;
      case 'Share Code': return Icons.share;
      case 'Clear Code': return Icons.clear;
      case 'About': return Icons.info;
      default: return Icons.more_horiz;
    }
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(icon: Icon(Icons.edit), text: 'Editor'),
          Tab(icon: Icon(Icons.terminal), text: 'Output'),
          Tab(icon: Icon(Icons.settings), text: 'Options'),
        ],
        onTap: (index) {
          context.read<CompilerBloc>().add(ChangeTab(index));
        },
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return BlocBuilder<CompilerBloc, CompilerState>(
      builder: (context, state) {
        final canCompile = !(state is Compiling) && state.isServerConnected;
        
        return FloatingActionButton(
          onPressed: canCompile ? () {
            if (_codeController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter some C++ code first'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            context.read<CompilerBloc>().add(CompileCode(
              _codeController.text,
              filename: 'mobile_input.cpp',
              showGeneratedCode: false,
              verbose: false,
            ));
          } : state.isServerConnected ? null : () {
            // Show connection error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Not connected to server. Tap to configure.'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () => _showServerSettings(context),
                ),
              ),
            );
          },
          backgroundColor: state is Compiling 
              ? Colors.grey 
              : state.isServerConnected 
                  ? Colors.green 
                  : Colors.red,
          child: state is Compiling 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  state.isServerConnected ? Icons.play_arrow : Icons.wifi_off,
                  color: Colors.white,
                ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomBarButton(Icons.cleaning_services, 'Clear', () {
            _codeController.clear();
            context.read<CompilerBloc>().add(ClearCode());
          }),
          _buildBottomBarButton(Icons.content_copy, 'Copy', () => _copyToClipboard()),
          _buildBottomBarButton(Icons.share, 'Share', () => _shareCode()),
          _buildBottomBarButton(Icons.help, 'Help', () {
            _showHelpDialog(context);
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBarButton(IconData icon, String label, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  void _showSaveDialog(BuildContext context) async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save empty file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SaveFileDialog(
        code: _codeController.text,
        initialFilename: _currentFilename,
      ),
    );
    
    if (result != null) {
      _setCurrentFile(result, _codeController.text);
    }
  }
  
  void _showLoadDialog(BuildContext context) async {
    final result = await showDialog<CodeFile>(
      context: context,
      builder: (context) => const LoadFileDialog(),
    );
    
    if (result != null) {
      // Check for unsaved changes
      if (_hasUnsavedChanges) {
        final shouldDiscard = await _showUnsavedChangesDialog();
        if (!shouldDiscard) return;
      }
      
      _codeController.text = result.code;
      _setCurrentFile(result.filename, result.code);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Loaded: ${result.filename}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Future<bool> _showUnsavedChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Discard', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }



  void _showHelpDialog(BuildContext context) {
    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.help, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Help & Tips'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'C++ Compiler Mobile App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('• Write your C++ code in the Editor tab'),
              Text('• Tap the play button to compile and run'),
              Text('• View output in the Output tab'),
              Text('• Configure compiler options in Settings'),
              SizedBox(height: 12),
              Text('Supported: C++11, C++14, C++17'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppColors.primary),),
          ),
        ],
      ),
    );
  }

  void _showServerSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ServerSettingsDialog(),
    );
  }

  void _loadExamples(BuildContext context) {
    context.read<CompilerBloc>().add(FetchExamples());
    
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<CompilerBloc, CompilerState>(
        builder: (context, state) {
          if (state is ExamplesLoaded) {
            return ExamplesDialog(
              examples: state.examples,
              onExampleSelected: (example) {
                _codeController.text = example.code;
                context.read<CompilerBloc>().add(LoadExample(
                  example.code,
                  example.filename,
                ));
              },
            );
          } else if (state is ExamplesError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(state.error),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          } else {
            return const AlertDialog(
              title: Text('Loading Examples'),
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No code to copy'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    await Clipboard.setData(ClipboardData(text: _codeController.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Code copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Future<void> _shareCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No code to share'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      await Share.share(
        _codeController.text,
        subject: _currentFilename ?? 'C++ Code',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _exportFile() async {
    if (_codeController.text.isEmpty || _currentFilename == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save the file first before exporting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final filePath = await LocalStorageService.instance.exportCodeFile(_currentFilename!);
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Exported to: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'Language Manager':
        _navigateToLanguageManager(context);
        break;
      case 'Create Language':
        _navigateToLanguageDesigner(context);
        break;
      case 'Server Settings':
        _showServerSettings(context);
        break;
      case 'Reconnect':
        context.read<CompilerBloc>().add(TestConnection());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reconnecting to server...')),
        );
        break;
      case 'Export File':
        _exportFile();
        break;
      case 'Share Code':
        _shareCode();
        break;
      case 'Clear Code':
        if (_hasUnsavedChanges) {
          _showUnsavedChangesDialog().then((shouldClear) {
            if (shouldClear) {
              _codeController.clear();
              _setCurrentFile(null, '');
              context.read<CompilerBloc>().add(ClearCode());
            }
          });
        } else {
          _codeController.clear();
          _setCurrentFile(null, '');
          context.read<CompilerBloc>().add(ClearCode());
        }
        break;
      case 'About':
        _showAboutDialog(context);
        break;
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<CompilerBloc, CompilerState>(
        builder: (context, state) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text('About C++ Compiler'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mobile C++ Compiler App',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('• Version: 2.0.0'),
                const Text('• Network-enabled compilation'),
                const Text('• Built with Flutter & BLoC'),
                const SizedBox(height: 12),
                Text('Server: ${state.serverUrl}'),
                Text('Status: ${state.isServerConnected ? " " : " "}'),
                const SizedBox(height: 12),
                const Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• WiFi-based compilation'),
                const Text('• Real-time code execution'),
                const Text('• Example programs'),
                const Text('• Mobile-optimized interface'),
                const Text('• Custom language designer'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToLanguageManager(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageManagerScreen(),
      ),
    );
  }

  void _navigateToLanguageDesigner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageDesignerScreen(),
      ),
    );
  }
}