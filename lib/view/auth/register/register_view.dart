import 'package:bookingmanager/core/services/firebase/auth/auth_service.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/core/services/navigation/navigation_service.dart';
import 'package:bookingmanager/core/utils/popup_helper.dart';
import 'package:bookingmanager/view/auth/verify_email/verify_email_view.dart';
import 'package:bookingmanager/view/main/home/home_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _emailController =
      TextEditingController(text: kDebugMode ? "ertu1ertu@hotmail.com" : null);
  final TextEditingController _passwordController =
      TextEditingController(text: kDebugMode ? "Ertuertu27" : null);

  final TextEditingController _displayNameController =
      TextEditingController(text: kDebugMode ? "Ertuğrul Çakıcı" : null);

  final StateProvider<bool> _isObscureProvider =
      StateProvider<bool>((ref) => true);

  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.register_title.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _emailField(),
                const SizedBox(height: 16.0),
                _passwordField(),
                const SizedBox(height: 16.0),
                _displayNameField(),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _register,
                  child: Text(LocaleKeys.register_register_button.tr()),
                ),
              ],
            )),
      ),
    );
  }

  TextFormField _displayNameField() {
    return TextFormField(
      controller: _displayNameController,
      onSaved: (newValue) {
        _displayNameController.text = newValue!;
      },
      decoration:
          InputDecoration(labelText: LocaleKeys.register_name_hint.tr()),
    );
  }

  Consumer _passwordField() {
    return Consumer(
      builder: (context, ref, child) {
        return TextFormField(
          onSaved: (newValue) {
            _passwordController.text = newValue!;
          },
          controller: _passwordController,
          obscureText: ref.watch(_isObscureProvider),
          autocorrect: false,
          decoration: InputDecoration(
              labelText: LocaleKeys.register_password_label.tr(),
              hintText: LocaleKeys.register_password_hint.tr(),
              suffixIcon: IconButton(
                  onPressed: () {
                    ref.read(_isObscureProvider.notifier).state =
                        !ref.watch(_isObscureProvider);
                  },
                  icon: Icon(ref.watch(_isObscureProvider)
                      ? Icons.visibility_off
                      : (Icons.visibility)))),
        );
      },
    );
  }

  TextFormField _emailField() {
    return TextFormField(
      onSaved: (newValue) {
        _emailController.text = newValue!;
      },
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: LocaleKeys.register_email_label.tr(),
        hintText: LocaleKeys.register_email_hint.tr(),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await PopupHelper.showLoadingWhile(() async =>
            await AuthService.instance.register(
                email: _emailController.text,
                password: _passwordController.text,
                displayName: _displayNameController.text));
        if (AuthService.instance.didEmailVerified) {
          NavigationService.toPageAndRemoveUntil(const HomeView());
        } else {
          NavigationService.toPageAndRemoveUntil(const VerifyEmailView());
        }
      } catch (e) {
        PopupHelper.showSnackBar(message: e.toString(), error: true);
      }
    }
  }
}
