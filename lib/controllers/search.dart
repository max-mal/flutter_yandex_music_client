import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test/controllers/home.dart';
import 'package:test/models/search_result.dart';

class SearchController extends GetxController {
  Rxn<SearchResult> result = Rxn<SearchResult>();
  TextEditingController searchController = TextEditingController();

  final homeController = Get.find<HomeController>();

  onSearch() async {
    result(await homeController.search(searchController.text));
  }
}
