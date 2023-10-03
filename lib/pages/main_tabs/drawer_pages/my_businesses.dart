///Shows the full list of users to start a chat with
///
///

import 'package:adlinc/extras/colors.dart';
import 'package:adlinc/pages/add_business.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../single_business_views/view_business.dart';
import 'business_orders.dart';


class MyBusinesses extends StatefulWidget {
  final String userID;
  const MyBusinesses({super.key, required this.userID});

  @override
  State<MyBusinesses> createState() => _MyBusinessesState();
}

class _MyBusinessesState extends State<MyBusinesses> {
  ///Variables
  List<DocumentSnapshot> orders = [];

  ///Get list of users from Firebase
  void getOrders() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').where('ownerID', isEqualTo: widget.userID).get();
    final List<DocumentSnapshot> documents = result.docs;

    //print("It is herer......$documents with id: ${widget.userID}");
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

      ///App Bar
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: getColor("blue", 1.0)
        ),
        centerTitle: true,
        title: Text('My Businesses',
        style: TextStyle(
          color: getColor("blue", 1.0)
        ),
        ),
        backgroundColor: getColor("white", 1.0),
      ),

      ///Floating Action Button
      floatingActionButton: FloatingActionButton(
          elevation: 6.0,
          backgroundColor: Colors.lightBlue,
          child: Icon(Icons.add, size: 33,),
          onPressed: (){
            //Navigator.push(context, MaterialPageRoute(builder: (context) => AddBait(bizID: '',)));
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddBusiness()));
          }//_showSimpleDialog,
      ),

      ///Page body
      body: Container(
        child: ListView.builder(itemBuilder: (BuildContext context, index){
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ViewBusiness(category: orders[index]['category'], businessId: orders[index]['id'], businessDoc: orders[index],)));
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      ///Business Logo
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              orders[index]['logo']
                            )
                          )
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///Name Side
                          Text("${orders[index]['name']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          Text("${orders[index]['bio']}"),
                          Text("${orders[index]['category']}"),
                          //Text("${orders[index]['address']}"),

                        ],
                      ),
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
