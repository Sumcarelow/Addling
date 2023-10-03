///Landing page for business view

import 'package:adlinc/extras/colors.dart';
import 'package:adlinc/extras/ui_elements.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extras/data.dart';
import '../../extras/full_photos.dart';
import '../../extras/functions.dart';
import '../../extras/variables.dart';
import '../business_reg/add_bait.dart';
import '../commentsPage.dart';
import '../main_tabs/home.dart';

class ViewBusiness extends StatefulWidget {
  final String businessId, category;
  final DocumentSnapshot businessDoc;
  const ViewBusiness({Key? key, required this.category, required this.businessId, required this.businessDoc}) : super(key: key);

  @override
  State<ViewBusiness> createState() => _ViewBusinessState();
}

class _ViewBusinessState extends State<ViewBusiness> {

  ///Variables
  List<DocumentSnapshot> listings = [];
  List<DocumentSnapshot> pictures = [];
  List<Listing> listingsList = [];
  String id = '';
  List<BaitPlant> baits = [];

  ///Functions

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
  ///Get Listings
  void getListing() async {

    ///Empty baits list
    setState(() {
      baits = [];
    });
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('baits').where('businessID', isEqualTo: widget.businessId).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isNotEmpty){
      setState(() {
        baits = [];
        listings = documents;
      });


      documents.forEach((element) async {
        ///Load images
        final QuerySnapshot resultPics =
            await FirebaseFirestore.instance.collection('baits').doc(element.id).collection('pictures').get();
        final List<DocumentSnapshot> documentPics = resultPics.docs;

        ///Fetch Followers
        final QuerySnapshot resultFollowers =
        await FirebaseFirestore.instance.collection('baits').doc(element.id).collection('follows').get();
        final List<DocumentSnapshot> documentFollowers = resultFollowers.docs;

        ///Fetch Likes
        final QuerySnapshot resultLikes =
        await FirebaseFirestore.instance.collection('baits').doc(element.id).collection('likes').get();
        final List<DocumentSnapshot> documentLikes = resultLikes.docs;

        bool tempLike = await checkUserBaitReaction('likes', element.id);
        bool tempFollow = await checkUserBaitReaction('follows', element.id);

        setState(() {
          baits.add(BaitPlant(
            doc: element,
            pics: documentPics,
            likes: documentLikes,
            followers: documentFollowers,
            like: tempLike,
            follow: tempFollow,
          ));
          isLoading = false;
        });
        //loadPics(element.id, element);
      });
    }

  }

  ///Load Pics
  void loadPics(String id, DocumentSnapshot doc) async {
    ///Pull from Firebase
  final QuerySnapshot result =
      await FirebaseFirestore.instance.collection('listings').doc(id).collection("pictures").get();
  final List<DocumentSnapshot> pics = result.docs;

  ///Load to List
    setState(() {
      pictures = pics;
      listingsList.add(Listing(name: doc['name'], description: doc['description'], pics: pics, price: doc['price'], doc: doc));
    });

}

  ///Picture Slider
  Container adSlider(List<DocumentSnapshot> picList){
    return Container(
        height: MediaQuery.of(context).size.height * 0.35,
        width: MediaQuery.of(context).size.width,
        child: CarouselSlider(
          options: CarouselOptions(height: MediaQuery.of(context).size.height * 0.25,
            initialPage: 0,
            enlargeCenterPage: true,
            autoPlay: true,
            reverse: false,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 2000),
            viewportFraction: 1.0,
            //pauseAutoPlayOnTouch: Duration(seconds: 10),)
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              /*setState(() {
                _current = index;
              });*/
            },
          ),

          items: picList.map<Widget>((advert){
            String image = advert['location'];
            return Builder(builder: (BuildContext context){
              return GestureDetector(
                onTap: null,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 7.0),
                    child: Text(' '),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.fill,
                        )
                    )
                ),
              );
            });
          }).toList(),)
    );
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
    getListing();

  }

  ///Load data from storage
  ///load Local Storage Info
  void loadData() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
    });
  }

  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getListing();
    loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      ///Floating Action: Add Product
      floatingActionButton:
      id == widget.businessDoc['ownerID']
      ///If user is business owner
        ? FloatingActionButton(
        backgroundColor: getColor('green', 1.0),
        onPressed: (){
          ///Navigate to Add Listing Page
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddBait(
            bizID: widget.businessDoc['id'],
            bizAddress: widget.businessDoc['address'],
            bizName: widget.businessDoc['name'],
            bizLogo: widget.businessDoc['logo'],
            bizCategory: widget.businessDoc['category'],)));
          //Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
        },
        child: Icon(Icons.add),
      )
      : null,

      ///App Bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: getColor('white', 1.0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: getColor('black', 1.0),),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          },
        ),
        centerTitle: true,
        title: Text(
          "${widget.businessDoc['name']}",
          style: TextStyle(
            color: getColor('black', 1.0),
          ),
        ),

      ),

      ///App Body
      body: Column(
        children: [
          ///Business Details
          Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text("${widget.businessDoc['bio']}",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:  getColor('black', 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ///Address
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.mapLocation,
                      color: getColor('black', 0.8),
                      size: 15,
                    ),
                    Text("${widget.businessDoc['address']}",
                      style: TextStyle(
                          color:  getColor('black', 1.0),
                          fontSize: 13
                      ),
                    ),
                  ],
                ),
                ///Phone Number
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.phone,
                              color: getColor('black', 0.8),
                              size: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("${widget.businessDoc['phone']}",
                                style: TextStyle(
                                    color:  getColor('black', 1.0),
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.message,
                            color: getColor('black', 0.8),
                            size: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text("${widget.businessDoc['email']}",
                              style: TextStyle(
                                  color:  getColor('black', 1.0),
                                  fontSize: 13
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
          ),

          ///List of baits
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('baits').where('businessID', isEqualTo: widget.businessId).snapshots(),
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
            ),
          ),
        ],
      ),
    );
  }
}
