import 'dart:async';

import 'package:bookingmanager/core/services/navigation/navigation_service.dart';
import 'package:bookingmanager/product/constants/image_enums.dart';
import 'package:bookingmanager/view/auth/login/login_view.dart';
import 'package:bookingmanager/view/main/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/firebase/auth/auth_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initRuntime();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ImageEnums.logo.assetImage(width: 120),
            const SizedBox(height: 24.0),
            Text("Booking Manager",
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24.0),
            CircularProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initRuntime() async {
    if (await AuthService.instance.isLoggedIn) {
      NavigationService.toPageAndRemoveUntil(const HomeView());
    } else {
      NavigationService.toPageAndRemoveUntil(const LoginView());
    }
  }
}
