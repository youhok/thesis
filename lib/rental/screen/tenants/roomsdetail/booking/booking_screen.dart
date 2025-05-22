import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/landlordwidgets/Custom_Dropdown_Field.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _professionController =
      TextEditingController(text: "");
  final TextEditingController _rentDurationController =
      TextEditingController(); // Controller for Rent Duration
  String? _selectedRentType;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "booking_screen.roomDetails".tr,
      actionButton:  Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Center(
                    child: Text(
                      '5',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ), 
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Set Date Section
                                Text(
                                  "booking_screen.setTheDate".tr,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text("booking_screen.setTheDateDescription".tr),
                                SizedBox(height: 12),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TableCalendar(
                                    focusedDay: _selectedDay,
                                    firstDay: DateTime(2020),
                                    lastDay: DateTime(2030),
                                    selectedDayPredicate: (day) {
                                      return isSameDay(_selectedDay, day);
                                    },
                                    onDaySelected: (selectedDay, focusedDay) {
                                      setState(() {
                                        _selectedDay = selectedDay;
                                      });
                                    },
                                    calendarStyle: CalendarStyle(
                                      todayDecoration: BoxDecoration(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      selectedDecoration: BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      todayTextStyle:
                                          TextStyle(color: Colors.white),
                                      selectedTextStyle:
                                          TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Phone Number
                                CustomTextField(
                                  label: "booking_screen.phoneNumber".tr,
                                  hintText: "booking_screen.enterPhoneNumber".tr,
                                  controller: _phoneController,
                                ),
                                SizedBox(height: 12),

                                // Profession
                                CustomTextField(
                                  label: "booking_screen.profession".tr,
                                  hintText: "Student",
                                  controller: _professionController,
                                ),
                                SizedBox(height: 12),

                                // Upload ID Card
                                 Text("booking_screen.uploadIdCard".tr),
                                const SizedBox(height: 8),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.cloud_upload,
                                        color: Colors.grey),
                                  ),
                                ),
                                SizedBox(height: 12),

                                // Rent Type Dropdown
                                CustomDropdownField(
                                  label: "booking_screen.rentType".tr,
                                  options: ["monthly", "contract"],
                                  hintText: "Select rent type",
                                  selectedValue: _selectedRentType,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRentType = value;
                                    });
                                  },
                                ),

                                // Conditionally show Rent Duration when "contract" is selected
                                Visibility(
                                  visible: _selectedRentType == "contract",
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 12,
                                      ),
                                      CustomTextField(
                                        label: "booking_screen.rentDuration".tr,
                                        hintText: "booking_screen.month".tr,
                                        controller: _rentDurationController,
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Book Now Button
                                Custombutton(
                                  onPressed: () {
                                    // Handle booking logic
                                  },
                                  text: "booking_screen.bookNow".tr,
                                ),
                              ],
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
        ],
      ),
      );
  }
}


