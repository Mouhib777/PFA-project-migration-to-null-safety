import 'dart:convert';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';

class PayementRepository {
  static final _baseUrl = BaseUrl.urlAPi;

  Future<List<PaidYears>> getYears({@required String token}) async {
    final url = '$_baseUrl/payement/getYears';
    // set value

    final prefs = await SharedPreferences.getInstance();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none && !kIsWeb) {
      final saved = prefs.get('years');

      Iterable json = jsonDecode(saved);

      final years = json.map((e) => PaidYears.fromJson(e)).toList();

      // List<PaidYears> yearss = await _yearDao.getYears();

      return years;
    } else {
      // set value

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "bearer " + token,
        },
      );
      if (response.statusCode != 200) {}

      // _yearDao.insert(dede[0].PaidYears);
      // PaidYears aaa = await _yearDao.getYear();

      Iterable json = jsonDecode(response.body);

      var years = json.map((e) => PaidYears.fromJson(e)).toList();

      prefs.setString('years', response.body);

      // List<PaidYears> yearss = await _yearDao.getYears();

      return years;
    }
  }
}
