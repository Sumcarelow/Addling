import 'package:adlinc/pages/add_business.dart';
import 'package:adlinc/pages/single_business_views/view_business.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extras/colors.dart';
import '../../extras/data.dart';
import '../../extras/full_photos.dart';
import '../../extras/ui_elements.dart';
import '../../extras/variables.dart';
import 'buy/buy.dart';
import 'drawer_pages/my_businesses.dart';
import 'drawer_pages/my_profile.dart';
import 'drawer_pages/wallet.dart';
import 'feed.dart';


class Home extends StatefulWidget {
  const Home({Key? key,}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  ///Variables
  String selected = 'All', subSelected = 'All', coins = '0', wallet = '0', dropdownvalue = 'Delete/Remove';
  late String id;
  double paddingIndex = 20.0;


  final _pageViewController = PageController();

  ///Documents list
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> subs = [];
  List<BaitPlant> baits = [];
  List<BusinessClass> newBusinesses = [];

  ///Top Nav Buttons
  List<Widget> topNav = [];

  ///Dropdown Items
  var items = [
    'Delete/Remove',
  ];

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

  ///Get amenities list from Firebase
  void getBaits() async{
    setState(() {
      amenities = [];
      newBusinesses = [];
      baits = [];
      isLoading = true;
    });

    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('baits').get();
    final List<DocumentSnapshot> documents = result.docs;

    final QuerySnapshot resultBusinesses =
    await FirebaseFirestore.instance.collection('businesses').get();
    final List<DocumentSnapshot> documentsBusinesses = resultBusinesses.docs;

    ///Load Businesses to new class
    loadNewBusinesses(documentsBusinesses);

    if(documents.isEmpty){

      this.setState(() {
        amenities = [];
        //newBusinesses = [];
        isLoading = false;
      });
    }

    else{

      ///Check if bait is in any of the user's list

      ///Load to Baits List
      documents.forEach((element) async{
        ///Fetch Pics
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
        bool tempDelete = await checkUserBaitReaction('removed', element.id);

        if(!tempDelete){
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
          amenities = documentsBusinesses;
        }


      });

    }
  }

  ///Get List from Firebase
  getList(String listOf, String businessID) async{
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });
    int temp = 0;

