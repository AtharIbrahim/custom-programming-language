// lib/widgets/file_manager_dialog.dart
import 'package:custom_programming/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/local_storage_service.dart';

class SaveFileDialog extends StatefulWidget {
  final String code;
  final String? initialFilename;

  const SaveFileDialog({
    Key? key,
    required this.code,
    this.initialFilename,
  }) : super(key: key);

  @override
  State<SaveFileDialog> createState() => _SaveFileDialogState();
}

class _SaveFileDialogState extends State<SaveFileDialog> {
  late TextEditingController _filenameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _filenameController = TextEditingController(
      text: widget.initialFilename ?? 'main.cpp',
    );
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _filenameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveFile() async {
    if (_filenameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a filename';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String filename = _filenameController.text.trim();
      
      // Add .cpp extension if not present
      if (!filename.toLowerCase().endsWith('.cpp') && 
          !filename.toLowerCase().endsWith('.c') &&
          !filename.toLowerCase().endsWith('.h')) {
        filename += '.cpp';
      }

      final success = await LocalStorageService.instance.saveCodeFile(
        filename,
        widget.code,
        description: _descriptionController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(filename);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ File saved: $filename'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to save file';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.save, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Save C++ File'),
        ],
      ),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _filenameController,
              decoration: const InputDecoration(
                labelText: 'Filename',
                hintText: 'main.cpp',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                suffixText: '.cpp',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief description of the program',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 File Information:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Size: ${widget.code.length} characters'),
                  Text('Lines: ${widget.code.split('\\n').length}'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.primary),),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFile,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save', style: TextStyle(color: AppColors.primary),),
        ),
      ],
    );
  }
}

class LoadFileDialog extends StatefulWidget {
  const LoadFileDialog({Key? key}) : super(key: key);

  @override
  State<LoadFileDialog> createState() => _LoadFileDialogState();
}

class _LoadFileDialogState extends State<LoadFileDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CodeFile> _allFiles = [];
  List<String> _recentFiles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await LocalStorageService.instance.getAllCodeFiles();
      final recent = await LocalStorageService.instance.getRecentFiles();

      setState(() {
        _allFiles = files;
        _recentFiles = recent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<CodeFile> get _filteredFiles {
    if (_searchQuery.isEmpty) return _allFiles;
    
    return _allFiles.where((file) {
      return file.filename.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             file.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _loadFile(String filename) async {
    try {
      final codeFile = await LocalStorageService.instance.loadCodeFile(filename);
      if (codeFile != null && mounted) {
        Navigator.of(context).pop(codeFile);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found or corrupted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteFile(String filename) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "$filename"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await LocalStorageService.instance.deleteCodeFile(filename);
      if (success) {
        _loadFiles(); // Reload files
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Deleted: $filename'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _shareFile(CodeFile file) async {
    try {
      await Share.share(
        file.code,
        subject: file.filename,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFileItem(CodeFile file, {bool isRecent = false}) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.code, color: AppColors.primary),
        ),
        title: Text(
          file.filename,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (file.description.isNotEmpty)
              Text(
                file.description,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                Text(
                  file.formattedSize,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Text(' • ', style: TextStyle(color: Colors.grey)),
                Text(
                  file.formattedDate,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (action) async {
            switch (action) {
              case 'load':
                _loadFile(file.filename);
                break;
              case 'share':
                _shareFile(file);
                break;
              case 'delete':
                _deleteFile(file.filename);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'load',
              child: Row(
                children: [
                  Icon(Icons.folder_open, size: 18),
                  SizedBox(width: 8),
                  Text('Load'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 18),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _loadFile(file.filename),
      ),
    );
  }

  Widget _buildRecentFileItem(String filename) {
    final file = _allFiles.firstWhere(
      (f) => f.filename == filename,
      orElse: () => CodeFile(
        filename: filename,
        code: '',
        description: 'File not found',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        size: 0,
      ),
    );

    if (file.code.isEmpty) {
      return ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.error, color: Colors.white),
        ),
        title: Text(filename),
        subtitle: const Text('File not found', style: TextStyle(color: Colors.red)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteFile(filename),
        ),
      );
    }

    return _buildFileItem(file, isRecent: true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.folder_open, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Load C++ File'),
        ],
      ),
      content: SizedBox(
        
        width: 400,
        height: 500,
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search files...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'All Files'),
                Tab(text: 'Recent'),
              ],
            ),
            
            // Tab content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // All files
                        _filteredFiles.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.description, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('No files found'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredFiles.length,
                                itemBuilder: (context, index) {
                                  return _buildFileItem(_filteredFiles[index]);
                                },
                              ),
                        
                        // Recent files
                        _recentFiles.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('No recent files'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _recentFiles.length,
                                itemBuilder: (context, index) {
                                  return _buildRecentFileItem(_recentFiles[index]);
                                },
                              ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.primary),),
        ),
        if (_allFiles.isNotEmpty)
          TextButton(
            onPressed: _loadFiles,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 18, color: AppColors.primary,),
                SizedBox(width: 4),
                Text('Refresh', style: TextStyle(color: AppColors.primary),),
              ],
            ),
          ),
      ],
    );
  }
}