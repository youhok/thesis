import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sankaestay/composables/useStorage.dart';
import 'package:sankaestay/core/config/map_picker_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class AddPropertyScreen extends StatefulWidget {
  final Map<String, dynamic>? property;
  const AddPropertyScreen({super.key, this.property});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final PageController _pageController = PageController();
  final StorageService storageService = StorageService();

  // Controllers
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _waterPriceController = TextEditingController();
  final TextEditingController _electricityPriceController =
      TextEditingController();
  final TextEditingController _garbagePriceController = TextEditingController();
  final TextEditingController _internetPriceController =
      TextEditingController();

  final List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];

  LatLng? _pickedLocation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeForEdit();
  }

  void _initializeForEdit() {
    if (widget.property != null) {
      final p = widget.property!;
      _propertyNameController.text = p['name'] ?? '';
      _addressController.text = p['address'] ?? '';
      _descriptionController.text = p['description'] ?? '';

      // Initialize price fields from numeric Firestore values:
      _waterPriceController.text = p['waterPrice']?.toString() ?? '';
      _electricityPriceController.text =
          p['electricityPrice']?.toString() ?? '';
      _garbagePriceController.text = p['garbagePrice']?.toString() ?? '';
      _internetPriceController.text = p['internetPrice']?.toString() ?? '';

      _existingImageUrls = List<String>.from(p['imageUrls'] ?? []);
      if (p['longLat'] != null && p['longLat'].contains(',')) {
        final parts = p['longLat'].split(',');
        _pickedLocation = LatLng(
          double.parse(parts[0]),
          double.parse(parts[1]),
        );
      }
    }
  }

  void _selectLocation() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: _pickedLocation ?? const LatLng(11.5564, 104.9282),
        ),
      ),
    );
    if (selectedLocation != null) {
      setState(() {
        _pickedLocation = selectedLocation;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  Future<void> _saveProperty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: const Text("User not logged in"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
      return;
    }

    context.loaderOverlay.show();

    try {
      // 1) Upload any newly picked images
      List<String> imageUrls = List.from(_existingImageUrls);
      for (var image in _selectedImages) {
        File imageFile = File(image.path);
        String fileName =
            'properties/${user.uid}-${DateTime.now().millisecondsSinceEpoch}-${image.name}';
        String imageUrl = await storageService.uploadImage(fileName, imageFile);
        imageUrls.add(imageUrl);
      }

      // 2) Parse text fields into doubles
      final double waterPrice =
          double.tryParse(_waterPriceController.text.trim()) ?? 0.0;
      final double electricityPrice =
          double.tryParse(_electricityPriceController.text.trim()) ?? 0.0;
      final double garbagePrice =
          double.tryParse(_garbagePriceController.text.trim()) ?? 0.0;
      final double internetPrice =
          double.tryParse(_internetPriceController.text.trim()) ?? 0.0;

      // 3) Build the map with numeric values
      final Map<String, dynamic> propertyData = {
        'userId': user.uid,
        'propertyTitle': _propertyNameController.text.trim(),
        'name': _propertyNameController.text.trim(),
        'address': _addressController.text.trim(),
        'longLat': _pickedLocation != null
            ? '${_pickedLocation!.latitude},${_pickedLocation!.longitude}'
            : '',
        'description': _descriptionController.text.trim(),
        'imageUrls': imageUrls,
        'waterPrice': waterPrice,
        'electricityPrice': electricityPrice,
        'garbagePrice': garbagePrice,
        'internetPrice': internetPrice,
        'status': true,
      };

      if (widget.property != null && widget.property!['id'] != null) {
        // Update existing
        propertyData['updatedAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('properties')
            .doc(widget.property!['id'])
            .update(propertyData);

        toastification.show(
          context: context,
          title: const Text("Success"),
          description: const Text("Property updated successfully!"),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      } else {
        // Create new
        propertyData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('properties')
            .add(propertyData);

        toastification.show(
          context: context,
          title: const Text("Success"),
          description: const Text("Property added successfully!"),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }

      Get.back();
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text("Error"),
        description: Text("Error saving property: $e"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } finally {
      context.loaderOverlay.hide();
    }
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _waterPriceController.dispose();
    _electricityPriceController.dispose();
    _garbagePriceController.dispose();
    _internetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.property != null
          ? "add_property_step_1.update_title".tr
          : "add_property_step_1.title".tr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(0),
          const SizedBox(height: 15),
          Text("add_property_step_1.section_title".tr,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryBlue)),
          const SizedBox(height: 20),
          CustomTextField(
            label: "add_property_step_1.property_name".tr,
            hintText: "property name",
            controller: _propertyNameController,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "add_property_step_1.address".tr,
            hintText: "address",
            controller: _addressController,
          ),
          const SizedBox(height: 16),
          Text('add_property_step_1.set_location'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
          GestureDetector(
            onTap: _selectLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  _pickedLocation == null
                      ? 'Set Location'
                      : 'Lat: ${_pickedLocation!.latitude}, Lng: ${_pickedLocation!.longitude}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('add_property_step_1.add_images'.tr,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImageUrls
                    .map((url) => _buildImagePreview(url: url))
                    .toList(),
                ..._selectedImages
                    .map((img) => _buildImagePreview(file: File(img.path)))
                    .toList(),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(AppIcons.addphoto, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('add_property_step_1.description_optional'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'add_property_step_1.enter_description'.tr,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Custombutton(
              onPressed: _goToNextPage, text: "add_property_step_1.next".tr),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(1),
          const SizedBox(height: 16),
          Text("add_property_step_1.section_title".tr,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryBlue)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'add_property_step_2.water_price'.tr,
                  hintText: '\$0.25/m3',
                  controller: _waterPriceController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'add_property_step_2.electricity_price'.tr,
                  hintText: '\$0.27/kwh',
                  controller: _electricityPriceController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'add_property_step_2.garbage_price'.tr,
                  hintText: '\$0.25/month',
                  controller: _garbagePriceController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'add_property_step_2.internet_price'.tr,
                  hintText: '\$1.00/month',
                  controller: _internetPriceController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Custombutton(
            onPressed: _saveProperty,
            text: widget.property != null
                ? "Update Property"
                : "add_property_step_2.add_property".tr,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int activeStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: activeStep == 0 ? AppColors.secondaryBlue : Colors.grey,
                shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: activeStep == 1 ? AppColors.secondaryBlue : Colors.grey,
                shape: BoxShape.circle)),
      ],
    );
  }

  Widget _buildImagePreview({String? url, File? file}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url != null
              ? Image.network(url, fit: BoxFit.cover)
              : Image.file(file!, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
