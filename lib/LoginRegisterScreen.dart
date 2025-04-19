import 'package:chairbrow/utils/colors.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
          top: false,
          child: Container(
            margin: EdgeInsets.only(top: 40,),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/onboarding_sipeduli.png'),
                    fit: BoxFit.fill
                )
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                              (root) => false
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      alignment: Alignment.center,
                      child: Text('Mulai', style: TextStyle(
                          color: AppColors.quaternaryColor
                      ),
                    ),),
                  ),
                  const SizedBox(height: 60,),
                ],
              ),
            ),
          )
      ),
    );
  }
}