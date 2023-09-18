class Control {
  bool hasActiveObservation = false;
  String id;
  String controlName;

  Control({this.hasActiveObservation = false, this.id, this.controlName});

  Control.fromJson(Map<String, dynamic> json) {
    hasActiveObservation = json['hasActiveObservation'];
    id = json['_id'] ?? json['id'];
    controlName = json['controlname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasActiveObservation'] = this.hasActiveObservation;
    data['_id'] = this.id;
    data['controlname'] = this.controlName;
    return data;
  }
}
