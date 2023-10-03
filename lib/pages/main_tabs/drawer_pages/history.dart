///Shows the full list of users to start a chat with
///
///

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class History extends StatefulWidget {
  final String userID;
  const History({super.key, required this.userID});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  ///Variables
  List<DocumentSnapshot> orders = [];


  ///Get list of users from Firebase
  void getOrders() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('orders').where('customerID', isEqualTo: widget.userID).get();
    final List<DocumentSnapshot> documents = result.docs;

    setState(() {
      orders = documents;
    });
  }


  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrders();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: Container(
        child: ListView.builder(itemBuilder: (BuildContext context, index){
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
                      Text("${orders[index]['price']}", style: TextStyle(fontWeight: FontWeight.bold),),
                      Divider(
                        thickness: 1.2,
                      ),
                      Text("${orders[index]['status']}")
                    ],
                  ),
                ),
              ),
            ),
          );
        },
          itemCount: orders.length,
        ),
      ),
    );
  }
}
