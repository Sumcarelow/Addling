import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddHealthNew extends StatefulWidget {
  const AddHealthNew({Key? key}) : super(key: key);

  @override
  State<AddHealthNew> createState() => _AddHealthNewState();
}

class _AddHealthNewState extends State<AddHealthNew> {

  List<DocumentSnapshot> amenities = [];
  ///Get amenities list from Firebase
  void getAmenities() async{
    //print("STarted pilling");
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').get();
   // print("Done pulling");
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.length == 0){
      setState(() {
        amenities = [];
      });
    } else{
      setState(() {
        amenities = documents;
      });
    }
  }
  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAmenities();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
