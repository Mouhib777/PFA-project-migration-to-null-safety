class UserData {
  Token? token;
  User? user;

  UserData({this.token, this.user});

  UserData.fromJson(Map<String, dynamic> json) {
    token = json['token'] != null ? new Token.fromJson(json['token']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.token != null) {
      data['token'] = this.token!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class Token {
  String? tokenType;
  String? accessToken;
  String? refreshToken;
  String? expiresIn;

  Token({this.tokenType, this.accessToken, this.refreshToken, this.expiresIn});

  Token.fromJson(Map<String, dynamic> json) {
    tokenType = json['tokenType'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    expiresIn = json['expiresIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tokenType'] = this.tokenType;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['expiresIn'] = this.expiresIn;
    return data;
  }
}

class User {
  String? id;
  String? name;
  String? lastname;
  String? email;
  String? confirmationCode;
  bool? validateCompte;
  String? role;
  List<Null>? topics;
  String? createdAt;

  User(
      {this.id,
      this.name,
      this.lastname,
      this.email,
      this.role,
      this.confirmationCode,
      this.validateCompte,
      this.topics,
      this.createdAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lastname = json['lastname'];
    confirmationCode = json['confirmationCode'];
    validateCompte = json['validateCompte'];
    email = json['email'];
    role = json['role'];

    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['lastname'] = this.lastname;
    data['email'] = this.email;
    data['confirmationCode'] = this.confirmationCode;
    data['validateCompte'] = this.validateCompte;
    data['role'] = this.role;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
