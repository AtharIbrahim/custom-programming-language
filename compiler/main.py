"""
C++ Compiler implemented in Python
A complete C++ compiler that can compile and execute C++ programs.

Usage:
    python main.py <source_file>    # Compile file
    python main.py                  # Interactive mode  
    python main.py --api           # Start Flask web API
"""

import sys
import os
import json
import traceback
from pathlib import Path
from io import StringIO
from contextlib import redirect_stdout, redirect_stderr

# Web framework imports
from flask import Flask, request, jsonify
from flask_cors import CORS

# Import compiler modules
from lexer import Lexer, TokenType
from parser import Parser
from semantic_analyzer import SemanticAnalyzer
from code_generator import CodeGenerator

class CppCompiler:
    """Main C++ Compiler class"""
    
    def __init__(self):
        self.verbose = False
        self.output_file = None
        self.show_tokens = False
        self.show_ast = False
        self.show_generated_code = False
    
    def compile_file(self, source_file: str) -> bool:
        """Compile a C++ source file"""
        try:
            # Read source code
            with open(source_file, 'r', encoding='utf-8') as f:
                source_code = f.read()
            
            return self.compile_source(source_code, source_file)
            
        except FileNotFoundError:
            print(f"Error: File '{source_file}' not found.")
            return False
        except Exception as e:
            print(f"Error reading file '{source_file}': {e}")
            return False
    
    def compile_source(self, source_code: str, filename: str = "<input>") -> bool:
        """Compile C++ source code"""
        try:
            print(f"Compiling {filename}...")
            
            # Phase 1: Lexical Analysis
            if self.verbose:
                print("Phase 1: Lexical Analysis...")
            
            lexer = Lexer(source_code)
            tokens = lexer.tokenize()
            
            if self.show_tokens:
                self.print_tokens(tokens)
            
            # Phase 2: Syntax Analysis (Parsing)
            if self.verbose:
                print("Phase 2: Syntax Analysis...")
            
            parser = Parser(tokens)
            ast = parser.parse()
            
            if self.show_ast:
                self.print_ast(ast)
            
            # Phase 3: Semantic Analysis
            if self.verbose:
                print("Phase 3: Semantic Analysis...")
            
            analyzer = SemanticAnalyzer()
            if not analyzer.analyze(ast):
                print("Compilation failed with semantic errors:")
                for error in analyzer.errors:
                    print(f"  {error}")
                return False
            
            if self.verbose:
                print("Semantic analysis passed!")
            
            # Phase 4: Code Generation
            if self.verbose:
                print("Phase 4: Code Generation...")
            
            generator = CodeGenerator(analyzer)
            generated_code = generator.generate(ast)
            
            if self.show_generated_code:
                print("\nGenerated Code:")
                print("=" * 50)
                print(generated_code)
                print("=" * 50)
            
            # Phase 5: Execution
            if self.verbose:
                print("Phase 5: Execution...")
            
            print(f"\nExecuting {filename}:")
            print("-" * 30)
            
            # Execute the generated code
            try:
                # Create isolated namespace for execution
                exec_globals = {
                    '__name__': '__main__',
                    '__builtins__': __builtins__,
                }
                exec(generated_code, exec_globals)
            except SystemExit:
                # This is expected behavior - the program calls sys.exit()
                pass
            
            return True
            
        except SyntaxError as e:
            print(f"Syntax Error: {e}")
            return False
        except Exception as e:
            print(f"Compilation Error: {e}")
            return False
    
    def print_tokens(self, tokens):
        """Print the list of tokens"""
        print("\nTokens:")
        print("-" * 30)
        for token in tokens:
            if token.type not in [TokenType.WHITESPACE, TokenType.NEWLINE]:
                print(f"{token.type.name:20} : {repr(token.value):20} at ({token.line}, {token.column})")
        print()
    
    def print_ast(self, ast):
        """Print the Abstract Syntax Tree"""
        print("\nAbstract Syntax Tree:")
        print("-" * 30)
        print(ast)
        print()
    
    def interactive_mode(self):
        """Run the compiler in interactive mode"""
        print("C++ Compiler - Interactive Mode")
        print("Enter C++ code (type 'EXIT' to quit, 'HELP' for commands):")
        print("-" * 50)
        
        buffer = []
        
        while True:
            try:
                if not buffer:
                    line = input("cpp> ")
                else:
                    line = input("...> ")
                
                if line.strip().upper() == 'EXIT':
                    break
                elif line.strip().upper() == 'HELP':
                    self.show_help()
                    continue
                elif line.strip().upper() == 'CLEAR':
                    buffer.clear()
                    print("Buffer cleared.")
                    continue
                elif line.strip().upper() == 'TOKENS':
                    self.show_tokens = not self.show_tokens
                    print(f"Token display: {'ON' if self.show_tokens else 'OFF'}")
                    continue
                elif line.strip().upper() == 'AST':
                    self.show_ast = not self.show_ast
                    print(f"AST display: {'ON' if self.show_ast else 'OFF'}")
                    continue
                elif line.strip().upper() == 'CODE':
                    self.show_generated_code = not self.show_generated_code
                    print(f"Generated code display: {'ON' if self.show_generated_code else 'OFF'}")
                    continue
                elif line.strip().upper() == 'VERBOSE':
                    self.verbose = not self.verbose
                    print(f"Verbose mode: {'ON' if self.verbose else 'OFF'}")
                    continue
                elif line.strip().upper() == 'RUN':
                    if buffer:
                        source_code = '\n'.join(buffer)
                        print("\nCompiling and running...")
                        self.compile_source(source_code, "<interactive>")
                        buffer.clear()
                    else:
                        print("Buffer is empty. Enter some C++ code first.")
                    continue
                
                buffer.append(line)
                
                # Try to compile when we have a complete program
                source_code = '\n'.join(buffer)
                if self.is_complete_program(source_code):
                    print("\nCompiling and running...")
                    if self.compile_source(source_code, "<interactive>"):
                        buffer.clear()
                    else:
                        print("Keep the code in buffer. Type 'CLEAR' to clear or continue editing.")
                
            except KeyboardInterrupt:
                print("\nUse 'EXIT' to quit.")
            except EOFError:
                print("\nGoodbye!")
                break
    
    def is_complete_program(self, source_code: str) -> bool:
        """Check if the source code looks like a complete program"""
        # Simple heuristic: check for main function and balanced braces
        has_main = 'int main()' in source_code or 'int main(' in source_code
        open_braces = source_code.count('{')
        close_braces = source_code.count('}')
        return has_main and open_braces > 0 and open_braces == close_braces
    
    def show_help(self):
        """Show help information"""
        print("\nCommands:")
        print("  EXIT     - Exit the compiler")
        print("  HELP     - Show this help")
        print("  CLEAR    - Clear the input buffer")
        print("  RUN      - Compile and run current buffer")
        print("  TOKENS   - Toggle token display")
        print("  AST      - Toggle AST display")
        print("  CODE     - Toggle generated code display")
        print("  VERBOSE  - Toggle verbose mode")
        print("\nEnter C++ code and it will be compiled automatically when complete.")
        print()
    
    def compile_source_api(self, source_code: str, filename: str = "<api_input>") -> dict:
        """Compile C++ source code and return result as dictionary for API"""
        try:
            # Capture all output
            stdout_buffer = StringIO()
            stderr_buffer = StringIO()
            
            with redirect_stdout(stdout_buffer), redirect_stderr(stderr_buffer):
                # Phase 1: Lexical Analysis
                lexer = Lexer(source_code)
                tokens = lexer.tokenize()
                
                # Phase 2: Syntax Analysis (Parsing)
                parser = Parser(tokens)
                ast = parser.parse()
                
                # Phase 3: Semantic Analysis
                analyzer = SemanticAnalyzer()
                if not analyzer.analyze(ast):
                    return {
                        "success": False,
                        "error": "Semantic Analysis Failed",
                        "details": analyzer.errors,
                        "output": "",
                        "execution_output": ""
                    }
                
                # Phase 4: Code Generation
                generator = CodeGenerator(analyzer)
                generated_code = generator.generate(ast)
                
                # Phase 5: Execution
                execution_output = StringIO()
                try:
                    with redirect_stdout(execution_output):
                        # Create isolated namespace for execution
                        exec_globals = {
                            '__name__': '__main__',
                            '__builtins__': __builtins__,
                        }
                        exec(generated_code, exec_globals)
                except SystemExit:
                    # This is expected behavior - the program calls sys.exit()
                    pass
                except Exception as exec_error:
                    return {
                        "success": False,
                        "error": f"Runtime Error: {str(exec_error)}",
                        "details": [str(exec_error)],
                        "output": stdout_buffer.getvalue(),
                        "execution_output": execution_output.getvalue()
                    }
            
            return {
                "success": True,
                "error": None,
                "details": [],
                "output": stdout_buffer.getvalue(),
                "execution_output": execution_output.getvalue(),
                "generated_code": generated_code if self.show_generated_code else None
            }
            
        except SyntaxError as e:
            return {
                "success": False,
                "error": f"Syntax Error: {str(e)}",
                "details": [str(e)],
                "output": "",
                "execution_output": ""
            }
        except Exception as e:
            return {
                "success": False,
                "error": f"Compilation Error: {str(e)}",
                "details": [str(e), traceback.format_exc()],
                "output": "",
                "execution_output": ""
            }

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Global compiler instance
compiler = CppCompiler()

