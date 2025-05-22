import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/composables/useDocumetn.dart';
import 'package:sankaestay/composables/useStorage.dart';
import 'package:sankaestay/rental/screen/landlord/properties/addproperty_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/custom_search_field.dart';
import 'package:sankaestay/rental/widgets/dailog.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:toastification/toastification.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> filteredProperties = [];
  late final FirestoreService _firestoreService;

  @override
  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService('properties');

    getCollectionQuery(
      collectionName: 'properties',
      filters: [
        (query) => query.orderBy('createdAt', descending: true),
      ],
      useSnapshot: true,
      callback: (List<Map<String, dynamic>> data) async {
        List<Map<String, dynamic>> updatedProperties = [];

        for (var property in data) {
          final propertyId = property['id'];

          if (propertyId != null) {
            final roomCount = await getRoomCountForProperty(propertyId);
            property['roomCount'] = roomCount;
          } else {
            property['roomCount'] = 0;
          }

          updatedProperties.add(property);
        }

        setState(() {
          properties = updatedProperties;
          filteredProperties = updatedProperties;
        });
      },
    );
  }

  Future<int> getRoomCountForProperty(String propertyId) async {
    final completer = Completer<int>();

    await getCollectionQuery(
      collectionName: 'rooms',
      filters: [
        (query) => query.where('propertyID', isEqualTo: propertyId),
      ],
      callback: (List<Map<String, dynamic>> rooms) {
        completer.complete(rooms.length);
      },
    );

    return completer.future;
  }

  void _filterProperties(String query) {
    setState(() {
      filteredProperties = properties.where((property) {
        final title = property['title']?.toString().toLowerCase() ?? '';
        final address = property['address']?.toString().toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) ||
            address.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _handleDelete(String id) async {
    final success = await _firestoreService.removeDocument(id);
    if (success) {
      toastification.show(
        context: context,
        title: const Text("Success"),
        description: const Text("Property deleted successfull"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } else {
      toastification.show(
        context: context,
        title: const Text("Failed"),
        description: const Text("Failed to delete property"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "property_list.title".tr,
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
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: CustomSearchField(
                          controller: _searchController,
                          onChanged: _filterProperties,
                          hintText: 'property_list.search_placeholder'.tr,
                        ),
                      ),
                      const SizedBox(height: 10),
                      filteredProperties.isEmpty
                          ? Container(
                              margin: const EdgeInsets.only(top: 200),
                              child: Center(
                                child: Image.asset(
                                  "images/undraw_no-data_ig65-removebg-preview.png",
                                  height: 250,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text(
                                      "Image not found",
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: filteredProperties.length,
                                itemBuilder: (context, index) {
                                  final property = filteredProperties[index];
                                  return RoomRentalCard(
                                    property: property,
                                    onDelete: _handleDelete,
                                  );
                                },
                              ),
                            ),
                    ],
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
                    builder: (context) => const AddPropertyScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(AppIcons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class RoomRentalCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final void Function(String id) onDelete;

  const RoomRentalCard({
    super.key,
    required this.property,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = (property['imageUrls'] != null &&
            property['imageUrls'] is List &&
            property['imageUrls'].isNotEmpty)
        ? property['imageUrls'][0]
        : null;

    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      'images/home.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['name'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property['address'] ?? 'No Address',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Property ID: ${property['name'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Room: ${property['roomCount'] ?? 0}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Tenants: ${property['tenants'] ?? 0}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF0D1C2E)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddPropertyScreen(property: property),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final id = property['id'];
                          final imageUrls = property['imageUrls'];

                          if (id != null) {
                            showDeleteConfirmationDialog(
                              context,
                              title: "Delete Property",
                              message:
                                  "Are you sure you want to delete this property?",
                            ).then((confirmed) async {
                              if (confirmed == true) {
                                final storageService = StorageService();

                                if (imageUrls is List) {
                                  for (final url in imageUrls) {
                                    if (url is String && url.isNotEmpty) {
                                      await storageService
                                          .deleteImageByUrl(url);
                                    }
                                  }
                                }

                                onDelete(id);
                              }
                            });
                          } else {
                            toastification.show(
                              context: context,
                              title: const Text("Missing"),
                              description: const Text("Missing property ID"),
                              type: ToastificationType.error,
                              autoCloseDuration: const Duration(seconds: 2),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
