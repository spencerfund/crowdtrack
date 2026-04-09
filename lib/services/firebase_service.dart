import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/project.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: "ai-studio-bbca5485-d8d1-4a64-8f5d-0442aee9d2f0",
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final List<String> scopes = ['email', 'profile'];
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(
        scopes,
      );
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: clientAuth.accessToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error calling Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Projects
  Stream<List<Project>> streamProjects(String userId) {
    return _db
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final projects = snapshot.docs
              .map((doc) => Project.fromFirestore(doc))
              .toList();
          projects.sort((a, b) {
            final timeA = a.lastUpdate?.millisecondsSinceEpoch ?? 0;
            final timeB = b.lastUpdate?.millisecondsSinceEpoch ?? 0;
            return timeB.compareTo(timeA);
          });
          return projects;
        });
  }

  Future<void> addProject(Project project) async {
    final data = project.toMap();
    data['userId'] = _auth.currentUser!.uid;
    data['lastUpdate'] = FieldValue.serverTimestamp();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('projects').add(data);
  }

  Future<void> updateProject(Project project) async {
    final data = project.toMap();
    data['lastUpdate'] = FieldValue.serverTimestamp();
    // Do not overwrite createdAt on update
    data.remove('createdAt');
    await _db.collection('projects').doc(project.id).update(data);
  }

  Future<void> deleteProject(String id) async {
    await _db.collection('projects').doc(id).delete();
  }
}