    ///Fetch List
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').doc(businessID).collection(listOf).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isNotEmpty){
      print(documents.length);
      setState(() {
        temp = documents.length;
      });
      if(listOf == 'favourites'){
        ///Check if User added shop to their favourites


      } else if(listOf == 'comments'){

      } else if(listOf == 'ratings'){

      }
    } else {
      temp = 0;
    }
    ///Set Loading Screen
    setState(() {
      isLoading = false;
    });

   return documents.length;
  }

  ///Get specific category amenities
  void getAmenitiesByCat(String key) async{
    setState(() {
      amenities = [];
      baits = [];
      isLoading = true;
    });
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('baits').where('category', isEqualTo: key).get();
    final List<DocumentSnapshot> documents = result.docs;

    final QuerySnapshot resultBusinesses =
    await FirebaseFirestore.instance.collection('businesses').get();
    final List<DocumentSnapshot> documentsBusinesses = resultBusinesses.docs;

    if(documents.isEmpty){

      this.setState(() {
        amenities = [];
        isLoading = false;
      });
    } else{
      ///Load to Baits List
      documents.forEach((element) async{
        final QuerySnapshot resultPics =
        await FirebaseFirestore.instance.collection('baits').doc(element.id).collection('pictures').get();
        final List<DocumentSnapshot> documentPics = resultPics.docs;

        ///Fetch Followers
        final QuerySnapshot resultFollowers =
        await FirebaseFirestore.instance.collection('baits').doc(element.id).collection('followers').get();
        final List<DocumentSnapshot> documentFollowers = resultFollowers.docs;

        ///Fetch Likes
        final QuerySnapshot resultLikes =
        await FirebaseFirestore.instance.collection('baits').doc(element.id).collection('likes').get();
        final List<DocumentSnapshot> documentLikes = resultLikes.docs;
        bool tempLike = await checkUserBaitReaction('likes', element.id);
        bool tempFollow = await checkUserBaitReaction('follows', element.id);
        bool tempDelete = await checkUserBaitReaction('removed', element.id);

        if(!tempDelete){
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
          amenities = documentsBusinesses;
        }
      });
    }
  }

  ///Get specific sub-category amenities
  void getAmenitiesBySubCat(String key) async{

    setState(() {
      amenities = [];
    });
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').where('subCategory', isEqualTo: key).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isEmpty){
      setState(() {
        amenities = [];
      });
    } else{

      setState(() {
        amenities = documents;
        subSelected = key;
      });
      //print("I am called");
    }
  }

  ///Get Sub Categories
  void getSubs(String cat) async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('categories').where('from', isEqualTo: cat).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isNotEmpty){
      setState(() {
        subs = documents;
      });

    } else {
      setState(() {
        subs = [];
      });
    }

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

  ///Refresh List
    if(selected == 'All'){
      getBaits();
    } else {
      getAmenitiesByCat(selected);
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

  ///App Body
  ///
  List<Widget> _body = [Feed(), Wallet(), Buy(userID: globalUserID,), MyProfile()];
   Widget appBody(int index){
    Widget result = Container();
    if(index == 0){
      result = Feed();


         /* Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [

            ///Search
            SliverList(
                delegate: SliverChildListDelegate([

              ///Search Section
            Padding(
              padding:  EdgeInsets.only(top: 12, bottom: 12),
              child: GestureDetector(
                onTap: (){
                    List<String> temps = [];
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
                            padding:  EdgeInsets.only(left:5.0),
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
              ),
            ),
            ])),

            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 8),
                height: MediaQuery.of(context).size.height * 0.06,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ///All
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: (){
                          getBaits();
                          setState(() {
                            selected = 'All';
                            //subs = [];
                          });
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
                      padding: EdgeInsets.only(left: paddingIndex),
                      child: GestureDetector(
                        onTap: (){
                          getAmenitiesByCat('FASHION');
                          setState(() {
                            selected = 'FASHION';
                          });
                          getSubs('FASHION');
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
                          getAmenitiesByCat('FOOD');
                          setState(() {
                            selected = 'FOOD';
                          });
                          getSubs('FOOD');
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
                          getAmenitiesByCat('BEAUTY');
                          setState(() {
                            selected = 'BEAUTY';
                          });
                          getSubs('BEAUTY');
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
                          getAmenitiesByCat('STATIONARY');
                          setState(() {
                            selected = 'STATIONARY';
                          });
                          getSubs('STATIONARY');
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
                          getAmenitiesByCat('TECH');
                          setState(() {
                            selected = 'TECH';
                          });
                          getSubs('TECH');
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
                          getAmenitiesByCat('TRAVEL');
                          setState(() {
                            selected = 'TRAVEL';
                          });
                          getSubs('TRAVEL');
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
                          getAmenitiesByCat('JEWELLERY');
                          setState(() {
                            selected = 'JEWELLERY';
                          });
                          getSubs('JEWELLERY');
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

           ///
            SliverList(delegate: SliverChildListDelegate([
              Divider(
                color: Colors.grey,
              )
            ])),

            SliverList(

              delegate:  SliverChildBuilderDelegate(
                    (BuildContext context, index){
                  return Column(
                    children: [
                      Container(
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
                                  var doc = await getBusinessDoc(baits[index].doc['businessID']);
                                  *//*Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => ViewBait(
                                        baitPlant: baits[index],
                                        userID: id,
                                      )));*//*
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => ViewBusiness(
                                        category: baits[index].doc['category'],
                                        businessDoc: doc,
                                        businessId: baits[index].doc['businessID'],
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
                                                  baits[index].doc["businessLogo"],
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
                                              Text(baits[index].doc["businessName"],
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 1.0), fontSize: 14, fontWeight: FontWeight.bold))
                                              ),
                                              Text(baits[index].doc["businessAddress"],
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 0.6), fontSize: 12,))
                                              ),
                                              Text(baits[index].doc["dateRegistered"],
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
                                            FavPress(baits[index].doc.id, false, 'removed'),
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
                                    Text(baits[index].doc["name"],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 1.0), fontSize: 16, fontWeight: FontWeight.bold))
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
                                      child: ListView.builder(
                                        itemCount: baits[index].pics.length,
                                        itemBuilder: (BuildContext context, int indexp){
                                          return GestureDetector(
                                            onTap: (){

                                              Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhotosPage(baits: baits[index].pics,)));
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
                                                      baits[index].pics[indexp]['location']
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
                                              GestureDetector(
                                                onTap: (){
                                                  FavPress(baits[index].doc.id, baits[index].like, 'likes');
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      FaIcon (
                                                        FontAwesomeIcons.solidHeart, size: 21,
                                                        color:  baits[index].like ? getColor('red', 1.0) : Colors.grey,),
                                                      Text('${baits[index].likes.length}')
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              ///Remove
                                              Padding(
                                                padding: const EdgeInsets.all(9.0),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    //FavPress(baits[index].doc.id, false, 'removed');
                                                  },
                                                  child: Column(
                                                    children: [
                                                      FaIcon(FontAwesomeIcons.comment, size: 21, color: getColor('black', 1.0),),
                                                      //Text('Remove')
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              ///Follow
                                              Padding(
                                                padding: const EdgeInsets.all( 12.0),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    FavPress(baits[index].doc.id, baits[index].follow, 'follows');
                                                  },
                                                  child: Column(
                                                    children: [
                                                      FaIcon(FontAwesomeIcons.fileCircleCheck,
                                                        color: baits[index].follow ? Colors.green : Colors.grey,
                                                        size: 21,),
                                                      Text('${baits[index].followers.length}')
                                                    ],
                                                  ),
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
                                                    Text('${double.parse(baits[index].doc["coins"]).toStringAsFixed(2)}')
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
                                    Text("R${baits[index].doc["price"]}",
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("black", 0.6), fontSize: 16, fontWeight: FontWeight.bold))
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      )
                    ],
                  );
                },
                childCount: baits.length,
              ),


            )

          ],
        ),
      );*/
    }
   /* else if (index == 1){
      result = ListOfContacts(); //ChatPage(arguments: ChatPageArguments(peerAvatar: '', peerId: '', peerNickname: ''), );
    } */else if (index == 1){
      result = Wallet();
    }
    else if (index == 2){
      result = Buy(userID: id,);
    } else if (index == 3){
      result = MyProfile();
    }
    return result;
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
    fetchDataFromFB(id);
  }

  ///Get data from Firebase
  void fetchDataFromFB(String userID) async {
    ///Set Loading Screen
    setState(() {
      isLoading = true;
    });
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: userID).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents != null){
      setState(() {
        coins = documents[0]['coins'];
        wallet = documents[0]['wallet'];
      });
    }
    ///Set Loading Screen
    setState(() {
      isLoading = false;
    });
  }

  TabBar get _tabBar => TabBar(
    indicatorColor: Colors.transparent,
    labelColor: getColor('blue', 1.0),
    unselectedLabelColor: Colors.grey,
    onTap: (index){
      //change Category filter
      setState(() {
        appBodyIndex = index;
        //categoryFilter = categories[index];
        //updateList();
      });
    },
    tabs: [

      Tab(
        icon: Icon(Icons.grid_view_rounded,
        ),
        child: Text(
            'Feed',
            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(
               fontSize: 13,))
        ),
      ),
      Tab(
        icon: Icon(Icons.account_balance_wallet_rounded),
        child: Text(
            'Wallet',
            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle( fontSize: 13,))
        ),
      ),
      Tab(
        icon: Icon(Icons.monetization_on_rounded),
        child: Text(
            'Baits',
            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle( fontSize: 13,))
        ),
      ),
      Tab(
        icon: Icon(Icons.person_2_outlined),
        child: Text(
            'Profile',
            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(fontSize: 13,))
        ),
      ),
    ],
  );

  //Test new TabBar
  Widget bottomTab(){
    return PreferredSize(
      preferredSize: _tabBar.preferredSize,
      child: Material(
        color: Colors.white,
        child: _tabBar,
      ),
    );
  }


  ///initial state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getBaits();
    loadData();
  }

  @override
  Widget build(BuildContext context) {

    return Material(

      child: DefaultTabController(
        length: 4,
        child: Stack(
          children: [
            Scaffold(
              ///App Bar
              appBar: AppBar(
                elevation: 0,
                bottomOpacity: 0,
                shadowColor: Colors.white,
                leadingWidth: MediaQuery.of(context).size.width * 0.22,

                ///Leading
                leading: Container(
                  margin: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Center(
                    child: Text(
                      'ZAR: $wallet',
                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                    ),
                  ),
                ),
/*
                actions: [

                  ///Golden Points
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => MyGoldenPoints()
                        ));
                      },
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_rounded, color: Colors.grey,),
                          Text("Slasch Pay", style: TextStyle(color: Colors.black, fontSize: 13),)
                        ],
                      ),
                    ),
                  )

                ],*/
                iconTheme: IconThemeData(
                  color: getColor("blue", 1.0)
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on_outlined,
                    color: Color.fromRGBO(255, 215, 0, 1.0),
                    ),
                   /// SvgPicture.asset('assets/icons/coin.svg', color: Colors.yellowAccent,),
                    Text("Coins: ${double.parse(coins).toStringAsFixed(2)}",
                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 13, fontWeight: FontWeight.bold))
                    ),
                  ],
                ),
              ),

              ///Floating Action Button
              floatingActionButton: FloatingActionButton(
                elevation: 6.0,
                backgroundColor: Colors.lightBlue,
                child: Icon(Icons.business, size: 33,),
                onPressed: (){
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => AddBait(bizID: '',)));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyBusinesses(userID: id,)));
                }//_showSimpleDialog,
              ),

              ///Bottom Nab Bar
                bottomNavigationBar: isLoading ? Container() : bottomTab(),

             /* BottomNavigationBar(
                currentIndex: appBodyIndex,
                unselectedItemColor: Colors.grey,
                fixedColor: getColor("blue", 1.0),
                onTap: (int){
                  setState(() {
                    //_pageViewController.animateToPage(int, duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
                    appBodyIndex = int;
                  });
                },
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_rounded),
                    label: 'Feed',
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_rounded),
                    label: 'Wallet',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.monetization_on_rounded),
                    label: 'Baits',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_2_outlined),
                    label: 'Profile',
                  ),
                ],
              ),*/

              ///App Body
              body: TabBarView(
                children: _body,
              )

            ),

            ///Loading Screen
            Positioned(child: loadingScreen())
          ],
        ),
      ),
    );
  }
}


