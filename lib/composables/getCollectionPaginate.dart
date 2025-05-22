import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetCollectionPaginate {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String pathCollection;
  final List<Query Function(Query)>? filters;
  final Function(List<Map<String, dynamic>>)? callback;

  List<Map<String, dynamic>> documents = [];
  String? error;
  StreamSubscription<QuerySnapshot>? _subscription;

  GetCollectionPaginate({
    required this.pathCollection,
    this.filters,
    this.callback,
  }) {
    _listenToData();
  }

  CollectionReference get _collectionRef =>
      _firestore.collection(pathCollection);

  Query get _baseQuery {
    Query query = _collectionRef;
    if (filters != null) {
      for (var f in filters!) {
        query = f(query);
      }
    }
    return query;
  }

  /// Get previous page
  Future<List<Map<String, dynamic>>> previousPage(String docId, int limit) async {
    try {
      final doc = await _collectionRef.doc(docId).get();
      final query = _baseQuery.endBeforeDocument(doc).limitToLast(limit);
      await _fetchQuery(query);
      return documents;
    } catch (e) {
      error = e.toString();
      return [];
    }
  }

  /// Get next page
  Future<List<Map<String, dynamic>>> nextPage(String docId, int limit) async {
    try {
      final doc = await _collectionRef.doc(docId).get();
      final query = _baseQuery.startAfterDocument(doc).limit(limit);
      await _fetchQuery(query);
      return documents;
    } catch (e) {
      error = e.toString();
      return [];
    }
  }

  /// Get full collection count with filters
  Future<int> getCollectionLength() async {
    try {
      final query = _baseQuery;
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      error = e.toString();
      return 0;
    }
  }

  /// Fetch manually with query
  Future<void> _fetchQuery(Query query) async {
    try {
      final snapshot = await query.get();
      documents = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      callback?.call(documents);
    } catch (e) {
      error = e.toString();
    }
  }

  /// Real-time data updates
  void _listenToData() {
    _subscription?.cancel();
    _subscription = _baseQuery.snapshots().listen(
      (snapshot) {
        documents = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        callback?.call(documents);
      },
      onError: (e) => error = e.toString(),
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}



// final paginate = GetCollectionPaginate(
//   pathCollection: 'products',
//   filters: [
//     (query) => query.where('active', isEqualTo: true),
//     (query) => query.orderBy('createdAt', descending: true),
//     (query) => query.limit(10),
//   ],
//   callback: (data) {
//     print("🔥 Products: $data");
//   },
// );

// // Get next page
// paginate.nextPage('docID_here', 10);

// // Get previous page
// paginate.previousPage('docID_here', 10);

// // Get collection length
// final count = await paginate.getCollectionLength();

// // When you're done
// paginate.dispose();
