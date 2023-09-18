class ControlModel {
  bool hasActiveObservation;
  String sId;
  String controlName;

  ControlModel({this.hasActiveObservation, this.sId, this.controlName});

  ControlModel.fromJson(Map<String, dynamic> json) {
    hasActiveObservation = json['hasActiveObservation'];
    sId = json['_id'];
    controlName = json['controlname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasActiveObservation'] = this.hasActiveObservation;
    data['_id'] = this.sId;
    data['controlname'] = this.controlName;
    return data;
  }
}
