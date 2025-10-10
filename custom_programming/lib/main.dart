// main.dart
import 'package:custom_programming/bloc/compiler_bloc/compiler_bloc.dart';
import 'package:custom_programming/screens/comiler_screen.dart';
import 'package:custom_programming/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  try {
    await LocalStorageService.instance.initialize();
    debugPrint('✅ Local storage initialized');
  } catch (e) {
    debugPrint('❌ Failed to initialize local storage: $e');
  }
  
  runApp(const CppCompilerApp());
}

class CppCompilerApp extends StatelessWidget {
  const CppCompilerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompilerBloc(),
      child: MaterialApp(
        title: 'Compiler',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'RobotoMono',
        ),
        home: const CompilerScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
