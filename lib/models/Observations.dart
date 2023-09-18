class ObservationsModel {
  String title;
  String classId;
  String topicId;
  String controlId;
  Rating rating;

  ObservationsModel(
      {this.title, this.classId, this.topicId, this.controlId, this.rating});

  ObservationsModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    classId = json['classId'];
    topicId = json['topicId'];
    controlId = json['controlId'];
   // rating = json['rating'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['classId'] = this.classId;
    data['topicId'] = this.topicId;
    data['controlId'] = this.controlId;
  //  data['rating'] = this.rating;

    return data;
  }
}

class Rating {
  int value;
  String studentId;
  Rating(int v , String studentId ){

    this.value = v ;
    this.studentId = studentId ;

  }
  Rating.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    studentId = json['studentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['studentId'] = this.studentId;
    return data;
  }
}