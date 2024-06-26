import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:temp/models/user_model.dart';

class DbHelper {
  static Database? _db;

  //In case return value is null walk around
  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  //db name
  static const String DB_Name = 'test.db';
  static const int Version = 1;

  //table name
  static const String Users = 'users';

  //table columns title
  static const int Uid = 0;
  static const String Fname = 'fname';
  static const String Lname = 'lname';
  static const String Email = 'email';
  static const String Bdate = 'bdate';
  static const String Pwd = 'pwd';
  static const String Img = 'img';

  //Initializing the db
  initDb() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_Name);
    var db = await openDatabase(path, version: Version, onCreate: _onCreate);
    return db;
  }

  //Creating the table Users for the Registration Form aka Sign Up
  _onCreate(Database db, int Version) async {
    await db.execute("CREATE TABLE $Users ("
        " $Fname VARCHAR NOT NULL, "
        " $Lname  VARCHAR NOT NULL, "
        " $Email  VARCHAR NOT NULL, "
        " $Bdate VARCHAR NOT NULL, "
        " $Pwd  VARCHAR NOT NULL, "
        " $Img VARCHAR NOT NULL, "
        " PRIMARY KEY ($Email))");
  }

  //Check if email is already used before registration
  Future<UserModel?> checkEmail(String email) async {
    var dbClient = await db;
    var res = await dbClient!.rawQuery("SELECT * FROM $Users WHERE "
        "$Email = '$email'  ");

    if (res.length > 0) {
      return null;
    }
    return UserModel(Fname, Lname, email, Bdate, Pwd, Img);
  }

  //User registration query
  Future<int> saveData(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient!.insert(Users, user.toMap());
    return res;
  }

  //Profile Image query
  Future<String?> getUsersProfile(String email) async {
    final dbClient = await db;
    final res = await dbClient!.query(
      Users,
      columns: [Img],
      where: '$Email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return res.first[Img] as String?;
    }
    return null;
  }

  //User login query
  Future<UserModel?> getLogInData(String email, String pwd) async {
    var dbClient = await db;
    var res = await dbClient!.rawQuery("SELECT * FROM $Users WHERE "
        "$Email = '$email' AND "
        "$Pwd = '$pwd' ");

    if (res.length > 0) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }

  //Password recovery query
  Future<String?> getPwd(String email) async {
    var dbClient = await db;
    var res = await dbClient!.rawQuery("SELECT $Pwd FROM $Users WHERE "
        "$Email = '$email'  ");

    if (res.length > 0) {
      return res.first[Pwd] as String?;
    }
    return null;
  }

  //Edit profile query to update info
  Future<int> updateUser(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient!.update(Users, user.toMap(),
        where: '$Email=?', whereArgs: [user.email]);
    return res;
  }
}
