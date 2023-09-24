import 'dart:convert';

Classes classesFromJson(String str) => Classes.fromJson(json.decode(str));

String classesToJson(Classes data) => json.encode(data.toJson());

class Classes {
  String? teacherId;
  String? className;
  String? sid;
  String? createdAt;
  String? updatedAt;
  int? version;
  Classes(this.sid, this.teacherId, this.className);

// get
  Classes.fromJson(Map<String, dynamic> json) {
    teacherId = json['teacherId'];
    className = json['className'];
    sid = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    version = json['__v'];
  }

  //post
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sid;
    data['teacherId'] = this.teacherId;
    data['className'] = this.className;

    return data;
  }
}
