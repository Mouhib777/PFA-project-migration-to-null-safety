import 'package:docu_diary/models/control.dart';

class Topic {
  String? id;
  bool? selected;
  String? name;
  String? order;
  String? color;
  List<Control>? controls;

  // default color is black
  Topic(
      {this.id,
      this.name,
      this.order,
      this.color = "0xff000000",
      this.selected = true,
      this.controls = const []});

  Topic.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    selected = json['selected'];
    name = json['name'];
    order = json['order'];
    color = json['color'];
    if (json["controls"] != null && json["controls"].length > 0) {
      controls =
          List<Control>.from(json["controls"].map((e) => Control.fromJson(e)));
    } else {
      controls = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['selected'] = this.selected;
    data['name'] = this.name;
    data['order'] = this.order;
    data['color'] = this.color;
    data['controls'] = List<dynamic>.from(this.controls!.map((e) => e.toJson()));
    return data;
  }
}
