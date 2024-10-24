class User {
  final BigInt? userId;
  final String username;
  final String email;
  final String firstname;
  final String lastname;
  final String password;

  User({
    this.userId,
    required this.username,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.password
  });


  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['userId'] != null ? BigInt.parse(json['userId'].toString()) : null,
      username: json['username'],
      email: json['email'],
      firstname: json['firstname'],
      lastname:  json['lastname'],
      password: json['password']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'user_id' : userId,
      'username' : username,
      'email' : email,
      'firstname' : firstname,
      'lastname' : lastname,
      'password' : password
    };
  }
}
