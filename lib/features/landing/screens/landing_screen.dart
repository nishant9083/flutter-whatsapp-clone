import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/utils/colors.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
import 'package:whatsapp_ui/features/auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  static const String routeName = '/landing-screen';
  const LandingScreen({Key? key}) : super(key: key);

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                'Welcome to ChatBh',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? titleColor
                      : lightTabColor,
                ),
              ),
              SizedBox(height: size.height / 12),
              Image.asset(
                'assets/iit-bh.png',
                height: 340,
                width: 340,
                color: Colors.blue[900],
              ),
              SizedBox(height: size.height / 9),
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
                  style: TextStyle(color: greyColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width * 0.75,
                child: CustomButton(
                  text: 'AGREE AND CONTINUE',
                  onPressed: () => navigateToLoginScreen(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
