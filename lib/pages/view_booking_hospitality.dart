///Page for displaying Hospitality Businesses
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';


class ViewHospitality extends StatefulWidget {
  final String businessID;
  const ViewHospitality({Key? key, required this.businessID}) : super(key: key);

  @override
  State<ViewHospitality> createState() => _ViewHospitalityState();
}

class _ViewHospitalityState extends State<ViewHospitality> {
  ///Variables
  List<DocumentSnapshot> listings = [];

  ///Fetch Business Listings from Firebase
  fetchData() async {
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('listings').where('businessID', isEqualTo: widget.businessID).get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if list is empty
    if(documents.isNotEmpty){
      setState(() {
        listings = documents;
      });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      ///App Bar
      appBar: AppBar(
        title: Text('${widget.businessID}'),
      ),

      body: Container(
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
