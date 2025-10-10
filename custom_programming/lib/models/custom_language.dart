// lib/models/custom_language.dart

/// Represents a custom programming language created by the user
class CustomLanguage {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LanguageSyntax syntax;
  final LanguageMetadata metadata;

  CustomLanguage({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.syntax,
    required this.metadata,
  });

  /// Create a copy with updated fields
  CustomLanguage copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    LanguageSyntax? syntax,
    LanguageMetadata? metadata,
  }) {
    return CustomLanguage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syntax: syntax ?? this.syntax,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syntax': syntax.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  /// Create from JSON
  factory CustomLanguage.fromJson(Map<String, dynamic> json) {
    return CustomLanguage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      syntax: LanguageSyntax.fromJson(json['syntax'] ?? {}),
      metadata: LanguageMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() => 'CustomLanguage(name: $name, id: $id)';
}

/// Contains all syntax definitions for the custom language
class LanguageSyntax {
  final ControlStructures controlStructures;
  final DataTypes dataTypes;
  final Operators operators;
  final Functions functions;
  final Comments comments;
  final Keywords keywords;

  LanguageSyntax({
    required this.controlStructures,
    required this.dataTypes,
    required this.operators,
    required this.functions,
    required this.comments,
    required this.keywords,
  });

  Map<String, dynamic> toJson() {
    return {
      'controlStructures': controlStructures.toJson(),
      'dataTypes': dataTypes.toJson(),
      'operators': operators.toJson(),
      'functions': functions.toJson(),
      'comments': comments.toJson(),
      'keywords': keywords.toJson(),
    };
  }

  factory LanguageSyntax.fromJson(Map<String, dynamic> json) {
    return LanguageSyntax(
      controlStructures: ControlStructures.fromJson(json['controlStructures'] ?? {}),
      dataTypes: DataTypes.fromJson(json['dataTypes'] ?? {}),
      operators: Operators.fromJson(json['operators'] ?? {}),
      functions: Functions.fromJson(json['functions'] ?? {}),
      comments: Comments.fromJson(json['comments'] ?? {}),
      keywords: Keywords.fromJson(json['keywords'] ?? {}),
    );
  }

  /// Create default English syntax
  factory LanguageSyntax.defaultEnglish() {
    return LanguageSyntax(
      controlStructures: ControlStructures.defaultEnglish(),
      dataTypes: DataTypes.defaultEnglish(),
      operators: Operators.defaultEnglish(),
      functions: Functions.defaultEnglish(),
      comments: Comments.defaultEnglish(),
      keywords: Keywords.defaultEnglish(),
    );
  }
}

/// Control structures (if, else, for, while, etc.)
class ControlStructures {
  final String ifStatement;
  final String elseStatement;
  final String elseIfStatement;
  final String forLoop;
  final String whileLoop;
  final String doWhileLoop;
  final String switchStatement;
  final String caseStatement;
  final String defaultCase;
  final String breakStatement;
  final String continueStatement;
  final String returnStatement;

  ControlStructures({
    required this.ifStatement,
    required this.elseStatement,
    required this.elseIfStatement,
    required this.forLoop,
    required this.whileLoop,
    required this.doWhileLoop,
    required this.switchStatement,
    required this.caseStatement,
    required this.defaultCase,
    required this.breakStatement,
    required this.continueStatement,
    required this.returnStatement,
  });

  Map<String, dynamic> toJson() {
    return {
      'ifStatement': ifStatement,
      'elseStatement': elseStatement,
      'elseIfStatement': elseIfStatement,
      'forLoop': forLoop,
      'whileLoop': whileLoop,
      'doWhileLoop': doWhileLoop,
      'switchStatement': switchStatement,
      'caseStatement': caseStatement,
      'defaultCase': defaultCase,
      'breakStatement': breakStatement,
      'continueStatement': continueStatement,
      'returnStatement': returnStatement,
    };
  }

  factory ControlStructures.fromJson(Map<String, dynamic> json) {
    return ControlStructures(
      ifStatement: json['ifStatement'] ?? 'if',
      elseStatement: json['elseStatement'] ?? 'else',
      elseIfStatement: json['elseIfStatement'] ?? 'else if',
      forLoop: json['forLoop'] ?? 'for',
      whileLoop: json['whileLoop'] ?? 'while',
      doWhileLoop: json['doWhileLoop'] ?? 'do',
      switchStatement: json['switchStatement'] ?? 'switch',
      caseStatement: json['caseStatement'] ?? 'case',
      defaultCase: json['defaultCase'] ?? 'default',
      breakStatement: json['breakStatement'] ?? 'break',
      continueStatement: json['continueStatement'] ?? 'continue',
      returnStatement: json['returnStatement'] ?? 'return',
    );
  }

  factory ControlStructures.defaultEnglish() {
    return ControlStructures(
      ifStatement: 'if',
      elseStatement: 'else',
      elseIfStatement: 'else if',
      forLoop: 'for',
      whileLoop: 'while',
      doWhileLoop: 'do',
      switchStatement: 'switch',
      caseStatement: 'case',
      defaultCase: 'default',
      breakStatement: 'break',
      continueStatement: 'continue',
      returnStatement: 'return',
    );
  }
}

/// Data types (int, string, bool, etc.)
class DataTypes {
  final String integerType;
  final String stringType;
  final String booleanType;
  final String floatType;
  final String doubleType;
  final String characterType;
  final String voidType;

  DataTypes({
    required this.integerType,
    required this.stringType,
    required this.booleanType,
    required this.floatType,
    required this.doubleType,
    required this.characterType,
    required this.voidType,
  });

  Map<String, dynamic> toJson() {
    return {
      'integerType': integerType,
      'stringType': stringType,
      'booleanType': booleanType,
      'floatType': floatType,
      'doubleType': doubleType,
      'characterType': characterType,
      'voidType': voidType,
    };
  }

  factory DataTypes.fromJson(Map<String, dynamic> json) {
    return DataTypes(
      integerType: json['integerType'] ?? 'int',
      stringType: json['stringType'] ?? 'string',
      booleanType: json['booleanType'] ?? 'bool',
      floatType: json['floatType'] ?? 'float',
      doubleType: json['doubleType'] ?? 'double',
      characterType: json['characterType'] ?? 'char',
      voidType: json['voidType'] ?? 'void',
    );
  }

  factory DataTypes.defaultEnglish() {
    return DataTypes(
      integerType: 'int',
      stringType: 'string',
      booleanType: 'bool',
      floatType: 'float',
      doubleType: 'double',
      characterType: 'char',
      voidType: 'void',
    );
  }
}

/// Operators (+, -, *, /, etc.)
class Operators {
  final String addition;
  final String subtraction;
  final String multiplication;
  final String division;
  final String modulo;
  final String assignment;
  final String equality;
  final String notEqual;
  final String lessThan;
  final String greaterThan;
  final String lessThanOrEqual;
  final String greaterThanOrEqual;
  final String logicalAnd;
  final String logicalOr;
  final String logicalNot;

  Operators({
    required this.addition,
    required this.subtraction,
    required this.multiplication,
    required this.division,
    required this.modulo,
    required this.assignment,
    required this.equality,
    required this.notEqual,
    required this.lessThan,
    required this.greaterThan,
    required this.lessThanOrEqual,
    required this.greaterThanOrEqual,
    required this.logicalAnd,
    required this.logicalOr,
    required this.logicalNot,
  });

  Map<String, dynamic> toJson() {
    return {
      'addition': addition,
      'subtraction': subtraction,
      'multiplication': multiplication,
      'division': division,
      'modulo': modulo,
      'assignment': assignment,
      'equality': equality,
      'notEqual': notEqual,
      'lessThan': lessThan,
      'greaterThan': greaterThan,
      'lessThanOrEqual': lessThanOrEqual,
      'greaterThanOrEqual': greaterThanOrEqual,
      'logicalAnd': logicalAnd,
      'logicalOr': logicalOr,
      'logicalNot': logicalNot,
    };
  }

  factory Operators.fromJson(Map<String, dynamic> json) {
    return Operators(
      addition: json['addition'] ?? '+',
      subtraction: json['subtraction'] ?? '-',
      multiplication: json['multiplication'] ?? '*',
      division: json['division'] ?? '/',
      modulo: json['modulo'] ?? '%',
      assignment: json['assignment'] ?? '=',
      equality: json['equality'] ?? '==',
      notEqual: json['notEqual'] ?? '!=',
      lessThan: json['lessThan'] ?? '<',
      greaterThan: json['greaterThan'] ?? '>',
      lessThanOrEqual: json['lessThanOrEqual'] ?? '<=',
      greaterThanOrEqual: json['greaterThanOrEqual'] ?? '>=',
      logicalAnd: json['logicalAnd'] ?? '&&',
      logicalOr: json['logicalOr'] ?? '||',
      logicalNot: json['logicalNot'] ?? '!',
    );
  }

  factory Operators.defaultEnglish() {
    return Operators(
      addition: '+',
      subtraction: '-',
      multiplication: '*',
      division: '/',
      modulo: '%',
      assignment: '=',
      equality: '==',
      notEqual: '!=',
      lessThan: '<',
      greaterThan: '>',
      lessThanOrEqual: '<=',
      greaterThanOrEqual: '>=',
      logicalAnd: '&&',
      logicalOr: '||',
      logicalNot: '!',
    );
  }
}

/// Function-related syntax
class Functions {
  final String mainFunction;
  final String functionDeclaration;
  final String parameters;
  final String returnType;

  Functions({
    required this.mainFunction,
    required this.functionDeclaration,
    required this.parameters,
    required this.returnType,
  });

  Map<String, dynamic> toJson() {
    return {
      'mainFunction': mainFunction,
      'functionDeclaration': functionDeclaration,
      'parameters': parameters,
      'returnType': returnType,
    };
  }

  factory Functions.fromJson(Map<String, dynamic> json) {
    return Functions(
      mainFunction: json['mainFunction'] ?? 'main',
      functionDeclaration: json['functionDeclaration'] ?? 'function',
      parameters: json['parameters'] ?? '()',
      returnType: json['returnType'] ?? ':',
    );
  }

  factory Functions.defaultEnglish() {
    return Functions(
      mainFunction: 'main',
      functionDeclaration: 'function',
      parameters: '()',
      returnType: ':',
    );
  }
}

/// Comment syntax
class Comments {
  final String singleLineComment;
  final String multiLineCommentStart;
  final String multiLineCommentEnd;

  Comments({
    required this.singleLineComment,
    required this.multiLineCommentStart,
    required this.multiLineCommentEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'singleLineComment': singleLineComment,
      'multiLineCommentStart': multiLineCommentStart,
      'multiLineCommentEnd': multiLineCommentEnd,
    };
  }

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      singleLineComment: json['singleLineComment'] ?? '//',
      multiLineCommentStart: json['multiLineCommentStart'] ?? '/*',
      multiLineCommentEnd: json['multiLineCommentEnd'] ?? '*/',
    );
  }

  factory Comments.defaultEnglish() {
    return Comments(
      singleLineComment: '//',
      multiLineCommentStart: '/*',
      multiLineCommentEnd: '*/',
    );
  }
}

