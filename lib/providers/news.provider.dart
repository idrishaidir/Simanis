import 'package:flutter/material.dart';
import 'package:SIMANIS_V1/helpers/api.dart';
import 'package:SIMANIS_V1/models/TopNews.model.dart';
import 'package:SIMANIS_V1/utils/const.dart';

class NewsProvider with ChangeNotifier {
  bool isDataEmpty = true;

  bool isLoading = true;
  bool isLoadingSearch = true;
  TopNewsModel? resNews;
  TopNewsModel? resSearch;
  setLoading(data) {
    isLoading = data;
    notifyListeners();
  }

  getTopNews() async {
    // panggil API Get News
    final res = await api(
      '${baseUrl}top-headlines?country=us&category=business&apiKey=$apiKey',
    );

    if (res.statusCode == 200) {
      resNews = TopNewsModel.fromJson(res.data);
    } else {
      resNews = TopNewsModel();
    }
    isLoading = false;
    notifyListeners();
  }

  search(String search) async {
    isDataEmpty = false;
    isLoadingSearch = true;
    final res = await api(
      '${baseUrl}everything?q=${search}&sortBy=popularity&apiKey=$apiKey',
    );

    if (res.statusCode == 200) {
      resSearch = TopNewsModel.fromJson(res.data);
    } else {
      resSearch = TopNewsModel();
    }
    isLoadingSearch = false;
    notifyListeners();
  }
}
