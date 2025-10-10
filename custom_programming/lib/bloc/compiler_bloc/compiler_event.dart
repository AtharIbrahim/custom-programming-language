// bloc/compiler_event.dart
part of 'compiler_bloc.dart';

abstract class CompilerEvent {}

class CompileCode extends CompilerEvent {
  final String code;
  final String? filename;
  final bool showGeneratedCode;
  final bool verbose;
  
  CompileCode(
    this.code, {
    this.filename,
    this.showGeneratedCode = false,
    this.verbose = false,
  });
}

class TestConnection extends CompilerEvent {
  final String? host;
  final int? port;
  
  TestConnection({this.host, this.port});
}

class UpdateServerConfig extends CompilerEvent {
  final String host;
  final int port;
  
  UpdateServerConfig(this.host, this.port);
}

class LoadExample extends CompilerEvent {
  final String exampleCode;
  final String filename;
  
  LoadExample(this.exampleCode, this.filename);
}

class FetchExamples extends CompilerEvent {}

class SaveCode extends CompilerEvent {
  final String code;
  final String filename;
  SaveCode(this.code, this.filename);
}

class LoadCode extends CompilerEvent {
  final String filename;
  LoadCode(this.filename);
}

class ClearCode extends CompilerEvent {}

class ChangeTab extends CompilerEvent {
  final int tabIndex;
  ChangeTab(this.tabIndex);
}