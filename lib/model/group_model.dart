import 'package:cloud_firestore/cloud_firestore.dart';

class Group{
  String name;
  String groupCode;
  String createdBy;
  Timestamp createdAt;

Group(this.name, this.groupCode, this.createdBy,  this.createdAt);
}