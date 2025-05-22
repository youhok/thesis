import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:toastification/toastification.dart';

class EditRoomScreen extends StatefulWidget {
  final Map<String, dynamic> room;
  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final RxList<Map<String, dynamic>> propertyList =
      <Map<String, dynamic>>[].obs;
  final Rx<String?> selectedPropertyId = Rx<String?>(null);
  bool isAvailable = false;
  bool status = false;

  final _formKey = GlobalKey<FormState>();
  final numberOfRoomsController = TextEditingController();
  final roomPriceController = TextEditingController();

  final Map<String, bool> features = {
    'airCon': false,
    'balcony': false,
    'bathroom': false,
    'bed': false,
    'fan': false,
    'wifi': false,
  };

  @override
  void initState() {
    super.initState();
    fetchProperties();

    numberOfRoomsController.text = widget.room['name'] ?? '';
    roomPriceController.text = widget.room['price'].toString();
    isAvailable = widget.room['isAvailable'] ?? false;
    status = widget.room['status'] ?? false;
    selectedPropertyId.value = widget.room['propertyID'];

    for (var key in features.keys) {
      if (widget.room.containsKey(key)) {
        features[key] = widget.room[key] == true;
      }
    }
  }

  void fetchProperties() async {
    await getCollectionQuery(
      collectionName: 'properties',
      callback: (List<Map<String, dynamic>> data) {
        propertyList.value = data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "add_room_screen.edit_room".tr,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Obx(() {
                      return CustomDropdownField(
                        label: "add_room_screen.selectproperty".tr,
                        hintText: "add_room_screen.selectproperty".tr,
                        options: propertyList
                            .map((prop) => prop['name'] as String)
                            .toList(),
                        selectedValue: propertyList.firstWhereOrNull(
                          (e) => e['id'] == selectedPropertyId.value,
                        )?['name'],
                        onChanged: (value) {
                          final selected = propertyList.firstWhereOrNull(
                            (e) => e['name'] == value,
                          );
                          if (selected != null) {
                            selectedPropertyId.value = selected['id'];
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: numberOfRoomsController,
                      label: "add_room_screen.Number_name".tr,
                      hintText: "add_room_screen.Number_name".tr,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: roomPriceController,
                      label: "add_room_screen.Roomprice".tr,
                      hintText: "add_room_screen.Roomprice".tr,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: isAvailable,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value ?? false;
                            });
                          },
                        ),
                        Text(
                          "add_room_screen.isavailable".tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: status,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) {
                            setState(() {
                              status = value ?? false;
                            });
                          },
                        ),
                        Text(
                          "add_room_screen.status".tr,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "add_room_screen.room_features".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: features.keys.map((feature) {
                        final isSelected = features[feature]!;
                        return FilterChip(
                          label: Text(
                            feature,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.grey.shade200,
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              features[feature] = selected;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    Custombutton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() != true) return;

                        String roomId = widget.room['id'];
                        final userId = FirebaseAuth.instance.currentUser?.uid;

                        final updatedRoomData = {
                          'id': roomId, // include id for parent update
                          'propertyID': selectedPropertyId.value,
                          'name': numberOfRoomsController.text.trim(),
                          'price':
                              double.tryParse(roomPriceController.text) ?? 0,
                          'isAvailable': isAvailable,
                          'status': status,
                          ...features.map((key, value) => MapEntry(key, value)),
                          'updatedBy': userId,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };

                        try {
                          await FirebaseFirestore.instance
                              .collection('rooms')
                              .doc(roomId)
                              .update(updatedRoomData);

                          Get.back(
                              result: updatedRoomData); // Return updated data

                          toastification.show(
                            context: context,
                            title: const Text("Success"),
                            description: Text("Room updated successfully"),
                            type: ToastificationType.success,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                        } catch (e) {
                          toastification.show(
                            context: context,
                            title: const Text("Error"),
                            description: Text("Failed to update room: $e"),
                            type: ToastificationType.error,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                        }
                      },
                      text: "add_room_screen.update_room".tr,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
