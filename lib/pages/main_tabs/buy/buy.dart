///Page to facilitate the Buy feature for the App
import 'package:adlinc/extras/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../extras/colors.dart';
import '../../../extras/data.dart';
import '../../../extras/full_photos.dart';
import '../../../extras/ui_elements.dart';
import '../../../extras/variables.dart';
import '../../product_pages/view_bait.dart';
import '../../single_business_views/view_business.dart';


class Buy extends StatefulWidget {
  final String userID;
  const Buy({super.key, required this.userID});

  @override
  State<Buy> createState() => _BuyState();
}

class _BuyState extends State<Buy> {

  List<DocumentSnapshot> businesses = [];
  late DocumentSnapshot user;
  String selected = 'saved';
  String placeholder = 'You currently have no saved deals.';
  List<BaitPlant> baits = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///App Body
      body:
      Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('baits').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {

              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];

                    return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('baits').doc(doc.id).collection('follows').snapshots(),
                        builder: (context, snapshot) {
                          //bool removed = false;
                          List<String> tempList = [];
                          snapshot.data?.docs.forEach((element) {
                            tempList.add(element.id);
                          });

                          if(tempList.contains(globalUserID)){
                            return  Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: MediaQuery.of(context).size.width,
                              // alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.transparent ,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ///Pics and side menu options
                                    Flexible(
                                      child: Row(
                                        children: [
                                          ///Image Slider
                                          Flexible(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.55,
                                              child: StreamBuilder<QuerySnapshot>(
                                                  stream: FirebaseFirestore.instance.collection('baits').doc(doc.id).collection('pictures').snapshots(),
                                                  builder: (context, snapshot){
                                                    if(snapshot.hasData){
                                                      return ListView.builder(
                                                        itemCount: snapshot.data!.docs.length,
                                                        itemBuilder: (BuildContext context, int indexp){
                                                          DocumentSnapshot pic = snapshot.data!.docs[indexp];
                                                          return GestureDetector(
                                                            onTap: (){

                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhotosPage(baits: snapshot.data!.docs,)));
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets.only(left: 2, right: 8),
                                                              height: MediaQuery.of(context).size.height,
                                                              width: MediaQuery.of(context).size.width * 0.45,
                                                              decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors.grey,
                                                                    width: 0.3
                                                                ),
                                                                borderRadius: BorderRadius.circular(15),
                                                                image: DecorationImage(
                                                                    image: NetworkImage(
                                                                        pic['location']
                                                                    ),
                                                                    fit: BoxFit.fill
                                                                ),
                                                                //color: Colors.white ,
                                                                // border: Border.all(color: Colors.grey),
                                                                // borderRadius: BorderRadius.circular(15)),

                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        scrollDirection: Axis.horizontal,

                                                        //children: topNav,
                                                      );
                                                    } else {
                                                      return Text('Loading');
                                                    }
                                                  }
                                              ),
                                            ),
                                          ),
                                          ///Side Menu
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => ViewBait(
                                                      baitPlant: doc,
                                                      userID: globalUserID
                                                  )));
                                            },
                                            child: Padding(
                                              padding:  EdgeInsets.only(left: 8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(doc["name"],
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 8.0),
                                                    child: Text(doc["dateRegistered"],
                                                        textAlign: TextAlign.left,
                                                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 0.6), fontSize: 12,))
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: MediaQuery.of(context).size.height * 0.13,
                                                  ),
                                                  Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: Text("R ${doc["price"]}",
                                                        textAlign: TextAlign.left,
                                                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 0.6), fontSize: 16, fontWeight: FontWeight.bold))
                                                    ),
                                                  ),



                                                ],
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }
                    );

                  });
            } else {
              return Text("No data");
            }
          },
        ),
      )
    );
  }
}
