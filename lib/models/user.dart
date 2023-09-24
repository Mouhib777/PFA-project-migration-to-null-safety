import 'package:docu_diary/models/PaidYears.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? picture;
  String? confirmationCode;
  bool? validateCompte;
  String? role;
  String? createdAt;
  String? currentSubscription;
  String? expirationDate;
  List<PaidYears>? paidYears;

  User(
      {this.id,
      this.name,
      this.email,
      this.picture,
      this.role,
      this.confirmationCode,
      this.validateCompte,
      this.createdAt,
      this.currentSubscription,
      this.expirationDate,
      this.paidYears});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    confirmationCode = json['confirmationCode'];
    validateCompte = json['validateCompte'];
    email = json['email'];
    picture = json['picture'];
    role = json['role'];
    createdAt = json['createdAt'];
    currentSubscription = json['currentSubscription'];
    expirationDate = json['expirationDate'];
    if (json['paidYears'] != null) {
      paidYears = [];
      json['paidYears'].forEach((v) {
        paidYears!.add(new PaidYears.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['picture'] = this.picture;
    data['confirmationCode'] = this.confirmationCode;
    data['validateCompte'] = this.validateCompte;
    data['role'] = this.role;
    data['createdAt'] = this.createdAt;
    data['currentSubscription'] = this.currentSubscription;
    data['expirationDate'] = this.expirationDate;
    if (this.paidYears != null) {
      data['paidYears'] = this.paidYears!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
