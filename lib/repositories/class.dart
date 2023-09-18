import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class ClassRepository {
  static final _baseUrl = BaseUrl.urlAPi;

  Future<List<Class>> loadOfflineClasses({@required String token}) async {
    final url = '$_baseUrl/class/offline';
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "bearer " + token,
      },
    );
    if (response.statusCode != 200) {
      throw new Exception('error load classes');
    }

    Iterable json = jsonDecode(response.body);
    var classes = json.map((e) => Class.fromJson(e)).toList();
    return classes;
  }

  Future<List<Control>> getControls(
      {@required String token,
      @required String topicId,
      @required String classId}) async {
    final url = classId != null
        ? '$_baseUrl/teacher/getControlsByTopicsId/?topicId=$topicId&classId=$classId'
        : '$_baseUrl/teacher/getControlsByTopicsId/?topicId=$topicId';
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "bearer " + token,
      },
    );

    if (response.statusCode != 200) {
      throw new Exception('error get controls');
    }

    Iterable json = jsonDecode(response.body);

    var controls = json.map((e) => Control.fromJson(e)).toList();
    return controls;
  }

  Future<bool> updateTopics(
      {@required String token, @required Class cls}) async {
    List<Map<String, dynamic>> topics = cls.topics.map((e) {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['topicId'] = e.id;
      data['selected'] = e.selected;
      data['name'] = e.name;
      data['order'] = e.order;
      data['color'] = e.color;
      return data;
    }).toList();
    Map<String, dynamic> data = {
      'topics': jsonEncode(topics),
      'classId': cls.id,
    };

    final response = await http.post('$_baseUrl/class/addTopicsToClass',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "bearer " + token
        },
        body: data);
    if (response.statusCode != 200) {
      throw new Exception('error update topics');
    }
    return true;
  }

  Future<List<Student>> getStudents(
      {@required String token, @required String classId}) async {
    final url = '$_baseUrl/student/getStudentByClassId/?classId=$classId';
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "bearer " + token,
      },
    );

    if (response.statusCode != 200) {
      throw new Exception('error get controls');
    }

    Iterable json = jsonDecode(response.body);

    return json.map((e) => Student.fromJson(e)).toList();
  }

  Future<Observation> getObservation(
      {@required String token,
      @required String classId,
      @required String topicId,
      @required String controlId}) async {
    final url =
        '$_baseUrl/observation/structured?classId=$classId&topicId=$topicId&controlId=$controlId';
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    Map<String, dynamic> json = jsonDecode(response.body);
    return Observation.fromJson(json);
  }

  Future<Observation> createStructuredObservation(
      {@required String token,
      @required String classId,
      @required String topicId,
      @required String controlId,
      @required String name}) async {
    Map<String, dynamic> data = {
      "title": name,
      "classId": classId,
      "topicId": topicId,
      "controlId": controlId
    };

    String body = jsonEncode(data);

    final response = await Dio().post(
      '$_baseUrl/observation/structured',
      data: body,
      options: Options(
        headers: <String, String>{
          'Authorization': "Bearer " + token,
        },
        contentType: "application/json",
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error create structured observation');
    }
    return Observation.fromJson(response.data);
  }

  Future<Observation> editObservationName(
      {@required String token,
      @required String observationId,
      @required String name}) async {
    Map<String, dynamic> data = {'title': name, 'observationId': observationId};

    final response = await http.put(
      '$_baseUrl/observation/$observationId/name',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(data),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error edit structured observation');
    }

    Map<String, dynamic> json = jsonDecode(response.body);

    return Observation.fromJson(json);
  }

  Future<bool> completeObservation(
      {@required String token, @required String observationId}) async {
    final response = await http.put(
      '$_baseUrl/observation/$observationId/complete',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error complete structured observation');
    }

    return true;
  }

  Future<bool> deleteObservation(
      {@required String token, @required String observationId}) async {
    final response = await http.delete(
      '$_baseUrl/observation/$observationId',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error delete structured observation');
    }

    return true;
  }

  Future<bool> updateRating(
      {@required String token,
      @required String observationId,
      @required String studentId,
      @required int rating}) async {
    Map<String, dynamic> data = {
      'rating': rating,
    };
    final response = await http.put(
      '$_baseUrl/observation/$observationId/students/$studentId/rating',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error update rating');
    }

    return true;
  }

  Future loadClassesList({@required String token}) async {
    final url = '$_baseUrl/class';
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "bearer " + token,
      },
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body).toList();

      return responseJson;
    } else {
      throw "Can't get classes.";
    }
  }

  Future<Class> addClass(
      {@required String className,
      @required String token,
      @required String schoolYear}) async {
    Map<String, dynamic> data = {'className': className, 'year': schoolYear};
    final http.Response response = await http.post('$_baseUrl/class',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "Bearer " + token
        },
        body: data);
    if (response.statusCode != 200) {
      throw new Exception('error add class');
    }

    Map<String, dynamic> json = jsonDecode(response.body);
    return Class.fromJson(json);
  }

  Future<bool> updateFavorite(
      {@required String token,
      @required String observationId,
      @required String studentId,
      @required bool isFavorite}) async {
    Map<String, dynamic> data = {
      'is_favorite': isFavorite,
    };
    final response = await http.put(
      '$_baseUrl/observation/$observationId/students/$studentId/favorites',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error update favorite');
    }

    return true;
  }

  Future<String> deleteClass(
      {@required String classId, @required String token}) async {
    final http.Response response =
        await http.delete('$_baseUrl/class/$classId', headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': "Bearer " + token
    });
    if (response.statusCode != 200) {
      throw new Exception('error delete class');
    }
    return 'delete';
  }

  Future<Topic> addTopic(
      {@required String token,
      @required String topicName,
      @required String schoolYear,
      String topicOrder,
      String topicColor}) async {
    Map<String, dynamic> data = {'name': topicName, 'year': schoolYear};
    if (topicOrder != null && topicOrder.isNotEmpty) {
      data['order'] = topicOrder;
    }
    if (topicColor != null && topicColor.isNotEmpty) {
      data['color'] = topicColor;
    }
    final http.Response response = await http.post('$_baseUrl/class/topic',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token
        },
        body: jsonEncode(data));

    if (response.statusCode != 200) {
      throw new Exception('error add topic to all classes');
    }
    Map<String, dynamic> json = jsonDecode(response.body);
    return Topic.fromJson(json);
  }

  Future<bool> deleteTopic(
      {@required String token,
      @required String name,
      @required String schoolYear}) async {
    Map<String, dynamic> data = {'name': name, 'year': schoolYear};

    final http.Response response =
        await http.put('$_baseUrl/teacher/delete-topic',
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': "bearer " + token
            },
            body: data);

    if (response.statusCode != 200) {
      throw new Exception('error delete topic');
    }
    return true;
  }

  Future<bool> updateTopicName(
      {@required String token,
      @required String oldName,
      @required String newName,
      @required String schoolYear}) async {
    Map<String, dynamic> data = {
      'oldName': oldName,
      'newName': newName,
      'year': schoolYear
    };

    final http.Response response =
        await http.put('$_baseUrl/teacher/updatecontrole',
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': "bearer " + token
            },
            body: data);

    if (response.statusCode != 200) {
      throw new Exception('error update topic name');
    }
    return true;
  }

  Future<bool> updateTopicColor(
      {@required String token,
      @required String topicId,
      @required String topicColor}) async {
    Map<String, dynamic> data = {'color': topicColor};

    final http.Response response =
        await http.put('$_baseUrl/class/topics/$topicId/color',
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': "Bearer " + token
            },
            body: data);

    if (response.statusCode != 200) {
      throw new Exception('error update topic name');
    }
    return true;
  }

  Future<bool> sortTopics(
      {@required String token,
      @required List<Topic> topics,
      @required String schoolYear}) async {
    var jsonTopics = List<dynamic>.from(topics.asMap().entries.map((e) {
      int idx = e.key + 1;
      Topic val = e.value;
      Map<String, dynamic> obj = {
        'name': val.name,
        'order': '$idx',
        'color': val.color
      };
      return obj;
    }));

    Map<String, dynamic> data = {
      'topics': jsonEncode(jsonTopics),
      'year': schoolYear
    };
    final http.Response response =
        await http.put('$_baseUrl/teacher/updateAllTopic',
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': "bearer " + token
            },
            body: data);

    if (response.statusCode != 200) {
      throw new Exception('error sort topics');
    }
    return true;
  }

  Future<bool> updateControls(
      {@required String token, @required Topic topic}) async {
    var jsonTopics = List<dynamic>.from(topic.controls.map((e) {
      Map<String, dynamic> obj = {
        'controlname': e.controlName,
      };
      return obj;
    }));

    Map<String, dynamic> data = {
      'controls': jsonEncode(jsonTopics),
      'topicId': topic.id
    };

    final http.Response response =
        await http.put('$_baseUrl/teacher/addControls',
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': "bearer " + token
            },
            body: data);

    if (response.statusCode != 200) {
      throw new Exception('error update controls');
    }
    return true;
  }

  Future<bool> updateClassName(
      {@required String token,
      @required String classId,
      @required String className}) async {
    Map<String, dynamic> data = {'className': className};

    final http.Response response =
        await http.put('$_baseUrl/class/$classId/name',
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': "bearer " + token
            },
            body: data);

    if (response.statusCode != 200) {
      throw new Exception('error update class name');
    }
    return true;
  }

  Future<bool> synchronizeClasses(
      {@required String token, @required List<Class> classes}) async {
    var jsonClasses = List<dynamic>.from(classes.map((e) {
      Map<String, dynamic> obj = {
        'name': e.className,
        'isDeleted': e.isDeleted,
        'topicsIsUpdated': e.topicsIsUpdated,
        'schoolYear': e.schoolYear,
        'topics': List<dynamic>.from(e.topics.map((t) {
          Map<String, dynamic> obj = {
            'name': t.name,
            'selected': t.selected,
            'order': t.order,
            'color': t.color,
            'controls': List<dynamic>.from(t.controls.map((c) {
              Map<String, dynamic> obj = {
                'controlname': c.controlName,
                'hasActiveObservation': c.hasActiveObservation,
              };
              if (c.id != null) {
                obj['_id'] = c.id;
              }
              return obj;
            }))
          };
          if (t.id != null) {
            obj['_id'] = t.id;
          }
          return obj;
        })),
        'observations': List<dynamic>.from(
            e.observations.where((o) => o.synchronize == true).map((o) {
          Map<String, dynamic> obj = {
            'isDeleted': o.isDeleted,
            'title': o.title,
            'classId': o.classId,
            'topicId': o.topicId,
            'controlId': o.controlId,
            'topicName': o.topicName,
            'controlName': o.controlName,
            'type': o.type,
            'completed': o.completed,
          };

          if (o.type == 'STRUCTURED') {
            obj['ratings'] = List<dynamic>.from(
                o.ratings.where((r) => r.rating > 0).map((rt) {
              Map<String, dynamic> obj = {
                'studentId': rt.studentId,
                'rating': rt.rating,
                'isFavorite': rt.isFavorite
              };
              return obj;
            }));
          } else {
            obj['ratings'] = List<dynamic>.from(o.ratings.map((rt) {
              Map<String, dynamic> obj = {
                'studentId': rt.studentId,
                'rating': rt.rating,
              };
              return obj;
            }));
          }
          if (o.id != null) {
            obj['_id'] = o.id;
          }
          return obj;
        })),
      };
      if (e.id != null) {
        obj['_id'] = e.id;
      }
      return obj;
    }));

    Map<String, dynamic> data = {
      'classes': jsonEncode(jsonClasses),
    };

    final http.Response response = await http.post('$_baseUrl/class/sync',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "Bearer " + token
        },
        body: data);

    if (response.statusCode != 200) {
      throw new Exception('error sync classes');
    }
    return true;
  }
}
