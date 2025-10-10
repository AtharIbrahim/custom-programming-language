// lib/services/custom_language_parser.dart
import '../models/custom_language.dart';

class CustomLanguageParser {
  final CustomLanguage language;
  
  CustomLanguageParser(this.language);

  /// Convert custom language code to C++ code
  String parseToCpp(String customCode) {
    try {
      // First validate that the code follows custom language syntax strictly
      _validateCustomLanguageSyntax(customCode);
      
      // Start with basic preprocessing
      String cppCode = _preprocess(customCode);
      
      // Convert syntax elements step by step
      cppCode = _convertControlStructures(cppCode);
      cppCode = _convertDataTypes(cppCode);
      cppCode = _convertOperators(cppCode);
      cppCode = _convertFunctions(cppCode);
      cppCode = _convertKeywords(cppCode);
      cppCode = _convertComments(cppCode);
      
      // Add necessary includes and namespace
      cppCode = _addStandardHeaders(cppCode);
      
      return cppCode;
    } catch (e) {
      throw CustomLanguageParserException('Failed to parse custom language: $e');
    }
  }

  /// Validate that code uses only custom language syntax (not C++ keywords)
  void _validateCustomLanguageSyntax(String code) {
    // Define C++ keywords that should NOT appear in custom language code
    final forbiddenCppKeywords = {
      'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default',
      'break', 'continue', 'return', 'int', 'string', 'bool', 'float',
      'double', 'char', 'void', 'main', 'namespace', 'using', 'struct',
      'class', 'public', 'private', 'protected'
    };

    // Get the custom language syntax
    final customSyntax = _getAllCustomSyntaxElements();
    
    // Check for forbidden C++ keywords in the code
    final codeWords = _extractWords(code);
    final violatingWords = <String>[];
    
    for (final word in codeWords) {
      if (forbiddenCppKeywords.contains(word) && !customSyntax.contains(word)) {
        violatingWords.add(word);
      }
    }
    
    if (violatingWords.isNotEmpty) {
      throw CustomLanguageParserException(
        'Standard C++ keywords found: ${violatingWords.join(', ')}. '
        'When using custom language "${language.name}", you must use only '
        'the custom syntax you defined. For example, use "${language.syntax.controlStructures.ifStatement}" instead of "if".'
      );
    }
    
    // Additional validation: ensure custom keywords are actually being used
    _validateCustomKeywordUsage(code, customSyntax);
  }
  
  /// Get all custom syntax elements defined in the language
  Set<String> _getAllCustomSyntaxElements() {
    final syntax = language.syntax;
    return {
      // Control structures
      syntax.controlStructures.ifStatement,
      syntax.controlStructures.elseStatement,
      syntax.controlStructures.elseIfStatement,
      syntax.controlStructures.forLoop,
      syntax.controlStructures.whileLoop,
      syntax.controlStructures.doWhileLoop,
      syntax.controlStructures.switchStatement,
      syntax.controlStructures.caseStatement,
      syntax.controlStructures.defaultCase,
      syntax.controlStructures.breakStatement,
      syntax.controlStructures.continueStatement,
      syntax.controlStructures.returnStatement,
      
      // Data types
      syntax.dataTypes.integerType,
      syntax.dataTypes.stringType,
      syntax.dataTypes.booleanType,
      syntax.dataTypes.floatType,
      syntax.dataTypes.doubleType,
      syntax.dataTypes.characterType,
      syntax.dataTypes.voidType,
      
      // Functions
      syntax.functions.mainFunction,
      
      // Keywords that are commonly used
      syntax.keywords.namespace,
      syntax.keywords.using,
      syntax.keywords.struct,
      syntax.keywords.class_,
      syntax.keywords.public,
      syntax.keywords.private,
      syntax.keywords.protected,
    };
  }
  
