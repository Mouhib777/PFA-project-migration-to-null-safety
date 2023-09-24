class Student {
  int? rating;
  int observation = 0;
  String? id;
  String? name;
  String? firstName;
  String? lastName;
  String? classId;
  String? className;
  String? emergencyNumber;
  String? schoolYear;
  String? teacherId;
  String? birthdayDate;
  String? picture;
  List<TopicRating>? topics;

  Student(
      {this.rating,
      required this.observation,
      this.id,
      this.firstName,
      this.lastName,
      this.classId,
      this.className,
      this.emergencyNumber,
      this.schoolYear,
      this.teacherId,
      this.topics,
      this.birthdayDate,
      this.picture});

  Student.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    observation = json['observation'];
    id = json['_id'] ?? json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    name = firstName! + " " + lastName!;
    classId = json['classId'];
    className = json['className'];
    emergencyNumber = json['emergencyNumber'];
    schoolYear = json['schoolYear'];
    teacherId = json['teacherId'];
    birthdayDate = json['birthdayDate'];
    picture = json['picture'];
    if (json["topics"].length > 0) {
      topics = List<TopicRating>.from(
          json["topics"].map((e) => TopicRating.fromJson(e)));
    } else {
      topics = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['observation'] = this.observation;
    data['_id'] = this.id;
    data['firstName'] = this.firstName;
    data['name'] = this.name;
    data['lastName'] = this.lastName;
    data['classId'] = this.classId;
    data['className'] = this.className;
    data['emergencyNumber'] = this.emergencyNumber;
    data['schoolYear'] = this.schoolYear;
    data['teacherId'] = this.teacherId;
    data['birthdayDate'] = this.birthdayDate;
    data['picture'] = this.picture;
    data['topics'] = List<dynamic>.from(this.topics!.map((e) => e.toJson()));

    return data;
  }
}

class TopicRating {
  int? rating;
  int? observation;
  String? id;
  String? name;

  TopicRating({this.rating, this.observation, this.id, this.name});

  TopicRating.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    observation = json['observation'];
    id = json['_id'] ?? json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['observation'] = this.observation;
    data['_id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