@app.route('/', methods=['GET'])
def home():
    """Root endpoint"""
    return jsonify({
        "message": "C++ Compiler API",
        "version": "1.0.0",
        "endpoints": {
            "/compile": "POST - Compile C++ code",
            "/health": "GET - Health check"
        }
    })

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "message": "Compiler API is running"})

@app.route('/compile', methods=['POST'])
def compile_code():
    """Compile C++ code endpoint"""
    try:
        # Get JSON data
        data = request.get_json()
        
        if not data:
            return jsonify({
                "success": False,
                "error": "No JSON data provided",
                "details": ["Request must contain JSON data"]
            }), 400
        
        # Extract source code
        source_code = data.get('code', '').strip()
        
        if not source_code:
            return jsonify({
                "success": False,
                "error": "No source code provided",
                "details": ["The 'code' field is required and cannot be empty"]
            }), 400
        
        # Optional parameters
        filename = data.get('filename', 'input.cpp')
        show_generated_code = data.get('show_generated_code', False)
        verbose = data.get('verbose', False)
        
        # Set compiler options
        compiler.show_generated_code = show_generated_code
        compiler.verbose = verbose
        
        # Compile the code
        result = compiler.compile_source_api(source_code, filename)
        
        # Return appropriate HTTP status
        status_code = 200 if result['success'] else 400
        
        return jsonify(result), status_code
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Server Error: {str(e)}",
            "details": [traceback.format_exc()],
            "output": "",
            "execution_output": ""
        }), 500

