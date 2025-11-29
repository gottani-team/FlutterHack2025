import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Firebase Authentication データソース
///
/// Firebase Authenticationとの直接通信を担当するマイクロサービス。
/// 匿名認証、セッション管理、ユーザー情報のFirestore同期を提供。
class FirebaseAuthService {
  FirebaseAuthService(this._auth, this._firestore);
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// 匿名認証を実行
  ///
  /// Firebase Authで匿名ユーザーを作成し、Firestoreにユーザードキュメントを作成する。
  /// 既に認証済みの場合は、現在のユーザー情報を返す。
  ///
  /// Returns: UserModel（認証済みユーザー）
  /// Throws: FirebaseAuthException, FirebaseException
  Future<UserModel> signInAnonymously() async {
    // 既に認証済みの場合は現在のユーザーを返す
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _getUserModel(currentUser);
    }

    // 匿名認証を実行
    final userCredential = await _auth.signInAnonymously();
    final user = userCredential.user!;

    // Firestoreにユーザードキュメントを作成
    final userModel = UserModel(
      id: user.uid,
      currentKarma: 0,
      createdAt: Timestamp.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());

    return userModel;
  }

  /// 現在の認証ユーザーを取得
  ///
  /// Returns: UserModel（認証済みの場合）
  /// Throws: StateError（未認証の場合）
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }

    return _getUserModel(user);
  }

  /// 認証状態の変更をStreamで監視
  ///
  /// Returns: `Stream<UserModel?>`（null = ログアウト状態）
  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _getUserModel(user);
    });
  }

  /// サインアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Firebase UserからUserModelを作成
  ///
  /// Firestoreからユーザー情報を取得するか、存在しない場合は作成する。
  Future<UserModel> _getUserModel(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    // ドキュメントが存在しない場合は作成
    final userModel = UserModel(
      id: user.uid,
      currentKarma: 0,
      createdAt: Timestamp.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());

    return userModel;
  }
}
