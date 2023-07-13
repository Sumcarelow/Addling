///Re-used UI Elements
///
///

import 'package:adlinc/extras/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


///Listing Class
class Listing {
  final String name, description, price;
  final List<DocumentSnapshot> pics;
  final DocumentSnapshot doc;

  Listing({required this.name, required this.description, required this.pics, required this.price, required this.doc});

}