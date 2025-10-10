// bloc/compiler_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/compiler_api_service.dart';
import '../../services/custom_language_service.dart';
import '../../services/custom_language_parser.dart';

part 'compiler_event.dart';
part 'compiler_state.dart';

class CompilerBloc extends Bloc<CompilerEvent, CompilerState> {
  late CompilerApiService _apiService;
  
  CompilerBloc() : super(CompilerInitial()) {
    _apiService = CompilerApiService();
    
    on<CompileCode>(_onCompileCode);
    on<TestConnection>(_onTestConnection);
    on<UpdateServerConfig>(_onUpdateServerConfig);
    on<LoadExample>(_onLoadExample);
    on<FetchExamples>(_onFetchExamples);
    on<SaveCode>(_onSaveCode);
    on<LoadCode>(_onLoadCode);
    on<ClearCode>(_onClearCode);
    on<ChangeTab>(_onChangeTab);
    
    // Auto-test connection on startup
    add(TestConnection());
  }

  void _onCompileCode(CompileCode event, Emitter<CompilerState> emit) async {
    emit(Compiling(
      isServerConnected: state.isServerConnected,
      serverUrl: state.serverUrl,
    ));
    
    try {
      String codeToCompile = event.code;
      
      // Check if there's an active custom language
      await CustomLanguageService.instance.initialize();
      final activeLanguage = CustomLanguageService.instance.activeLanguage;
      
      if (activeLanguage != null) {
        // Parse custom language code to C++
        try {
          final parser = CustomLanguageParser(activeLanguage);
          codeToCompile = parser.parseToCpp(event.code);
        } catch (e) {
          String errorMessage = e.toString();
          
          // Clean up the error message for better user experience
          if (errorMessage.contains('CustomLanguageParserException:')) {
            errorMessage = errorMessage.replaceFirst('CustomLanguageParserException: ', '');
          }
          if (errorMessage.contains('Failed to parse custom language:')) {
            errorMessage = errorMessage.replaceFirst('Failed to parse custom language: ', '');
          }
          
          emit(CompilationError(
            error: '🚫 Custom Language Error:\n\n$errorMessage\n\n💡 Tip: You can switch to "Standard C++" mode from the Language Manager if you want to write regular C++ code.',
            isServerConnected: state.isServerConnected,
            serverUrl: state.serverUrl,
          ));
          return;
        }
      }
      
      final result = await _apiService.compileCode(
        code: codeToCompile,
        filename: event.filename,
        showGeneratedCode: event.showGeneratedCode,
        verbose: event.verbose,
      );
      
      if (result.success) {
        emit(CompilationSuccess(
          output: result.formattedOutput,
          result: result,
          isServerConnected: state.isServerConnected,
          serverUrl: state.serverUrl,
        ));
      } else {
        emit(CompilationError(
          error: result.formattedOutput,
          result: result,
          isServerConnected: state.isServerConnected,
          serverUrl: state.serverUrl,
        ));
      }
    } catch (e) {
      emit(CompilationError(
        error: 'Network error: ${e.toString()}',
        isServerConnected: false,
        serverUrl: state.serverUrl,
      ));
    }
  }

  void _onTestConnection(TestConnection event, Emitter<CompilerState> emit) async {
    emit(ServerConnecting(
      serverUrl: state.serverUrl,
    ));
    
    try {
      if (event.host != null && event.port != null) {
        _apiService.updateServerUrl(host: event.host!, port: event.port!);
      }
      
      final result = await _apiService.testConnection();
      
      if (result.isConnected) {
        emit(ServerConnected(
          message: result.message,
          serverInfo: result.serverInfo,
          serverUrl: _apiService.serverUrl,
        ));
        
        // Automatically fetch examples after successful connection
        add(FetchExamples());
      } else {
        emit(ServerConnectionError(
          error: result.message,
          serverUrl: _apiService.serverUrl,
        ));
      }
    } catch (e) {
      emit(ServerConnectionError(
        error: 'Connection failed: ${e.toString()}',
        serverUrl: state.serverUrl,
      ));
    }
  }

  void _onUpdateServerConfig(UpdateServerConfig event, Emitter<CompilerState> emit) {
    _apiService.updateServerUrl(host: event.host, port: event.port);
    add(TestConnection(host: event.host, port: event.port));
  }

  void _onLoadExample(LoadExample event, Emitter<CompilerState> emit) {
    emit(CompilerInitial(
      initialCode: event.exampleCode,
      isServerConnected: state.isServerConnected,
      serverUrl: state.serverUrl,
    ));
  }

  void _onFetchExamples(FetchExamples event, Emitter<CompilerState> emit) async {
    try {
      final result = await _apiService.getExamples();
      
      if (result.success) {
        emit(ExamplesLoaded(
          examples: result.examples,
          isServerConnected: state.isServerConnected,
          serverUrl: state.serverUrl,
        ));
      } else {
        emit(ExamplesError(
          error: result.error ?? 'Failed to fetch examples',
          isServerConnected: state.isServerConnected,
          serverUrl: state.serverUrl,
        ));
      }
    } catch (e) {
      emit(ExamplesError(
        error: 'Failed to fetch examples: ${e.toString()}',
        isServerConnected: state.isServerConnected,
        serverUrl: state.serverUrl,
      ));
    }
  }

  void _onSaveCode(SaveCode event, Emitter<CompilerState> emit) {
    // Save code logic would go here
    // Could save to local storage or send to server
  }

  void _onLoadCode(LoadCode event, Emitter<CompilerState> emit) {
    // Load code logic would go here
    // Could load from local storage or server
  }

  void _onClearCode(ClearCode event, Emitter<CompilerState> emit) {
    emit(CompilerInitial(
      isServerConnected: state.isServerConnected,
      serverUrl: state.serverUrl,
    ));
  }

  void _onChangeTab(ChangeTab event, Emitter<CompilerState> emit) {
    final currentState = state;
    
    if (currentState is CompilerInitial) {
      emit(CompilerInitial(
        initialCode: currentState.initialCode,
        availableExamples: currentState.availableExamples,
        activeTab: event.tabIndex,
        isServerConnected: currentState.isServerConnected,
        serverUrl: currentState.serverUrl,
      ));
    } else if (currentState is CompilationSuccess) {
      emit(CompilationSuccess(
        output: currentState.output,
        result: currentState.result,
        activeTab: event.tabIndex,
        isServerConnected: currentState.isServerConnected,
        serverUrl: currentState.serverUrl,
      ));
    } else if (currentState is CompilationError) {
      emit(CompilationError(
        error: currentState.error,
        result: currentState.result,
        activeTab: event.tabIndex,
        isServerConnected: currentState.isServerConnected,
        serverUrl: currentState.serverUrl,
      ));
    }
  }
  
  @override
  Future<void> close() {
    _apiService.dispose();
    return super.close();
  }
}