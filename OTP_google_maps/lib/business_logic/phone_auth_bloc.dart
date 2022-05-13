import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneAuthBloc {
  String? verificationId;

  // i love to do it with streams may i need more than listeners at the same time
  StreamController<bool?> isLoadingController = StreamController<bool?>.broadcast();

  //another pure isLoading for otp screen
  bool otpIsLoading = false; 

  Future<void> submitPhoneToFirebase(
      String phoneNumber, BuildContext context) async {
    try{
      isLoadingController.add(true);
      await FirebaseAuth.instance.verifyPhoneNumber(
        timeout: const Duration(seconds: 60),
        phoneNumber: '+2$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await signIn(credential,context);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print("verificationFailed");
          }
          _buildExceptionDialog(context, e.toString());
        },
        codeSent: (String verificationId, int? resendToken)async {
          // the code is sent and the phone number have id so navigate to otp and rst loading
          this.verificationId = verificationId;
          final prefs =  await SharedPreferences.getInstance();
          prefs.setString("verificationId",verificationId);
          if (kDebugMode) {
            print('verificationId : '+this.verificationId!);
          }
          isLoadingController.add(false);
          Navigator.pushNamed(context, Routes.otpScreen,arguments: phoneNumber);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print("verification retrieval timeout ");
          }
        },
      );
    }catch (e){
      _buildExceptionDialog(context,e.toString());
    }finally{
      isLoadingController.add(false);
    }
  }

  void _buildExceptionDialog(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          error,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> submitWithOtp(String otpCode,BuildContext context) async {
    if (kDebugMode) {
      print('verificationId : '+verificationId.toString()+" otp code : "+otpCode);
    }
    try{
        otpIsLoading = true;
      final prefs =  await SharedPreferences.getInstance();
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId:  prefs.getString("verificationId")!, smsCode: otpCode);
      await signIn(credential, context);
    } catch(e){
      if (kDebugMode) {
        print("submit otp Failed");
      }
      _buildExceptionDialog(context, e.toString());
    }finally{
        otpIsLoading = false;
    }
  }

  Future<void> signIn(credential, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential).then((value) =>
          Navigator.of(context).pushReplacementNamed(Routes.mapScreen));
    } catch (e) {
      if (kDebugMode) {
        print("sign in otp Failed");
      }
      _buildExceptionDialog(context,e.toString());
    }
  }

  void dispose() {
    isLoadingController.close();
  }
}
