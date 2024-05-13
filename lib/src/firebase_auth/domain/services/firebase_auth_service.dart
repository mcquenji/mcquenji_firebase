import 'package:firebase_auth/firebase_auth.dart';
import 'package:mcquenji_core/mcquenji_core.dart';

/// Service for working with Firebase Authentication.
///
/// Wraps the [FirebaseAuth] class from the `firebase_auth` package for use in a modular environment.
abstract class FirebaseAuthService extends Service {
  @override
  String get name => 'FirebaseAuth';

  /// Applies a verification code sent to the user by email or other out-of-band mechanism.
  Future<void> applyActionCode(String code);

  /// Notifies about changes to the user's sign-in state (such as sign-in or sign-out).
  Stream<User?> authStateChanges();

  /// Checks a verification code sent to the user by email or other out-of-band mechanism.
  Future<ActionCodeInfo> checkActionCode(String code);

  /// Completes the password reset process, given a confirmation code and new password.
  Future<void> confirmPasswordReset(
      {required String code, required String newPassword});

  /// Tries to create a new user account with the given email address and password.
  Future<UserCredential> createUserWithEmailAndPassword(
      {required String email, required String password});

  /// Returns a UserCredential from the redirect-based sign-in flow.
  Future<UserCredential> getRedirectResult();

  /// Notifies about changes to the user's sign-in state (such as sign-in or sign-out) and also token refresh events.
  Stream<User?> idTokenChanges();

  /// Checks if an incoming link is a sign-in with email link.
  bool isSignInWithEmailLink(String emailLink);

  /// Revokes token using an authorization code for users signed in with Apple provider.
  Future<void> revokeTokenWithAuthorizationCode(String authorizationCode);

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(
      {required String email, ActionCodeSettings? actionCodeSettings});

  /// Sends a sign in with email link to provided email address.
  Future<void> sendSignInLinkToEmail(
      {required String email, required ActionCodeSettings actionCodeSettings});

  /// Sets the user-facing language code to the default app language when set to null.
  Future<void> setLanguageCode(String? languageCode);

  /// Changes the current type of persistence on the current Auth instance for the currently saved Auth session.
  Future<void> setPersistence(Persistence persistence);

  /// Updates the current instance with the provided settings.
  Future<void> setSettings({
    bool appVerificationDisabledForTesting = false,
    String? userAccessGroup,
    String? phoneNumber,
    String? smsCode,
    bool? forceRecaptchaFlow,
  });

  /// Asynchronously creates and becomes an anonymous user.
  Future<UserCredential> signInAnonymously();

  /// Signs in with an AuthProvider using native authentication flow. Deprecated in favor of signInWithProvider().
  Future<UserCredential> signInWithAuthProvider(
      AuthProvider provider); // Deprecated

  /// Asynchronously signs in to Firebase with the given 3rd-party credentials and returns additional identity provider data.
  Future<UserCredential> signInWithCredential(AuthCredential credential);

  /// Tries to sign in a user with a given custom token.
  Future<UserCredential> signInWithCustomToken(String token);

  /// Attempts to sign in a user with the given email address and password.
  Future<UserCredential> signInWithEmailAndPassword(
      {required String email, required String password});

  /// Signs in using an email address and email sign-in link.
  Future<UserCredential> signInWithEmailLink(
      {required String email, required String emailLink});

  /// Starts a sign-in flow for a phone number.
  Future<ConfirmationResult> signInWithPhoneNumber(String phoneNumber,
      [RecaptchaVerifier? verifier]);

  /// Authenticates a Firebase client using a popup-based OAuth authentication flow.
  Future<UserCredential> signInWithPopup(AuthProvider provider);

  /// Signs in with an AuthProvider using native authentication flow.
  Future<UserCredential> signInWithProvider(AuthProvider provider);

  /// Authenticates a Firebase client using a full-page redirect flow.
  Future<void> signInWithRedirect(AuthProvider provider);

  /// Signs out the current user.
  Future<void> signOut();

  /// Changes this instance to point to an Auth emulator running locally.
  Future<void> useAuthEmulator(String host, int port,
      {bool automaticHostMapping = true});

  /// Notifies about changes to any user updates.
  Stream<User?> userChanges();

  /// Checks a password reset code sent to the user by email or other out-of-band mechanism.
  Future<String> verifyPasswordResetCode(String code);

  /// Starts a phone number verification process for the given phone number.
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
  });
}
