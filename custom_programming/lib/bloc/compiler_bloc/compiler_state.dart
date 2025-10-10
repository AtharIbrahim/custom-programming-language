// bloc/compiler_state.dart
part of 'compiler_bloc.dart';

abstract class CompilerState {
  final int activeTab;
  final bool isServerConnected;
  final String serverUrl;
  
  const CompilerState({
    this.activeTab = 0,
    this.isServerConnected = false,
    this.serverUrl = 'http://192.168.100.13:5000',
  });
}

class CompilerInitial extends CompilerState {
  final String initialCode;
  final List<CodeExample> availableExamples;
  
  CompilerInitial({
    this.initialCode = '''
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, World!" << endl;
    return 0;
}
''',
    this.availableExamples = const [],
    super.activeTab = 0,
    super.isServerConnected = false,
    super.serverUrl = 'http://192.168.100.13:5000',
  });
}

class ServerConnecting extends CompilerState {
  const ServerConnecting({
    super.activeTab = 0,
    super.isServerConnected = false,
    super.serverUrl,
  });
}

class ServerConnected extends CompilerState {
  final String message;
  final Map<String, dynamic>? serverInfo;
  
  const ServerConnected({
    required this.message,
    this.serverInfo,
    super.activeTab = 0,
    super.isServerConnected = true,
    super.serverUrl,
  });
}

class ServerConnectionError extends CompilerState {
  final String error;
  
  const ServerConnectionError({
    required this.error,
    super.activeTab = 0,
    super.isServerConnected = false,
    super.serverUrl,
  });
}

class Compiling extends CompilerState {
  const Compiling({
    super.activeTab = 0,
    super.isServerConnected,
    super.serverUrl,
  });
}

class CompilationSuccess extends CompilerState {
  final String output;
  final CompilationResult result;
  
  const CompilationSuccess({
    required this.output,
    required this.result,
    super.activeTab = 1,
    super.isServerConnected,
    super.serverUrl,
  });
}

class CompilationError extends CompilerState {
  final String error;
  final CompilationResult? result;
  
  const CompilationError({
    required this.error,
    this.result,
    super.activeTab = 1,
    super.isServerConnected,
    super.serverUrl,
  });
}

class ExamplesLoaded extends CompilerState {
  final List<CodeExample> examples;
  
  const ExamplesLoaded({
    required this.examples,
    super.activeTab = 0,
    super.isServerConnected,
    super.serverUrl,
  });
}

class ExamplesError extends CompilerState {
  final String error;
  
  const ExamplesError({
    required this.error,
    super.activeTab = 0,
    super.isServerConnected,
    super.serverUrl,
  });
}