# C++ Compiler API

A Python-based C++ compiler with a Flask web API for remote compilation and execution.

## Features

- Complete C++ compilation pipeline (Lexer → Parser → Semantic Analysis → Code Generation → Execution)
- RESTful API endpoints for web/mobile app integration
- Support for basic C++ constructs (functions, variables, loops, conditionals)
- CORS enabled for cross-origin requests
- Example programs included

## API Endpoints

### Base URL
- Local development: `http://localhost:5000`
- Replit deployment: `https://your-repl-name.username.repl.co`

### Endpoints

#### `GET /`
Returns API information and available endpoints.

#### `GET /health`
Health check endpoint.

#### `POST /compile`
Compiles and executes C++ code.

**Request Body:**
```json
{
  "code": "string (required) - C++ source code",
  "filename": "string (optional) - Source filename",
  "show_generated_code": "boolean (optional) - Include generated Python code in response",
  "verbose": "boolean (optional) - Enable verbose output"
}
```

**Response:**
```json
{
  "success": boolean,
  "error": "string or null",
  "details": ["array of error details"],
  "output": "string - compilation output",
  "execution_output": "string - program execution output",
  "generated_code": "string or null - generated Python code (if requested)"
}
```

#### `GET /examples`
Returns available example C++ programs.

## Deployment Instructions

### Replit Deployment

1. Create a new Replit project
2. Upload all project files to Replit
3. The `.replit` and `replit.nix` files will automatically configure the environment
4. Click "Run" - the API server will start automatically
5. Use the provided Replit URL to access your API

### Local Development

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Start the API server:
   ```bash
   python main.py --api
   ```

3. Access the API at `http://localhost:5000`

### Alternative Usage

- Interactive mode: `python main.py`
- Compile file: `python main.py program.cpp`
- Show help: `python main.py --help`

## Flutter Integration Example

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompilerService {
  static const String baseUrl = 'https://your-repl-name.username.repl.co';
  
  Future<Map<String, dynamic>> compileCode(String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/compile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'filename': 'main.cpp',
        'show_generated_code': false,
        'verbose': false,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

## Example C++ Code

```cpp
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, World!" << endl;
    
    int a = 10;
    int b = 20;
    int sum = a + b;
    
    cout << "Sum: " << sum << endl;
    
    return 0;
}
```

## Environment Variables

- `PORT`: Server port (default: 5000)
- `PYTHONPATH`: Python module path (set to "." for local imports)

## Security Notes

- This compiler executes submitted code - only deploy in trusted environments
- Consider adding authentication for production use
- Input validation is basic - enhance for production deployment