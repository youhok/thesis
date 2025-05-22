import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyA7TCd8sTaCPjCwvEIS1GnakDpXDzPFOuU",
            authDomain: "thesis-sangkaestay.firebaseapp.com",
            projectId: "thesis-sangkaestay",
            storageBucket: "thesis-sangkaestay.firebasestorage.app",
            messagingSenderId: "179320462747",
            appId: "1:179320462747:web:542d064b9c9a4204a1953e",
            measurementId: "G-H98L8W0EPK"));
  } else {
    await Firebase.initializeApp();
  }
}
