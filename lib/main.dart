import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sankaestay/rental/screen/intro_screen/loading_screen.dart';
import 'package:sankaestay/rental/screen/landlord/addtenants_screen.dart';
import 'package:sankaestay/rental/screen/landlord/dash_board.dart';
import 'package:sankaestay/rental/screen/landlord/tenants_screen.dart';
import 'package:sankaestay/routes/app_middleware.dart';
import 'package:sankaestay/routes/app_router.dart';
import 'package:sankaestay/screen/login_screen.dart';
import 'package:sankaestay/screen/start_screen.dart';
import 'package:sankaestay/screen/super_admin.dart';
import 'package:sankaestay/translate/app_translate.dart';
import 'package:sankaestay/translate/localization_controller.dart';
import 'package:sankaestay/widgets/custom_loader.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart'
    if (dart.library.html) 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Configure web-specific settings
    try {
      setUrlStrategy(null); // Use path URL strategy
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Error configuring web settings: $e');
    }
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Load translations FIRST
  await AppTranslations.loadTranslations();
  // Inject LocalizationController
  Get.put(LocalizationController());

  runApp(
    GlobalLoaderOverlay(
      // 🔹 Wrap your app here
      overlayWidgetBuilder: (_) => const CustomLoader(), // ✅ Recommended way
      overlayColor:
          Colors.transparent, // Background already included in the loade
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: Obx(() {
        final localeController = Get.find<LocalizationController>();
        final selectedLanguage = localeController.selectedLanguage.value;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: Locale(selectedLanguage),
          fallbackLocale: const Locale('en'),
          initialRoute: kIsWeb ? AdminRoutes.initialRoute : '/',
          getPages: [
            // Mobile app route
            GetPage(
              name: '/',
              page: () => LoadingScreen(),
            ),
            // Admin web routes
            if (kIsWeb) ...AdminRoutes.routes,
          ],
        );
      }),
    );
  }
}
