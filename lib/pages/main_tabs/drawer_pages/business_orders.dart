///Shows the full list of users to start a chat with

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../extras/colors.dart';


class BusinessOrders extends StatefulWidget {
  final String businessID;
  const BusinessOrders({super.key, required this.businessID});

  @override
  State<BusinessOrders> createState() => _BusinessOrdersState();
}


class _BusinessOrdersState extends State<BusinessOrders> {
  ///Variables
  List<DocumentSnapshot> orders = [];

  ///Get list of users from Firebase
  void getOrders() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('orders').where('businessID', isEqualTo: widget.businessID).get();
    final List<DocumentSnapshot> documents = result.docs;

    setState(() {
      orders = documents;
    });
  }

  ///Send Response
  void sendResponse(String docId, String response) async{
    DocumentReference docRef = FirebaseFirestore.instance.collection('orders').doc(docId);

    docRef.update({
      'status': response
    });

    getOrders();
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
        title: Text('My Business Orders'),
      ),
      body: Container(
        child: ListView.builder(itemBuilder: (BuildContext context, index){
          var item = orders[index];
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    ///Name Side
                    Text("${item['productName']}", style: TextStyle(fontWeight: FontWeight.bold),),
                    Text("${item['status']}"),
                    Text("R${item['price']}"),

                  ///Check status and display button on pending
                  item['status'] == 'pending'
                   ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:  MaterialStatePropertyAll<Color>(getColor("green", 1.0)),
                              ),
                              onPressed: (){
                                sendResponse(item['id'], "approved");
                              }, child: Text("Approve")),
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:  MaterialStatePropertyAll<Color>(getColor("red", 1.0)),
                            ),
                            onPressed: (){
                              sendResponse(item['id'], "declined");}, child: Text("Decline"))

                      ],
                    )
                  :Container()
                  ],
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
