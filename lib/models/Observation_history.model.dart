import 'dart:convert';

Observation observationFromJson(String str) =>
    Observation.fromJson(json.decode(str));

String observationToJson(Observation data) => json.encode(data.toJson());

class Observation {
  String sId;
  String title;
  String classId;
  String topicId;
  String controlId;
  String type;
  String studentId;
  String topicName;
  String controlName;
  Student student;
  int rating;
  String date;
  String topicColor;
  String createdAt;
  String dateofupdate;
  String dateofcreate;

  Observation(
      {this.sId,
      this.title,
      this.classId,
      this.topicId,
      this.controlId,
      this.type,
      this.studentId,
      this.topicName,
      this.controlName,
      this.student,
      this.rating,
      this.date,
      this.topicColor,
      this.createdAt,
      this.dateofupdate,
      this.dateofcreate});

  Observation.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    classId = json['classId'];
    topicId = json['topicId'];
    controlId = json['controlId'];
    type = json['type'];
    studentId = json['studentId'];
    topicName = json['topicName'];
    controlName = json['controlName'];
    student =
        json['student'] != null ? new Student.fromJson(json['student']) : null;
    rating = json['rating'];
    date = json['date'];
    topicColor = json['topicColor'];
    createdAt = json['createdAt'];
    dateofupdate = json['dateofupdate'];
    dateofcreate = json['dateofcreate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['classId'] = this.classId;
    data['topicId'] = this.topicId;
    data['controlId'] = this.controlId;
    data['type'] = this.type;
    data['studentId'] = this.studentId;
    data['topicName'] = this.topicName;
    data['controlName'] = this.controlName;
    if (this.student != null) {
      data['student'] = this.student.toJson();
    }
    data['rating'] = this.rating;
    data['date'] = this.date;
    data['topicColor'] = this.topicColor;
    data['createdAt'] = this.createdAt;
    data['dateofupdate'] = this.dateofupdate;
    data['dateofcreate'] = this.dateofcreate;

    return data;
  }
}

class Student {
  String sId;
  String firstName;
  String lastName;
  String className;
  String emergencyNumber;
  String schoolYear;
  String picture;

  Student(
      {this.sId,
      this.firstName,
      this.lastName,
      this.className,
      this.emergencyNumber,
      this.schoolYear,
      this.picture});

  Student.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    className = json['className'];
    emergencyNumber = json['emergencyNumber'];
    schoolYear = json['schoolYear'];
    picture = json['picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['className'] = this.className;
    data['emergencyNumber'] = this.emergencyNumber;
    data['schoolYear'] = this.schoolYear;
    data['picture'] = this.picture;

    return data;
  }
}
