import 'dart:convert';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static final _baseUrl = BaseUrl.urlAPi;

  Future<UserData> login(
      {@required String? email, @required String? password}) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    Map<String, dynamic> data = {
      'email': email!.trim(),
      'password': password!.trim(),
    };
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setString('email', email);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw new Exception('error user login');
    }

    final json = jsonDecode(response.body);
    return UserData.fromJson(json);
  }

  Future<UserData> register(
      {@required String? name,
      @required String? email,
      @required String? password,
      @required String? confirmPassword}) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'name': name,
    };
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setString('email', email!);
    prefs.setString('password', password!);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw new Exception('error user login');
    }
    final json = jsonDecode(response.body);
    return UserData.fromJson(json);
  }

  Future<String> forgetPassword({@required String? email}) async {
    final url = Uri.parse('$_baseUrl/auth/send-password-reset');
    Map<String, dynamic> data = {
      'email': email,
    };
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setString('email', email!);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw new Exception('error user login');
    }
    return "Succes";
  }

  Future<String> resetPassword(
      {@required String? code, @required String? password}) async {
    final url = Uri.parse('$_baseUrl/auth/send-password-reset-by-code');
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('email') ?? '';

    Map<String, dynamic> data = {
      'resetCode': code,
      'password': password,
      'email': email,
    };
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw new Exception('error user login');
    }
    return "Succes";
  }
}
