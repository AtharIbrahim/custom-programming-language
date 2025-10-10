"""
Production C++ Compiler
A simple wrapper for the C++ compiler components for production use
"""

import sys
import os
import tempfile
import subprocess
from pathlib import Path
from typing import Tuple, Optional

# Import existing compiler modules
from lexer import Lexer
from parser import Parser
from semantic_analyzer import SemanticAnalyzer
from code_generator import CodeGenerator

class ProductionCppCompiler:
    """Production C++ Compiler wrapper"""
    
    def __init__(self):
        self.cpp_standard = "c++17"
        self.optimization = "-O2"
        self.flags = ["-Wall", "-Wextra"]
        self.gpp_path = self.find_gpp()
    
    def find_gpp(self) -> str:
        """Find g++ compiler path"""
        # Try common paths for g++
        paths = ["g++", "c++", "/usr/bin/g++", "/usr/local/bin/g++"]
        
        for path in paths:
            try:
                result = subprocess.run([path, "--version"], 
                                      capture_output=True, text=True, timeout=5)
                if result.returncode == 0:
                    return path
            except:
                continue
        
        # If no g++ found, we'll simulate compilation
        return "g++"
    
    def set_cpp_standard(self, standard: str):
        """Set C++ standard"""
        self.cpp_standard = standard
    
    def set_optimization(self, optimization: str):
        """Set optimization level"""
        self.optimization = optimization
    
    def add_compiler_flag(self, flag: str):
        """Add compiler flag"""
        if flag not in self.flags:
            self.flags.append(flag)
    
    def compile_source_string(self, source_code: str, filename: str = "main.cpp", 
                            run_after_compile: bool = True) -> Tuple[bool, str, str]:
        """
        Compile C++ source code string
        
        Returns:
            Tuple of (success, output, error)
        """
        try:
            # Use our custom compiler pipeline
            return self._compile_with_custom_compiler(source_code, filename, run_after_compile)
            
        except Exception as e:
            return False, "", f"Compilation error: {str(e)}"
    
    def _compile_with_custom_compiler(self, source_code: str, filename: str, 
                                    run_after_compile: bool) -> Tuple[bool, str, str]:
        """Compile using our custom compiler pipeline"""
        try:
            # Phase 1: Lexical Analysis
            lexer = Lexer(source_code)
            tokens = lexer.tokenize()
            
            # Phase 2: Syntax Analysis
            parser = Parser(tokens)
            ast = parser.parse()
            
            # Phase 3: Semantic Analysis
            analyzer = SemanticAnalyzer()
            if not analyzer.analyze(ast):
                error_msg = "Semantic errors:\n" + "\n".join(analyzer.errors)
                return False, "", error_msg
            
            # Phase 4: Code Generation
            generator = CodeGenerator(analyzer)
            generated_code = generator.generate(ast)
            
            # Phase 5: Execution (if requested)
            output = ""
            if run_after_compile:
                # Capture output by redirecting stdout
                import io
                from contextlib import redirect_stdout, redirect_stderr
                
                stdout_capture = io.StringIO()
                stderr_capture = io.StringIO()
                
                try:
                    with redirect_stdout(stdout_capture), redirect_stderr(stderr_capture):
                        exec_globals = {
                            '__name__': '__main__',
                            '__builtins__': __builtins__,
                        }
                        exec(generated_code, exec_globals)
                except SystemExit:
                    # This is expected - programs call sys.exit()
                    pass
                except Exception as e:
                    return False, "", f"Runtime error: {str(e)}"
                
                output = stdout_capture.getvalue()
                stderr_output = stderr_capture.getvalue()
                
                if stderr_output:
                    output += f"\nStderr: {stderr_output}"
            
            return True, output, ""
            
        except Exception as e:
            return False, "", f"Compilation failed: {str(e)}"
    
    def _compile_with_real_gpp(self, source_code: str, filename: str, 
                             run_after_compile: bool) -> Tuple[bool, str, str]:
        """Fallback: compile with real g++ if available"""
        try:
            # Create temporary files
            with tempfile.TemporaryDirectory() as temp_dir:
                source_file = Path(temp_dir) / filename
                exe_file = Path(temp_dir) / "program"
                
                # Write source code to file
                source_file.write_text(source_code, encoding='utf-8')
                
                # Build compile command
                cmd = [
                    self.gpp_path,
                    f"-std={self.cpp_standard}",
                    self.optimization,
                    *self.flags,
                    str(source_file),
                    "-o", str(exe_file)
                ]
                
                # Compile
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
                
                if result.returncode != 0:
                    return False, "", result.stderr
                
                # Run if requested
                output = ""
                if run_after_compile and exe_file.exists():
                    run_result = subprocess.run([str(exe_file)], 
                                              capture_output=True, text=True, timeout=10)
                    output = run_result.stdout
                    if run_result.stderr:
                        output += f"\nStderr: {run_result.stderr}"
                
                return True, output, ""
                
        except subprocess.TimeoutExpired:
            return False, "", "Compilation or execution timed out"
        except Exception as e:
            return False, "", f"Error: {str(e)}"