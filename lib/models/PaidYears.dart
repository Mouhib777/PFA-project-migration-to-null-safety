class PaidYears {
  String? sId;
  String? name;
  int? updatedAt;

  PaidYears({this.sId, this.name, this.updatedAt});

  PaidYears.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
