import 'dart:convert';

MyTopic myTopicFromJson(String str) => MyTopic.fromJson(json.decode(str));

String myTopicToJson(MyTopic data) => json.encode(data.toJson());

class MyTopic {
  String? sId;
  bool? selected;
  String? classId;
  String? name;
  String? order;
  String? color;
  String? controlname;

  MyTopic(
      this.sId, this.selected, this.name, this.order, this.color, this.classId);

  MyTopic.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    selected = json['selected'];
    name = json['name'];
    order = json['order'];
    color = json['color'];
    controlname = json['controlname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['topicId'] = this.sId;
    data['selected'] = this.selected;
    data['name'] = this.name;
    data['order'] = this.order;
    data['color'] = this.color;
    data['classId'] = this.classId;

    return data;
  }
}
