import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../business_logic/phone_auth_bloc.dart';

// ignore: must_be_immutable
class OtpScreen extends StatelessWidget {

  String? otpCode;
  late String phoneNumber;
  PhoneAuthBloc? bloc;

  OtpScreen({Key? key,required this.phoneNumber,this.bloc}) : super(key: key);

  static Widget create(BuildContext context,String phoneNumber) {
    return Consumer<PhoneAuthBloc>(
        builder: (_, bloc, widget) =>
            OtpScreen(
              bloc: bloc, phoneNumber: phoneNumber,
            ),
    );
  }

  Widget _buildIntroTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify your phone number',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: RichText(
            text: TextSpan(text:'enter the code sent to ',style: const TextStyle(color: Colors.black,fontSize: 16), children: <TextSpan>[
              TextSpan(
                  text: "+2$phoneNumber",
                  style: const TextStyle(color: Colors.blue)),
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroTexts(),
                const SizedBox(
                  height: 110,
                ),
                _buildOtpField(context),
                const SizedBox(
                  height: 70,
                ),
                bloc!.otpIsLoading?const Center(child: CircularProgressIndicator(),):_buildVerifyButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          bloc?.submitWithOtp(otpCode!,context);
        },
        child: const Text(
          'Next',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(110, 50),
          primary: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  _buildOtpField(BuildContext context) {
    return PinCodeTextField(

        appContext: context,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        keyboardType: TextInputType.number,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          activeFillColor: Colors.blue.shade100,
          activeColor: Colors.blue,
          disabledColor: Colors.grey,
          errorBorderColor: Colors.red,
          inactiveColor: Colors.grey,
          inactiveFillColor: Colors.white,
          selectedColor: Colors.blue,
          selectedFillColor: Colors.white,
        ),
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.blue.shade50,
        enableActiveFill: true,
        autoFocus: true,
        cursorColor: Colors.black,
        onCompleted: (v) {
          if (kDebugMode) {
            print("Completed");
          }
          otpCode = v;
        },
        onChanged: (value) {
          if (kDebugMode) {
            print(value);
          }
          otpCode = value;
        });
  }
}
