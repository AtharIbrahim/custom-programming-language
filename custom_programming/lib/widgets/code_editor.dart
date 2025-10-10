// widgets/code_editor.dart
import 'package:custom_programming/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/local_storage_service.dart';

class CodeEditorWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? filename;
  final VoidCallback? onChanged;
  
  const CodeEditorWidget({
    super.key,
    required this.controller,
    this.filename,
    this.onChanged,
  });

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  double _fontSize = 14.0;
  bool _showLineNumbers = true;
  bool _wordWrap = true;
  EditorSettings? _settings;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    widget.controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    try {
      final settings = await LocalStorageService.instance.loadEditorSettings();
      setState(() {
        _settings = settings;
        _fontSize = settings.fontSize;
        _showLineNumbers = settings.lineNumbers;
        _wordWrap = settings.wordWrap;
      });
    } catch (e) {
      debugPrint('Error loading editor settings: $e');
    }
  }
  
  Future<void> _saveSettings() async {
    if (_settings != null) {
      final newSettings = EditorSettings(
        fontSize: _fontSize,
        theme: _settings!.theme,
        lineNumbers: _showLineNumbers,
        wordWrap: _wordWrap,
        tabSize: _settings!.tabSize,
      );
      await LocalStorageService.instance.saveEditorSettings(newSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Editor Header
          _buildEditorHeader(),
          // Code Editor with Line Numbers
          Expanded(
            child: Row(
              children: [
                // Line Numbers
                if (_showLineNumbers) _buildLineNumbers(),
                // Code Editor
                Expanded(child: _buildCodeEditor()),
              ],
            ),
          ),
          // Editor Footer
          _buildEditorFooter(),
        ],
      ),
    );
  }
  
  Widget _buildEditorHeader() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.code, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.filename ?? 'untitled.cpp',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Editor Controls
          IconButton(
            icon: Icon(
              _showLineNumbers ? Icons.format_list_numbered : Icons.format_list_numbered_rtl,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _showLineNumbers = !_showLineNumbers;
              });
              _saveSettings();
            },
            tooltip: 'Toggle Line Numbers',
          ),
          // IconButton(
          //   icon: Icon(
          //     _wordWrap ? Icons.wrap_text : Icons.notes,
          //     color: Colors.white,
          //     size: 18,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _wordWrap = !_wordWrap;
          //     });
          //     _saveSettings();
          //   },
          //   tooltip: 'Toggle Word Wrap',
          // ),
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
            onPressed: () => _changeFontSize(1),
            tooltip: 'Increase Font Size',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white, size: 18),
            onPressed: () => _changeFontSize(-1),
            tooltip: 'Decrease Font Size',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
            onSelected: _handleEditorMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'paste',
                child: Row(
                  children: [
                    Icon(Icons.content_paste, size: 18),
                    SizedBox(width: 8),
                    Text('Paste'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'select_all',
                child: Row(
                  children: [
                    Icon(Icons.select_all, size: 18),
                    SizedBox(width: 8),
                    Text('Select All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'format',
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 18),
                    SizedBox(width: 8),
                    Text('Auto Format'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLineNumbers() {
    final lineCount = widget.controller.text.split('\\n').length;
    
    return Container(
      width: 50,
      color: const Color(0xFF2A2A2A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: lineCount,
              itemBuilder: (context, index) {
                return Container(
                  height: _fontSize * 1.5,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      color: Colors.grey.shade500,
                      fontSize: _fontSize - 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCodeEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyPress,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: null,
          expands: true,
          scrollController: _scrollController,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            color: Colors.white,
            fontSize: _fontSize,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter your C++ code here...',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
  
  Widget _buildEditorFooter() {
    final text = widget.controller.text;
    final lines = text.split('\\n').length;
    final chars = text.length;
    final words = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\\s+')).length;
    
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Text(
            'Lines: $lines',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(width: 16),
          Text(
            'Words: $words',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(width: 16),
          Text(
            'Characters: $chars',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Spacer(),
          Text(
            'Font: ${_fontSize.toInt()}px',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  void _changeFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(10.0, 24.0);
    });
    _saveSettings();
  }
  
  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Handle Tab key for indentation
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        final selection = widget.controller.selection;
        if (selection.isValid) {
          final text = widget.controller.text;
          final newText = text.replaceRange(
            selection.start,
            selection.end,
            '    ', // 4 spaces for tab
          );
          widget.controller.text = newText;
          widget.controller.selection = TextSelection.collapsed(
            offset: selection.start + 4,
          );
        }
      }
      
      // Handle Ctrl+A (Select All)
      if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyA) {
        widget.controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.controller.text.length,
        );
      }
      
      // Handle auto-indentation on Enter
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleAutoIndent();
      }
    }
  }
  
  void _handleAutoIndent() {
    final selection = widget.controller.selection;
    if (selection.isValid) {
      final text = widget.controller.text;
      final beforeCursor = text.substring(0, selection.start);
      final lines = beforeCursor.split('\\n');
      
      if (lines.isNotEmpty) {
        final lastLine = lines.last;
        final indentation = RegExp(r'^\\s*').firstMatch(lastLine)?.group(0) ?? '';
        
        // Add extra indentation after opening braces
        String extraIndent = '';
        if (lastLine.trimRight().endsWith('{')) {
          extraIndent = '    ';
        }
        
        final newText = text.replaceRange(
          selection.start,
          selection.end,
          '\\n$indentation$extraIndent',
        );
        
        final newOffset = selection.start + 1 + indentation.length + extraIndent.length;
        
        widget.controller.text = newText;
        widget.controller.selection = TextSelection.collapsed(offset: newOffset);
      }
    }
  }
  
  Future<void> _handleEditorMenuAction(String action) async {
    switch (action) {
      case 'paste':
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (clipboardData?.text != null) {
          final selection = widget.controller.selection;
          final newText = widget.controller.text.replaceRange(
            selection.start,
            selection.end,
            clipboardData!.text!,
          );
          widget.controller.text = newText;
          widget.controller.selection = TextSelection.collapsed(
            offset: selection.start + clipboardData.text!.length,
          );
        }
        break;
        
      case 'select_all':
        widget.controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.controller.text.length,
        );
        break;
        
      case 'format':
        _autoFormatCode();
        break;
    }
  }
  
  void _autoFormatCode() {
    // Basic C++ code formatting
    final lines = widget.controller.text.split('\\n');
    final formattedLines = <String>[];
    int indentLevel = 0;
    
    for (String line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.isEmpty) {
        formattedLines.add('');
        continue;
      }
      
      // Decrease indent for closing braces
      if (trimmedLine.startsWith('}')) {
        indentLevel = (indentLevel - 1).clamp(0, 20);
      }
      
      // Add indentation
      final indentation = '    ' * indentLevel;
      formattedLines.add('$indentation$trimmedLine');
      
      // Increase indent for opening braces
      if (trimmedLine.endsWith('{')) {
        indentLevel++;
      }
    }
    
    widget.controller.text = formattedLines.join('\\n');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Code formatted'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}