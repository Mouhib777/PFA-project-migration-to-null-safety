import 'dart:convert';

PuplisReport puplisReportFromJson(String str) =>
    PuplisReport.fromJson(json.decode(str));

String puplisReportToJson(PuplisReport data) => json.encode(data.toJson());

class PuplisReport {
  String? sId;
  String? className;
  String? schoolYear;
  String? firstName;
  String? lastName;
  String? emergencyNumber;
  int? rating;
  int? observation;
  String? picture;
  List<Topics>? topics;

  PuplisReport(
      {this.sId,
      this.className,
      this.schoolYear,
      this.firstName,
      this.lastName,
      this.emergencyNumber,
      this.rating,
      this.observation,
      this.picture,
      this.topics});

  PuplisReport.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    className = json['className'];
    schoolYear = json['schoolYear'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    emergencyNumber = json['emergencyNumber'];
    rating = json['rating'];
    observation = json['observation'];
    picture = json['picture'];
    if (json['topics'] != null) {
      topics =  [];
      json['topics'].forEach((v) {
        topics!.add(new Topics.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['className'] = this.className;
    data['schoolYear'] = this.schoolYear;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['emergencyNumber'] = this.emergencyNumber;
    data['rating'] = this.rating;
    data['observation'] = this.observation;
    data['picture'] = this.picture;
    if (this.topics != null) {
      data['topics'] = this.topics!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Topics {
  String? sId;
  String? name;
  int? rating;
  int? observation;
  List<Controls>? controls;
  String? topicColor;

  Topics(
      {this.sId,
      this.name,
      this.rating,
      this.observation,
      this.controls,
      this.topicColor});

  Topics.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    rating = json['rating'];
    observation = json['observation'];
    if (json['controls'] != null) {
      controls =  [];
      json['controls'].forEach((v) {
        controls!.add(new Controls.fromJson(v));
      });
    }
    topicColor = json['topicColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['rating'] = this.rating;
    data['observation'] = this.observation;
    if (this.controls != null) {
      data['controls'] = this.controls!.map((v) => v.toJson()).toList();
    }
    data['topicColor'] = this.topicColor;
    return data;
  }
}

class Controls {
  String? sId;
  String? name;
  List<Observations>? observations;

  Controls({this.sId, this.name, this.observations});

  Controls.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    if (json['observations'] != null) {
      observations =  [];
      json['observations'].forEach((v) {
        observations!.add(new Observations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.observations != null) {
      data['observations'] = this.observations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Observations {
  String? observationId;
  bool? completed;
  String? topicId;
  String? controlId;
  String? type;
  String? title;
  String? topicName;
  String? controlName;
  int? rating;
  String? date;
  String? dateOfUpdate;

  Observations(
      {this.observationId,
      this.completed,
      this.topicId,
      this.controlId,
      this.type,
      this.title,
      this.topicName,
      this.controlName,
      this.rating,
      this.date,
      this.dateOfUpdate});

  Observations.fromJson(Map<String, dynamic> json) {
    observationId = json['observationId'];
    completed = json['completed'];
    topicId = json['topicId'];
    controlId = json['controlId'];
    type = json['type'];
    title = json['title'];
    topicName = json['topicName'];
    controlName = json['controlName'];
    rating = json['rating'];
    date = json['date'];
    dateOfUpdate = json['dateOfUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['observationId'] = this.observationId;
    data['completed'] = this.completed;
    data['topicId'] = this.topicId;
    data['controlId'] = this.controlId;
    data['type'] = this.type;
    data['title'] = this.title;
    data['topicName'] = this.topicName;
    data['controlName'] = this.controlName;
    data['rating'] = this.rating;
    data['date'] = this.date;
    data['dateOfUpdate'] = this.dateOfUpdate;

    return data;
  }
}
