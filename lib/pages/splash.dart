import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          autocorrect: false,
                          controller: controller.codeController,
                          decoration: const InputDecoration(
                            label: Text("Enter code")
                          ),
                          onSubmitted: (value) {
                            controller.onCodeEntered(value);
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.onCodeEntered(controller.codeController.text);
                        },
                        child: const Text('OK'),
                      )
                    ],
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
                ? SplashCodeRequestButton(
                    onPressed: controller.onEnterTokenManually,
                    text: 'Enter token',
                  )
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
