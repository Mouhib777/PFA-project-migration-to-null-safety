class PupilsModel {
  String? birthdayDate;
  int? rating;
  int? observation;
  String? sId;
  String? firstName;
  String? lastName;
  String? classId;
  String? className;
  String? emergencyNumber;
  String? schoolYear;
  String? teacherId;
  late List<Topics> topics;
  String? picture;

  PupilsModel(
      {this.birthdayDate,
      this.rating,
      this.observation,
      this.sId,
      this.firstName,
      this.lastName,
      this.classId,
      this.className,
      this.emergencyNumber,
      this.schoolYear,
      this.teacherId,
       required this.topics,
      this.picture});

  PupilsModel.fromJson(Map<String, dynamic> json) {
    birthdayDate = json['birthdayDate'];
    rating = json['rating'];
    observation = json['observation'];
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    classId = json['classId'];
    className = json['className'];
    emergencyNumber = json['emergencyNumber'];
    schoolYear = json['schoolYear'];
    teacherId = json['teacherId'];
    picture = json['picture'];
    if (json['topics'] != null) {
      topics =  [];
      json['topics'].forEach((v) {
        topics.add(new Topics.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['birthdayDate'] = this.birthdayDate;
    data['rating'] = this.rating;
    data['observation'] = this.observation;
    data['_id'] = this.sId;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['classId'] = this.classId;
    data['className'] = this.className;
    data['emergencyNumber'] = this.emergencyNumber;
    data['schoolYear'] = this.schoolYear;
    data['teacherId'] = this.teacherId;
    data['picture'] = this.picture;
    if (this.topics != null) {
      data['topics'] = this.topics.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Topics {
  int? rating;
  int? observation;
  String? sId;
  String? name;

  Topics({this.rating, this.observation, this.sId, this.name});

  Topics.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    observation = json['observation'];
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['observation'] = this.observation;
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}
