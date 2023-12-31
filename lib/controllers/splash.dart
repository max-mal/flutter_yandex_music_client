import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/pages/home.dart';
import 'package:test/use_cases/login.dart';

class SplashController extends GetxController {
  RxBool canRequestCode = false.obs;
  RxBool isCodeRequested = false.obs;
  TextEditingController pinputController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  FocusNode pinputFocusNode = FocusNode();

  RxBool canEnterTokenManually = false.obs;
  RxBool showTokenInput = false.obs;

  final LoginUseCase loginUseCase = LoginUseCase();

  @override
  onReady() {
    _initApplication();
    super.onReady();
  }

  _initApplication() async {
    loginUseCase.loadAccessToken();

    if (loginUseCase.isAuthorized()) {
      Get.offAll(() => HomePage());
      return;
    }

    canRequestCode(true);
    canEnterTokenManually(true);
  }

  onRequestCode() {
    showTokenInput(false);
    loginUseCase.requestCode();
    isCodeRequested(true);
    pinputFocusNode.requestFocus();
  }

  onCodeEntered(String code) async {
    Get.closeAllSnackbars();
    try {
      await loginUseCase.authorizeByCode(code);
    } catch (e) {
      Get.snackbar('Error', 'Failed to log in. Please try again');
      pinputController.text = "";
      rethrow;
    }
    Get.offAll(() => HomePage());
  }

  onEnterTokenManually() {
    canEnterTokenManually(false);
    showTokenInput(true);
  }

  onTokenSubmitted() async {
    showTokenInput(false);
    canEnterTokenManually(true);
    Get.closeAllSnackbars();
    try {
      await loginUseCase.authorizeByToken(tokenController.text);
    } catch (e) {
      Get.snackbar('Error', 'Failed to log in. Please try again');
      rethrow;
    }
    Get.offAll(() => HomePage());
  }
}
