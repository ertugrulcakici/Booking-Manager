import 'package:bookingmanager/core/services/firebase/auth/auth_service.dart';
import 'package:bookingmanager/core/services/navigation/navigation_service.dart';
import 'package:bookingmanager/core/utils/popup_helper.dart';
import 'package:bookingmanager/view/auth/login/login_view.dart';
import 'package:bookingmanager/view/main/home/home_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/localization/locale_keys.g.dart';

class VerifyEmailView extends ConsumerStatefulWidget {
  const VerifyEmailView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerifyEmailViewState();
}

class _VerifyEmailViewState extends ConsumerState<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!AuthService.instance.didEmailVerified) {
          PopupHelper.showOkCancelDialog(
              title: LocaleKeys.general_attention.tr(),
              content: LocaleKeys.verify_email_mail_not_verified_yet.tr(),
              onOk: () {
                AuthService.instance.signOut();
                NavigationService.toPageAndRemoveUntil(const LoginView());
              },
              onCancel: () {
                Navigator.of(context).pop();
              });
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(LocaleKeys.verify_email_mail_verification.tr()),
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocaleKeys.verify_email_check_mail_message.tr(),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () async {
                PopupHelper.showLoadingWhile(() async {
                  await AuthService.instance.reloadCurrentUser();
                  await _checkApproved();
                });
              },
              child: Text(LocaleKeys.verify_email_i_verified.tr()))
        ],
      ),
    );
  }

  Future<void> _checkApproved() async {
    if (AuthService.instance.didEmailVerified) {
      AuthService.instance.initAllServicesAndListeners();
      NavigationService.toPageAndRemoveUntil(const HomeView());
      PopupHelper.showSnackBar(
          message: LocaleKeys.verify_email_mail_verified.tr());
    } else {
      PopupHelper.showSnackBar(
          message: LocaleKeys.verify_email_mail_verified_error.tr(),
          error: true);
      NavigationService.toPageAndRemoveUntil(const LoginView());
      await AuthService.instance.signOut();
    }
  }
}
