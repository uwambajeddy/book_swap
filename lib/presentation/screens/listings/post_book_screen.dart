import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/book_model.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/book_provider.dart';

class PostBookScreen extends StatefulWidget {
  final BookModel? book;

  const PostBookScreen({super.key, this.book});

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _swapForController = TextEditingController();
  BookCondition _selectedCondition = BookCondition.used;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _swapForController.text = widget.book!.swapFor;
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _swapForController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Copy file to app's temporary directory for reliable access
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
        final String newPath = path.join(tempDir.path, fileName);
        
        // Copy the picked image to temp directory
        final File originalFile = File(image.path);
        final File copiedFile = await originalFile.copy(newPath);
        
        // Verify the copied file exists
        if (await copiedFile.exists()) {
          setState(() {
            _imageFile = copiedFile;
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to access the selected image'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (authProvider.currentUserData == null) return;

    print('🔍 Save Book Debug:');
    print('🔍 Is Editing: $isEditing');
    print('🔍 _imageFile: $_imageFile');
    print('🔍 _imageFile path: ${_imageFile?.path}');
    print('🔍 Existing image URL: ${widget.book?.imageUrl}');

    // Validate image file if provided
    File? validImageFile;
    if (_imageFile != null) {
      print('🔍 Checking if image file exists...');
      if (await _imageFile!.exists()) {
        validImageFile = _imageFile;
        print('✅ Image file is valid');
      } else {
        print('❌ Image file does not exist!');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected image file is no longer available. Please select a new image.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } else {
      print('ℹ️ No new image selected (keeping existing image)');
    }

    print('🔍 validImageFile: $validImageFile');

    bool success;
    if (isEditing) {
      print('📝 Updating book...');
      success = await bookProvider.updateBook(
        bookId: widget.book!.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        swapFor: _swapForController.text.trim(),
        condition: _selectedCondition,
        imageFile: validImageFile,
        existingImageUrl: widget.book!.imageUrl,
      );
    } else {
      print('📝 Creating new book...');
      success = await bookProvider.createBook(
        ownerId: authProvider.currentUserData!.id,
        ownerName: authProvider.currentUserData!.fullName,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        swapFor: _swapForController.text.trim(),
        condition: _selectedCondition,
        imageFile: validImageFile,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Book updated successfully!' : 'Book posted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookProvider.errorMessage ?? 'Failed to save book'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editBook : AppStrings.postABook),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mediumGray),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : (isEditing && widget.book!.imageUrl != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildExistingImage(widget.book!.imageUrl!),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: AppColors.darkGray),
                                SizedBox(height: 8),
                                Text('Add Book Cover', style: TextStyle(color: AppColors.darkGray)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: AppStrings.bookTitle,
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.errorBookTitleEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: AppStrings.author,
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.errorAuthorEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _swapForController,
                decoration: const InputDecoration(
                  labelText: AppStrings.swapFor,
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter what you want to swap for';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.condition,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: BookCondition.values.map((condition) {
                  final isSelected = _selectedCondition == condition;
                  return ChoiceChip(
                    label: Text(condition.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCondition = condition;
                        });
                      }
                    },
                    selectedColor: AppColors.primaryYellow,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryDark : AppColors.darkGray,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: bookProvider.isLoading ? null : _saveBook,
                  child: bookProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                          ),
                        )
                      : Text(isEditing ? AppStrings.save : AppStrings.post),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to display existing images from local storage or network
  Widget _buildExistingImage(String imagePath) {
    // Check if it's a local file path (starts with /) or network URL
    final isLocal = imagePath.startsWith('/');
    
    if (isLocal) {
      return Image.file(File(imagePath), fit: BoxFit.cover);
    } else {
      return Image.network(imagePath, fit: BoxFit.cover);
    }
  }
}