/// Additional keywords
class Keywords {
  final String include;
  final String namespace;
  final String using;
  final String struct;
  final String class_;
  final String public;
  final String private;
  final String protected;

  Keywords({
    required this.include,
    required this.namespace,
    required this.using,
    required this.struct,
    required this.class_,
    required this.public,
    required this.private,
    required this.protected,
  });

  Map<String, dynamic> toJson() {
    return {
      'include': include,
      'namespace': namespace,
      'using': using,
      'struct': struct,
      'class': class_,
      'public': public,
      'private': private,
      'protected': protected,
    };
  }

  factory Keywords.fromJson(Map<String, dynamic> json) {
    return Keywords(
      include: json['include'] ?? '#include',
      namespace: json['namespace'] ?? 'namespace',
      using: json['using'] ?? 'using',
      struct: json['struct'] ?? 'struct',
      class_: json['class'] ?? 'class',
      public: json['public'] ?? 'public',
      private: json['private'] ?? 'private',
      protected: json['protected'] ?? 'protected',
    );
  }

  factory Keywords.defaultEnglish() {
    return Keywords(
      include: '#include',
      namespace: 'namespace',
      using: 'using',
      struct: 'struct',
      class_: 'class',
      public: 'public',
      private: 'private',
      protected: 'protected',
    );
  }
}

