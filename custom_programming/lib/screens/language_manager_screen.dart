// lib/screens/language_manager_screen.dart
import 'package:custom_programming/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/custom_language.dart';
import '../services/custom_language_service.dart';
import 'language_designer_screen.dart';

class LanguageManagerScreen extends StatefulWidget {
  const LanguageManagerScreen({Key? key}) : super(key: key);

  @override
  State<LanguageManagerScreen> createState() => _LanguageManagerScreenState();
}

class _LanguageManagerScreenState extends State<LanguageManagerScreen> {
  List<CustomLanguage> _languages = [];
  String? _activeLanguageId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    setState(() => _isLoading = true);
    
    try {
      await CustomLanguageService.instance.initialize();
      final languages = CustomLanguageService.instance.languages;
      final activeLanguage = CustomLanguageService.instance.activeLanguage;
      
      setState(() {
        _languages = languages;
        _activeLanguageId = activeLanguage?.id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load languages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('My Languages'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 2,
      actions: [
        PopupMenuButton<String>(
          color: Colors.white,
          icon: const Icon(Icons.more_vert, color: AppColors.primary),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'samples',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Add Sample Languages'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.file_upload, size: 20),
                  SizedBox(width: 8),
                  Text('Import Language'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Clear All Languages', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadLanguages,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length + 1, // +1 for Standard C++ option
        itemBuilder: (context, index) {
          if (index == 0) {
            // Standard C++ option
            return _buildStandardCppCard();
          }
          
          final language = _languages[index - 1];
          return _buildLanguageCard(language);
        },
      ),
    );
  }

  Widget _buildStandardCppCard() {
    final isActive = CustomLanguageService.instance.isStandardCppMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isActive ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            width: isActive ? 3 : 1,
          ),
        ),
        child: Container(
          decoration: isActive ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ) : null,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.code,
                color: Colors.white,
                size: 28,
              ),
            ),
            title: Row(
              children: [
                Text(
                  'Standard C++',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isActive ? Colors.blue : null,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Use standard C++ syntax without custom language features',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.language, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Built-in • Always available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: isActive 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            onTap: () async {
              if (!isActive) {
                await CustomLanguageService.instance.activateStandardCpp();
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('Switched to Standard C++ mode'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Still show Standard C++ option
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildStandardCppCard(),
        ),
        
        // Then show empty state for custom languages
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.language_outlined,
                  size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Custom Languages Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first programming language\nor add sample languages to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _createNewLanguage,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Language'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _addSampleLanguages,
                    icon: const Icon(Icons.download),
                    label: const Text('Add Samples'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        )
      ],
    );
  }

  Widget _buildLanguageCard(CustomLanguage language) {
    final isActive = _activeLanguageId == language.id;
    final color = language.metadata.iconColor != null
        ? Color(int.parse(language.metadata.iconColor!.replaceFirst('#', '0xFF')))
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _setActiveLanguage(language),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Language icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.code,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Language info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                language.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          language.description.isEmpty
                              ? 'No description'
                              : language.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // More options
                  PopupMenuButton<String>(
                    color: Colors.white,
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) => _handleLanguageAction(value, language),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.file_download, size: 20),
                            SizedBox(width: 8),
                            Text('Export'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Language stats
              Row(
                children: [
                  _buildStatChip(Icons.person, language.metadata.author, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatChip(Icons.tag, language.metadata.version, Colors.green),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.access_time,
                    _formatDate(language.updatedAt),
                    Colors.orange,
                  ),
                ],
              ),
              
              // Language tags
              if (language.metadata.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: language.metadata.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              // Sample syntax preview
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '${language.syntax.controlStructures.ifStatement} (condition) { ... } ${language.syntax.controlStructures.elseStatement} { ... }',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _createNewLanguage,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('New Language', style: TextStyle(color: Colors.white)),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    if (difference < 30) return '${(difference / 7).floor()}w ago';
    return '${(difference / 30).floor()}m ago';
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'samples':
        await _addSampleLanguages();
        break;
      case 'import':
        await _importLanguage();
        break;
      case 'clear':
        await _clearAllLanguages();
        break;
    }
  }

  void _handleLanguageAction(String action, CustomLanguage language) async {
    switch (action) {
      case 'edit':
        await _editLanguage(language);
        break;
      case 'duplicate':
        await _duplicateLanguage(language);
        break;
      case 'export':
        await _exportLanguage(language);
        break;
      case 'delete':
        await _deleteLanguage(language);
        break;
    }
  }

  Future<void> _createNewLanguage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageDesignerScreen(),
      ),
    );
    
    if (result != null) {
      await _loadLanguages();
    }
  }

  Future<void> _editLanguage(CustomLanguage language) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageDesignerScreen(language: language),
      ),
    );
    
    if (result != null) {
      await _loadLanguages();
    }
  }

  Future<void> _duplicateLanguage(CustomLanguage language) async {
    try {
      final duplicated = language.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${language.name} (Copy)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await CustomLanguageService.instance.saveLanguage(duplicated);
      await _loadLanguages();
      
      _showSuccess('Language duplicated successfully!');
    } catch (e) {
      _showError('Failed to duplicate language: $e');
    }
  }

  Future<void> _exportLanguage(CustomLanguage language) async {
    try {
      final jsonString = CustomLanguageService.instance.exportLanguage(language.id);
      await Clipboard.setData(ClipboardData(text: jsonString));
      
      _showSuccess('Language exported to clipboard!');
    } catch (e) {
      _showError('Failed to export language: $e');
    }
  }

  Future<void> _deleteLanguage(CustomLanguage language) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Language'),
        content: Text('Are you sure you want to delete "${language.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await CustomLanguageService.instance.deleteLanguage(language.id);
        await _loadLanguages();
        _showSuccess('Language deleted successfully!');
      } catch (e) {
        _showError('Failed to delete language: $e');
      }
    }
  }

  Future<void> _setActiveLanguage(CustomLanguage language) async {
    try {
      final isCurrentlyActive = _activeLanguageId == language.id;
      
      if (isCurrentlyActive) {
        // Deactivate current language
        await CustomLanguageService.instance.setActiveLanguage(null);
        setState(() => _activeLanguageId = null);
        _showSuccess('Language deactivated');
      } else {
        // Activate new language
        await CustomLanguageService.instance.setActiveLanguage(language.id);
        setState(() => _activeLanguageId = language.id);
        _showSuccess('${language.name} is now active!');
      }
    } catch (e) {
      _showError('Failed to change active language: $e');
    }
  }

  Future<void> _addSampleLanguages() async {
    try {
      await CustomLanguageService.instance.createSampleLanguages();
      await _loadLanguages();
      _showSuccess('Sample languages added successfully!');
    } catch (e) {
      _showError('Failed to add sample languages: $e');
    }
  }

  Future<void> _importLanguage() async {
    final controller = TextEditingController();
    
    final jsonString = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste the exported language JSON:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste JSON here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    
    if (jsonString != null && jsonString.trim().isNotEmpty) {
      try {
        final success = await CustomLanguageService.instance.importLanguage(jsonString);
        if (success) {
          await _loadLanguages();
          _showSuccess('Language imported successfully!');
        } else {
          _showError('Failed to import language. Please check the JSON format.');
        }
      } catch (e) {
        _showError('Failed to import language: $e');
      }
    }
  }

  Future<void> _clearAllLanguages() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Languages'),
        content: const Text('Are you sure you want to delete all custom languages? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await CustomLanguageService.instance.clearAll();
        await _loadLanguages();
        _showSuccess('All languages cleared successfully!');
      } catch (e) {
        _showError('Failed to clear languages: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}