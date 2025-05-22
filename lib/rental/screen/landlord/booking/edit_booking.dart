import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
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

class EditBooking extends StatefulWidget {
  final String bookingId;
  const EditBooking({super.key, required this.bookingId});

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  final _formKey = GlobalKey<FormState>();
  final firestoreService = FirestoreService('bookings');
  final tenantService = FirestoreService('tenants');
  final storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _professionController = TextEditingController();

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
    fetchBookingData();
  }

  void fetchRooms() {
    getCollectionQuery(
      collectionName: 'rooms',
      callback: (List<Map<String, dynamic>> data) {
        roomOptions.value = data
            .where((room) =>
                room['name'] != null &&
                room['name'].toString().trim().isNotEmpty)
            .map((room) => {
                  'id': room['id'],
                  'name': room['name'],
                })
            .toList();
      },
    );
  }

  void fetchBookingData() async {
    context.loaderOverlay.show();
    try {
      await getCollectionQuery(
        collectionName: 'bookings',
        docID: widget.bookingId,
        callback: (Map<String, dynamic> bookingDoc) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _nameController.text = bookingDoc['name'] ?? '';
            _phoneController.text = bookingDoc['phoneNumbers'] ?? '';
            _professionController.text = bookingDoc['profession'] ?? '';
            selectedRoom.value = bookingDoc['roomId'] ?? '';
            rentDurationType.value = bookingDoc['rentDurationType'] ?? 'Month';
            status.value = bookingDoc['status'] ?? 'booking.pending'.tr;
            moveIn.value = bookingDoc['moveIn'] ?? false;
            moveInDate.value = bookingDoc['moveInDate'] != null
                ? DateTime.parse(bookingDoc['moveInDate'])
                : null;
            idCardUrl.value = bookingDoc['idCardImage'];
          });
        },
      );
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("Failed to fetch booking data"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> pickAndUploadIdCardImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileName =
        'idCards/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

    final oldImageUrl = idCardUrl.value;

    try {
      final newImageUrl = await storageService.uploadImage(fileName, file);
      idCardUrl.value = newImageUrl;

      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await storageService.deleteImageByUrl(oldImageUrl);
      }

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
    }
  }

  Future<void> updateBooking() async {
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

    String formattedMoveInDate =
        DateFormat('yyyy-MM-dd').format(moveInDate.value!);
    final currentUser = FirebaseAuth.instance.currentUser;

    final bookingData = {
      'roomId': selectedRoom.value,
      'name': _nameController.text.trim(),
      'phoneNumbers': _phoneController.text.trim(),
      'profession': _professionController.text.trim(),
      'moveInDate': formattedMoveInDate,
      'rentDurationType': rentDurationType.value,
      'status': status.value,
      'moveIn': moveIn.value,
      'idCardImage': idCardUrl.value,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': currentUser?.uid,
    };

    try {
      final success =
          await firestoreService.updateDocument(widget.bookingId, bookingData);

      if (success) {
        if (moveIn.value) {
          // Check if tenant already exists for this room
          final existingTenantQuery = await FirebaseFirestore.instance
              .collection('tenants')
              .where('roomId', isEqualTo: selectedRoom.value)
              .limit(1)
              .get();

          // Add booking and get its ID back
          final bookingID = await firestoreService.addDocumentId(bookingData);
          if (bookingID == null) throw 'Failed to create booking';

          final tenantData = {
            'bookingID': bookingID,
            'name': _nameController.text.trim(),
            'phoneNumbers': _phoneController.text.trim(),
            'roomId': selectedRoom.value,
            'moveInDate': formattedMoveInDate,
            'profession': _professionController.text.trim(),
            'rentDurationType': rentDurationType.value,
            'idCardImage': idCardUrl.value,
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': currentUser?.uid,
          };

          if (existingTenantQuery.docs.isNotEmpty) {
            // Update the existing tenant
            final tenantDocId = existingTenantQuery.docs.first.id;
            await tenantService.updateDocument(tenantDocId, tenantData);
          } else {
            // Add new tenant
            tenantData['createdAt'] = FieldValue.serverTimestamp();
            tenantData['createdBy'] = currentUser?.uid;
            await tenantService.addDocument(tenantData);
          }
        }

        toastification.show(
          context: context,
          title: const Text("Success"),
          description: const Text("Booking updated successfully"),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      } else {
        toastification.show(
          context: context,
          title: const Text("Error"),
          description: const Text("Failed to update booking"),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("Failed to update booking"),
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
      title: "booking.edit_booking".tr,
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
                                label: "booking.select_rooms".tr,
                                options: roomOptions
                                    .map((room) => room['name'] as String)
                                    .toList(),
                                selectedValue: roomOptions.firstWhereOrNull(
                                  (room) => room['id'] == selectedRoom.value,
                                )?['name'],
                                onChanged: (value) {
                                  final selected = roomOptions.firstWhereOrNull(
                                      (room) => room['name'] == value);
                                  if (selected != null) {
                                    selectedRoom.value = selected['id'];
                                  }
                                },
                                menuMaxHeight: 200,
                              );
                            }),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _nameController,
                              label: "booking.name".tr,
                              hintText: "booking.name".tr,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _phoneController,
                              label: "booking.phone_number".tr,
                              hintText: "booking.placeholder".tr,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _professionController,
                              label: "booking.profession".tr,
                              hintText: "booking.profession".tr,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "booking.id_card".tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: pickAndUploadIdCardImage,
                              child: Obx(() {
                                return Container(
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
                                          child: Icon(
                                            Icons.badge,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                );
                              }),
                            ),
                            const SizedBox(height: 20),
                            Obx(() {
                              return CustomDatePicker(
                                label: "booking.move_in".tr,
                                selectedDate: moveInDate.value,
                                onDateSelected: (date) {
                                  moveInDate.value = date;
                                },
                              );
                            }),
                            const SizedBox(height: 10),
                            Obx(() {
                              return CustomDropdownField(
                                label: "booking.rent_duration".tr,
                                options: ['Month', 'Year'],
                                selectedValue: rentDurationType.value,
                                onChanged: (value) =>
                                    rentDurationType.value = value,
                              );
                            }),
                            const SizedBox(height: 10),
                            Obx(() {
                              return CustomDropdownField(
                                label: "booking.status".tr,
                                options: [
                                  "booking.pending".tr,
                                  "booking.approved".tr,
                                  "booking.rejected".tr,
                                ],
                                selectedValue: status.value,
                                onChanged: (value) => status.value = value,
                              );
                            }),
                            const SizedBox(height: 10),
                            Obx(() {
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text("booking.move_in".tr),
                                value: moveIn.value,
                                activeColor: AppColors.primaryBlue,
                                checkColor: AppColors.white,
                                onChanged: (value) {
                                  moveIn.value = value ?? false;
                                },
                              );
                            }),
                            const SizedBox(height: 20),
                            Custombutton(
                              onPressed: updateBooking,
                              text: "booking.update_booking".tr,
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