/// Language metadata
class LanguageMetadata {
  final String author;
  final String version;
  final List<String> tags;
  final String? iconColor;
  final bool isPublic;
  final int usageCount;

  LanguageMetadata({
    required this.author,
    required this.version,
    required this.tags,
    this.iconColor,
    required this.isPublic,
    required this.usageCount,
  });

  /// Create a copy with updated fields
  LanguageMetadata copyWith({
    String? author,
    String? version,
    List<String>? tags,
    String? iconColor,
    bool? isPublic,
    int? usageCount,
  }) {
    return LanguageMetadata(
      author: author ?? this.author,
      version: version ?? this.version,
      tags: tags ?? this.tags,
      iconColor: iconColor ?? this.iconColor,
      isPublic: isPublic ?? this.isPublic,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'version': version,
      'tags': tags,
      'iconColor': iconColor,
      'isPublic': isPublic,
      'usageCount': usageCount,
    };
  }

  factory LanguageMetadata.fromJson(Map<String, dynamic> json) {
    return LanguageMetadata(
      author: json['author'] ?? 'Unknown',
      version: json['version'] ?? '1.0.0',
      tags: List<String>.from(json['tags'] ?? []),
      iconColor: json['iconColor'],
      isPublic: json['isPublic'] ?? false,
      usageCount: json['usageCount'] ?? 0,
    );
  }

  factory LanguageMetadata.defaultMetadata(String author) {
    return LanguageMetadata(
      author: author,
      version: '1.0.0',
      tags: [],
      isPublic: false,
      usageCount: 0,
    );
  }
}