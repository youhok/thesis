// lib/screens/AddTenantsScreen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';
import '../../../composables/useStorage.dart';
import 'package:sankaestay/composables/useDocumetn.dart';

import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Date_Picker.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Image_Upload.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:sankaestay/widgets/custom_loader.dart';

class AddTenantsScreen extends StatefulWidget {
  final String? tenantId;
  const AddTenantsScreen({Key? key, this.tenantId}) : super(key: key);

  @override
  State<AddTenantsScreen> createState() => _AddTenantsScreenState();
}

class _AddTenantsScreenState extends State<AddTenantsScreen> {
  final FirestoreService _tenantService = FirestoreService('tenants');
  final FirestoreService _propertyService = FirestoreService('properties');
  final FirestoreService _roomService = FirestoreService('rooms');
  final _formKey = GlobalKey<FormState>();
  final StorageService storageService = StorageService();
  // controllers
  final _nameCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _telegramCtrl = TextEditingController();

  var selectedProperty = Rx<String?>(null);
  var propertyOptions = <String>[].obs;
  var propertyIDs = <String>[].obs;

  var selectedRoom = Rx<String?>(null);
  var roomOptions = <String>[].obs;
  var roomIDs = <String>[].obs;

  var gender = Rx<String?>(null);
  var dateOfBirth = Rx<DateTime?>(null);
  var moveInDate = Rx<DateTime?>(null);

  File? _pickedProfile;
  File? _pickedIdCard;
  String? _existingProfileUrl;
  String? _existingIdCardUrl;

