import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonus/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sonus/features/profile/presentation/pages/profile_page.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfileSheet({super.key, required this.userProfile});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late TextEditingController _nameController;
  File? _selectedImage;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentName = widget.userProfile['full_name'] as String? ?? '';
    _nameController = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 50, // Compress for base64 storage
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(
            displayName: _nameController.text.trim(),
            avatarFile: _selectedImage,
          );

      if (mounted) {
        context.pop(); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.userProfile['avatar_url'] as String? ?? '';
    final displayName = widget.userProfile['full_name'] as String? ?? 'User';

    return Container(
      padding: EdgeInsets.only(
        top: 24.h,
        left: 24.w,
        right: 24.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chỉnh sửa hồ sơ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),

          // Avatar Selector
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[800]!, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.grey[900],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (avatarUrl.isNotEmpty
                              ? parseAvatarImage(avatarUrl)
                              : null),
                    child: (_selectedImage == null && avatarUrl.isEmpty)
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 40.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Name Input
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Tên hiển thị',
              labelStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Lưu thay đổi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
