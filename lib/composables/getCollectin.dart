import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

typedef CollectionCallback = void Function(List<Map<String, dynamic>> data);
typedef DocumentCallback = void Function(Map<String, dynamic> data);

Future<StreamSubscription?> getCollectionQuery({
  required String collectionName,
  List<Query Function(Query)>? filters,
  dynamic callback,
  String? docID,
  bool useSnapshot = false,
}) async {
  final collectionRef = FirebaseFirestore.instance.collection(collectionName);

  // Apply filters dynamically
  Query query = collectionRef;
  if (filters != null) {
    for (var filter in filters) {
      query = filter(query);
    }
  }

  try {
    // Realtime listener
    if (useSnapshot) {
      final subscription = query.snapshots(includeMetadataChanges: true).listen(
        (snapshot) {
          final data = snapshot.docs.map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }).toList();

          if (callback is CollectionCallback) callback(data);
        },
        onError: (error) => print("Snapshot Error: $error"),
      );

      return subscription;
    } else {
      // One-time fetch
      final snapshot = await query.get();
      final data = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }).toList();

      if (callback is CollectionCallback) callback(data);
    }

    // Optional: fetch a single doc by ID
    if (docID != null) {
      final docSnapshot = await collectionRef.doc(docID).get();

      if (docSnapshot.exists) {
        final data = {
          'id': docSnapshot.id,
          ...docSnapshot.data() as Map<String, dynamic>,
        };
        if (callback is DocumentCallback) callback(data);
      } else {
        print("❌ Document not found");
      }
    }
  } catch (e) {
    print("🔥 Firestore Error: $e");
  }

  return null;
}


// // Example: one-time fetch with filter
// getCollectionQuery(
//   collectionName: 'users',
//   filters: [
//     (query) => query.where('age', isGreaterThan: 18),
//     (query) => query.orderBy('createdAt', descending: true),
//   ],
//   callback: (List<Map<String, dynamic>> users) {
//     print(users);
//   },
// );

// // Example: realtime listener
// final sub = await getCollectionQuery(
//   collectionName: 'posts',
//   useSnapshot: true,
//   callback: (List<Map<String, dynamic>> posts) {
//     print("Live posts: $posts");
//   },
// );

// // Example: fetch single doc
// getCollectionQuery(
//   collectionName: 'users',
//   docID: 'abc123',
//   callback: (Map<String, dynamic> user) {
//     print("User doc: $user");
//   },
// );