  /// Extract meaningful words from code (excluding strings, comments, and operators)
  Set<String> _extractWords(String code) {
    final words = <String>{};
    
    // Remove string literals and comments first
    String cleanCode = code
        .replaceAll(RegExp(r'"[^"]*"'), '') // Remove string literals
        .replaceAll(RegExp(r"'[^']*'"), '') // Remove char literals
        .replaceAll(RegExp(r'//.*'), '') // Remove single line comments
        .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), ''); // Remove multi-line comments
    
    // Extract words (alphanumeric sequences)
    final wordMatches = RegExp(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b').allMatches(cleanCode);
    
    for (final match in wordMatches) {
      final word = match.group(0)!;
      // Exclude common identifiers that are likely user-defined
      if (!_isLikelyUserIdentifier(word)) {
        words.add(word);
      }
    }
    
    return words;
  }
  
  /// Check if a word is likely a user-defined identifier
  bool _isLikelyUserIdentifier(String word) {
    // Skip words that look like variable names, function names, etc.
    final userIdentifierPatterns = [
      RegExp(r'^[a-z][a-zA-Z0-9]*$'), // camelCase variables
      RegExp(r'^[A-Z][a-zA-Z0-9]*$'), // PascalCase classes
      RegExp(r'^[a-z_]+[a-z0-9_]*$'), // snake_case variables
      RegExp(r'^\d+$'), // numbers
    ];
    
    // Common user variable names to ignore
    final commonUserNames = {
      'x', 'y', 'z', 'i', 'j', 'k', 'n', 'm', 'count', 'index', 'temp',
      'value', 'result', 'data', 'item', 'element', 'node', 'size', 'length',
      'width', 'height', 'name', 'id', 'key', 'val', 'num', 'number',
      'str', 'text', 'message', 'info', 'flag', 'status', 'type', 'mode',
      'cout', 'cin', 'endl', 'std', 'iostream' // Allow C++ standard library
    };
    
    if (commonUserNames.contains(word.toLowerCase())) {
      return true;
    }
    
    return userIdentifierPatterns.any((pattern) => pattern.hasMatch(word));
  }
  
  /// Validate that custom keywords are being used appropriately
  void _validateCustomKeywordUsage(String code, Set<String> customSyntax) {
    // Check if the code contains any custom keywords
    bool hasCustomKeywords = false;
    
    for (final keyword in customSyntax) {
      if (code.contains(keyword)) {
        hasCustomKeywords = true;
        break;
      }
    }
    
    // If no custom keywords are used, it might be plain C++ code
    if (!hasCustomKeywords && code.trim().isNotEmpty) {
      // Check if it looks like C++ code with control structures
      final cppPatterns = [
        RegExp(r'\bif\s*\('),
        RegExp(r'\bfor\s*\('),
        RegExp(r'\bwhile\s*\('),
        RegExp(r'\bint\s+\w+'),
        RegExp(r'\bstring\s+\w+'),
      ];
      
      for (final pattern in cppPatterns) {
        if (pattern.hasMatch(code)) {
          throw CustomLanguageParserException(
            'This appears to be standard C++ code. When using custom language "${language.name}", '
            'you must write code using your custom syntax. '
            '\n\nFor example, use:\n'
            '• "${language.syntax.controlStructures.ifStatement}" instead of "if"\n'
            '• "${language.syntax.dataTypes.integerType}" instead of "int"\n'
            '• "${language.syntax.functions.mainFunction}" instead of "main"\n\n'
            'Switch to "Standard C++" mode if you want to write regular C++ code.'
          );
        }
      }
    }
  }

  /// Preprocess the code to handle special cases
  String _preprocess(String code) {
    // Remove extra whitespace and normalize line endings
    return code
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
  }

  /// Convert control structures
  String _convertControlStructures(String code) {
    final syntax = language.syntax.controlStructures;
    
    // Convert if statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.ifStatement)}\\b'),
      'if'
    );
    
    // Convert else statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.elseStatement)}\\b'),
      'else'
    );
    
    // Convert else if statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.elseIfStatement)}\\b'),
      'else if'
    );
    
    // Convert for loops
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.forLoop)}\\b'),
      'for'
    );
    
    // Convert while loops
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.whileLoop)}\\b'),
      'while'
    );
    
    // Convert do-while loops
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.doWhileLoop)}\\b'),
      'do'
    );
    
    // Convert switch statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.switchStatement)}\\b'),
      'switch'
    );
    
    // Convert case statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.caseStatement)}\\b'),
      'case'
    );
    
    // Convert default case
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.defaultCase)}\\b'),
      'default'
    );
    
    // Convert break statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.breakStatement)}\\b'),
      'break'
    );
    
    // Convert continue statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.continueStatement)}\\b'),
      'continue'
    );
    
    // Convert return statements
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.returnStatement)}\\b'),
      'return'
    );
    
    return code;
  }

  /// Convert data types
  String _convertDataTypes(String code) {
    final syntax = language.syntax.dataTypes;
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.integerType)}\\b'),
      'int'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.stringType)}\\b'),
      'string'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.booleanType)}\\b'),
      'bool'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.floatType)}\\b'),
      'float'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.doubleType)}\\b'),
      'double'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.characterType)}\\b'),
      'char'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.voidType)}\\b'),
      'void'
    );
    
    return code;
  }

  /// Convert operators (be careful with order and escaping)
  String _convertOperators(String code) {
    final syntax = language.syntax.operators;
    
    // Handle multi-character operators first
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.greaterThanOrEqual)),
      '>='
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.lessThanOrEqual)),
      '<='
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.equality)),
      '=='
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.notEqual)),
      '!='
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.logicalAnd)),
      '&&'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.logicalOr)),
      '||'
    );
    
    // Handle single-character operators
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.addition)),
      '+'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.subtraction)),
      '-'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.multiplication)),
      '*'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.division)),
      '/'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.modulo)),
      '%'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.assignment)),
      '='
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.lessThan)),
      '<'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.greaterThan)),
      '>'
    );
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.logicalNot)),
      '!'
    );
    
    return code;
  }

  /// Convert function-related syntax
  String _convertFunctions(String code) {
    final syntax = language.syntax.functions;
    
    // Convert main function
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.mainFunction)}\\b'),
      'main'
    );
    
    // Convert function declaration keyword
    if (syntax.functionDeclaration != 'function') {
      code = code.replaceAll(
        RegExp('\\b${RegExp.escape(syntax.functionDeclaration)}\\b'),
        ''
      );
    }
    
    return code;
  }

  /// Convert keywords
  String _convertKeywords(String code) {
    final syntax = language.syntax.keywords;
    
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.include)),
      '#include'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.namespace)}\\b'),
      'namespace'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.using)}\\b'),
      'using'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.struct)}\\b'),
      'struct'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.class_)}\\b'),
      'class'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.public)}\\b'),
      'public'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.private)}\\b'),
      'private'
    );
    
    code = code.replaceAll(
      RegExp('\\b${RegExp.escape(syntax.protected)}\\b'),
      'protected'
    );
    
    return code;
  }

  /// Convert comments
  String _convertComments(String code) {
    final syntax = language.syntax.comments;
    
    // Convert single-line comments
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.singleLineComment)),
      '//'
    );
    
    // Convert multi-line comment start
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.multiLineCommentStart)),
      '/*'
    );
    
    // Convert multi-line comment end
    code = code.replaceAll(
      RegExp(RegExp.escape(syntax.multiLineCommentEnd)),
      '*/'
    );
    
    return code;
  }

  /// Add standard C++ headers and namespace if needed
  String _addStandardHeaders(String code) {
    // Check if iostream is already included
    bool hasIOStream = code.contains('#include <iostream>') || 
                      code.contains('#include<iostream>');
    
    // Check if using namespace std is already present
    bool hasNamespace = code.contains('using namespace std') ||
                       code.contains('std::');
    
    String result = '';
    
    // Add iostream if not present and code uses cout, cin, or endl
    if (!hasIOStream && (code.contains('cout') || code.contains('cin') || code.contains('endl'))) {
      result += '#include <iostream>\n';
    }
    
    // Add namespace if not present and code uses cout, cin, or endl without std::
    if (!hasNamespace && (code.contains('cout') || code.contains('cin') || code.contains('endl'))) {
      if (!code.contains('std::')) {
        result += 'using namespace std;\n';
      }
    }
    
    if (result.isNotEmpty) {
      result += '\n';
    }
    
    return result + code;
  }

  /// Get syntax highlighting keywords for the custom language
  Set<String> getCustomKeywords() {
    final syntax = language.syntax;
    return {
      // Control structures
      syntax.controlStructures.ifStatement,
      syntax.controlStructures.elseStatement,
      syntax.controlStructures.elseIfStatement,
      syntax.controlStructures.forLoop,
      syntax.controlStructures.whileLoop,
      syntax.controlStructures.doWhileLoop,
      syntax.controlStructures.switchStatement,
      syntax.controlStructures.caseStatement,
      syntax.controlStructures.defaultCase,
      syntax.controlStructures.breakStatement,
      syntax.controlStructures.continueStatement,
      syntax.controlStructures.returnStatement,
      
      // Data types
      syntax.dataTypes.integerType,
      syntax.dataTypes.stringType,
      syntax.dataTypes.booleanType,
      syntax.dataTypes.floatType,
      syntax.dataTypes.doubleType,
      syntax.dataTypes.characterType,
      syntax.dataTypes.voidType,
      
      // Functions
      syntax.functions.mainFunction,
      syntax.functions.functionDeclaration,
      
      // Keywords
      syntax.keywords.namespace,
      syntax.keywords.using,
      syntax.keywords.struct,
      syntax.keywords.class_,
      syntax.keywords.public,
      syntax.keywords.private,
      syntax.keywords.protected,
    };
  }

  /// Get example code in the custom language
  String generateExample() {
    final cs = language.syntax.controlStructures;
    final dt = language.syntax.dataTypes;
    final fn = language.syntax.functions;
    final ops = language.syntax.operators;
    final kw = language.syntax.keywords;
    
    return '''
${kw.include} <iostream>
${kw.using} namespace std;

${dt.integerType} ${fn.mainFunction}() {
    ${dt.integerType} x ${ops.assignment} 10;
    ${dt.integerType} y ${ops.assignment} 20;
    
    ${cs.ifStatement} (x ${ops.lessThan} y) {
        cout << "x is smaller" << endl;
    } ${cs.elseStatement} {
        cout << "x is bigger or equal" << endl;
    }
    
    ${cs.forLoop} (${dt.integerType} i ${ops.assignment} 1; i ${ops.lessThanOrEqual} 5; i${ops.addition}${ops.addition}) {
        cout << "Count: " << i << endl;
    }
    
    ${cs.returnStatement} 0;
}''';
  }
}

