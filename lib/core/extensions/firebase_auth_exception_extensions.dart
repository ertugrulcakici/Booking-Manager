import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

extension FirebaseAuthExceptionExtensions on FirebaseAuthException {
  ErrorDescription get localized {
    switch (code) {
      case "invalid-email":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_invalid_mail.tr());
      case "email-already-in-use":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_email_already_in_use.tr());
      case "operation-not-allowed":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_operation_not_allowed.tr());
      case "weak-password":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_weak_password.tr());
      case "missing-android-pkg-name":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_missing_android_pkg_name.tr());
      case "missing-continue-uri":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_missing_continue_uri.tr());
      case "missing-ios-bundle-id":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_missing_ios_bundle_id.tr());
      case "invalid-continue-uri":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_invalid_continue_uri.tr());
      case "unauthorized-continue-uri":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_unauthorized_continue_uri.tr());
      case "user-not-found":
        throw ErrorDescription(LocaleKeys.commons_user_not_found.tr());
      case "user-disabled":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_user_disabled.tr());
      case "wrong-password":
        throw ErrorDescription(
            LocaleKeys.exception_extensions_wrong_password.tr());
      default:
        throw ErrorDescription(LocaleKeys.general_unknown_error.tr());
    }
  }
}
