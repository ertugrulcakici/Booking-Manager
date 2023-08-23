import 'dart:developer';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:bookingmanager/core/services/firebase/auth/auth_service.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/core/services/navigation/navigation_service.dart';
import 'package:bookingmanager/core/utils/popup_helper.dart';
import 'package:bookingmanager/product/constants/image_enums.dart';
import 'package:bookingmanager/view/auth/forgot_password/forgot_password_view.dart';
import 'package:bookingmanager/view/auth/register/register_view.dart';
import 'package:bookingmanager/view/auth/verify_email/verify_email_view.dart';
import 'package:bookingmanager/view/main/home/home_view.dart';
import 'package:bookingmanager/view/settings/settings_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final StateProvider<bool> _isObscureProvider =
      StateProvider<bool>((ref) => false);

  late final GlobalKey<FormState> _formKey;

  String? email;
  String? password;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();

    AppTrackingTransparency.requestTrackingAuthorization().then((value) {
      log(value.toString());
      if (value != TrackingStatus.authorized) {
        Future.delayed(
            const Duration(seconds: 1),
            () async =>
                await AppTrackingTransparency.requestTrackingAuthorization());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body(), floatingActionButton: _settings());
  }

  Widget _body() {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              _logo(),
              _fields(),
              _forgotPassword(),
              const Spacer(),
              _loginButton(),
              _orLoginWith(),
              _googleLoginButton(),
              _registerButton(),
            ],
          ),
        ),
      ),
    );
  }

  Container _logo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      child: ImageEnums.logo.assetImage(width: 120),
    );
  }

  Widget _fields() {
    return Column(children: [
      TextFormField(
        onSaved: (newValue) {
          email = newValue;
        },
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        initialValue: kDebugMode ? "ertu1ertu@hotmail.com" : null,
        decoration: InputDecoration(
          labelText: LocaleKeys.login_email_label.tr(),
          hintText: LocaleKeys.login_email_hint.tr(),
        ),
      ),
      const SizedBox(height: 16),
      Consumer(
        builder: (context, ref, child) {
          return TextFormField(
            initialValue: kDebugMode ? "Ertuertu27" : null,
            obscureText: !ref.watch(_isObscureProvider),
            onSaved: (newValue) {
              password = newValue;
            },
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: LocaleKeys.login_password_label.tr(),
              hintText: LocaleKeys.login_password_hint.tr(),
              suffixIcon: IconButton(
                onPressed: () {
                  ref.read(_isObscureProvider.notifier).state =
                      !ref.watch(_isObscureProvider);
                },
                icon: Icon(ref.read(_isObscureProvider)
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
          );
        },
      ),
    ]);
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _loginWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(LocaleKeys.login_login_button.tr()),
    );
  }

  Widget _forgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          NavigationService.toPage(const ForgotPasswordView());
        },
        child: Text(LocaleKeys.login_forgot_password_button.tr()),
      ),
    );
  }

  Widget _registerButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(LocaleKeys.login_no_account_message.tr()),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () {
            NavigationService.toPage(const RegisterView());
          },
          child: Text(LocaleKeys.login_register_button.tr()),
        ),
      ],
    );
  }

  Widget _orLoginWith() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(LocaleKeys.login_or_login_with.tr()));
  }

  Widget _googleLoginButton() {
    return GestureDetector(
        onTap: _loginWithGoogle,
        child: SizedBox(
            height: 100,
            width: 100,
            child: Image.asset("assets/images/google_logo.png")));
  }

  FloatingActionButton _settings() {
    return FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          NavigationService.toPage(const SettingsView())
              .then((value) => setState(() {}));
        },
        child: const Icon(Icons.settings, size: 32));
  }

  Future<void> _loginWithGoogle() async {
    try {
      await PopupHelper.showLoadingWhile(AuthService.instance.loginWithGoogle);
      NavigationService.toPageAndRemoveUntil(const HomeView());
      PopupHelper.showSnackBar(message: LocaleKeys.login_login_successful.tr());
    } catch (e) {
      PopupHelper.showSnackBar(message: e.toString(), error: true);
    }
  }

  Future<void> _loginWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await PopupHelper.showLoadingWhile(() async => await AuthService
            .instance
            .login(email: email!, password: password!));
        if (AuthService.instance.didEmailVerified) {
          NavigationService.toPageAndRemoveUntil(const HomeView());
          PopupHelper.showSnackBar(
              message: LocaleKeys.login_login_successful.tr());
        } else {
          NavigationService.toPage(const VerifyEmailView());
        }
      } catch (e) {
        PopupHelper.showSnackBar(message: e.toString(), error: true);
      }
    }
  }
}
