// lib/services/custom_language_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_language.dart';
import 'custom_language_parser.dart';

class CustomLanguageService {
  static const String _languagesKey = 'custom_languages';
  static const String _activeLanguageKey = 'active_language_id';

  
  static CustomLanguageService? _instance;
  SharedPreferences? _prefs;
  
  List<CustomLanguage> _languages = [];
  CustomLanguage? _activeLanguage;
  
  static CustomLanguageService get instance {
    _instance ??= CustomLanguageService._();
    return _instance!;
  }
  
  CustomLanguageService._();
  
  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadLanguages();
    await _loadActiveLanguage();
  }
  
  /// Get all saved languages
  List<CustomLanguage> get languages => List.from(_languages);
  
  /// Get currently active language
  CustomLanguage? get activeLanguage => _activeLanguage;
  
  /// Check if standard C++ mode is active (no custom language selected)
  bool get isStandardCppMode => _activeLanguage == null;
  
  /// Get active language name for display
  String get activeLanguageName => _activeLanguage?.name ?? 'Standard C++';
  
  /// Deactivate custom language (switch to standard C++)
  Future<void> activateStandardCpp() async {
    _activeLanguage = null;
    await _saveActiveLanguage();
  }
  
  /// Create a new language template
  CustomLanguage createNewLanguage(String name, String description, String author) {
    final now = DateTime.now();
    return CustomLanguage(
      id: _generateId(),
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      syntax: LanguageSyntax.defaultEnglish(),
      metadata: LanguageMetadata.defaultMetadata(author),
    );
  }
  
  /// Save a language
  Future<bool> saveLanguage(CustomLanguage language) async {
    try {
      // Update the language in the list
      final index = _languages.indexWhere((l) => l.id == language.id);
      if (index >= 0) {
        _languages[index] = language.copyWith(updatedAt: DateTime.now());
      } else {
        _languages.add(language);
      }
      
      await _saveLanguages();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Delete a language
  Future<bool> deleteLanguage(String languageId) async {
    try {
      _languages.removeWhere((l) => l.id == languageId);
      
      // If the deleted language was active, clear active language
      if (_activeLanguage?.id == languageId) {
        _activeLanguage = null;
        await _prefs?.remove(_activeLanguageKey);
      }
      
      await _saveLanguages();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Set active language
  Future<void> setActiveLanguage(String? languageId) async {
    if (languageId == null) {
      _activeLanguage = null;
      await _prefs?.remove(_activeLanguageKey);
    } else {
      _activeLanguage = _languages.firstWhere(
        (l) => l.id == languageId,
        orElse: () => throw Exception('Language not found'),
      );
      await _prefs?.setString(_activeLanguageKey, languageId);
    }
  }
  
  /// Get language by ID
  CustomLanguage? getLanguageById(String id) {
    try {
      return _languages.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse custom code to C++ using active language
  String? parseActiveLanguageCode(String customCode) {
    if (_activeLanguage == null) return null;
    
    try {
      final parser = CustomLanguageParser(_activeLanguage!);
      return parser.parseToCpp(customCode);
    } catch (e) {
      throw Exception('Failed to parse code: $e');
    }
  }
  
  /// Get parser for active language
  CustomLanguageParser? getActiveParser() {
    if (_activeLanguage == null) return null;
    return CustomLanguageParser(_activeLanguage!);
  }
  
  /// Validate a language
  ValidationResult validateLanguage(CustomLanguage language) {
    return LanguageValidator.validate(language);
  }
  
  /// Export language to JSON string
  String exportLanguage(String languageId) {
    final language = getLanguageById(languageId);
    if (language == null) throw Exception('Language not found');
    
    return jsonEncode(language.toJson());
  }
  
  /// Import language from JSON string
  Future<bool> importLanguage(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      var language = CustomLanguage.fromJson(json);
      
      // Generate new ID to avoid conflicts
      language = language.copyWith(
        id: _generateId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return await saveLanguage(language);
    } catch (e) {
      return false;
    }
  }
  
  /// Create sample languages
  Future<void> createSampleLanguages() async {
    // Create Urdu language sample
    final urduLanguage = _createUrduLanguage();
    await saveLanguage(urduLanguage);
    
    // Create Hindi language sample
    final hindiLanguage = _createHindiLanguage();
    await saveLanguage(hindiLanguage);
    
    // Create Simple English language
    final simpleLanguage = _createSimpleEnglishLanguage();
    await saveLanguage(simpleLanguage);
  }
  
  /// Create Urdu language template
  CustomLanguage _createUrduLanguage() {
    final now = DateTime.now();
    return CustomLanguage(
      id: _generateId(),
      name: 'اردو پروگرامنگ',
      description: 'Urdu programming language with Urdu keywords',
      createdAt: now,
      updatedAt: now,
      syntax: LanguageSyntax(
        controlStructures: ControlStructures(
          ifStatement: 'اگر',
          elseStatement: 'ورنہ',
          elseIfStatement: 'ورنہ اگر',
          forLoop: 'لوپ',
          whileLoop: 'جب تک',
          doWhileLoop: 'کرو',
          switchStatement: 'تبدیل',
          caseStatement: 'صورت',
          defaultCase: 'بنیادی',
          breakStatement: 'توڑ',
          continueStatement: 'جاری',
          returnStatement: 'واپس',
        ),
        dataTypes: DataTypes(
          integerType: 'عدد',
          stringType: 'متن',
          booleanType: 'بولین',
          floatType: 'اعشاری',
          doubleType: 'ڈبل',
          characterType: 'حرف',
          voidType: 'خالی',
        ),
        operators: Operators.defaultEnglish(), // Keep operators as symbols
        functions: Functions(
          mainFunction: 'بنیادی',
          functionDeclaration: 'فنکشن',
          parameters: '()',
          returnType: ':',
        ),
        comments: Comments.defaultEnglish(),
        keywords: Keywords(
          include: '#شامل',
          namespace: 'نام_جگہ',
          using: 'استعمال',
          struct: 'ڈھانچہ',
          class_: 'کلاس',
          public: 'عوامی',
          private: 'نجی',
          protected: 'محفوظ',
        ),
      ),
      metadata: LanguageMetadata(
        author: 'System',
        version: '1.0.0',
        tags: ['urdu', 'sample', 'localized'],
        iconColor: '#4CAF50',
        isPublic: true,
        usageCount: 0,
      ),
    );
  }
  
  /// Create Hindi language template
  CustomLanguage _createHindiLanguage() {
    final now = DateTime.now();
    return CustomLanguage(
      id: _generateId(),
      name: 'हिंदी प्रोग्रामिंग',
      description: 'Hindi programming language with Hindi keywords',
      createdAt: now,
      updatedAt: now,
      syntax: LanguageSyntax(
        controlStructures: ControlStructures(
          ifStatement: 'यदि',
          elseStatement: 'अन्यथा',
          elseIfStatement: 'अन्यथा यदि',
          forLoop: 'के लिए',
          whileLoop: 'जब तक',
          doWhileLoop: 'करें',
          switchStatement: 'स्विच',
          caseStatement: 'केस',
          defaultCase: 'डिफ़ॉल्ट',
          breakStatement: 'तोड़ें',
          continueStatement: 'जारी',
          returnStatement: 'वापसी',
        ),
        dataTypes: DataTypes(
          integerType: 'संख्या',
          stringType: 'पाठ',
          booleanType: 'बूलियन',
          floatType: 'दशमलव',
          doubleType: 'डबल',
          characterType: 'अक्षर',
          voidType: 'खाली',
        ),
        operators: Operators.defaultEnglish(),
        functions: Functions(
          mainFunction: 'मुख्य',
          functionDeclaration: 'फंक्शन',
          parameters: '()',
          returnType: ':',
        ),
        comments: Comments.defaultEnglish(),
        keywords: Keywords(
          include: '#शामिल',
          namespace: 'नाम_स्थान',
          using: 'उपयोग',
          struct: 'संरचना',
          class_: 'क्लास',
          public: 'सार्वजनिक',
          private: 'निजी',
          protected: 'संरक्षित',
        ),
      ),
      metadata: LanguageMetadata(
        author: 'System',
        version: '1.0.0',
        tags: ['hindi', 'sample', 'localized'],
        iconColor: '#FF9800',
        isPublic: true,
        usageCount: 0,
      ),
    );
  }
  
  /// Create Simple English language
  CustomLanguage _createSimpleEnglishLanguage() {
    final now = DateTime.now();
    return CustomLanguage(
      id: _generateId(),
      name: 'Simple English',
      description: 'Easy to understand English programming language',
      createdAt: now,
      updatedAt: now,
      syntax: LanguageSyntax(
        controlStructures: ControlStructures(
          ifStatement: 'check',
          elseStatement: 'otherwise',
          elseIfStatement: 'otherwise check',
          forLoop: 'repeat',
          whileLoop: 'keep doing',
          doWhileLoop: 'start',
          switchStatement: 'choose',
          caseStatement: 'when',
          defaultCase: 'normally',
          breakStatement: 'stop',
          continueStatement: 'skip',
          returnStatement: 'give back',
        ),
        dataTypes: DataTypes(
          integerType: 'number',
          stringType: 'text',
          booleanType: 'yes_no',
          floatType: 'decimal',
          doubleType: 'big_decimal',
          characterType: 'letter',
          voidType: 'nothing',
        ),
        operators: Operators(
          addition: 'plus',
          subtraction: 'minus',
          multiplication: 'times',
          division: 'divided_by',
          modulo: 'remainder',
          assignment: 'equals',
          equality: 'is_same_as',
          notEqual: 'is_not',
          lessThan: 'is_less_than',
          greaterThan: 'is_greater_than',
          lessThanOrEqual: 'is_at_most',
          greaterThanOrEqual: 'is_at_least',
          logicalAnd: 'and',
          logicalOr: 'or',
          logicalNot: 'not',
        ),
        functions: Functions(
          mainFunction: 'start_program',
          functionDeclaration: 'define',
          parameters: '()',
          returnType: 'gives',
        ),
        comments: Comments(
          singleLineComment: 'note:',
          multiLineCommentStart: 'begin_note',
          multiLineCommentEnd: 'end_note',
        ),
        keywords: Keywords(
          include: 'use_library',
          namespace: 'from_group',
          using: 'import',
          struct: 'structure',
          class_: 'blueprint',
          public: 'everyone_can_see',
          private: 'only_me',
          protected: 'family_only',
        ),
      ),
      metadata: LanguageMetadata(
        author: 'System',
        version: '1.0.0',
        tags: ['english', 'simple', 'beginner-friendly'],
        iconColor: '#2196F3',
        isPublic: true,
        usageCount: 0,
      ),
    );
  }
  
  /// Load languages from storage
  Future<void> _loadLanguages() async {
    try {
      final languagesJson = _prefs?.getStringList(_languagesKey) ?? [];
      _languages = languagesJson
          .map((json) => CustomLanguage.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _languages = [];
    }
  }
  
  /// Save languages to storage
  Future<void> _saveLanguages() async {
    try {
      final languagesJson = _languages
          .map((lang) => jsonEncode(lang.toJson()))
          .toList();
      await _prefs?.setStringList(_languagesKey, languagesJson);
    } catch (e) {
      // Handle error
    }
  }
  
  /// Load active language from storage
  Future<void> _loadActiveLanguage() async {
    try {
      final activeId = _prefs?.getString(_activeLanguageKey);
      if (activeId != null) {
        _activeLanguage = _languages.firstWhere(
          (l) => l.id == activeId,
          orElse: () => throw Exception(),
        );
      }
    } catch (e) {
      _activeLanguage = null;
    }
  }
  
  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (DateTime.now().microsecond % 1000).toString();
  }

  /// Save active language to storage
  Future<void> _saveActiveLanguage() async {
    if (_activeLanguage != null) {
      await _prefs?.setString(_activeLanguageKey, _activeLanguage!.id);
    } else {
      await _prefs?.remove(_activeLanguageKey);
    }
  }
  
  /// Clear all data (for testing/reset)
  Future<void> clearAll() async {
    _languages.clear();
    _activeLanguage = null;
    await _prefs?.remove(_languagesKey);
    await _prefs?.remove(_activeLanguageKey);
  }
}