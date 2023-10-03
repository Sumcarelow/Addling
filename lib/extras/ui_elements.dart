///Re-used UI Elements
///
///

import 'package:adlinc/extras/colors.dart';
import 'package:adlinc/extras/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

///Listing Class
class Listing {
  final String name, description, price;
  final List<DocumentSnapshot> pics;
  final DocumentSnapshot doc;

  Listing({required this.name, required this.description, required this.pics, required this.price, required this.doc});

}

///Loading Screen
Container loadingScreen(){
  return
    isLoading
        ?
    Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: getColor('green', 1.0),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Processing Please Wait...', style: TextStyle(color: getColor('black', 1.0))),
            )
          ],
        ),
      ),
    )
        : Container();
}