class User {
  String id;
  String name;
  String lastname;
  String picture;

  User({this.id, this.name, this.lastname, this.picture});

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      id: parsedJson["_id"],
      name: parsedJson["firstName"] as String,
      lastname: parsedJson["lastName"] as String,
      picture: parsedJson["picture"] as String,
    );
  }
}
