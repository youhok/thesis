import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:toastification/toastification.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final RxList<Map<String, dynamic>> propertyList =
      <Map<String, dynamic>>[].obs;
  final Rx<String?> selectedPropertyId = Rx<String?>(null);
  bool isAvailable = false;
  bool status = false;

  final _formKey = GlobalKey<FormState>();
  final numberOfRoomsController = TextEditingController();
  final roomPriceController = TextEditingController();

  final Map<String, bool> features = {
    "Bathroom": false,
    "Bed": false,
    "Fan": false,
    "Air Conditioner": false,
    "Wifi": false,
    "Balcony": false,
  };

  @override
  void initState() {
    super.initState();
    fetchProperties();
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
      title: "add_room_screen.addnewroom".tr,
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
                          final selected = propertyList
                              .firstWhereOrNull((e) => e['name'] == value);
                          if (selected != null) {
                            selectedPropertyId.value = selected['id'];
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: numberOfRoomsController,
                      label: "add_room_screen.Numberofroom".tr,
                      hintText: "add_room_screen.Numberofroom".tr,
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
                        if (!_formKey.currentState!.validate()) return;

                        final propertyId = selectedPropertyId.value;
                        final numberOfRooms =
                            int.tryParse(numberOfRoomsController.text);
                        final price = double.tryParse(roomPriceController.text);

                        if (propertyId == null ||
                            numberOfRooms == null ||
                            price == null) {
                          toastification.show(
                            context: context,
                            title: const Text("Error"),
                            description: Text(
                                "Please fill in all required fields correctly"),
                            type: ToastificationType.error,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                          return;
                        }

                        context.loaderOverlay.show();

                        final batch = FirebaseFirestore.instance.batch();
                        final collection =
                            FirebaseFirestore.instance.collection('rooms');
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final userId = currentUser?.uid;

                        for (int i = 1; i <= numberOfRooms; i++) {
                          final docRef = collection.doc();

                          final roomData = {
                            'propertyID': propertyId,
                            'name':
                                "${propertyList.firstWhere((e) => e['id'] == propertyId)['name']} - Room $i",
                            'price': price,
                            'isAvailable': isAvailable,
                            'status': status,
                            'bathroom': features['Bathroom'] ?? false,
                            'bed': features['Bed'] ?? false,
                            'fan': features['Fan'] ?? false,
                            'airCon': features['Air Conditioner'] ?? false,
                            'wifi': features['Wifi'] ?? false,
                            'balcony': features['Balcony'] ?? false,
                            'isBooked': false,
                            'createdAt': FieldValue.serverTimestamp(),
                            'createdBy': userId,
                          };

                          batch.set(docRef, roomData);
                        }

                        try {
                          await batch.commit();

                          toastification.show(
                            context: context,
                            title: const Text("Success"),
                            description:
                                Text("$numberOfRooms rooms added successfully"),
                            type: ToastificationType.success,
                            autoCloseDuration: const Duration(seconds: 2),
                          );

                          numberOfRoomsController.clear();
                          roomPriceController.clear();
                          setState(() {
                            isAvailable = false;
                            status = false;
                            features.updateAll((key, value) => false);
                          });
                        } catch (e) {
                          toastification.show(
                            context: context,
                            title: const Text("Error"),
                            description: Text("Failed to add rooms"),
                            type: ToastificationType.error,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                          print('Firestore error: $e');
                        } finally {
                          context.loaderOverlay.hide();
                        }
                      },
                      text: "add_room_screen.AddRoom".tr,
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
