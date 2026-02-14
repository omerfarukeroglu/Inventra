import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMapper {
  static String getMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Girdiğiniz şifre hatalı. Lütfen tekrar deneyin.';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi formatı.';
        case 'weak-password':
          return 'Şifreniz çok zayıf. En az 6 karakterli daha güçlü bir şifre seçin.';
        case 'operation-not-allowed':
          return 'Bu giriş yöntemi şu anda devre dışı.';
        case 'too-many-requests':
          return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
        case 'network-request-failed':
          return 'İnternet bağlantınızı kontrol edin.';
        case 'user-disabled':
          return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
        default:
          return 'Bir hata oluştu: ${error.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
