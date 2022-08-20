import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class OAuthService extends GetxService {
  static const String oauthHost = "oauth.yandex.ru";
  static const String clientId = "23cabbbdc6cd418abb4b39c32c41195d";
  static const String clientSecret = "53bc75238f0c4d08a118e51fe9203300";

  Future<OAuthService> init() async {
    return this;
  }

  openRequestCodeUri() async {
    await launchUrl(
      Uri.https(oauthHost, "/authorize", {
        'response_type': "code",
        'client_id': clientId,
        'force_confirm': 'yes',
      }),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<String> getTokenFromCode(String code) async {
    final response = await http.post(Uri.https(oauthHost, '/token'), body: {
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'client_secret': clientSecret,
      'code': code,
    });
    if (kDebugMode) {
      print(response.body);
    }
    final decoded = jsonDecode(response.body);

    if (decoded['access_token'] == null) {
      throw "Failed to get token";
    }

    return decoded['access_token'].toString();
  }
}
