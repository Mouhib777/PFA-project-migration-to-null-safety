import 'package:dio/dio.dart';
import 'package:docu_diary/config/url.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ObservationRepository {
  static final _baseUrl = BaseUrl.urlAPi;

  Future<bool> sendObservation(
      {@required String? token, @required Map? data}) async {
    final response = await Dio().post(
      '$_baseUrl/observation/spontaneous',
      data: data,
      options: Options(
        headers: <String, String>{'Authorization': "Bearer " + token!},
        contentType: "application/json",
      ),
    );
    if (response.statusCode! < 200 || response.statusCode! >= 300) {
      throw new Exception('error in send observation');
    }

    return true;
  }

  Future<List> loadObservation(
      {@required String? token, @required String? selectYear}) async {
    final response = await http.get(Uri.parse(
      '$_baseUrl/class/?year=$selectYear'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token!,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error');
    }
    final responseJson = json.decode(response.body).toList();

    return responseJson;
  }

  Future<List> fetchPeople(
      {@required String? token, @required String? id}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/student/getStudentByClassId/?classId=$id'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token!,
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw new Exception('error');
      }

      final responseJson = json.decode(response.body).toList();
      return responseJson;
    } catch (e) {
      return [];
    }
  }

  Future<List> getStudentsObservations(
      {@required String? token, @required String? id}) async {
    try {
      final response = await http.get(
    Uri.parse('$_baseUrl/observation/history/?classId=$id'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token!,
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw new Exception('error');
      }

      final responseJson = json.decode(response.body).toList();
      return responseJson;
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteSpontaneousObservation(
      {@required String? token, @required String? observationId}) async {
    Map<String, dynamic> data = {
      'observationId': observationId,
    };

    final response = await http.put(Uri.parse('$_baseUrl/observation/delete'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token!,
        },
        body: jsonEncode(data));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error');
    }

    return true;
  }

  Future<bool> deleteStructuredObservation(
      {@required String? token,
      @required String? observationId,
      @required String? studentId}) async {
    final response = await http.delete(Uri.parse(
      '$_baseUrl/observation/$observationId/students/$studentId/rating'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token!,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error');
    }

    return true;
  }

  Future<List> getTopicsByClass(
      {@required String? token, @required String? classId}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/class/getClassTopics?classId=$classId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token!
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw new Exception('error');
      }
      final responseJson = json.decode(response.body).toList();

      return responseJson;
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendeditObservation(
      {@required String? token,
      @required String? id,
      @required Map? observation}) async {
    final response = await Dio().put(
      '$_baseUrl/observation/$id/spontaneous',
      data: observation,
      options: Options(
        headers: <String, String>{'Authorization': "Bearer " + token!},
        contentType: "application/json",
      ),
    );
    if (response.statusCode! < 200 || response.statusCode! >= 300) {
      throw new Exception('error');
    }

    return true;
  }

  Future<List> getPuplisReport({
    @required String? token,
    @required String? studentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/student/$studentId/report'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token!,
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw new Exception('error');
      }
      final responseJson = json.decode(response.body);

      var reportDetails = [];
      reportDetails.add(responseJson);
      reportDetails = reportDetails.toList();
      return reportDetails;
    } catch (e) {
      return [];
    }
  }

  Future<String> getPuplisReportPdf({
    @required String? token,
    @required String? studentId,
    @required List? observationList,
  }) async {
    try {
      final response = await Dio().put(
        '$_baseUrl/student/$studentId/report/pdf',
        data: observationList,
        options: Options(
          headers: <String, String>{'Authorization': "Bearer " + token!},
          contentType: "application/json",
        ),
      );

      if (response.statusCode! < 200 || response.statusCode! >= 300) {
        throw new Exception('error');
      }

      // var reportDetails = [];
      // reportDetails.add(responseJson);
      // reportDetails = reportDetails.toList();
      return response.data;
    } catch (e) {
      return '';
    }
  }
}
