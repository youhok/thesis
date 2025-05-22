import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sankaestay/composables/useDocumetn.dart';
import 'dart:io';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Date_Picker.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Image_Upload.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- important

class AddTenantsScreen extends StatefulWidget {
  @override
  State<AddTenantsScreen> createState() => _AddTenantsScreenState();
}

class _AddTenantsScreenState extends State<AddTenantsScreen> {
  FirestoreService firestoreService = FirestoreService('tenants');
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController telegramPhoneNumberController =
      TextEditingController();

  var selectedRoom = Rx<String?>(null);
  var selectedProperty = Rx<String?>(null);
  var gender = Rx<String>('male');
  var dateOfBirth = Rx<DateTime?>(null);
  var moveInDate = Rx<DateTime?>(null);
  File? profileImage;
  File? IDCardImage;

  var roomOptions = <String>[].obs;
  var roomIDs = <String>[].obs;
  var propertyOptions = <String>[].obs;
  var propertyIDs = <String>[].obs;

  @override
  void initState() {
    super.initState();
    loadRooms();
    loadProperties();
  }

  Future<String> uploadFile(File file, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        IDCardImage = File(pickedFile.path);
      });
    }
  }

  void loadProperties() async {
    try {
      FirestoreService firestoreService = FirestoreService('properties');
      var snapshot = await firestoreService.getWhere('status', true);

      propertyOptions.value =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      propertyIDs.value = snapshot.docs.map((doc) => doc.id).toList();

      if (propertyOptions.isNotEmpty) {
        selectedProperty.value = propertyOptions[0];
      }
    } catch (e) {
      print('Error fetching available properties: $e');
    }
  }

  void loadRooms() async {
    try {
      FirestoreService roomsService = FirestoreService('rooms');
      var selectedPropertyIndex =
          propertyOptions.indexOf(selectedProperty.value!);
      var snapshot = await roomsService.collectionRef
          .where(
            'propertyID',
            isEqualTo: propertyIDs[selectedPropertyIndex],
          )
          .where('isAvailable', isEqualTo: true)
          .get();
      roomOptions.value = snapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();
      roomIDs.value = snapshot.docs.map((doc) => doc.id).toList();
      setState(() {});
    } catch (e) {
      print('Error fetching available rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "add_tenant.add_tenant".tr,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
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
                            Obx(() {
                              return CustomDropdownField(
                                label: "add_tenant.assign_to_property".tr,
                                options: propertyOptions,
                                selectedValue: selectedProperty.value,
                                onChanged: (value) {
                                  selectedProperty.value = value;
                                  loadRooms();
                                },
                              );
                            }),
                            const SizedBox(height: 10),
                            Obx(() {
                              return CustomDropdownField(
                                label: "add_tenant.assign_to_room".tr,
                                options: roomOptions,
                                selectedValue: selectedRoom.value,
                                onChanged: (value) =>
                                    selectedRoom.value = value,
                              );
                            }),
                            const SizedBox(height: 10),
                            CustomImageUpload(
                              imageFile: profileImage,
                              onImageChanged: (newImage) {
                                setState(() {
                                  profileImage = newImage;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: fullNameController,
                              label: "add_tenant.full_name".tr,
                              hintText:
                                  "add_tenant.placeholders.enter_full_name".tr,
                            ),
                            const SizedBox(height: 10),
                            Obx(() {
                              return CustomDropdownField(
                                label: "add_tenant.gender".tr,
                                options: ["male", "female"],
                                selectedValue: gender.value,
                                onChanged: (value) => gender.value = value!,
                                itemLabelBuilder: (value) =>
                                    "add_tenant.labels.$value".tr,
                              );
                            }),
                            const SizedBox(height: 10),
                            Obx(() {
                              return CustomDatePicker(
                                label: "add_tenant.date_of_birth".tr,
                                selectedDate: dateOfBirth.value,
                                onDateSelected: (date) =>
                                    dateOfBirth.value = date,
                              );
                            }),
                            const SizedBox(height: 10),
                            CustomTextField(
                              label: "add_tenant.profession".tr,
                              controller: professionController,
                              hintText:
                                  "add_tenant.placeholders.enter_profession".tr,
                            ),
                            const SizedBox(height: 10),
                            Obx(() {
                              return CustomDatePicker(
                                label: "add_tenant.move_in_date".tr,
                                selectedDate: moveInDate.value,
                                onDateSelected: (date) =>
                                    moveInDate.value = date,
                              );
                            }),
                            const SizedBox(height: 10),
                            CustomTextField(
                              label: "add_tenant.address".tr,
                              controller: addressController,
                              hintText:
                                  "add_tenant.placeholders.enter_address".tr,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              label: "add_tenant.phone_number".tr,
                              controller: phoneNumberController,
                              hintText:
                                  "add_tenant.placeholders.enter_phone_number"
                                      .tr,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              label: "add_tenant.telegram_phone_number".tr,
                              controller: telegramPhoneNumberController,
                              hintText:
                                  "add_tenant.placeholders.enter_telegram_contact"
                                      .tr,
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "add_tenant.id_card".tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 220,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                  image: IDCardImage != null
                                      ? DecorationImage(
                                          image: FileImage(IDCardImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: IDCardImage == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.badge,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Custombutton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    selectedRoom.value != null) {
                                  String? profileImageUrl;

                                  if (profileImage != null) {
                                    final storageRef = FirebaseStorage.instance
                                        .ref()
                                        .child(
                                            'profiles/${DateTime.now().millisecondsSinceEpoch}.jpg');
                                    await storageRef.putFile(profileImage!);
                                    profileImageUrl =
                                        await storageRef.getDownloadURL();
                                  }
                                  FirestoreService('rooms').updateDocument(
                                    roomIDs[roomOptions.indexOf(selectedRoom.value!)],
                                    {'status': true, 'isAvailable': false},
                                  );

                                  await firestoreService.addDocument({
                                    'tenantID': FirestoreService('tenants')
                                        .collectionRef
                                        .doc()
                                        .id,
                                    'name': fullNameController.text,
                                    'gender': gender.value,
                                    'dob':
                                        dateOfBirth.value?.toIso8601String(),
                                    'address': addressController.text,
                                    'profession': professionController.text,
                                    'phoneNumber': phoneNumberController.text,
                                    'telegramUsername':
                                        telegramPhoneNumberController.text,
                                    'moveInDate':
                                        moveInDate.value?.toIso8601String(),
                                    'moveOutDate': null,
                                    'rentDurationtype': 'monthly',
                                    'roomID': roomIDs[roomOptions
                                        .indexOf(selectedRoom.value!)],
                                    'idCardImage': IDCardImage != null
                                        ? await uploadFile(
                                            IDCardImage!,
                                            'tenants/${DateTime.now().millisecondsSinceEpoch}_id_card.jpg',
                                          )
                                        : null,
                                    'profileImage': profileImageUrl,
                                    'status': true,
                                    'isMoveOut': false,
                                    'createdAt': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                    'updatedAt':DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                  });
                                  Get.snackbar(
                                      'Success', 'Tenant added successfully');
                                  Navigator.pop(context);
                                }
                              },
                              text: "add_tenant.submit".tr,
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
