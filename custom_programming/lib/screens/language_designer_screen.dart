// lib/screens/language_designer_screen.dart
import 'package:custom_programming/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/custom_language.dart';
import '../services/custom_language_service.dart';
import '../services/custom_language_parser.dart';

class LanguageDesignerScreen extends StatefulWidget {
  final CustomLanguage? language; // null for new language, existing for edit
  
  const LanguageDesignerScreen({Key? key, this.language}) : super(key: key);

  @override
  State<LanguageDesignerScreen> createState() => _LanguageDesignerScreenState();
}

class _LanguageDesignerScreenState extends State<LanguageDesignerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Basic info controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  
  // Control structure controllers
  final _ifController = TextEditingController();
  final _elseController = TextEditingController();
  final _elseIfController = TextEditingController();
  final _forController = TextEditingController();
  final _whileController = TextEditingController();
  final _doWhileController = TextEditingController();
  final _switchController = TextEditingController();
  final _caseController = TextEditingController();
  final _defaultController = TextEditingController();
  final _breakController = TextEditingController();
  final _continueController = TextEditingController();
  final _returnController = TextEditingController();
  
  // Data type controllers
  final _intController = TextEditingController();
  final _stringController = TextEditingController();
  final _boolController = TextEditingController();
  final _floatController = TextEditingController();
  final _doubleController = TextEditingController();
  final _charController = TextEditingController();
  final _voidController = TextEditingController();
  
  // Function controllers
  final _mainController = TextEditingController();
  final _functionController = TextEditingController();
  
  // Keyword controllers
  final _includeController = TextEditingController();
  final _namespaceController = TextEditingController();
  final _usingController = TextEditingController();
  final _structController = TextEditingController();
  final _classController = TextEditingController();
  final _publicController = TextEditingController();
  final _privateController = TextEditingController();
  final _protectedController = TextEditingController();
  
  // Operator controllers
  final _additionController = TextEditingController();
  final _subtractionController = TextEditingController();
  final _multiplicationController = TextEditingController();
  final _divisionController = TextEditingController();
  final _assignmentController = TextEditingController();
  final _equalityController = TextEditingController();
  final _notEqualController = TextEditingController();
  final _lessThanController = TextEditingController();
  final _greaterThanController = TextEditingController();
  final _logicalAndController = TextEditingController();
  final _logicalOrController = TextEditingController();
  final _logicalNotController = TextEditingController();
  
  // Comment controllers
  final _singleCommentController = TextEditingController();
  final _multiStartController = TextEditingController();
  final _multiEndController = TextEditingController();
  
  bool _isEditing = false;
  String? _selectedColor;
  ValidationResult? _validationResult;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _isEditing = widget.language != null;
    _selectedColor = widget.language?.metadata.iconColor ?? '#4CAF50';
    
    if (_isEditing) {
      _loadLanguageData(widget.language!);
    } else {
      _setDefaultValues();
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _disposeControllers();
    super.dispose();
  }
  
  void _disposeControllers() {
    // Dispose all controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _ifController.dispose();
    _elseController.dispose();
    // ... (dispose all other controllers)
  }
  
  void _loadLanguageData(CustomLanguage language) {
    _nameController.text = language.name;
    _descriptionController.text = language.description;
    _authorController.text = language.metadata.author;
    
    // Load control structures
    final cs = language.syntax.controlStructures;
    _ifController.text = cs.ifStatement;
    _elseController.text = cs.elseStatement;
    _elseIfController.text = cs.elseIfStatement;
    _forController.text = cs.forLoop;
    _whileController.text = cs.whileLoop;
    _doWhileController.text = cs.doWhileLoop;
    _switchController.text = cs.switchStatement;
    _caseController.text = cs.caseStatement;
    _defaultController.text = cs.defaultCase;
    _breakController.text = cs.breakStatement;
    _continueController.text = cs.continueStatement;
    _returnController.text = cs.returnStatement;
    
    // Load data types
    final dt = language.syntax.dataTypes;
    _intController.text = dt.integerType;
    _stringController.text = dt.stringType;
    _boolController.text = dt.booleanType;
    _floatController.text = dt.floatType;
    _doubleController.text = dt.doubleType;
    _charController.text = dt.characterType;
    _voidController.text = dt.voidType;
    
    // Load functions
    final fn = language.syntax.functions;
    _mainController.text = fn.mainFunction;
    _functionController.text = fn.functionDeclaration;
    
    // Load keywords
    final kw = language.syntax.keywords;
    _includeController.text = kw.include;
    _namespaceController.text = kw.namespace;
    _usingController.text = kw.using;
    _structController.text = kw.struct;
    _classController.text = kw.class_;
    _publicController.text = kw.public;
    _privateController.text = kw.private;
    _protectedController.text = kw.protected;
    
    // Load operators
    final ops = language.syntax.operators;
    _additionController.text = ops.addition;
    _subtractionController.text = ops.subtraction;
    _multiplicationController.text = ops.multiplication;
    _divisionController.text = ops.division;
    _assignmentController.text = ops.assignment;
    _equalityController.text = ops.equality;
    _notEqualController.text = ops.notEqual;
    _lessThanController.text = ops.lessThan;
    _greaterThanController.text = ops.greaterThan;
    _logicalAndController.text = ops.logicalAnd;
    _logicalOrController.text = ops.logicalOr;
    _logicalNotController.text = ops.logicalNot;
    
    // Load comments
    final cm = language.syntax.comments;
    _singleCommentController.text = cm.singleLineComment;
    _multiStartController.text = cm.multiLineCommentStart;
    _multiEndController.text = cm.multiLineCommentEnd;
  }
  
  void _setDefaultValues() {
    // Set default English values
    final syntax = LanguageSyntax.defaultEnglish();
    _loadLanguageData(CustomLanguage(
      id: '',
      name: '',
      description: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syntax: syntax,
      metadata: LanguageMetadata.defaultMetadata('User'),
    ));
    
    // Clear the basic info for new language
    _nameController.clear();
    _descriptionController.clear();
    _authorController.text = 'Me';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildControlStructuresTab(),
                _buildDataTypesTab(),
                _buildOperatorsTab(),
                _buildKeywordsTab(),
                _buildPreviewTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSaveFAB(),
    );
  }
  
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Edit Language' : 'Create New Language'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 2,
      actions: [
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.code, color: AppColors.primary),
            onPressed: _testLanguage,
            tooltip: 'Test Language',
          ),
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppColors.primary),
          onPressed: _showHelp,
        ),
      ],
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(icon: Icon(Icons.info), text: 'Basic'),
          Tab(icon: Icon(Icons.code_outlined), text: 'Control'),
          Tab(icon: Icon(Icons.data_object), text: 'Data Types'),
          Tab(icon: Icon(Icons.calculate), text: 'Operators'),
          Tab(icon: Icon(Icons.key), text: 'Keywords'),
          Tab(icon: Icon(Icons.preview), text: 'Preview'),
        ],
      ),
    );
  }
  
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Language Information', Icons.language),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _nameController,
            label: 'Language Name',
            hint: 'e.g., اردو پروگرامنگ, Simple English',
            icon: Icons.title,
            required: true,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Brief description of your programming language',
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _authorController,
            label: 'Author',
            hint: 'Your name',
            icon: Icons.person,
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Visual Settings', Icons.palette),
          const SizedBox(height: 16),
          
          _buildColorPicker(),
          
          const SizedBox(height: 24),
          
          if (_validationResult != null)
            _buildValidationResults(),
        ],
      ),
    );
  }
  
  Widget _buildControlStructuresTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Control Structures', Icons.account_tree),
          const SizedBox(height: 8),
          Text(
            'Define how control flow statements work in your language',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_ifController, 'if', 'if', 'e.g., اگر, यदि, check')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_elseController, 'else', 'else', 'e.g., ورنہ, अन्यथा, otherwise')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_elseIfController, 'else if', 'else if', 'e.g., ورنہ اگر, अन्यथा यदि'),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_forController, 'for', 'for', 'e.g., لوپ, के लिए, repeat')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_whileController, 'while', 'while', 'e.g., جب تک, जब तक')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_doWhileController, 'do', 'do', 'e.g., کرو, करें, start'),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_switchController, 'switch', 'switch', 'e.g., تبدیل, स्विच')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_caseController, 'case', 'case', 'e.g., صورت, केस')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_defaultController, 'default', 'default', 'e.g., بنیادی, डिफ़ॉल्ट'),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_breakController, 'break', 'break', 'e.g., توڑ, तोड़ें, stop')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_continueController, 'continue', 'continue', 'e.g., جاری, जारी, skip')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_returnController, 'return', 'return', 'e.g., واپس, वापसी, give back'),
        ],
      ),
    );
  }
  
  Widget _buildDataTypesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Data Types', Icons.data_object),
          const SizedBox(height: 8),
          Text(
            'Define data type keywords in your language',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_intController, 'int', 'int', 'e.g., عدد, संख्या, number')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_stringController, 'string', 'string', 'e.g., متن, पाठ, text')),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_boolController, 'bool', 'bool', 'e.g., بولین, बूलियन, yes_no')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_floatController, 'float', 'float', 'e.g., اعشاری, दशमलव, decimal')),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_doubleController, 'double', 'double', 'e.g., ڈبل, डबल, big_decimal')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_charController, 'char', 'char', 'e.g., حرف, अक्षर, letter')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_voidController, 'void', 'void', 'e.g., خالی, खाली, nothing'),
        ],
      ),
    );
  }
  
  Widget _buildOperatorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Operators', Icons.calculate),
          const SizedBox(height: 8),
          Text(
            'Define operators for your language (can be symbols or words)',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          Text('Arithmetic Operators', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_additionController, '+', '+', 'e.g., +, plus, جمع')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_subtractionController, '-', '-', 'e.g., -, minus, منہا')),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_multiplicationController, '*', '*', 'e.g., *, times, ضرب')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_divisionController, '/', '/', 'e.g., /, divided_by, تقسیم')),
            ],
          ),
          const SizedBox(height: 16),
          
          Text('Comparison Operators', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_assignmentController, '=', '=', 'e.g., =, equals, برابر')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_equalityController, '==', '==', 'e.g., ==, is_same_as')),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_notEqualController, '!=', '!=', 'e.g., !=, is_not')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_lessThanController, '<', '<', 'e.g., <, is_less_than')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_greaterThanController, '>', '>', 'e.g., >, is_greater_than'),
          const SizedBox(height: 16),
          
          Text('Logical Operators', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_logicalAndController, '&&', '&&', 'e.g., &&, and, اور')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_logicalOrController, '||', '||', 'e.g., ||, or, یا')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_logicalNotController, '!', '!', 'e.g., !, not, نہیں'),
        ],
      ),
    );
  }
  
  Widget _buildKeywordsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Keywords & Functions', Icons.key),
          const SizedBox(height: 16),
          
          Text('Function Keywords', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_mainController, 'main', 'main', 'e.g., بنیادی, मुख्य, start_program')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_functionController, 'function', 'function', 'e.g., فنکشن, फंक्शन, define')),
            ],
          ),
          const SizedBox(height: 16),
          
          Text('Language Keywords', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_includeController, '#include', '#include', 'e.g., #شامل, #शामिल, use_library')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_usingController, 'using', 'using', 'e.g., استعمال, उपयोग, import')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_namespaceController, 'namespace', 'namespace', 'e.g., نام_جگہ, नाम_स्थान, from_group'),
          const SizedBox(height: 16),
          
          Text('Object-Oriented Keywords', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_structController, 'struct', 'struct', 'e.g., ڈھانچہ, संरचना, structure')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_classController, 'class', 'class', 'e.g., کلاس, क्लास, blueprint')),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_publicController, 'public', 'public', 'e.g., عوامی, सार्वजनिक, everyone_can_see')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_privateController, 'private', 'private', 'e.g., نجی, निजी, only_me')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_protectedController, 'protected', 'protected', 'e.g., محفوظ, संरक्षित, family_only'),
          const SizedBox(height: 16),
          
          Text('Comment Syntax', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSyntaxField(_singleCommentController, '//', '//', 'e.g., //, note:, ٹپنی')),
              const SizedBox(width: 12),
              Expanded(child: _buildSyntaxField(_multiStartController, '/*', '/*', 'e.g., /*, begin_note')),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildSyntaxField(_multiEndController, '*/', '*/', 'e.g., */, end_note'),
        ],
      ),
    );
  }
  
  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Language Preview', Icons.preview),
          const SizedBox(height: 8),
          Text(
            'See how your language looks in action',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          _buildExampleCode(),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _validateLanguage,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Validate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyExample,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Example'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          if (_validationResult != null) ...[
            const SizedBox(height: 16),
            _buildValidationResults(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildSyntaxField(TextEditingController controller, String label, String defaultValue, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
  
  Widget _buildColorPicker() {
    const colors = [
      '#4CAF50', '#2196F3', '#FF9800', '#9C27B0',
      '#F44336', '#795548', '#607D8B', '#E91E63',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language Color',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: colors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: AppColors.primary, width: 3) : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildExampleCode() {
    try {
      final tempLanguage = _buildTempLanguage();
      final parser = CustomLanguageParser(tempLanguage);
      final example = parser.generateExample();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Example Program in Your Language:',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              example,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Text(
          'Error generating example: $e',
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }
  }
  
  Widget _buildValidationResults() {
    if (_validationResult == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _validationResult!.isValid ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _validationResult!.isValid ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _validationResult!.isValid ? Icons.check_circle : Icons.error,
                color: _validationResult!.isValid ? Colors.green[700] : Colors.red[700],
              ),
              const SizedBox(width: 8),
              Text(
                _validationResult!.isValid ? 'Language is Valid!' : 'Validation Errors',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _validationResult!.isValid ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          
          if (_validationResult!.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...(_validationResult!.errors.map((error) => Text(
              '• $error',
              style: TextStyle(color: Colors.red[700]),
            ))),
          ],
          
          if (_validationResult!.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Warnings:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[700]),
            ),
            ...(_validationResult!.warnings.map((warning) => Text(
              '• $warning',
              style: TextStyle(color: Colors.orange[700]),
            ))),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSaveFAB() {
    return FloatingActionButton.extended(
      onPressed: _saveLanguage,
      backgroundColor: Colors.green,
      icon: const Icon(Icons.save, color: Colors.white),
      label: Text(
        _isEditing ? 'Update' : 'Create',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
  
  void _validateLanguage() {
    try {
      final language = _buildTempLanguage();
      final result = CustomLanguageService.instance.validateLanguage(language);
      setState(() => _validationResult = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validation error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _copyExample() {
    try {
      final tempLanguage = _buildTempLanguage();
      final parser = CustomLanguageParser(tempLanguage);
      final example = parser.generateExample();
      Clipboard.setData(ClipboardData(text: example));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Example code copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error copying example: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _testLanguage() {
    // TODO: Navigate to test screen with this language
  }
  
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.help, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Designing Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Creating Your Custom Language:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Fill in basic information (name, description)'),
              Text('2. Define control structures (if, else, for, etc.)'),
              Text('3. Set data types (int, string, bool, etc.)'),
              Text('4. Configure operators (+, -, ==, etc.)'),
              Text('5. Define keywords and functions'),
              Text('6. Preview and validate your language'),
              SizedBox(height: 12),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Use words from your native language'),
              Text('• Keep syntax simple and consistent'),
              Text('• Test with the preview feature'),
              Text('• Avoid conflicting keywords'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  void _saveLanguage() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a language name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final language = _buildTempLanguage();
      final success = await CustomLanguageService.instance.saveLanguage(language);
      
      if (success) {
        Navigator.pop(context, language);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Language updated successfully!' : 'Language created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save language');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving language: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  CustomLanguage _buildTempLanguage() {
    final now = DateTime.now();
    
    return CustomLanguage(
      id: widget.language?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: widget.language?.createdAt ?? now,
      updatedAt: now,
      syntax: LanguageSyntax(
        controlStructures: ControlStructures(
          ifStatement: _ifController.text.trim(),
          elseStatement: _elseController.text.trim(),
          elseIfStatement: _elseIfController.text.trim(),
          forLoop: _forController.text.trim(),
          whileLoop: _whileController.text.trim(),
          doWhileLoop: _doWhileController.text.trim(),
          switchStatement: _switchController.text.trim(),
          caseStatement: _caseController.text.trim(),
          defaultCase: _defaultController.text.trim(),
          breakStatement: _breakController.text.trim(),
          continueStatement: _continueController.text.trim(),
          returnStatement: _returnController.text.trim(),
        ),
        dataTypes: DataTypes(
          integerType: _intController.text.trim(),
          stringType: _stringController.text.trim(),
          booleanType: _boolController.text.trim(),
          floatType: _floatController.text.trim(),
          doubleType: _doubleController.text.trim(),
          characterType: _charController.text.trim(),
          voidType: _voidController.text.trim(),
        ),
        operators: Operators(
          addition: _additionController.text.trim(),
          subtraction: _subtractionController.text.trim(),
          multiplication: _multiplicationController.text.trim(),
          division: _divisionController.text.trim(),
          modulo: '%',
          assignment: _assignmentController.text.trim(),
          equality: _equalityController.text.trim(),
          notEqual: _notEqualController.text.trim(),
          lessThan: _lessThanController.text.trim(),
          greaterThan: _greaterThanController.text.trim(),
          lessThanOrEqual: '<=',
          greaterThanOrEqual: '>=',
          logicalAnd: _logicalAndController.text.trim(),
          logicalOr: _logicalOrController.text.trim(),
          logicalNot: _logicalNotController.text.trim(),
        ),
        functions: Functions(
          mainFunction: _mainController.text.trim(),
          functionDeclaration: _functionController.text.trim(),
          parameters: '()',
          returnType: ':',
        ),
        comments: Comments(
          singleLineComment: _singleCommentController.text.trim(),
          multiLineCommentStart: _multiStartController.text.trim(),
          multiLineCommentEnd: _multiEndController.text.trim(),
        ),
        keywords: Keywords(
          include: _includeController.text.trim(),
          namespace: _namespaceController.text.trim(),
          using: _usingController.text.trim(),
          struct: _structController.text.trim(),
          class_: _classController.text.trim(),
          public: _publicController.text.trim(),
          private: _privateController.text.trim(),
          protected: _protectedController.text.trim(),
        ),
      ),
      metadata: LanguageMetadata(
        author: _authorController.text.trim(),
        version: widget.language?.metadata.version ?? '1.0.0',
        tags: widget.language?.metadata.tags ?? [],
        iconColor: _selectedColor,
        isPublic: widget.language?.metadata.isPublic ?? false,
        usageCount: widget.language?.metadata.usageCount ?? 0,
      ),
    );
  }
}