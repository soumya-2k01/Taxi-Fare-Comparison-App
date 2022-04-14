// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:firebase_database/firebase_database.dart';

class Users
{
  String? id;
  String? name;
  String? email;
  String? phone;

  Users({this.id, this.name, this.email, this.phone});

  Users.fromSnapshot(DataSnapshot data)
  {
    id = data.key;
    name = data.value['Name'];
    email = data.value['Email'];
    phone = data.value['Mobile'];
  }
}