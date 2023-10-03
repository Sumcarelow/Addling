///Shows the full list of users to start a chat with
///
///

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class Notifications extends StatefulWidget {
  final String userID;
  const Notifications({super.key, required this.userID});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  ///Variables
  List<DocumentSnapshot> notices = [];


  ///Get list of users from Firebase
  void getNoticies() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('users').doc(widget.userID).collection('notifications').get();
    final List<DocumentSnapshot> documents = result.docs;

    setState(() {
      notices = documents;
    });
  }


  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNoticies();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(itemBuilder: (BuildContext context, index){
        var user = notices[index];
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: GestureDetector(
            onTap: (){
             },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    ///Name Side
                    Text("${notices[index]['title']}", style: TextStyle(fontWeight: FontWeight.bold),),
                    Divider(
                      thickness: 1.2,

                    ),
                    Text("${notices[index]['mesage']}")
                  ],
                ),
              ),
            ),
          ),
        );
      },
        itemCount: notices.length,
      ),
    );
  }
}
