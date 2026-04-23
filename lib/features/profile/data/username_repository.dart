import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameRepository {
  UsernameRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String?> getUsername(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      return null;
    }

    final data = userDoc.data();
    return data?['username'] as String?;
  }

  Future<bool> hasUsername(String uid) async {
    final name = await getUsername(uid);
    return name != null && name.isNotEmpty;
  }

  Future<bool> reserveUniqueUsername({
    required String uid,
    required String username,
  }) async {
    final normalized = _normalize(username);

    if (!_isValid(normalized)) {
      throw const FormatException(
        'Der Name muss 3-20 Zeichen lang sein und darf nur a-z, 0-9 und _ enthalten.',
      );
    }

    final usersCollection = _firestore.collection('users');
    final usernamesCollection = _firestore.collection('usernames');

    return _firestore.runTransaction((transaction) async {
      final userRef = usersCollection.doc(uid);
      final usernameRef = usernamesCollection.doc(normalized);

      final userSnapshot = await transaction.get(userRef);
      final usernameSnapshot = await transaction.get(usernameRef);

      if (usernameSnapshot.exists) {
        final ownerUid = usernameSnapshot.data()?['uid'] as String?;
        if (ownerUid != uid) {
          return false;
        }
      }

      final currentNormalized =
          userSnapshot.data()?['username_normalized'] as String?;

      if (currentNormalized != null && currentNormalized != normalized) {
        final oldRef = usernamesCollection.doc(currentNormalized);
        final oldSnapshot = await transaction.get(oldRef);
        if (oldSnapshot.exists) {
          final oldOwnerUid = oldSnapshot.data()?['uid'] as String?;
          if (oldOwnerUid == uid) {
            transaction.delete(oldRef);
          }
        }
      }

      transaction.set(usernameRef, {
        'uid': uid,
        'username': username,
        'normalized': normalized,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(userRef, {
        'uid': uid,
        'username': username,
        'username_normalized': normalized,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    });
  }

  String _normalize(String username) => username.trim().toLowerCase();

  bool _isValid(String username) {
    final pattern = RegExp(r'^[a-z0-9_]{3,20}$');
    return pattern.hasMatch(username);
  }
}
