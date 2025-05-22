import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/getCollectin.dart';
import 'package:sankaestay/composables/useDocumetn.dart';
import 'package:sankaestay/composables/useStorage.dart';
import 'package:sankaestay/rental/screen/landlord/booking/add_booking.dart';
import 'package:sankaestay/rental/screen/landlord/booking/edit_booking.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/custom_search_field.dart';
import 'package:sankaestay/rental/widgets/dailog.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:toastification/toastification.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  List<Map<String, dynamic>> approvedApplicants = [];
  StreamSubscription? bookingSub;
  List<Map<String, dynamic>> allBookings = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  void fetchBookings() async {
    bookingSub = await getCollectionQuery(
      collectionName: 'bookings',
      useSnapshot: true,
      callback: (List<Map<String, dynamic>> data) {
        setState(() {
          allBookings = data;
          approvedApplicants = data;
        });
      },
    );
  }

  void filterBookings(String query) {
    final filtered = allBookings.where((booking) {
      final name = booking['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      approvedApplicants = filtered;
    });
  }

  @override
  void dispose() {
    bookingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "booking.title".tr,
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomSearchField(
                  controller: searchController,
                  hintText: "booking.search_placeholder".tr,
                  onChanged: (value) {
                    filterBookings(value);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: approvedApplicants.isEmpty
                    ? Center(
                        child: Image.asset(
                          "images/undraw_no-data_ig65-removebg-preview.png",
                          height: 260,
                        ),
                      )
                    : ListView.builder(
                        itemCount: approvedApplicants.length,
                        itemBuilder: (context, index) {
                          final tenant = approvedApplicants[index];
                          final hasMovedIn = tenant['moveIn'] == true;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Card(
                              elevation: 0,
                              color: AppColors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Name and phone
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tenant['name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tenant['phoneNumbers'] ?? '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            tenant['moveInDate'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Action Icons
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              approvedApplicants[index]
                                                  ['moveIn'] = !hasMovedIn;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: hasMovedIn
                                                  ? const Color(0xFFDFFFE2)
                                                  : Colors.grey.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: Icon(
                                              hasMovedIn
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color: hasMovedIn
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditBooking(
                                                    bookingId: tenant[
                                                        'id']), // Pass booking data
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(Icons.edit,
                                                color: Colors.black87),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            final confirm =
                                                await showDeleteConfirmationDialog(
                                              context,
                                              title: "Delete Booking",
                                              message:
                                                  "Do you want to delete this booking?",
                                            );

                                            if (confirm == true) {
                                              final bookingId = tenant['id'];
                                              final imageUrl =
                                                  tenant['idCardImage'];

                                              final firestore =
                                                  FirestoreService('bookings');
                                              final storage = StorageService();

                                              try {
                                                if (imageUrl != null &&
                                                    imageUrl
                                                        .toString()
                                                        .isNotEmpty) {
                                                  await storage
                                                      .deleteImageByUrl(
                                                          imageUrl);
                                                }

                                                final deleted = await firestore
                                                    .removeDocument(bookingId);

                                                if (deleted) {
                                                  toastification.show(
                                                    context: context,
                                                    title:
                                                        const Text("Success"),
                                                    description: const Text(
                                                        "Booking deleted successfully"),
                                                    type: ToastificationType
                                                        .success,
                                                    autoCloseDuration:
                                                        const Duration(
                                                            seconds: 2),
                                                  );
                                                } else {
                                                  toastification.show(
                                                    context: context,
                                                    title: const Text("Error"),
                                                    description: const Text(
                                                        "Failed to delete booking"),
                                                    type: ToastificationType
                                                        .error,
                                                    autoCloseDuration:
                                                        const Duration(
                                                            seconds: 2),
                                                  );
                                                }
                                              } catch (e) {
                                                toastification.show(
                                                  context: context,
                                                  title: const Text("Error"),
                                                  description:
                                                      Text("Error: $e"),
                                                  type:
                                                      ToastificationType.error,
                                                  autoCloseDuration:
                                                      const Duration(
                                                          seconds: 2),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFE0E0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(Icons.delete,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBooking(),
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
