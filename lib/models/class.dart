import 'package:docu_diary/models/models.dart';

class Class {
  String id;
  String teacherId;
  String className;
  String schoolYear;
  String createdAt;
  int updatedAt;
  List<Topic> topics;
  List<Student> students;
  bool hasActiveObservation = false;
  Observation observation;
  String selectedTopicId;
  String selectedControlId;
  bool synchronize = false;
  bool isDeleted = false;
  bool topicsIsUpdated = false;
  List<Observation> observations; // history of observations to synchronize

  Class(
      {this.teacherId,
      this.className,
      this.schoolYear,
      this.synchronize = false,
      this.topics = const [],
      this.students = const [],
      this.observations = const []});

  Class.fromJson(Map<String, dynamic> json) {
    teacherId = json['teacherId'];
    className = json['className'];
    schoolYear = json['schoolYear'];
    id = json['_id'] ?? json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'] is int
        ? json['updatedAt']
        : DateTime.parse(json['updatedAt']).millisecondsSinceEpoch;
    if (json["topics"].length > 0) {
      topics = List<Topic>.from(json["topics"].map((e) => Topic.fromJson(e)));
    } else {
      topics = [];
    }
    if (json["students"] != null && json["students"].length > 0) {
      students =
          List<Student>.from(json["students"].map((e) => Student.fromJson(e)));
    } else {
      students = [];
    }

    if (json["observation"] != null) {
      observation = Observation.fromJson(json["observation"]);
    } else {
      observation = null;
    }
    hasActiveObservation = json['hasActiveObservation'] ?? false;
    selectedTopicId = json['selectedTopicId'];
    selectedControlId = json['selectedControlId'];
    synchronize = json['synchronize'] ?? false;
    isDeleted = json['isDeleted'] ?? false;
    if (json["observations"] != null && json["observations"].length > 0) {
      observations = List<Observation>.from(
          json["observations"].map((e) => Observation.fromJson(e)));
    } else {
      observations = [];
    }
    topicsIsUpdated = json['topicsIsUpdated'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['teacherId'] = this.teacherId;
    data['className'] = this.className;
    data['schoolYear'] = this.schoolYear;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['topics'] = List<dynamic>.from(this.topics.map((e) => e.toJson()));
    data['students'] = List<dynamic>.from(this.students.map((e) => e.toJson()));
    data['observation'] = this.observation?.toJson();
    data['hasActiveObservation'] = this.hasActiveObservation;
    data['selectedTopicId'] = this.selectedTopicId;
    data['selectedControlId'] = this.selectedControlId;
    data['synchronize'] = this.synchronize;
    data['isDeleted'] = this.isDeleted;
    data['observations'] =
        List<dynamic>.from(this.observations.map((e) => e.toJson()));
    data['topicsIsUpdated'] = this.topicsIsUpdated;
    return data;
  }
}