///We just added this
class MySearchDelegate extends SearchDelegate{
  final List<String> searchResults;
  final List<DocumentSnapshot> docs;
   List<BusinessClass> newBusiness;
  final String id;
  MySearchDelegate({required this.searchResults, required this.docs, required this.id, required this.newBusiness});

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () => close(context, null), //close searchbar
  );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: (){
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
        }
      },
    ),
  ];
  Future<DocumentSnapshot<Object?>> getBusinessDoc(String docID) async {
    DocumentSnapshot doc;
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').where('id', isEqualTo: docID).get();
    final List<DocumentSnapshot> documents = result.docs;
    //print("I am called with $documents");
    doc = documents[0];

    return doc;

  }

  ///Check if business is followed
 bool checkFollowing(List<DocumentSnapshot> business) {
    ///Convert to list
   List<String> temp = [];

   //print('Its there $business');
   business.forEach((element) {
     temp.add(element.id);
   });

    bool follower = false;
    if (temp.contains(id)){
      follower = true;
    }
    return follower;
  }

  ///On Press Favourites Button
  void FavPress(String baitID, bool status, String collect) async {


    ///Updates Firebase business side
    if(status == false){

      FirebaseFirestore.instance.collection('businesses')
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

    }

    else if(status){

      FirebaseFirestore.instance.collection('businesses')
          .doc(baitID)
          .collection(collect)
          .doc(id)
          .delete();

      FirebaseFirestore.instance.collection('users')
          .doc(id)
          .collection(collect)
          .doc(baitID)
          .delete();

    }

  }


  @override
  Widget buildResults(BuildContext context) => Center(
    child: Text(
      query,
      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold,),
    ),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    List<DocumentSnapshot> suggestions = docs.where((searchResults) {
      final result = searchResults['name'].toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);

    }).toList();

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('businesses').snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                final suggestion = doc['name'];
                //bool isFollower = checkFollowing(newBusiness[index].followers);

                return ListTile (
                  title: Text(suggestion,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Text(doc['address'],

                  ),
                  leading: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              doc['logo']
                          ),

                        )
                    ),
                  ),
                  /*trailing:  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:  MaterialStatePropertyAll<Color>(getColor('blue', 1.0)),
                      ),
                      //color: colors[2],
                      onPressed: (){
                        //FavPress(doc.id, checkFollowing(newBusiness[index].followers), 'followers');
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                            right: MediaQuery.of(context).size.width * 0.07),
                        child: isFollower
                            ? Text("Unfollow")
                            : Text("Follow",
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
                        ),
                      )
                  ),*/
                  onTap: () async {
                    query = suggestion;

                    //var doc = await getBusinessDoc(suggestions[index]['businessID']);
                    ///Find doc and navigate to business
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ViewBusiness(
                          category: doc['category'], businessId: doc['id'], businessDoc: doc,

                        )));
                    showResults(context);
                  },
                );
              },
            );
          } else {
            return Container();
          }
        }
        );
  }

}
