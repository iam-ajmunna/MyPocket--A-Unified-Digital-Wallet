import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import '../Home/WalletScreen.dart';
import 'api_service.dart';

class OTPScreen extends StatelessWidget {
  final String tOTpTitle;
  final String tOtpSubTitle;
  final String tOtpMessage;

  const OTPScreen({
    Key? key,
    required this.tOTpTitle,
    required this.tOtpSubTitle,
    required this.tOtpMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tOTpTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 80.0,
              ),
            ),
            Text(
              tOtpSubTitle.toUpperCase(),
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 40.0),
            Text(
              '$tOtpMessage support@codingwitht.com',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            OtpTextField(
              mainAxisAlignment: MainAxisAlignment.center,
              numberOfFields: 6,
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              onSubmit: (code) {
                OTPController.instance.verifyOTP(code);
              },
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("tNext"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPController extends GetxController {
  static OTPController get instance => Get.find();

  Future<void> verifyOTP(String otp) async {
    var isVerified = await AuthenticationRepository.instance.verifyOTP(otp);
    if (isVerified) {
      Get.offAll(const WalletScreen());
    } else {}
  }
}