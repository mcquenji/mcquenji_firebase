import 'package:firebase_auth/firebase_auth.dart';
import 'package:mcquenji_firebase/mcquenji_firebase.dart';

/// Standard implementation of [FirebaseAuthService].
class StdFirebaseAuthService extends FirebaseAuthService {
  /// The [FirebaseAuth] instance to use.
  final FirebaseAuth firebaseAuth;

  /// Standard implementation of [FirebaseAuthService].
  StdFirebaseAuthService(this.firebaseAuth);

  @override
  Future<void> applyActionCode(String code) {
    return firebaseAuth.applyActionCode(code);
  }

  @override
  Stream<User?> authStateChanges() {
    return firebaseAuth.authStateChanges().asBroadcastStream();
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) {
    return firebaseAuth.checkActionCode(code);
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    return firebaseAuth.confirmPasswordReset(
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  void dispose() {}

  @override
  Future<UserCredential> getRedirectResult() {
    return firebaseAuth.getRedirectResult();
  }

  @override
  Stream<User?> idTokenChanges() {
    return firebaseAuth.idTokenChanges().asBroadcastStream();
  }

  @override
  bool isSignInWithEmailLink(String emailLink) {
    return firebaseAuth.isSignInWithEmailLink(emailLink);
  }

  @override
  Future<void> revokeTokenWithAuthorizationCode(String authorizationCode) {
    return firebaseAuth.revokeTokenWithAuthorizationCode(authorizationCode);
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    return firebaseAuth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  @override
  Future<void> sendSignInLinkToEmail({
    required String email,
    required ActionCodeSettings actionCodeSettings,
  }) {
    return firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  @override
  Future<void> setLanguageCode(String? languageCode) {
    return firebaseAuth.setLanguageCode(languageCode);
  }

  @override
  Future<void> setPersistence(Persistence persistence) {
    return firebaseAuth.setPersistence(persistence);
  }

  @override
  Future<void> setSettings({
    bool appVerificationDisabledForTesting = false,
    String? userAccessGroup,
    String? phoneNumber,
    String? smsCode,
    bool? forceRecaptchaFlow,
  }) {
    return firebaseAuth.setSettings(
      appVerificationDisabledForTesting: appVerificationDisabledForTesting,
      userAccessGroup: userAccessGroup,
      phoneNumber: phoneNumber,
      smsCode: smsCode,
      forceRecaptchaFlow: forceRecaptchaFlow,
    );
  }

  @override
  Future<UserCredential> signInAnonymously() {
    return firebaseAuth.signInAnonymously();
  }

  @override
  Future<UserCredential> signInWithAuthProvider(AuthProvider provider) {
    return firebaseAuth.signInWithProvider(provider);
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) {
    return firebaseAuth.signInWithCustomToken(token);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) {
    return firebaseAuth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
  }

  @override
  Future<ConfirmationResult> signInWithPhoneNumber(
    String phoneNumber, [
    RecaptchaVerifier? verifier,
  ]) {
    return firebaseAuth.signInWithPhoneNumber(phoneNumber, verifier);
  }

  @override
  Future<UserCredential> signInWithPopup(AuthProvider provider) {
    return firebaseAuth.signInWithPopup(provider);
  }

  @override
  Future<UserCredential> signInWithProvider(AuthProvider provider) {
    return firebaseAuth.signInWithProvider(provider);
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) {
    return firebaseAuth.signInWithRedirect(provider);
  }

  @override
  Future<void> signOut() {
    return firebaseAuth.signOut();
  }

  @override
  Future<void> useAuthEmulator(
    String host,
    int port, {
    bool automaticHostMapping = true,
  }) {
    return firebaseAuth.useAuthEmulator(
      host,
      port,
      automaticHostMapping: automaticHostMapping,
    );
  }

  @override
  Stream<User?> userChanges() {
    return firebaseAuth.userChanges().asBroadcastStream();
  }

  @override
  Future<String> verifyPasswordResetCode(String code) {
    return firebaseAuth.verifyPasswordResetCode(code);
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
  }) {
    return firebaseAuth.verifyPhoneNumber(
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }
}
