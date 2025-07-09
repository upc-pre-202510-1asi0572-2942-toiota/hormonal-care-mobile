import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePictureWidget extends StatelessWidget {
  final bool isEditing;
  final VoidCallback toggleEditMode;
  final String? imageUrl;
  final Color borderColor;
  final void Function(File)? onImageSelected;

  ProfilePictureWidget({
    required this.isEditing,
    required this.toggleEditMode,
    this.imageUrl,
    this.borderColor = Colors.white,
    this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null && onImageSelected != null) {
          onImageSelected!(File(pickedFile.path));
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 8,
          ),
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
          child: imageUrl == null || imageUrl!.isEmpty
              ? Icon(Icons.person, size: 50)
              : null,
        ),
      ),
    );
  }
}