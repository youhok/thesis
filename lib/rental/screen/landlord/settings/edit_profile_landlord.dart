import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sankaestay/composables/useStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/phone_number_input.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/util/alert/alert.dart';
import 'package:toastification/toastification.dart';

class EditProfileLandlord extends StatefulWidget {
  const EditProfileLandlord({super.key});

  @override
  State<EditProfileLandlord> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileLandlord> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _telegramController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String userId = '';
  String? imageUrl;
  File? imageFile;

  final ImagePicker _picker = ImagePicker();
  final storageService = StorageService();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? 'Unknown User';
    final imgUrl = prefs.getString('userImageUrl') ?? '';
    final telegram = prefs.getString('userTelegram') ?? '';
    final email = prefs.getString('userEmail') ?? '';
    final phone = prefs.getString('userPhoneNumber') ?? '';
    userId = prefs.getString('userId') ?? ''; // Make sure userId is saved
    _nameController.text = name;
    _emailController.text = email;
    _telegramController.text = telegram;
    _phoneController.text = phone;
    imageUrl = imgUrl;
    setState(() {});
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    context.loaderOverlay.show();
    // Show loading
    String? uploadedUrl = imageUrl;

    if (imageFile != null) {
      try {
        // Delete old image if from Firebase
        if (imageUrl != null &&
            imageUrl!.isNotEmpty &&
            imageUrl!.contains('firebasestorage.googleapis.com')) {
          await storageService.deleteImageByUrl(imageUrl!);
        }

        // Upload new image
        uploadedUrl = await storageService.uploadImage(
          'users/$userId/profile.jpg',
          imageFile!,
        );
      } catch (e) {
        Alert.show(
          type: ToastificationType.error,
          title: 'Image Upload Error',
          description: e.toString(),
        );
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text.trim(),
        'telegram': _telegramController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'imageURL': uploadedUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      await prefs.setString('userEmail', _emailController.text.trim());
      await prefs.setString('userImageUrl', uploadedUrl ?? '');
      await prefs.setString('userTelegram', _telegramController.text.trim());
      await prefs.setString('userPhoneNumber', _phoneController.text.trim());

      Alert.show(
        type: ToastificationType.success,
        title: 'Success',
        description: 'Profile updated successfully',
      );
    } catch (e) {
      Alert.show(
        type: ToastificationType.error,
        title: 'Update Failed',
        description: e.toString(),
      );
    } finally {
      context.loaderOverlay.hide(); // Always hide loader
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "edit_profile.title".tr,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGrey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ProfileAvatar(
                                imageFile: imageFile,
                                imageUrl: imageUrl,
                                onEdit: pickImage,
                              ),
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              label: "edit_profile.first_name".tr,
                              hintText:
                                  "edit_profile.placeholders.enter_first_name"
                                      .tr,
                              controller: _nameController,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter name'
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              label: "edit_profile.telegram".tr,
                              hintText:
                                  "edit_profile.placeholders.enter_telegram".tr,
                              controller: _telegramController,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              label: "edit_profile.email".tr,
                              hintText:
                                  "edit_profile.placeholders.enter_email".tr,
                              controller: _emailController,
                              validator: (value) =>
                                  value == null || !value.contains('@')
                                      ? 'Invalid email'
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            PhoneNumberInput(
                              label: "edit_profile.phone_number".tr,
                              controller: _phoneController,
                            ),
                            const SizedBox(height: 20),
                            Custombutton(
                              onPressed: updateProfile,
                              text: "edit_profile.save".tr,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final VoidCallback? onEdit;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (imageFile != null) {
      imageProvider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    } else {
      imageProvider = const AssetImage('images/user.png');
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 55,
            backgroundImage: imageProvider,
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
