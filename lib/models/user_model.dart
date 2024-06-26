class UserModel {
  late String fname;
  late String lname;
  late String email;
  late String bdate;
  late String pwd;
  late String img;

  UserModel(this.fname, this.lname, this.email, this.bdate, this.pwd, this.img);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'fname': fname,
      'lname': lname,
      'email': email,
      'bdate': bdate,
      'pwd': pwd,
      'img': img,
    };
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    fname = map['fname'];
    lname = map['lname'];
    email = map['email'];
    bdate = map['bdate'];
    pwd = map['pwd'];
    img = map['img'];
  }
}
