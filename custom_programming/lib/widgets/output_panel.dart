// widgets/output_panel.dart


import 'package:custom_programming/bloc/compiler_bloc/compiler_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../services/compiler_api_service.dart';

class OutputPanelWidget extends StatefulWidget {
  const OutputPanelWidget({super.key});

  @override
  State<OutputPanelWidget> createState() => _OutputPanelWidgetState();
}

class _OutputPanelWidgetState extends State<OutputPanelWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompilerBloc, CompilerState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Output Header with tabs
              _buildOutputHeader(state),
              // Output Content
              Expanded(
                child: _buildOutputTabs(state),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOutputHeader(CompilerState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _getOutputIcon(state),
                  color: _getOutputIconColor(state),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getOutputTitle(state),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (state is Compiling) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
                if (state is CompilationSuccess || state is CompilationError) ...[
                  IconButton(
                    icon: const Icon(Icons.content_copy, color: Colors.white, size: 18),
                    onPressed: () => _copyOutput(state),
                    tooltip: 'Copy Output',
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white, size: 18),
                    onPressed: () => _shareOutput(state),
                    tooltip: 'Share Output',
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                  //   onPressed: () => _clearOutput(),
                  //   tooltip: 'Clear Output',
                  // ),
                ],
              ],
            ),
          ),
          // Tab bar (only show when there's output)
          if (state is CompilationSuccess || state is CompilationError)
            TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: _getOutputIconColor(state),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(
                  icon: Icon(Icons.output, size: 16),
                  text: 'Output',
                ),
                Tab(
                  icon: Icon(Icons.info_outline, size: 16),
                  text: 'Details',
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildOutputTabs(CompilerState state) {
    if (state is CompilerInitial) {
      return _buildEmptyState();
    } else if (state is Compiling) {
      return _buildCompilingState();
    } else if (state is ServerConnecting) {
      return _buildConnectingState();
    } else if (state is ServerConnectionError) {
      return _buildConnectionErrorState(state);
    } else if (state is CompilationSuccess || state is CompilationError) {
      return TabBarView(
        controller: _tabController,
        children: [
          _buildOutputTab(state),
          _buildDetailsTab(state),
        ],
      );
    }
    return _buildEmptyState();
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow, color: Colors.grey, size: 64),
          SizedBox(height: 16),
          Text(
            'Ready to Compile',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Write your C++ code and tap the play button\\nto compile and run your program',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompilingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Compiling & Executing...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while your C++ code is being processed',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Connecting to Server...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Establishing connection with the compiler server',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionErrorState(ServerConnectionError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.red, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Connection Failed',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.error,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CompilerBloc>().add(TestConnection());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOutputTab(CompilerState state) {
    String output = '';
    Color textColor = Colors.white;
    
    if (state is CompilationSuccess) {
      output = state.output;
      textColor = const Color(0xFF4EC9B0);
    } else if (state is CompilationError) {
      output = state.error;
      textColor = const Color(0xFFF44747);
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: output.isEmpty
          ? const Center(
              child: Text(
                'No output available',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SelectableText(
                  output,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'RobotoMono',
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildDetailsTab(CompilerState state) {
    CompilationResult? result;
    
    if (state is CompilationSuccess) {
      result = state.result;
    } else if (state is CompilationError) {
      result = state.result;
    }
    
    if (result == null) {
      return const Center(
        child: Text(
          'No details available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compilation Status
            _buildDetailCard(
              'Compilation Status',
              Icons.check_circle,
              result.success ? Colors.green : Colors.red,
              result.success ? 'SUCCESS' : 'FAILED',
            ),
            
            const SizedBox(height: 12),
            
            // Compilation Phases
            if (result.compilationPhases.isNotEmpty) ...[
              _buildDetailCard(
                'Compilation Phases',
                Icons.timeline,
                Colors.blue,
                result.compilationPhases.join(' → '),
              ),
              const SizedBox(height: 12),
            ],
            
            // Server Info
            if (result.serverInfo != null) ...[
              _buildDetailCard(
                'Server Info',
                Icons.storage,
                Colors.purple,
                'Timestamp: ${DateTime.fromMillisecondsSinceEpoch((result.serverInfo!['timestamp'] * 1000).round()).toString()}',
              ),
              const SizedBox(height: 12),
            ],
            
            // Error Details (if any)
            if (result.details.isNotEmpty) ...[
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Error Details',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...result.details.map((detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $detail',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
            
            // Generated Code (if available)
            if (result.generatedCode != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.code, color: Colors.blue, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Generated Code',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SelectableText(
                          result.generatedCode!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailCard(String title, IconData icon, Color color, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getOutputIcon(CompilerState state) {
    if (state is Compiling) return Icons.hourglass_empty;
    if (state is CompilationSuccess) return Icons.check_circle;
    if (state is CompilationError) return Icons.error;
    if (state is ServerConnecting) return Icons.wifi;
    if (state is ServerConnectionError) return Icons.wifi_off;
    return Icons.terminal;
  }
  
  Color _getOutputIconColor(CompilerState state) {
    if (state is Compiling) return Colors.orange;
    if (state is CompilationSuccess) return Colors.green;
    if (state is CompilationError) return Colors.red;
    if (state is ServerConnecting) return Colors.blue;
    if (state is ServerConnectionError) return Colors.red;
    return Colors.grey;
  }
  
  String _getOutputTitle(CompilerState state) {
    if (state is Compiling) return 'Compiling...';
    if (state is CompilationSuccess) return 'Compilation Successful';
    if (state is CompilationError) return 'Compilation Failed';
    if (state is ServerConnecting) return 'Connecting...';
    if (state is ServerConnectionError) return 'Connection Failed';
    return 'Output';
  }
  
  Future<void> _copyOutput(CompilerState state) async {
    String output = '';
    
    if (state is CompilationSuccess) {
      output = state.output;
    } else if (state is CompilationError) {
      output = state.error;
    }
    
    if (output.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: output));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Output copied to clipboard'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  Future<void> _shareOutput(CompilerState state) async {
    String output = '';
    String title = 'C++ Compilation Output';
    
    if (state is CompilationSuccess) {
      output = state.output;
      title = 'C++ Program Output';
    } else if (state is CompilationError) {
      output = state.error;
      title = 'C++ Compilation Error';
    }
    
    if (output.isNotEmpty) {
      try {
        await Share.share(output, subject: title);
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
  }
  
  void _clearOutput() {
    context.read<CompilerBloc>().add(ClearCode());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Output cleared'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }
}