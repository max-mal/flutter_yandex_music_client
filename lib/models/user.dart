import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  int uid;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String secondName;

  @HiveField(3)
  String fullName;

  @HiveField(4)
  String login;

  @HiveField(5)
  DateTime registeredAt;

  User({
    this.uid = 0,
    this.firstName = "",
    this.secondName = "",
    this.fullName = "",
    this.login = "",
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();
}