/// Exception thrown when parsing fails
class CustomLanguageParserException implements Exception {
  final String message;
  
  CustomLanguageParserException(this.message);
  
  @override
  String toString() => 'CustomLanguageParserException: $message';
}

/// Utility class for language validation
class LanguageValidator {
  /// Validate that a custom language definition is complete and valid
  static ValidationResult validate(CustomLanguage language) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Check for empty or conflicting syntax
    final syntax = language.syntax;
    
    // Collect all syntax elements
    final allSyntaxElements = <String, String>{
      'if': syntax.controlStructures.ifStatement,
      'else': syntax.controlStructures.elseStatement,
      'for': syntax.controlStructures.forLoop,
      'while': syntax.controlStructures.whileLoop,
      'int': syntax.dataTypes.integerType,
      'string': syntax.dataTypes.stringType,
      'main': syntax.functions.mainFunction,
    };
    
    // Check for empty values
    for (final entry in allSyntaxElements.entries) {
      if (entry.value.trim().isEmpty) {
        errors.add('${entry.key} syntax cannot be empty');
      }
    }
    
    // Check for conflicts (same syntax for different elements)
    final syntaxValues = allSyntaxElements.values.toList();
    final uniqueValues = syntaxValues.toSet();
    if (syntaxValues.length != uniqueValues.length) {
      warnings.add('Some syntax elements have the same value, which may cause conflicts');
    }
    
    // Check for potentially problematic syntax
    for (final entry in allSyntaxElements.entries) {
      final value = entry.value;
      if (value.contains(' ') && entry.key != 'else if') {
        warnings.add('${entry.key} syntax contains spaces, which may cause parsing issues');
      }
      if (RegExp(r'[^a-zA-Z0-9_\-#]').hasMatch(value) && !['operators', 'comments'].contains(entry.key)) {
        warnings.add('${entry.key} syntax contains special characters that may cause issues');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Result of language validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
  
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => !isValid || hasWarnings;
}