@app.route('/examples', methods=['GET'])
def get_examples():
    """Get example C++ programs"""
    examples = []
    examples_dir = Path('./examples')
    
    if examples_dir.exists():
        for example_file in examples_dir.glob('*.cpp'):
            try:
                with open(example_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                examples.append({
                    "filename": example_file.name,
                    "code": content,
                    "description": f"Example: {example_file.stem}"
                })
            except Exception as e:
                continue
    
    return jsonify({
        "success": True,
        "examples": examples,
        "count": len(examples)
    })

def start_api_server(host='0.0.0.0', port=5000, debug=False):
    """Start the Flask API server"""
    print(f"Starting C++ Compiler API server on {host}:{port}")
    print(f"API Documentation: http://{host}:{port}/")
    print("Press Ctrl+C to stop the server")
    
    try:
        app.run(host=host, port=port, debug=debug)
    except KeyboardInterrupt:
        print("\nServer stopped by user")
    except Exception as e:
        print(f"Server error: {e}")

def main():
    """Main entry point"""
    # Check for API mode
    if len(sys.argv) >= 2 and sys.argv[1] in ['--api', '-api', 'api']:
        # Start Flask API server
        host = '0.0.0.0'
        port = int(os.environ.get('PORT', 5000))  # Use environment PORT or default to 5000
        debug = '--debug' in sys.argv
        start_api_server(host=host, port=port, debug=debug)
        return
    
    # Original CLI functionality
    compiler = CppCompiler()
    
    if len(sys.argv) == 1:
        # Interactive mode
        compiler.interactive_mode()
    elif len(sys.argv) == 2:
        # Check if it's an API command
        if sys.argv[1] in ['--help', '-h', 'help']:
            print("Usage:")
            print(f"  {sys.argv[0]}                    # Interactive mode")
            print(f"  {sys.argv[0]} <source_file>      # Compile and run a C++ file")
            print(f"  {sys.argv[0]} --api              # Start Flask API server")
            print(f"  {sys.argv[0]} --api --debug      # Start Flask API server with debug mode")
            print(f"  {sys.argv[0]} --help             # Show this help")
            return
        
        # Compile file
        source_file = sys.argv[1]
        
        # Add .cpp extension if not present
        if not source_file.endswith('.cpp') and not source_file.endswith('.c'):
            if os.path.exists(source_file + '.cpp'):
                source_file += '.cpp'
            elif os.path.exists(source_file + '.c'):
                source_file += '.c'
        
        if compiler.compile_file(source_file):
            print(f"\nCompilation of '{source_file}' completed successfully!")
        else:
            print(f"\nCompilation of '{source_file}' failed!")
            sys.exit(1)
    else:
        print("Usage:")
        print(f"  {sys.argv[0]}                    # Interactive mode")
        print(f"  {sys.argv[0]} <source_file>      # Compile and run a C++ file")
        print(f"  {sys.argv[0]} --api              # Start Flask API server")
        print(f"  {sys.argv[0]} --help             # Show help")
        sys.exit(1)

if __name__ == "__main__":
    main()