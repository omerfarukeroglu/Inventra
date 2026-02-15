import 'package:firebase_auth/firebase_auth.dart';
import '../../../l10n/app_localizations.dart';

class AuthErrorMapper {
  static String getMessage(Object error, AppLocalizations l10n) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return l10n.errorUserNotFound;
        case 'wrong-password':
          return l10n.errorWrongPassword;
        case 'email-already-in-use':
          return l10n.errorEmailAlreadyInUse;
        case 'invalid-email':
          return l10n.errorInvalidEmail;
        case 'weak-password':
          return l10n.errorWeakPassword;
        case 'operation-not-allowed':
          return l10n.errorOperationNotAllowed;
        case 'too-many-requests':
          return l10n.errorTooManyRequests;
        case 'network-request-failed':
          return l10n.errorNetworkRequestFailed;
        case 'user-disabled':
          return l10n.errorUserDisabled;
        case 'invalid-credential':
          return l10n.invalidCredentialsError;
        default:
          return '${l10n.errorUnknown}: ${error.message}';
      }
    }
    return l10n.errorUnknown;
  }
}
