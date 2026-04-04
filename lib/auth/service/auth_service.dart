import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 현재 로그인된 유저
  User? get currentUser => _auth.currentUser;

  // 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호 로그인
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google 로그인
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // 취소한 경우

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Firestore에 유저 정보 저장 (처음 로그인한 경우)
    final user = userCredential.user;
    if (user != null && userCredential.additionalUserInfo!.isNewUser) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'nickname': user.displayName ?? '',
        'language': 'ko',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String language,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Firestore에 유저 정보 저장
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'nickname': nickname,
        'language': language,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Firebase 에러 코드 → 한국어 메시지
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return '존재하지 않는 이메일이에요.';
      case 'wrong-password':
        return '비밀번호가 틀렸어요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일이에요.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않아요.';
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 해요.';
      case 'too-many-requests':
        return '잠시 후 다시 시도해주세요.';
      default:
        return '오류가 발생했어요. 다시 시도해주세요.';
    }
  }
}