  bool _isLoading = true; // loading flag
  bool get isEdit => widget.tenantId != null;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() => _isLoading = true);
    await _loadProperties();
    if (isEdit) await _loadTenantData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadProperties() async {
    final snap = await _propertyService.getWhere('status', true);
    propertyOptions.value = snap.docs.map((d) => d['name'] as String).toList();
    propertyIDs.value = snap.docs.map((d) => d.id).toList();
  }

  Future<void> _loadRooms() async {
    if (selectedProperty.value == null) {
      roomOptions.clear();
      roomIDs.clear();
      selectedRoom.value = null;
      return;
    }
    final idx = propertyOptions.indexOf(selectedProperty.value!);
    if (idx < 0) return;
    final propId = propertyIDs[idx];
    final snap = await _roomService.collectionRef
        .where('propertyID', isEqualTo: propId)
        .where('isAvailable', isEqualTo: true)
        .get();
    roomOptions.value = snap.docs.map((d) => d['name'] as String).toList();
    roomIDs.value = snap.docs.map((d) => d.id).toList();
  }

  Future<void> _loadTenantData() async {
    final docSnap = await _tenantService.getDocument(widget.tenantId!);
    if (!docSnap.exists) return;
    final data = docSnap.data() as Map<String, dynamic>;
    _nameCtrl.text = data['name'] ?? '';
    _professionCtrl.text = data['profession'] ?? '';
    _addressCtrl.text = data['address'] ?? '';
    _phoneCtrl.text = data['phoneNumber'] ?? '';
    _telegramCtrl.text = data['telegramUsername'] ?? '';
    gender.value = data['gender'];
    if (data['dob'] != null) {
      final dobRaw = data['dob'];
      dateOfBirth.value = dobRaw is Timestamp
          ? dobRaw.toDate()
          : DateTime.parse(dobRaw as String);
    }

    if (data['moveInDate'] != null) {
      final midRaw = data['moveInDate'];
      moveInDate.value = midRaw is Timestamp
          ? midRaw.toDate()
          : DateTime.parse(midRaw as String);
    }

    _existingProfileUrl = data['profileImage'];
    _existingIdCardUrl = data['idCardImage'];
    if (_existingProfileUrl != null)
      _pickedProfile = await _urlToFile(_existingProfileUrl!);
    if (_existingIdCardUrl != null)
      _pickedIdCard = await _urlToFile(_existingIdCardUrl!);

    final roomId = data['roomID'] as String;
    final roomDoc = await _roomService.getDocument(roomId);
    final propId = roomDoc['propertyID'] as String;
    final pIndex = propertyIDs.indexOf(propId);
    if (pIndex >= 0) selectedProperty.value = propertyOptions[pIndex];
    await _loadRooms();
    final rIndex = roomIDs.indexOf(roomId);
    if (rIndex >= 0) {
      selectedRoom.value = roomOptions[rIndex];
      selectedRoom.refresh();
    }
  }

  Future<File> _urlToFile(String url) async {
    final res = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    return file..writeAsBytesSync(res.bodyBytes);
  }

  Future<String?> _uploadIfPicked(File? file, String pathPrefix) async {
    if (file == null) return null;
    final path = '$pathPrefix/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedProperty.value == null) {
      Get.snackbar('Error', 'Select property');
      return;
    }
    if (selectedRoom.value == null) {
      Get.snackbar('Error', 'Select room');
      return;
    }
    if (gender.value == null) {
      Get.snackbar('Error', 'Select gender');
      return;
    }

    context.loaderOverlay.show(); // start loading

    try {
      // Upload new images if picked
      final newProfileUrl = await _uploadIfPicked(_pickedProfile, 'profiles');
      final newIdCardUrl = await _uploadIfPicked(_pickedIdCard, 'id_cards');

      // If new profile image uploaded and old exists, delete old from Firebase Storage
      if (newProfileUrl != null && _existingProfileUrl != null) {
        await storageService.deleteImageByUrl(_existingProfileUrl!);
      }

      // If new id card image uploaded and old exists, delete old from Firebase Storage
      if (newIdCardUrl != null && _existingIdCardUrl != null) {
        await storageService.deleteImageByUrl(_existingIdCardUrl!);
      }

      final data = <String, dynamic>{
        'name': _nameCtrl.text,
        'profession': _professionCtrl.text,
        'address': _addressCtrl.text,
        'phoneNumber': _phoneCtrl.text,
        'telegramUsername': _telegramCtrl.text,
        'gender': gender.value,
        'dob': dateOfBirth.value != null
            ? Timestamp.fromDate(dateOfBirth.value!)
            : null,
        'moveInDate': moveInDate.value != null
            ? Timestamp.fromDate(moveInDate.value!)
            : null,
        'roomID': roomIDs[roomOptions.indexOf(selectedRoom.value!)],
        'profileImage': newProfileUrl ?? _existingProfileUrl,
        'idCardImage': newIdCardUrl ?? _existingIdCardUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (isEdit) {
        await _tenantService.updateDocument(widget.tenantId!, data);
        toastification.show(
          context: context,
          title: const Text("Success"),
          description: const Text("Tenant updated successfully"),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      } else {
        data.addAll({
          'tenantID': _tenantService.collectionRef.doc().id,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
        await _tenantService.addDocument(data);
        await _roomService.updateDocument(
          roomIDs[roomOptions.indexOf(selectedRoom.value!)],
          {'isAvailable': false},
        );

        toastification.show(
          context: context,
          title: const Text("Success"),
          description: const Text("Tenant added successfully"),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("Failed to save tenant data"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } finally {
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: isEdit ? 'Edit Tenant'.tr : 'Add Tenant'.tr,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? CustomLoader()
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => CustomDropdownField(
                            label: 'add_tenant.assign_to_property'.tr,
                            options: propertyOptions,
                            selectedValue: selectedProperty.value,
                            onChanged: (v) async {
                              selectedProperty.value = v;
                              selectedRoom.value = null;
                              await _loadRooms();
                            },
                          )),
                      const SizedBox(height: 10),
                      Obx(() {
                        print('roomOptions inside UI: $roomOptions');
                        print('selectedRoom inside UI: ${selectedRoom.value}');
                        return CustomDropdownField(
                          label: 'add_tenant.assign_to_room'.tr,
                          options: roomOptions,
                          selectedValue: selectedRoom.value,
                          onChanged: (v) {
                            selectedRoom.value = v;
                          },
                        );
                      }),
                      const SizedBox(height: 10),
                      CustomImageUpload(
                        imageFile: _pickedProfile,
                        onImageChanged: (f) =>
                            setState(() => _pickedProfile = f),
                        existingImageUrl: _existingProfileUrl,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _nameCtrl,
                        label: 'add_tenant.full_name'.tr,
                        hintText: 'add_tenant.placeholders.enter_full_name'.tr,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please enter name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Obx(() => CustomDropdownField(
                            label: 'add_tenant.gender'.tr,
                            options: ['male', 'female'],
                            selectedValue: gender.value,
                            onChanged: (v) => gender.value = v,
                            itemLabelBuilder: (v) => 'add_tenant.labels.$v'.tr,
                          )),
                      const SizedBox(height: 10),
                      Obx(() => CustomDatePicker(
                            label: 'add_tenant.date_of_birth'.tr,
                            selectedDate: dateOfBirth.value,
                            onDateSelected: (d) => dateOfBirth.value = d,
                          )),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _professionCtrl,
                        label: 'add_tenant.profession'.tr,
                        hintText: 'add_tenant.placeholders.enter_profession'.tr,
                      ),
                      const SizedBox(height: 10),
                      Obx(() => CustomDatePicker(
                            label: 'add_tenant.move_in_date'.tr,
                            selectedDate: moveInDate.value,
                            onDateSelected: (d) => moveInDate.value = d,
                          )),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _addressCtrl,
                        label: 'add_tenant.address'.tr,
                        hintText: 'add_tenant.placeholders.enter_address'.tr,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _phoneCtrl,
                        label: 'add_tenant.phone_number'.tr,
                        hintText:
                            'add_tenant.placeholders.enter_phone_number'.tr,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _telegramCtrl,
                        label: 'add_tenant.telegram_phone_number'.tr,
                        hintText:
                            'add_tenant.placeholders.enter_telegram_contact'.tr,
                      ),
                      const SizedBox(height: 20),
                      Text('add_tenant.id_card'.tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final p = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (p != null)
                            setState(() => _pickedIdCard = File(p.path));
                        },
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            image: _pickedIdCard != null
                                ? DecorationImage(
                                    image: FileImage(_pickedIdCard!),
                                    fit: BoxFit.cover)
                                : (_existingIdCardUrl != null
                                    ? DecorationImage(
                                        image:
                                            NetworkImage(_existingIdCardUrl!),
                                        fit: BoxFit.cover)
                                    : null),
                          ),
                          child: (_pickedIdCard == null &&
                                  _existingIdCardUrl == null)
                              ? const Center(
                                  child: Icon(Icons.badge,
                                      size: 60, color: Colors.grey))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Custombutton(
                        text: isEdit
                            ? 'edit_tenant.update'.tr
                            : 'add_tenant.add_tenant'.tr,
                        onPressed: _onSubmit,
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
