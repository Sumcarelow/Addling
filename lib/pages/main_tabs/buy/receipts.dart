///Page to manage all receipts for Adlinc

///Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reciepts extends StatefulWidget {
  final String id;
  const Reciepts({super.key, required this.id});

  @override
  State<Reciepts> createState() => _RecieptsState();
}

class _RecieptsState extends State<Reciepts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      ///AppBar
      appBar: AppBar(
        title: Text("My Receipts",
        ),
        centerTitle: true,
      ),

      ///App Body
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.id).collection('receipts').snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index){
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${doc['title']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                            ),
                            Text("${doc['date']}"),
                            Text("Type: ${doc['type']}"),
                            Text("Spent: ${doc['amount']} coins"),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      )
                    ],
                  );

            });
          } else {
            return Container();
          }
        },
      ),


    );
  }
}
