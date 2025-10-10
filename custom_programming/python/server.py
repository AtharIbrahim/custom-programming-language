#!/usr/bin/env python3
"""
C++ Compiler API Server
Enhanced Flask server for mobile app integration with WiFi communication
"""

import sys
import os
import json
import traceback
import socket
import threading
import time
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

class CompilerAPIServer:
    """Enhanced C++ Compiler API Server for mobile integration"""
    
    def __init__(self):
        self.app = Flask(__name__)
        CORS(self.app, origins="*")  # Allow all origins for mobile app
        
        self.verbose = False
        self.show_generated_code = False
        self.server_thread = None
        self.shutdown_flag = threading.Event()
        
        # Setup routes
        self._setup_routes()
    
    def _setup_routes(self):
        """Setup Flask routes"""
        
        @self.app.route('/', methods=['GET'])
        def home():
            """Root endpoint with API information"""
            return jsonify({
                "message": "C++ Compiler API Server",
                "version": "2.0.0",
                "status": "running",
                "endpoints": {
                    "/": "GET - API information",
                    "/health": "GET - Health check",
                    "/compile": "POST - Compile C++ code",
                    "/examples": "GET - Get example programs",
                    "/server-info": "GET - Server information",
                    "/shutdown": "POST - Shutdown server (admin only)"
                },
                "usage": {
                    "compile": {
                        "method": "POST",
                        "url": "/compile",
                        "body": {
                            "code": "C++ source code (required)",
                            "filename": "filename.cpp (optional)",
                            "show_generated_code": "boolean (optional)",
                            "verbose": "boolean (optional)"
                        }
                    }
                }
            })

        @self.app.route('/health', methods=['GET'])
        def health():
            """Health check endpoint"""
            return jsonify({
                "status": "healthy", 
                "message": "C++ Compiler API is running",
                "timestamp": time.time(),
                "server": "Flask",
                "compiler": "C++ Compiler v2.0"
            })

        @self.app.route('/compile', methods=['POST', 'OPTIONS'])
        def compile_code():
            """Compile C++ code endpoint"""
            if request.method == 'OPTIONS':
                # Handle preflight CORS requests
                response = jsonify({})
                response.headers.add('Access-Control-Allow-Origin', '*')
                response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
                response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
                return response
            
            try:
                # Get JSON data
                data = request.get_json()
                
                if not data:
                    return jsonify({
                        "success": False,
                        "error": "No JSON data provided",
                        "details": ["Request must contain JSON data with 'code' field"],
                        "output": "",
                        "execution_output": ""
                    }), 400
                
                # Extract source code
                source_code = data.get('code', '').strip()
                
                if not source_code:
                    return jsonify({
                        "success": False,
                        "error": "No source code provided",
                        "details": ["The 'code' field is required and cannot be empty"],
                        "output": "",
                        "execution_output": ""
                    }), 400
                
                # Optional parameters
                filename = data.get('filename', 'mobile_input.cpp')
                show_generated_code = data.get('show_generated_code', False)
                verbose = data.get('verbose', False)
                
                # Compile the code
                result = self._compile_source_api(source_code, filename, show_generated_code, verbose)
                
                # Add server info to response
                result['server_info'] = {
                    'timestamp': time.time(),
                    'filename': filename,
                    'code_length': len(source_code)
                }
                
                # Return appropriate HTTP status
                status_code = 200 if result['success'] else 400
                
                return jsonify(result), status_code
                
            except json.JSONDecodeError as e:
                return jsonify({
                    "success": False,
                    "error": f"Invalid JSON: {str(e)}",
                    "details": ["Request body must be valid JSON"],
                    "output": "",
                    "execution_output": ""
                }), 400
            except Exception as e:
                return jsonify({
                    "success": False,
                    "error": f"Server Error: {str(e)}",
                    "details": [traceback.format_exc()],
                    "output": "",
                    "execution_output": ""
                }), 500

        @self.app.route('/examples', methods=['GET'])
        def get_examples():
            """Get example C++ programs"""
            examples = []
            examples_dir = Path('./examples')
            
            # Add built-in examples if no examples directory
            if not examples_dir.exists() or not any(examples_dir.glob('*.cpp')):
                examples = self._get_builtin_examples()
            else:
                for example_file in examples_dir.glob('*.cpp'):
                    try:
                        with open(example_file, 'r', encoding='utf-8') as f:
                            content = f.read()
                        examples.append({
                            "filename": example_file.name,
                            "code": content,
                            "description": f"Example: {example_file.stem}",
                            "category": "file"
                        })
                    except Exception as e:
                        continue
            
            return jsonify({
                "success": True,
                "examples": examples,
                "count": len(examples)
            })
        
        @self.app.route('/server-info', methods=['GET'])
        def server_info():
            """Get detailed server information"""
            import platform
            return jsonify({
                "server": {
                    "name": "C++ Compiler API Server",
                    "version": "2.0.0",
                    "status": "running",
                    "python_version": platform.python_version(),
                    "platform": platform.platform(),
                    "hostname": socket.gethostname(),
                    "local_ip": self._get_local_ip()
                },
                "compiler": {
                    "name": "Custom C++ Compiler",
                    "phases": ["Lexical Analysis", "Syntax Analysis", "Semantic Analysis", "Code Generation", "Execution"],
                    "supported_features": ["Basic C++ syntax", "Functions", "Variables", "Control structures"]
                },
                "endpoints": 6,
                "cors_enabled": True
            })
        
        @self.app.route('/shutdown', methods=['POST'])
        def shutdown():
            """Shutdown server endpoint (for development)"""
            data = request.get_json() or {}
            if data.get('confirm') == 'shutdown':
                self.shutdown_flag.set()
                return jsonify({"message": "Server shutdown initiated"})
            return jsonify({"error": "Confirmation required"}), 400
    
    def _compile_source_api(self, source_code: str, filename: str, show_generated_code: bool = False, verbose: bool = False) -> dict:
        """Compile C++ source code and return result as dictionary for API"""
        try:
            # Capture all output
            stdout_buffer = StringIO()
            stderr_buffer = StringIO()
            
            with redirect_stdout(stdout_buffer), redirect_stderr(stderr_buffer):
                # Phase 1: Lexical Analysis
                if verbose:
                    print("Phase 1: Lexical Analysis...")
                
                lexer = Lexer(source_code)
                tokens = lexer.tokenize()
                
                # Phase 2: Syntax Analysis (Parsing)
                if verbose:
                    print("Phase 2: Syntax Analysis...")
                
                parser = Parser(tokens)
                ast = parser.parse()
                
                # Phase 3: Semantic Analysis
                if verbose:
                    print("Phase 3: Semantic Analysis...")
                
                analyzer = SemanticAnalyzer()
                if not analyzer.analyze(ast):
                    return {
                        "success": False,
                        "error": "Semantic Analysis Failed",
                        "details": analyzer.errors,
                        "output": stdout_buffer.getvalue(),
                        "execution_output": "",
                        "compilation_phases": ["lexical", "syntax", "semantic_failed"]
                    }
                
                # Phase 4: Code Generation
                if verbose:
                    print("Phase 4: Code Generation...")
                
                generator = CodeGenerator(analyzer)
                generated_code = generator.generate(ast)
                
                # Phase 5: Execution
                if verbose:
                    print("Phase 5: Execution...")
                
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
                        "execution_output": execution_output.getvalue(),
                        "compilation_phases": ["lexical", "syntax", "semantic", "code_gen", "runtime_error"],
                        "generated_code": generated_code if show_generated_code else None
                    }
            
            return {
                "success": True,
                "error": None,
                "details": [],
                "output": stdout_buffer.getvalue(),
                "execution_output": execution_output.getvalue(),
                "compilation_phases": ["lexical", "syntax", "semantic", "code_gen", "execution"],
                "generated_code": generated_code if show_generated_code else None
            }
            
        except SyntaxError as e:
            return {
                "success": False,
                "error": f"Syntax Error: {str(e)}",
                "details": [str(e)],
                "output": "",
                "execution_output": "",
                "compilation_phases": ["lexical", "syntax_error"]
            }
        except Exception as e:
            return {
                "success": False,
                "error": f"Compilation Error: {str(e)}",
                "details": [str(e), traceback.format_exc()],
                "output": "",
                "execution_output": "",
                "compilation_phases": ["error"]
            }
    
    def _get_builtin_examples(self):
        """Get built-in example programs"""
        return [
            {
                "filename": "hello_world.cpp",
                "code": '''#include <iostream>
using namespace std;

int main() {
    cout << "Hello, World!" << endl;
    return 0;
}''',
                "description": "Basic Hello World program",
                "category": "basic"
            },
            {
                "filename": "variables.cpp",
                "code": '''#include <iostream>
using namespace std;

int main() {
    int x = 10;
    int y = 20;
    int sum = x + y;
    cout << "Sum of " << x << " and " << y << " is: " << sum << endl;
    return 0;
}''',
                "description": "Variables and arithmetic",
                "category": "basic"
            },
            {
                "filename": "function.cpp",
                "code": '''#include <iostream>
using namespace std;

int add(int a, int b) {
    return a + b;
}

int main() {
    int result = add(5, 3);
    cout << "5 + 3 = " << result << endl;
    return 0;
}''',
                "description": "Function definition and call",
                "category": "functions"
            },
            {
                "filename": "loops.cpp",
                "code": '''#include <iostream>
using namespace std;

int main() {
    cout << "Counting from 1 to 5:" << endl;
    for(int i = 1; i <= 5; i++) {
        cout << i << " ";
    }
    cout << endl;
    return 0;
}''',
                "description": "For loop example",
                "category": "control_structures"
            }
        ]
    
    def _get_local_ip(self):
        """Get the local IP address"""
        try:
            # Connect to a remote address to get local IP
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
            s.close()
            return local_ip
        except Exception:
            return "127.0.0.1"
    
    def start_server(self, host='0.0.0.0', port=5000, debug=False):
        """Start the Flask server"""
        local_ip = self._get_local_ip()
        
        print("=" * 60)
        print("🚀 C++ COMPILER API SERVER STARTING")
        print("=" * 60)
        print(f"📍 Server Address: http://{host}:{port}")
        print(f"🌐 Local IP: http://{local_ip}:{port}")
        print(f"📱 For mobile apps, use: http://{local_ip}:{port}")
        print("=" * 60)
        print("📋 Available Endpoints:")
        print(f"   • GET  {local_ip}:{port}/           - API info")
        print(f"   • GET  {local_ip}:{port}/health     - Health check")
        print(f"   • POST {local_ip}:{port}/compile    - Compile C++ code")
        print(f"   • GET  {local_ip}:{port}/examples   - Example programs")
        print(f"   • GET  {local_ip}:{port}/server-info- Server details")
        print("=" * 60)
        print("📝 Usage example:")
        print(f'   curl -X POST http://{local_ip}:{port}/compile \\')
        print('        -H "Content-Type: application/json" \\')
        print('        -d \'{"code": "#include<iostream>\\nint main(){std::cout<<\\"Hello!\\";}"}\'')
        print("=" * 60)
        print("🔧 Press Ctrl+C to stop the server")
        print("=" * 60)
        
        try:
            # Start server in a thread to handle shutdown
            def run_server():
                self.app.run(host=host, port=port, debug=debug, threaded=True, use_reloader=False)
            
            self.server_thread = threading.Thread(target=run_server)
            self.server_thread.daemon = True
            self.server_thread.start()
            
            # Wait for shutdown signal
            try:
                while not self.shutdown_flag.is_set():
                    time.sleep(1)
                print("\\n📴 Server shutdown initiated by API call")
            except KeyboardInterrupt:
                print("\\n🛑 Server stopped by user (Ctrl+C)")
            
        except Exception as e:
            print(f"❌ Server error: {e}")
        
        print("👋 Server stopped. Goodbye!")

def main():
    """Main entry point for the server"""
    import argparse
    
    parser = argparse.ArgumentParser(description='C++ Compiler API Server')
    parser.add_argument('--host', default='0.0.0.0', help='Host address (default: 0.0.0.0)')
    parser.add_argument('--port', type=int, default=5000, help='Port number (default: 5000)')
    parser.add_argument('--debug', action='store_true', help='Enable debug mode')
    
    args = parser.parse_args()
    
    # Create and start server
    server = CompilerAPIServer()
    server.start_server(host=args.host, port=args.port, debug=args.debug)

if __name__ == "__main__":
    main()