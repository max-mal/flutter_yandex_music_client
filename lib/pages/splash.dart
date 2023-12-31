import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:test/controllers/splash.dart';
import 'package:test/parts/splash/code_request_button.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              'YaMusic',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          Obx(
            () => controller.isCodeRequested.value
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Pinput(
                      onCompleted: (code) {
                        controller.onCodeEntered(code);
                      },
                      length: 7,
                      showCursor: true,
                      controller: controller.pinputController,
                      focusNode: controller.pinputFocusNode,
                    ),
                  )
                : const SizedBox(),
          ),
          Obx(
            () => controller.canRequestCode.value
                ? SplashCodeRequestButton(onPressed: controller.onRequestCode)
                : const SizedBox(),
          ),

          Obx(
            () => controller.canEnterTokenManually.value
                ? SplashCodeRequestButton(onPressed: controller.onEnterTokenManually, text: 'Enter token',)
                : const SizedBox(),
          ),
          Obx(
            () => controller.showTokenInput.value
                ? Center(
                  child: SizedBox(
                    width: 150,
                    child: TextField(
                      controller: controller.tokenController,
                      decoration: const InputDecoration(
                          label: Text('Token'),
                      ),
                      onSubmitted: (_) {
                        controller.onTokenSubmitted();
                      },
                    ),
                  ),
                )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
