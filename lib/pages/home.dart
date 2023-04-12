import 'package:adlinc/pages/add_business.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extras/colors.dart';
import 'add_business_community.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DocumentSnapshot> amenities = [];

  ///Get amenities list from Firebase
  void getAmenities() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isEmpty){
      this.setState(() {
        amenities = [];
      });
    } else{

      this.setState(() {
        amenities = documents;
      });
    }
  }

  Future<void> _showSimpleDialog() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog( // <-- SEE HERE
            title: const Text('Select Business Type'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddBusiness()));
                },
                child: const Text('Booking Based Business'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddBusinessComminity()));
                },
                child: const Text('Product Based Business'),
              ),
            ],
          );
        });
  }


  ///initial state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAmenities();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("Home Page",
              style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Color.fromRGBO(12, 106, 187, 1.0), fontSize: 13, fontWeight: FontWeight.bold))
          ),
        ),

        ///Floating Action Button
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _showSimpleDialog,
        ),
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100,
                childAspectRatio: 4 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20
            ),
            itemCount: amenities.length,
            itemBuilder: (BuildContext ctx, index) {
              return GestureDetector(
                onTap: (){

                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.green ,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(amenities[index]["name"],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1.0), fontSize: 8,))
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
