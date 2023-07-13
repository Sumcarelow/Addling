///Landing page for business view

import 'package:adlinc/extras/colors.dart';
import 'package:adlinc/extras/ui_elements.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../extras/data.dart';
import '../business_reg/accomodation.dart';
import '../business_reg/fun_and_games.dart';
import '../business_reg/healthcare.dart';
import '../business_reg/home_care.dart';
import '../business_reg/restaurants.dart';
import '../business_reg/self_love.dart';
import '../product_pages/product_accomodation.dart';
import '../product_pages/product_fun_and_games.dart';
import '../product_pages/product_healthcare.dart';
import '../product_pages/product_self_love.dart';

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

  ///Functions

  ///Get Listings
  void getListing() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('listings').where('businessID', isEqualTo: widget.businessId).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.isNotEmpty){
      setState(() {
        listings = documents;
      });

      ///Load images
      documents.forEach((element) {
        loadPics(element.id, element);
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

  ///Navigate to relevent listing add page
  void setNav(){
    ///Set Nav
    ///
    print("I am here with: ${widget.businessDoc['subCategory']}");
    //setGroupNav(subCategory);
    if(widget.businessDoc['subCategory'] == 'B&B' || widget.businessDoc['subCategory'] == 'HOTEL' || widget.businessDoc['subCategory'] == 'VACATION DESTINATION' ){

      //Fluttertoast.showToast(msg: "Business Registration Successful");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Accommodation(group: 'ACCOMMODATION', bizID: widget.businessId)));

    }
    else if (widget.businessDoc['subCategory'] == 'RESTAURANTS'){
      //Fluttertoast.showToast(msg: "Business Registration Successful");
      // Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => Restaurant(group: 'RESTAURANTS', bizID: widget.businessId)));
    }
    else if (widget.businessDoc['subCategory'] == 'FUN & GAMES'){
      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => FunAndGames(group: 'games', bizID: widget.businessId)));
    }
    else if (
    widget.businessDoc['subCategory'] == 'SELF LOVE' ||
        widget.businessDoc['subCategory'] == 'MAKE-UP ARTIST' ||
        widget.businessDoc['subCategory'] == 'HAIRDRESSING' ||
        widget.businessDoc['subCategory'] == 'MANI AND PEDI' ||
        widget.businessDoc['subCategory'] == 'TATTOO PARLOUR' ||
        widget.businessDoc['subCategory'] == 'BODY PIERCING' ||
        widget.businessDoc['subCategory'] == 'NAIL TECHNICIAN' ||
        widget.businessDoc['subCategory'] == 'MASSAGE SALON/THERAPIST' ||
        widget.businessDoc['subCategory'] == 'FACIAL SPA' ||
        widget.businessDoc['subCategory'] == 'FOOT MASSAGE' ||
        widget.businessDoc['subCategory'] == 'SKIN CARE CONSULTING'
    ){
      //Fluttertoast.showToast(msg: "Business Registration Successful");
      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => SelfLove(group: 'self', bizID: widget.businessId)));
    }
    else if(
    widget.businessDoc['subCategory'] == 'HEALTHCARE' ||
        widget.businessDoc['subCategory'] == 'DENTIST' ||
        widget.businessDoc['subCategory'] == 'PHYSICIAN' ||
        widget.businessDoc['subCategory'] == 'GENERAL PRACTISIONER' ||
        widget.businessDoc['subCategory'] == 'THERAPIST' ||
        widget.businessDoc['subCategory'] == 'DERMATOLOGIST' ||
        widget.businessDoc['subCategory'] == 'COUNSELLOR'
    ){
      //Fluttertoast.showToast(msg: "Business Registration Successful");
      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => Healthcare(group: 'healthcare', bizID: widget.businessId)));
    }
    else if (
    widget.businessDoc['subCategory'] == 'HOME CARE' ||
        widget.businessDoc['subCategory'] == 'LAWN-MOWER' ||
        widget.businessDoc['subCategory'] == 'PLUMBING' ||
        widget.businessDoc['subCategory'] == 'CARPET CLEANING' ||
        widget.businessDoc['subCategory'] == 'MOVERS' ||
        widget.businessDoc['subCategory'] == 'ELECTRICIAN' ||
        widget.businessDoc['subCategory'] == 'MECHANIC' ||
        widget.businessDoc['subCategory'] == 'ROOF REPAIR' ||
        widget.businessDoc['subCategory'] == 'FLOORING' ||
        widget.businessDoc['subCategory'] == 'GUTTER CLEAN' ||
        widget.businessDoc['subCategory'] == 'PAINTER' ||
        widget.businessDoc['subCategory'] == 'LANDSCAPER'

    ) {
      //Fluttertoast.showToast(msg: "Business Registration Successful");
      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeCare(group: 'homeCare', bizID: widget.businessId)));
    }
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


  ///Navigate
 void navigateToNextPage(String Cat, String docID, DocumentSnapshot doc){
   print("I arrive with $Cat");
   if(Cat == 'B&B' || Cat == 'HOTEL' || Cat == 'VACATION DESTINATION' || Cat == 'HOSPITALITY & TOURISM' ){

     //Fluttertoast.showToast(msg: "Business Registration Successful");
     Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>
                 ProductAccommodation(listingID: docID, listingDoc: doc,)));

   }
   else if (Cat == 'RESTAURANTS'){
     Fluttertoast.showToast(msg: "Business Registration Successful");
     // Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
     Navigator.push(context, MaterialPageRoute(builder: (context) => Restaurant(group: 'RESTAURANTS', bizID: docID)));
   }
   else if (Cat == 'FUN & GAMES'){
     //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
     Navigator.push(context, MaterialPageRoute(builder: (context) => ProductFun( listingID: docID, listingDoc: doc,)));
   }
   else if (
   Cat == 'SELF LOVE' ||
       Cat == 'MAKE-UP ARTIST' ||
       Cat == 'HAIRDRESSING' ||
       Cat == 'MANI AND PEDI' ||
       Cat == 'TATTOO PARLOUR' ||
       Cat == 'BODY PIERCING' ||
       Cat == 'NAIL TECHNICIAN' ||
       Cat == 'MASSAGE SALON/THERAPIST' ||
       Cat == 'FACIAL SPA' ||
       Cat == 'FOOT MASSAGE' ||
       Cat == 'SKIN CARE CONSULTING'
   ){
    // Fluttertoast.showToast(msg: "Business Registration Successful");
     //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
     Navigator.push(context, MaterialPageRoute(builder: (context) => ProductSelfLove(listingID: docID, listingDoc: doc,)));
   }
   else if(
   Cat == 'HEALTHCARE' ||
       Cat == 'DENTIST' ||
       Cat == 'PHYSICIAN' ||
       Cat == 'GENERAL PRACTISIONER' ||
       Cat == 'THERAPIST' ||
       Cat == 'DERMATOLOGIST' ||
       Cat == 'COUNSELLOR'
   ){
     //Fluttertoast.showToast(msg: "Business Registration Successful");
     //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
     Navigator.push(context, MaterialPageRoute(builder: (context) => ProductHealthcare(listingDoc: doc, listingID: docID)));
   }
   else if (
   Cat == 'HOME CARE' ||
       Cat == 'LAWN-MOWER' ||
       Cat == 'PLUMBING' ||
       Cat == 'CARPET CLEANING' ||
       Cat == 'MOVERS' ||
       Cat == 'ELECTRICIAN' ||
       Cat == 'MECHANIC' ||
       Cat == 'ROOF REPAIR' ||
       Cat == 'FLOORING' ||
       Cat == 'GUTTER CLEAN' ||
       Cat == 'PAINTER' ||
       Cat == 'LANDSCAPER'

   ) {
     //Fluttertoast.showToast(msg: "Business Registration Successful");
     //Navigator.push(context, MaterialPageRoute(builder: (context) => AddListingNew()));
     //Navigator.push(context, MaterialPageRoute(builder: (context) => HomeCare(group: 'homeCare', bizID: docID)));
   }
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
    return Material(
      child: Scaffold(

        ///Floating Action: Add Product
        floatingActionButton:
        id == widget.businessDoc['ownerID']
        ///If user is business owner
          ? FloatingActionButton(
          backgroundColor: getColor('green', 1.0),
          onPressed: (){
            ///Navigate to Add Listing Page
            setNav();
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
          },
          child: Icon(Icons.add),
        )
        : null,

        ///App Body
        body: CustomScrollView(
          
          slivers: [

            ///App Bar
            SliverAppBar(
          backgroundColor: getColor('white', 1.0),
            centerTitle: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.25,
            title: Text(
              "${widget.businessDoc['name']}",
              style: TextStyle(
                color: getColor('white', 1.0),
            ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                 adSlider(pictures),

                 /* Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(widget.businessDoc['coverImage']),
                            fit: BoxFit.cover
                        )
                    ),
                  ),*/
                  Container(
                    color: getColor('black', 0.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.mapLocation,
                              color: getColor('white', 0.8),
                              size: 15,
                            ),
                            Text("${widget.businessDoc['address']}",
                              style: TextStyle(
                                  color:  getColor('white', 1.0),
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Expanded(
                                child: Text("${widget.businessDoc['bio']}",
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:  getColor('white', 1.0),
                                ),
                                ),
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

                ],
              ),
            ),
        ),

            ///List of Listings
            SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: listingsList.length,
                    (BuildContext context, int index){
                      return GestureDetector(
                        onTap: (){
                          navigateToNextPage(widget.businessDoc['subCategory'], listingsList[index].doc['id'], listingsList[index].doc);
                          //Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProductFun(listingID: listingsList[index].doc['id'], listingDoc: listingsList[index].doc,)));
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
                                          adSlider(listingsList[index].pics),
                                          /*Container(
                                            height: MediaQuery.of(context).size.height * 0.5,
                                            width: MediaQuery.of(context).size.width ,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                      listings[index]["logo"],
                                                    ),
                                                    fit: BoxFit.cover
                                                )
                                            ),
                                          ),*/

                                          ///Add Favourite
                                          /*Positioned(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(onPressed: (){
                                                  Fluttertoast.showToast(msg: "Pressed");
                                                }, icon: FaIcon(FontAwesomeIcons.solidHeart, color: Colors.grey,))
                                              ],
                                            ),
                                          ),*/

                                          ///Name and Details
                                          Positioned(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    height: MediaQuery.of(context).size.height * 0.1,
                                                    width: MediaQuery.of(context).size.width,
                                                    color: getColor("black", 0.75),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Text(listingsList[index].name,
                                                            textAlign: TextAlign.left,
                                                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 1.0), fontSize: 20, fontWeight: FontWeight.bold))
                                                        ),
                                                        Text(listingsList[index].description,
                                                            textAlign: TextAlign.center,
                                                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 0.6), fontSize: 12,))
                                                        ),

                                                        Text("R ${listingsList[index].price}",
                                                            textAlign: TextAlign.left,
                                                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor("white", 1.0), fontSize: 14,))
                                                        ),

                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),

                                    ///Bottom Icons
                                    /*Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.heart, size: 21,),
                                            Text('${listings[index]["favourites"]}')
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.comment, size: 21, color: getColor('green', 1.0),),
                                              Text('${listings[index]["comments"]}')
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
                                              Text('${listings[index]["rating"]}')
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),*/
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                ))
          ],
        ),
      ),
    );
  }
}
