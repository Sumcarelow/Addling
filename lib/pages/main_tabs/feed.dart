///Main Feed Page

import 'package:adlinc/extras/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extras/colors.dart';
import '../../extras/data.dart';
import '../../extras/full_photos.dart';
import '../../extras/variables.dart';
import '../commentsPage.dart';
import '../product_pages/view_bait.dart';
import '../single_business_views/view_business.dart';
//import 'chat.dart';
import 'home.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  late String id;
  String selected = 'All';
  String sort = 'none';
  double paddingIndex = 20.0;
  List<DocumentSnapshot> amenities = [];
  List<BusinessClass> newBusinesses = [];
  Stream<QuerySnapshot<Object?>> myStream = FirebaseFirestore.instance.collection('baits').snapshots();



  ///Load Businesses with list of followers to new business class
  void loadNewBusinesses(List<DocumentSnapshot> myList) async {
    myList.forEach((element) async{
      final QuerySnapshot result =
      await FirebaseFirestore.instance.collection('businesses').doc(element.id).collection('followers').get();
      final List<DocumentSnapshot> documents = result.docs;

      //print("Check here.... $documents");
      setState(() {
        newBusinesses.add(BusinessClass(doc: element, followers: documents));
      });
    });
  }

  ///Get specific category amenities
  void getAmenitiesByCat() async{
    setState(() {
      amenities = [];
      isLoading = true;
    });

    final QuerySnapshot resultBusinesses =
    await FirebaseFirestore.instance.collection('businesses').get();
    final List<DocumentSnapshot> documentsBusinesses = resultBusinesses.docs;

    if(documentsBusinesses.isEmpty){

      this.setState(() {
        amenities = [];
        isLoading = false;
      });
    } else{
      setState(() {
        amenities = documentsBusinesses;
      });

      ///Load Businesses to new class
      loadNewBusinesses(documentsBusinesses);
    }
  }

  ///Check if user reacted
  Future<bool> checkUserBaitReaction(String key, String baitID) async {
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });
    bool result = false;
    List<String> tempList = [];

    final QuerySnapshot resultDocs =
    await FirebaseFirestore.instance.collection('users').doc(id).collection(key).get();
    final List<DocumentSnapshot> documents = resultDocs.docs;

    documents.forEach((element) {
      tempList.add(element['id']);
    });

    if(tempList.contains(baitID)){
      result = true;
    }
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });
    return result;
  }
  ///On Press Favourites Button
  void FavPress(String baitID, bool status, String collect) async {
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });
    ///Updates Firebase business side
    if(status == false){

      FirebaseFirestore.instance.collection('baits')
          .doc(baitID)
          .collection(collect)
          .doc(id)
          .set({
        "userId": id,
      });

      FirebaseFirestore.instance.collection('users')
          .doc(id)
          .collection(collect)
          .doc(baitID)
          .set({
        "id": baitID,
      });
      ///Set Loading Screen
      setState(() {
        isLoading = false;
      });
    }

    else if(status){

      FirebaseFirestore.instance.collection('baits')
          .doc(baitID)
          .collection(collect)
          .doc(id)
          .delete();

      FirebaseFirestore.instance.collection('users')
          .doc(id)
          .collection(collect)
          .doc(baitID)
          .delete();
      ///Set Loading Screen
      setState(() {
        isLoading = false;
      });
    }


  }

  ///Get Business Document from Bait
  Future<DocumentSnapshot<Object?>> getBusinessDoc(String docID) async {
    DocumentSnapshot doc;
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').where('id', isEqualTo: docID).get();
    final List<DocumentSnapshot> documents = result.docs;
    //print("I am called with $documents");
    doc = documents[0];

    return doc;

  }
  ///load Local Storage Info
  void loadData() async{
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
    });
    ///Set Loading Screen
    setState(() {
      isLoading = false;
    });

    //print(DateTime.now());
  }

  void updateDates() async{
    DocumentSnapshot doc;
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('baits').get();
    final List<DocumentSnapshot> documents = result.docs;

    documents.forEach((element) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('baits').doc(element.id);
      docRef.update({
        'timestamp': DateTime.now()
      });
    });
  }

  ///Function to set main Stream
  void setStream(){
    if(selected == 'All'){
      setState(() {
        myStream = FirebaseFirestore.instance.collection('baits').snapshots();
        sort = 'none';
      });
    } else {
      setState(() {
        myStream = FirebaseFirestore.instance.collection('baits').where('category', isEqualTo: selected).snapshots();
        sort = 'none';
      });
    }
  }

  ///Function to set main stream using price
  void sortStream(){

    if(selected == 'All'){
      if(sort == 'low'){
        setState(() {
          myStream = FirebaseFirestore.instance.collection('baits').orderBy('price', descending: false).snapshots();
        });

      } else if(sort == 'high'){
        setState(() {
          myStream = FirebaseFirestore.instance.collection('baits').orderBy('price', descending: true).snapshots();

        });

      }


    } else {


      if(sort == 'low'){
        setState(() {
          myStream = FirebaseFirestore.instance.collection('baits').where('category', isEqualTo: selected).orderBy('price', descending: false).snapshots();
        });

      } else if(sort == 'high'){
        setState(() {
          myStream = FirebaseFirestore.instance.collection('baits').where('category', isEqualTo: selected).orderBy('price', descending: true).snapshots();

        });

      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    //getAmenitiesByCat();
    //updateDates();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
    ///Search Section
    Padding(
    padding: EdgeInsets.only(top: 12, bottom: 0),
    child: GestureDetector(
    onTap: (){
    List<String> temps = [];
    //getAmenitiesByCat();
    amenities.forEach((element) {
    setState(() {
    temps.add(element['name']);
    });
    });
    showSearch(
    context: context,
    delegate:
    MySearchDelegate(searchResults: temps, docs: amenities, id: id, newBusiness: newBusinesses),
    );
    },
    child: Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28)

    ),
    child: Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
    children: [
    Icon(Icons.search, color: Colors.grey,),
    Padding(
    padding: EdgeInsets.only(left:5.0),
    child: Text("Enter your search here",
    style: TextStyle(
    color: Colors.grey
    ),
    ),
    )
    ],
    ),
    ),
    ),
    )),
        ///Category Filters
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.03,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ///All
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        selected = 'All';
                      });
                     setStream();
                    },
                    child: Container(
                      //width: 50,
                      decoration: BoxDecoration(
                          color: Colors.transparent, //selected == 'All'? Colors.lightBlue :Colors.grey[350] ,
                          // border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(28)),
                      child: Center(
                        child: Text(
                            'All',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'All' ?getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),

                ///Fashion
                Padding(
                  padding: EdgeInsets.only(
                      left: paddingIndex),
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        selected = 'FASHION';
                      });
                      setStream();
                      //getSubs('FASHION');
                    },
                    child: Container(
                      // width: 90,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                            'Fashion',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'FASHION' ? getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),

                ///Food
                Padding(
                  padding: EdgeInsets.only(left: paddingIndex),
                  child: GestureDetector(
                    onTap: (){
                      //getAmenitiesByCat('FOOD');
                      setState(() {
                        selected = 'FOOD';
                      });
                      setStream();
                      //getSubs('FOOD');
                    },
                    child: Container(
                      //width: 90,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                            'Food',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'FOOD' ? getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),

                ///Beauty
                Padding(
                  padding: EdgeInsets.only(left: paddingIndex),
                  child: GestureDetector(
                    onTap: (){
                      //getAmenitiesByCat('BEAUTY');
                      setState(() {
                        selected = 'BEAUTY';
                      });
                      setStream();
                      //getSubs('BEAUTY');
                    },
                    child: Container(
                      //width: 90,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                            'Beauty',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'BEAUTY' ? getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),

                ///Stationary
                Padding(
                  padding: EdgeInsets.only(left: paddingIndex),
                  child: GestureDetector(
                    onTap: (){
                      //getAmenitiesByCat('STATIONARY');
                      setState(() {
                        selected = 'STATIONARY';
                      });
                      setStream();
                     // getSubs('STATIONARY');
                    },
                    child: Container(
                      // width: 120,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                            'Books & Stationary',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'STATIONARY' ? getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),

                ///Tech & Electronics
                Padding(
                  padding: EdgeInsets.only(left: paddingIndex),
                  child: GestureDetector(
                    onTap: (){
                      //getAmenitiesByCat('TECH');
                      setState(() {
                        selected = 'TECH';
                      });
                      setStream();
                      //getSubs('TECH');
                    },
                    child: Container(
                      //width: 120,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                            'Tech',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'TECH' ? getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),

                ///Travel
                Padding(
                  padding: EdgeInsets.only(left: paddingIndex),
                  child: GestureDetector(
                    onTap: (){
                      //getAmenitiesByCat('TRAVEL');
                      setState(() {
                        selected = 'TRAVEL';
                      });
                      setStream();
                      //getSubs('TRAVEL');
                    },
                    child: Container(
                      //width: 120,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                            'Travel',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'TRAVEL' ? getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),

                ///Jewellery
                Padding(
                  padding: EdgeInsets.only(left: paddingIndex),
                  child: GestureDetector(
                    onTap: (){
                      //getAmenitiesByCat('JEWELLERY');
                      setState(() {
                        selected = 'JEWELLERY';
                      });
                      setStream();
                      //getSubs('JEWELLERY');
                    },
                    child: Container(
                      //width: 120,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                            'Jewellery',
                            style: GoogleFonts.getFont('Roboto',
                                textStyle: TextStyle(
                                    color: selected == 'JEWELLERY' ? getColor('black', 1.0) : Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        ///Price Filter
        /*Container(
          height: MediaQuery.of(context).size.height * 0.1,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [

              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.lightGreen, //selected == 'All'? Colors.lightBlue :Colors.grey[350] ,
                      // border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(28)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Sort by Price: ',
                          style: GoogleFonts.getFont('Roboto',
                              textStyle: TextStyle(
                                  color: getColor('black', 1.0),
                                  fontSize: 16,
                                  //fontWeight: FontWeight.bold
                              ))
                      ),
                    ),
                  ),
                ),
              ),

              ///Low to High
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      sort = 'low';
                    });
                    sortStream();
                  },
                  child: Container(
                    //width: 50,
                    decoration: BoxDecoration(
                        color: Colors.transparent, //selected == 'All'? Colors.lightBlue :Colors.grey[350] ,
                        // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(28)),
                    child: Center(
                      child: Text(
                          'Low to High',
                          style: GoogleFonts.getFont('Roboto',
                              textStyle: TextStyle(
                                  color: sort == 'low' ?getColor('black', 1.0) : Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ))
                      ),
                    ),
                  ),
                ),
              ),

              ///High to Low
              Padding(
                padding: EdgeInsets.only(
                    left: paddingIndex),
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      sort = 'high';
                    });
                    sortStream();
                    //getSubs('FASHION');
                  },
                  child: Container(
                    // width: 90,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        //border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(25)),
                    child: Center(
                      child: Text(
                          'High to Low',
                          style: GoogleFonts.getFont('Roboto',
                              textStyle: TextStyle(
                                  color: sort == 'high' ? getColor('black', 1.0) : Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ))
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),*/

        ///List of Baits
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: myStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {

                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('baits').doc(doc.id).collection('removed').snapshots(),
                            builder: (context, snapshot) {
                            //bool removed = false;
                            List<String> tempList = [];
                            snapshot.data?.docs.forEach((element) {
                              tempList.add(element.id);
                            });

                            if(!tempList.contains(id)){
                              return  Container(
                                height: MediaQuery.of(context).size.height * 0.54,
                                width: MediaQuery.of(context).size.width,
                                // alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.transparent ,
                                  borderRadius: BorderRadius.circular(15),

                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ///Store Logo and Name
                                      GestureDetector(
                                        onTap: () async{

                                          var Tempdoc = await getBusinessDoc(doc['businessID']);
                                              Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => ViewBusiness(
                                            category: doc['category'],
                                            businessDoc: Tempdoc,
                                            businessId: doc['businessID'],
                                          )));
                                        },
                                        child: Padding(
                                          padding:  EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                            children: [
                                              ///Logo
                                              Container(
                                                height:50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                          doc["businessLogo"],
                                                        ),
                                                        fit: BoxFit.cover
                                                    )
                                                ),
                                              ),

                                              ///Name
                                              Expanded(
                                                child: Padding(
                                                  padding:  EdgeInsets.only(left: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: [
                                                      Text(doc["businessName"],
                                                          textAlign: TextAlign.left,
                                                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 1.0), fontSize: 14, fontWeight: FontWeight.bold))
                                                      ),
                                                      Text(doc["businessAddress"],
                                                          textAlign: TextAlign.left,
                                                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 0.6), fontSize: 12,))
                                                      ),
                                                      Text(doc["dateRegistered"],
                                                          textAlign: TextAlign.left,
                                                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 0.6), fontSize: 12,))
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                              ),

                                              ///More options
                                              PopupMenuButton<int>(
                                                onSelected: (item) =>
                                                    FavPress(doc.id, false, 'removed'),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem<int>(value: 0, child: Text('Delete/Remove')),
                                                  //PopupMenuItem<int>(value: 1, child: Text('Settings')),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(doc["name"],
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                                                ),
                                                daysBetween(doc['timestamp'].toDate(), DateTime.now()) <= 1
                                                ? Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Row(
                                                    children: [
                                                      FaIcon(FontAwesomeIcons.fire, color: getColor('blue', 1.0), size: 14,),
                                                      Text("New")
                                                    ],
                                                  ),
                                                )
                                                    : Container()
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      ///Pics and side menu options
                                      Flexible(
                                        child: Row(
                                          children: [
                                            ///Image Slider
                                            Flexible(
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
                                                              width: MediaQuery.of(context).size.width * 0.65,
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

                                            ///Side Menu
                                            Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  //color: Colors.grey[350] ,
                                                    borderRadius: BorderRadius.circular(15)),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 8.0, top: 12.0, bottom: 12.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [

                                                      ///Favourites
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: StreamBuilder<QuerySnapshot>(
                                                            stream: FirebaseFirestore.instance.collection('baits').doc(doc.id).collection('likes').snapshots(),
                                                            builder: (context, snapshot){
                                                              if(snapshot.data != null){

                                                                List<String> tempList = [];
                                                                bool like =  false;
                                                                snapshot.data!.docs.forEach((element) {
                                                                  tempList.add(element.id);
                                                                });
                                                                if(tempList.contains(id)){

                                                                  like = true;
                                                                }
                                                                return GestureDetector(
                                                                  onTap: (){
                                                                    FavPress(doc.id, like, 'likes');
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      FaIcon (
                                                                        FontAwesomeIcons.solidHeart, size: 21,
                                                                        color:  like ? getColor('red', 1.0) : Colors.grey,),
                                                                      Text('${snapshot.data!.docs.length}'),

                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                return Text('loading');
                                                              }

                                                            }
                                                        ),
                                                      ),

                                                      ///~Comments
                                                      Padding(
                                                        padding: const EdgeInsets.all(9.0),
                                                        child:
                                                        StreamBuilder<QuerySnapshot>(
                                                            stream: FirebaseFirestore.instance.collection('baits').doc(doc.id).collection('comments').snapshots(),
                                                            builder: (context, snapshot){
                                                              if(snapshot.data != null){

                                                                List<String> tempList = [];

                                                                snapshot.data!.docs.forEach((element) {
                                                                  tempList.add(element.id);
                                                                });

                                                                return GestureDetector(
                                                                  onTap: (){
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                                        Comments(arguments: ChatPageArguments(peerAvatar: doc['businessLogo'], peerId: doc.id, peerNickname: doc['businessName']  + '-'  + doc['name']), )));

                                                                    //FavPress(baits[index].doc.id, false, 'removed');
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      FaIcon (
                                                                        FontAwesomeIcons.comment, size: 21,
                                                                        color:getColor('black', 1.0),),
                                                                      Text('${snapshot.data!.docs.length}'),

                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                return Text('loading');
                                                              }

                                                            }
                                                        ),

                                                      ),

                                                      ///Follow
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: StreamBuilder<QuerySnapshot>(
                                                            stream: FirebaseFirestore.instance.collection('baits').doc(doc.id).collection('follows').snapshots(),
                                                            builder: (context, snapshot){
                                                              if(snapshot.data != null){
                                                                List<String> tempList = [];
                                                                bool like =  false;
                                                                snapshot.data!.docs.forEach((element) {
                                                                  tempList.add(element.id);
                                                                });
                                                                if(tempList.contains(id)){

                                                                  like = true;
                                                                }
                                                                return GestureDetector(
                                                                  onTap: (){
                                                                    FavPress(doc.id, like, 'follows');
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      FaIcon (
                                                                        FontAwesomeIcons.fileCircleCheck, size: 21,
                                                                        color:  like ? getColor('green', 1.0) : Colors.grey,),
                                                                      Text('${snapshot.data!.docs.length}'),

                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                return Text('Loading');
                                                              }

                                                            }
                                                        ),
                                                      ),

                                                      ///Price
                                                      Padding(
                                                        padding: const EdgeInsets.all( 3.0),
                                                        child: Column(
                                                          children: [
                                                            Icon(Icons.monetization_on_outlined,
                                                              color: Color.fromRGBO(255, 215, 0, 1.0),
                                                            ),
                                                            Text('${double.parse(doc["coins"]).toStringAsFixed(2)}')
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text("R${doc["price"]}",
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 0.6), fontSize: 16, fontWeight: FontWeight.bold))
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      )
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
            )

        )
      ],
    );
  }
}
