import 'package:adlinc/pages/add_business.dart';
import 'package:adlinc/pages/single_business_views/view_business.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/colors.dart';
import '../extras/data.dart';
import 'add_business_community.dart';
import 'chat.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  ///Variables
  String selected = 'All', subSelected = 'All';
  late String id;
  int appBodyIndex = 0;

  ///Documents list
  List<DocumentSnapshot> amenities = [];

  List<DocumentSnapshot> subs = [];


  ///Top Nav Buttons
  List<Widget> topNav = [
  ];

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
        // documents.forEach((element) {
        //   FirebaseFirestore.instance.collection('businesses').doc(element['id'])
        //       .update({
        //     'favourites': 0,
        //     'comments': 0,
        //     'rating': 0
        //   });
        // });
        amenities = documents;
      });
    }
  }

  ///Get List from Firebase
  getList(String listOf, String businessID) async{
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

   return documents.length;
  }

  ///Get specific category amenities
  void getAmenitiesByCat(String key) async{
    setState(() {
      amenities = [];
    });
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').where('category', isEqualTo: key).get();
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

  ///Simple Dialog
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
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.calendarPlus, color: getColor('red', 1.0),),
                    Padding(
                      padding:  EdgeInsets.only(left: 8.0),
                      child: Text('Booking Based Business'),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddBusinessComminity()));
                },
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.cartShopping, color: getColor('green', 1.0),),
                    const Padding(
                      padding:  EdgeInsets.only(left: 8.0),
                      child: Text('Product Based Business'),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  ///On Press Favourites Button
  void FavPress(String businessID, String status) async {
    ///Updates Firebase business side
    if(status == 'add'){

      FirebaseFirestore.instance.collection('listings')
          .doc(businessID)
          .collection("favourites")
          .doc(id)
          .set({
        "userId": id,
      });

      FirebaseFirestore.instance.collection('users')
          .doc(id)
          .collection("favourites")
          .doc(businessID)
          .set({
        "storeId": businessID,
      });
    } else if(status == 'remove'){

      FirebaseFirestore.instance.collection('listings')
          .doc(businessID)
          .collection("favourites")
          .doc(id)
          .delete();

      FirebaseFirestore.instance.collection('users')
          .doc(id)
          .collection("favourites")
          .doc(businessID)
          .delete();
    }

  }

  Widget appBody(int index){
    Widget result = Container();
    if(index == 0){
      result = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              //margin: EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height * 0.06,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ///All
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: (){
                        getAmenities();
                        setState(() {
                          selected = 'All';
                          subs = [];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: selected == 'All'? getColor('green', 1.0) : Colors.white ,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'All',
                              style: GoogleFonts.getFont('Roboto',
                                  textStyle: TextStyle(
                                    color: selected == 'All' ?getColor('white', 1.0) : getColor('black', 1.0),
                                    fontSize: 12,
                                  ))
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///Hospitality
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: (){
                        getAmenitiesByCat('HOSPITALITY & TOURISM');
                        setState(() {
                          selected = 'HOSPITALITY & TOURISM';
                        });
                        getSubs('HOSPITALITY & TOURISM');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: selected == 'HOSPITALITY & TOURISM' ? getColor("green", 1.0) : Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Hospitality & Tourism',
                              style: GoogleFonts.getFont('Roboto',
                                  textStyle: TextStyle(
                                    color: selected == 'HOSPITALITY & TOURISM' ? getColor('white', 1.0) : getColor('black', 1.0),
                                    fontSize: 12, ))
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///Self Care
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: (){
                        getAmenitiesByCat('SELF LOVE');
                        setState(() {
                          selected = 'SELF LOVE';
                        });
                        getSubs('SELF LOVE');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: selected == 'SELF LOVE' ? getColor("green", 1.0) : Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Self Love',
                              style: GoogleFonts.getFont('Roboto',
                                  textStyle: TextStyle(
                                    color: selected == 'SELF LOVE' ? getColor('white', 1.0) : getColor('black', 1.0),
                                    fontSize: 12, ))
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///Home Care
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: (){
                        getAmenitiesByCat('HEALTHCARE');
                        setState(() {
                          selected = 'HEALTHCARE';
                        });
                        getSubs('HEALTHCARE');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: selected == 'HEALTHCARE' ? getColor("green", 1.0) : Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Health Care',
                              style: GoogleFonts.getFont('Roboto',
                                  textStyle: TextStyle(
                                    color: selected == 'HEALTHCARE' ? getColor('white', 1.0) : getColor('black', 1.0),
                                    fontSize: 12, ))
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              child: ListView.builder(
                itemCount: subs.length,
                itemBuilder: (BuildContext context, int index){
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          subSelected = subs[index]['name'];
                        });
                        getAmenitiesBySubCat(subs[index]['name']);
                      },
                      child: Container(
                        height: 23,
                        //width: 40,
                        decoration: BoxDecoration(
                            color: subSelected ==  subs[index]['name']? getColor('green', 1.0) : Colors.white ,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              subs[index]['name'],
                              style: GoogleFonts.getFont('Roboto',
                                  textStyle: TextStyle(
                                    color: subSelected ==  subs[index]['name'] ? getColor('white', 1.0) : getColor('black', 1.0),
                                    fontSize: 12,
                                  ))
                          ),
                        ),
                      ),
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,

                //children: topNav,
              ),
            ),
          ),


          SliverList(

            delegate:  SliverChildBuilderDelegate(
                  (BuildContext context, index){
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => ViewBusiness(
                                                      category: amenities[index]['category'], businessId: amenities[index]['id'], businessDoc: amenities[index],

                                                    )));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.8,
                        // alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white ,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              ///Store Logo and Name
                              Expanded(
                                child: Stack(
                                  children: [
                                    ///Logo
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      width: MediaQuery.of(context).size.width ,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                amenities[index]["logo"],
                                              ),
                                              fit: BoxFit.cover
                                          )
                                      ),
                                    ),

                                    ///Add Favourite
                                    Positioned(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(onPressed: (){
                                            Fluttertoast.showToast(msg: "Pressed");
                                          }, icon: FaIcon(FontAwesomeIcons.solidHeart, color: Colors.grey,))
                                        ],
                                      ),
                                    ),

                                    ///Name and Details
                                    Positioned(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.07,
                                              width: MediaQuery.of(context).size.width,
                                              color: getColor("black", 0.75),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(amenities[index]["name"],
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 1.0), fontSize: 20, fontWeight: FontWeight.bold))
                                                  ),
                                                  Text(amenities[index]["address"],
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 0.6), fontSize: 12,))
                                                  ),

                                                  // Text(amenities[index]["price"],
                                                  //     textAlign: TextAlign.left,
                                                  //     style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 0.6), fontSize: 12,))
                                                  // ),

                                                ],
                                              ),
                                            )
                                          ],
                                        ))
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      FaIcon(FontAwesomeIcons.heart, size: 21,),
                                      Text('${amenities[index]["favourites"]}')
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.comment, size: 21, color: getColor('green', 1.0),),
                                        Text('${amenities[index]["comments"]}')
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.star,
                                          color: getColor('orange', 1.0),
                                          size: 21,),
                                        Text('${amenities[index]["rating"]}')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: amenities.length,
            ),


          )

        ],
      );
    } else if (index == 1){
      result = ChatPage(arguments: ChatPageArguments(peerAvatar: '', peerId: '', peerNickname: ''), );
    } else if (index == 2){
      result = Container();
    } else if (index == 3){
      result = Container();
    } else if (index == 4){
      result = Container();
    }
    return result;
  }

  ///load Local Storage Info
  void loadData() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
    });
  }

  ///initial state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAmenities();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        
        ///App Bar
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("Home Page",
              style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Color.fromRGBO(12, 106, 187, 1.0), fontSize: 13, fontWeight: FontWeight.bold))
          ),
        ),
        
        
        ///Floating Action Button
        floatingActionButton: FloatingActionButton(
          backgroundColor: getColor('orange', 1.0),
          child: Icon(Icons.add),
          onPressed: _showSimpleDialog,
        ),

        ///Botton Nab Bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: appBodyIndex,
          unselectedItemColor: getColor("blue", 0.3),
          fixedColor: getColor("blue", 1.0),
          onTap: (int){
            setState(() {
              appBodyIndex = int;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: 'Buy',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_play_rounded),
              label: 'Play',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notification',
            ),
          ],
        ),



        ///App Body
        body: appBody(appBodyIndex),
      ),
    );
  }
}
