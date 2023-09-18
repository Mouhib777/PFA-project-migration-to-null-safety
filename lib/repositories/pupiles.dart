import 'dart:convert';
import 'package:docu_diary/config/url.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

class PupilesRepository {
  static final _baseUrl = BaseUrl.urlAPi;

  Future<bool> addPupiles(
      {@required String token, @required Map student}) async {
    final response = await http.post(
      '$_baseUrl/student',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "bearer " + token,
      },
      body: jsonEncode(student),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error');
    }

    return true;
  }

  Future<bool> editStudent(
      {@required String token,
      @required String id,
      @required Map student}) async {
    final response = await http.put(
      '$_baseUrl/student/$id',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(student),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error');
    }

    return true;
  }

  Future<bool> deleteUserPicture(
      {@required String token, @required String id}) async {
    final response = await http.delete(
      '$_baseUrl' + 'student/$id/picture',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error');
    }

    return true;
  }

  Future<bool> deleteStudent(
      {@required String token, @required String id}) async {
    final response = await http.delete(
      '$_baseUrl/student/$id',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error');
    }

    return true;
  }

  Future<List> getClasses(
      {@required String token, @required String currentYear}) async {
    List selectData = [];
    final response = await http.get(
      '$_baseUrl/class/?year=$currentYear',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "bearer " + token,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return selectData;
    }
    final responseJson = json.decode(response.body).toList();

    selectData = responseJson;
    return responseJson;
  }

  Future<String> getStudentPicture(
      {@required String token, @required String studentId}) async {
    String url = '';

    final response = await http.get(
      '$_baseUrl/student/$studentId/picture/url',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return '';
    }
    final json = jsonDecode(response.body);
    url = json != '' ? '$_baseUrl$json' : '';
    return url;
  }

  Future<String> uploadPicture(
      {@required String token,
      @required String studentId,
      @required String fileName}) async {
    //  String fileName = galleryFile.path;

    String mimeType = mime(fileName);
    String mimee = mimeType.split('/')[0];
    String type = mimeType.split('/')[1];
    Dio dio = new Dio();
    dio.options.headers["Content-Type"] = "multipart/form-data";
    dio.options.headers["Authorization"] = "Bearer " + token;
    FormData formData = new FormData.fromMap({
      'file': await MultipartFile.fromFile(fileName,
          filename: fileName, contentType: MediaType(mimee, type))
    });
    await dio
        .post(
          '$_baseUrl/student/$studentId/picture',
          data: formData,
        )
        .catchError((e) => {});

    return '';
  }
}
