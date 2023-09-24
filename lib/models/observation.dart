class Observation {
  String? id;
  String? title;
  String? classId;
  String? topicId;
  String? controlId;
  String? topicName;
  String? controlName;
  List<ObservationRating>? ratings;
  String? type;
  bool? completed;
  bool? synchronize;
  bool? isDeleted;
  Observation(
      {this.id,
      this.title,
      this.classId,
      this.topicId,
      this.controlId,
      this.topicName,
      this.controlName,
      this.ratings = const [],
      this.type,
      this.completed = false,
      this.synchronize = false,
      this.isDeleted = false});

  Observation.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    title = json['title'];
    classId = json['classId'];
    topicId = json['topicId'];
    controlId = json['controlId'];
    topicName = json['topicName'];
    controlName = json['controlName'];
    if (json["ratings"] != null && json["ratings"].length > 0) {
      ratings = List<ObservationRating>.from(
          json["ratings"].map((e) => ObservationRating.fromJson(e)));
    } else {
      ratings = [];
    }
    type = json['type'];
    completed = json['completed'] ?? false;
    synchronize = json['synchronize'] ?? false;
    isDeleted = json['isDeleted'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['classId'] = this.classId;
    data['topicId'] = this.topicId;
    data['controlId'] = this.controlId;
    data['topicName'] = this.topicName;
    data['controlName'] = this.controlName;
    data['ratings'] = List<dynamic>.from(this.ratings!.map((e) => e.toJson()));
    data['type'] = this.type;
    data['completed'] = this.completed;
    data['synchronize'] = this.synchronize;
    data['isDeleted'] = this.isDeleted;
    return data;
  }
}

class ObservationRating {
  String? id;
  String? studentId;
  String? name;
  String? firstName;
  String? lastName;
  int? rating;
  bool? isFavorite;
  String? picture;

  ObservationRating(
      {this.id,
      this.firstName,
      this.lastName,
      this.rating,
      this.isFavorite,
      this.picture,
      this.studentId});

  ObservationRating.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    studentId = json['studentId'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    name = firstName! + " " + lastName!;
    rating = json['rating'];
    picture = json['picture'];
    isFavorite = json['is_favorite'] ?? json['isFavorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['studentId'] = this.studentId;
    data['name'] = this.name;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['rating'] = this.rating;
    data['isFavorite'] = this.isFavorite;
    data['picture'] = this.picture;
    return data;
  }
}
