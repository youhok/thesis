// lib/screens/add_booking.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sankaestay/composables/useDocumetn.dart';
import 'package:sankaestay/composables/useStorage.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Date_Picker.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:toastification/toastification.dart';

class AddBooking extends StatefulWidget {
  const AddBooking({super.key});

  @override
  State<AddBooking> createState() => _AddBookingState();
}

class _AddBookingState extends State<AddBooking> {
  final _formKey = GlobalKey<FormState>();
  final firestoreService = FirestoreService('bookings');
  final storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final professionController = TextEditingController();

  var selectedRoom = Rx<String?>(null);
  var rentDurationType = Rx<String?>('Month');
  var status = Rx<String?>('booking.pending'.tr);
  var moveIn = false.obs;
  final moveInDate = Rx<DateTime?>(null);
  final idCardUrl = Rx<String?>(null);
  var roomOptions = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  void fetchRooms() {
    getCollectionQuery(
      collectionName: 'rooms',
      callback: (List<Map<String, dynamic>> data) {
        roomOptions.value = data
            .where((room) =>
                room['name'] != null &&
                room['name'].toString().trim().isNotEmpty &&
                room['isBooked'] != true)
            .map((room) => {
                  'id': room['id'],
                  'name': room['name'],
                })
            .toList();
      },
    );
  }

  Future<void> pickAndUploadIdCardImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileName =
        'idCards/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

    try {
      final url = await storageService.uploadImage(fileName, file);
      idCardUrl.value = url;
      toastification.show(
        context: context,
        title: const Text("Success"),
        description: const Text("ID Card uploaded successfully"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("Failed to upload ID Card"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
      print('Image upload error: $e');
    }
  }

  Future<void> submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedRoom.value == null || moveInDate.value == null) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("Please select a room and move-in date"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
      return;
    }
    if (idCardUrl.value == null) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("Please upload your ID card image"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
      return;
    }

    context.loaderOverlay.show();
    final formattedMoveInDate =
        DateFormat('yyyy-MM-dd').format(moveInDate.value!);
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    final bookingData = {
      'roomId': selectedRoom.value,
      'name': nameController.text.trim(),
      'phoneNumbers': phoneController.text.trim(),
      'profession': professionController.text.trim(),
      'moveInDate': formattedMoveInDate,
      'rentDurationType': rentDurationType.value,
      'status': status.value,
      'moveIn': moveIn.value,
      'idCardImage': idCardUrl.value,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': userId,
    };

    try {
      // Mark room as booked
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(selectedRoom.value)
          .update({'isBooked': true});

      // Add booking and get its ID back
      final bookingID = await firestoreService.addDocumentId(bookingData);
      if (bookingID == null) throw 'Failed to create booking';
      // Create tenant document if moveIn is true
      if (moveIn.value) {
        final tenantData = {
          'bookingID': bookingID,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': userId,
          'idCardImage': idCardUrl.value,
          'isActive': false, // your example has true here
          'moveInDate': formattedMoveInDate,
          'moveOutDate': null,
          'movedOut': false,
          'name': nameController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'profession': professionController.text.trim(),
          'rentDurationType': rentDurationType.value?.toLowerCase() == 'month'
              ? 'months'
              : 'years',
          'roomID': selectedRoom.value,
          'status': false, // boolean true like your example
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': null,
        };
        await FirebaseFirestore.instance.collection('tenants').add(tenantData);
      }

      toastification.show(
        context: context,
        title: const Text("Success"),
        description: const Text("Booking added successfully"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );

      // Reset form
      nameController.clear();
      phoneController.clear();
      professionController.clear();
      selectedRoom.value = null;
      rentDurationType.value = 'Month';
      status.value = 'booking.pending'.tr;
      moveIn.value = false;
      moveInDate.value = null;
      idCardUrl.value = null;
      fetchRooms(); // refresh available rooms
    } catch (e) {
      print('Booking error: $e');
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("Failed to add booking"),
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
      title: "booking.title".tr,
      child: Stack(
        children: [
          Column(children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => CustomDropdownField(
                                label: "booking.select_rooms".tr,
                                options: roomOptions
                                    .map((r) => r['name'] as String)
                                    .toList(),
                                selectedValue: roomOptions.firstWhereOrNull(
                                    (r) =>
                                        r['id'] == selectedRoom.value)?['name'],
                                onChanged: (v) {
                                  final sel = roomOptions
                                      .firstWhereOrNull((r) => r['name'] == v);
                                  if (sel != null)
                                    selectedRoom.value = sel['id'];
                                },
                                menuMaxHeight: 200,
                              )),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: nameController,
                            label: "booking.name".tr,
                            hintText: "booking.name".tr,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: phoneController,
                            label: "booking.phone_number".tr,
                            hintText: "booking.placeholder".tr,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: professionController,
                            label: "booking.profession".tr,
                            hintText: "booking.profession".tr,
                          ),
                          const SizedBox(height: 10),
                          Text("booking.id_card".tr,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: pickAndUploadIdCardImage,
                            child: Obx(() => Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: idCardUrl.value != null
                                      ? Image.network(idCardUrl.value!,
                                          fit: BoxFit.cover)
                                      : const Center(
                                          child: Icon(Icons.badge,
                                              size: 50, color: Colors.grey),
                                        ),
                                )),
                          ),
                          const SizedBox(height: 20),
                          CustomDatePicker(
                            label: "booking.move_in".tr,
                            selectedDate: moveInDate.value,
                            onDateSelected: (d) => moveInDate.value = d,
                          ),
                          const SizedBox(height: 10),
                          Obx(() => CustomDropdownField(
                                label: "booking.rent_duration".tr,
                                options: ['Month', 'Year'],
                                selectedValue: rentDurationType.value,
                                onChanged: (v) => rentDurationType.value = v,
                              )),
                          const SizedBox(height: 10),
                          Obx(() => CustomDropdownField(
                                label: "booking.status".tr,
                                options: [
                                  "booking.pending".tr,
                                  "booking.approved".tr,
                                  "booking.rejected".tr,
                                ],
                                selectedValue: status.value,
                                onChanged: (v) => status.value = v,
                              )),
                          const SizedBox(height: 10),
                          Obx(() => CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text("booking.move_in".tr),
                                value: moveIn.value,
                                activeColor: AppColors.primaryBlue,
                                checkColor: AppColors.white,
                                onChanged: (v) => moveIn.value = v ?? false,
                              )),
                          const SizedBox(height: 20),
                          Custombutton(
                            onPressed: submitBooking,
                            text: "booking.add_booking".tr,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
