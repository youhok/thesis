import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/composables/useDocumetn.dart';
import 'package:sankaestay/rental/screen/landlord/properties/rooms/add_room_screen.dart';
import 'package:sankaestay/rental/screen/landlord/properties/rooms/edit_room_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/custom_search_field.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Tenant_Card.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:toastification/toastification.dart';

class RoomsWithProperty extends StatefulWidget {
  const RoomsWithProperty({super.key});

  @override
  State<RoomsWithProperty> createState() => _RoomsWithPropertyState();
}

class _RoomsWithPropertyState extends State<RoomsWithProperty> {
  final RxList<Map<String, dynamic>> propertyList =
      <Map<String, dynamic>>[].obs;
  final Rx<String?> selectedPropertyId = Rx<String?>(null);
  List<Map<String, dynamic>> rooms = [];
  final FirestoreService firestoreService = FirestoreService('rooms');
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredRooms = [];

  @override
  void initState() {
    super.initState();
    fetchProperties();
    ever(selectedPropertyId, (_) => fetchRooms()); // re-fetch rooms on change
  }

  final RxMap<String, Map<String, dynamic>> propertyMap =
      <String, Map<String, dynamic>>{}.obs;

  void fetchProperties() async {
    await getCollectionQuery(
      collectionName: 'properties',
      filters: [],
      callback: (List<Map<String, dynamic>> data) {
        propertyList.assignAll(data);
        propertyMap.assignAll({
          for (var prop in data) prop['id']: prop,
        });
      },
    );
  }

  void fetchRooms() async {
    await getCollectionQuery(
      collectionName: 'rooms',
      filters: [
        (query) => query.where('status', isEqualTo: true),
        if (selectedPropertyId.value != null)
          (query) =>
              query.where('propertyID', isEqualTo: selectedPropertyId.value),
      ],
      callback: (List<Map<String, dynamic>> data) {
        data.sort((a, b) {
          final roomA = RegExp(r'\d+').firstMatch(a['name'] ?? '')?.group(0);
          final roomB = RegExp(r'\d+').firstMatch(b['name'] ?? '')?.group(0);
          return (int.tryParse(roomA ?? '0') ?? 0)
              .compareTo(int.tryParse(roomB ?? '0') ?? 0);
        });

        setState(() {
          rooms = data;
          filteredRooms = data;
        });
      },
    );
  }

  void filterRooms(String query) {
    final filtered = rooms.where((room) {
      final name = room['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredRooms = filtered;
    });
  }

  void deleteRoom(String roomId) async {
    bool success = await firestoreService.removeDocument(roomId);

    if (success) {
      // Remove room from local list if successfully deleted from Firestore
      setState(() {
        rooms.removeWhere((room) => room['id'] == roomId);
      });
      toastification.show(
        context: context,
        title: const Text("Success"),
        description: const Text("Room deleted successfully"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } else {
      toastification.show(
        context: context,
        title: const Text("Failed"),
        description: const Text("Failed to delete room"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "property_detail.rooms".tr,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: CustomSearchField(
                              controller: searchController,
                              hintText: "Search by room name",
                              onChanged: (value) {
                                filterRooms(value);
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          Obx(() {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: CustomDropdownField(
                                // label: "add_room_screen.selectproperty".tr,
                                hintText: "add_room_screen.selectproperty".tr,
                                options: propertyList
                                    .map((prop) => prop['name'] as String)
                                    .toList(),
                                selectedValue: propertyList.firstWhereOrNull(
                                  (e) => e['id'] == selectedPropertyId.value,
                                )?['name'],
                                onChanged: (value) {
                                  final selected =
                                      propertyList.firstWhereOrNull(
                                          (e) => e['name'] == value);
                                  if (selected != null) {
                                    selectedPropertyId.value = selected['id'];
                                  }
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  filteredRooms.asMap().entries.map((entry) {
                                var room = entry.value;
                                var property = propertyMap[room['propertyID']];
                                String address =
                                    property?['address'] ?? 'No Address';

                                return TenantCard(
                                  tenantName: room['name'],
                                  tenantAddress: address,
                                  roomPrice: double.tryParse(
                                          room['price'].toString()) ??
                                      0,
                                  isAvailable: room['isAvailable'] ?? true,
                                  onEdit: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditRoomScreen(room: room)),
                                    );
                                    if (result != null &&
                                        result is Map<String, dynamic>) {
                                      setState(() {
                                        rooms[entry.key] = result;
                                        filterRooms(searchController
                                            .text); // reapply filter
                                      });
                                    }
                                  },
                                  onDelete: () {
                                    deleteRoom(room['id']);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRoomScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(AppIcons.add, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
