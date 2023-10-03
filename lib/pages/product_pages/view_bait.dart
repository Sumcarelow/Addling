///Page for displaying Accommodation Businesses
import 'package:adlinc/extras/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../extras/data.dart';
import '../main_tabs/home.dart';
import 'package:http/http.dart' as http;
import '../payment.dart';


class ViewBait extends StatefulWidget {
  final DocumentSnapshot baitPlant;
  final String userID;
  const ViewBait({Key? key, required this.baitPlant, required this.userID}) : super(key: key);

  @override
  State<ViewBait> createState() => _ViewBaitState();
}

class _ViewBaitState extends State<ViewBait> {
  ///Variables
  late String  yocoUrl;
  String paymentMethod = payments[0];
  String id = '', moreInfo = '';
  List<DocumentSnapshot> pics = [];

  final TextEditingController checkInController = TextEditingController();
  final TextEditingController bookingTimeController = TextEditingController();
  final TextEditingController moreInfoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final FocusNode focusNodeCheckIn = FocusNode();
  final FocusNode focusNodeBookingTime = FocusNode();
  final FocusNode focusNodeMoreInfo = FocusNode();
  final FocusNode focusNodeAddress = FocusNode();
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> pictures = [];
  late DocumentSnapshot user;

  void paymentGateWay() async {
    setState(() {
      //isLoading = true;
    });
    var url = Uri.parse('https://checkout-online.yoco.com/checkouts');
    String basicAuth = 'Bearer sk_test_960bfde0VBrLlpK098e4ffeb53e1';
    var response = await http.post(url,
        headers: <String, String>{
          'X-Auth-Secret-Key': 'sk_test_960bfde0VBrLlpK098e4ffeb53e1',
          'publicKey': 'pk_test_ed3c54a6gOol69qa7f45',
          'authorization': basicAuth,
          "content-type":"application/json"
        },
        body: jsonEncode({
          //"token": token,
          'amount': (int.parse(widget.baitPlant['price'])/0.01),
          'currency': 'ZAR',
          "cancelUrl": 'https://www.eleglem.co.za'
        })

    );
    //print('Response status: ${response.body}');


    var decodeHttp = json.decode(response.body);
    //print("The data: ${decodeHttp["status"]}");

    if(decodeHttp["status"] == "created"){
      setState(() {
        //isLoading = false;
        yocoUrl = decodeHttp["redirectUrl"];
      });

      ///Go to yoco payment page
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentMethod(package: decodeHttp["redirectUrl"], price: widget.baitPlant['price'],)));
      //Fluttertoast.showToast(msg: "Payment Completed Successfully");

      ///Place order on Firebase
      //placeYocoOrder();

    } else {
      setState(() {
        //isLoading = false;
      });
      //print(decodeHttp);
      Fluttertoast.showToast(msg: "There was an error completing your payment.");
    }

    //print(response.body);
  }

  ///Post Data to firebase
  postData() async {

    ///Post to Firebase orders
    DocumentReference docRef = FirebaseFirestore.instance.collection('orders').doc();
    docRef.set({
      'id': docRef.id,
      'customerID': id,
      'productID': widget.baitPlant['id'],
      'price': widget.baitPlant['price'],
      'productName': widget.baitPlant['name'],
      'payment': paymentMethod,
      'status': 'pending',
      'datePlaced':  DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString()
    }).then((value)  {

      postDataForUser();

      ///Fluttertoast
      //Fluttertoast.showToast(msg: "Order Placed Successfully");

      ///Navigate to Home Page
      //Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

    });
  }

  postDataForUser() async {

    int cost = widget.baitPlant['price'];
    double newWallet = double.parse(user['wallet']) - cost;
    double gained = (cost)*0.05;

    if(double.parse(user['wallet']) < cost || newWallet < 0){
      Fluttertoast.showToast(msg: "You do not have enough money in your wallet to make this purchase.");
    } else {
      ///Post to Firebase orders
      DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(id);
      docRef.update({
        'wallet': newWallet.toString(),
        'coins': (double.parse(user['wallet']) + gained).toString()
      }).then((value)  {
        ///Fluttertoast
        Fluttertoast.showToast(msg: "Order Placed Successfully");

        FirebaseFirestore.instance.collection('baits')
            .doc(widget.baitPlant['id'])
            .collection('follows')
            .doc(id)
            .delete();

        FirebaseFirestore.instance.collection('users')
            .doc(user.id)
            .collection('follows')
            .doc(widget.baitPlant['id'])
            .delete();

        ///Add reciept
        DocumentReference receiptDoc = FirebaseFirestore.instance.collection('users').doc(id).collection('receipts').doc();
        receiptDoc.set({
          'title': 'Coins Purchase',
          'type': 'purchase',
          'amount': newWallet,
          'date':  DateFormat('dd MMMM yyyy').format(DateTime.now()).toString()
        });

        ///Navigate to Home Page
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

      });
    }


  }

  ///Fetch user location
  void getUsers() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: widget.userID).get();
    final List<DocumentSnapshot> documents = result.docs;
    var temp = documents[0];

    setState(() {
      user = temp;
    });
    //getAmenitiesByCat(selected);
    //getBusinesses(temp['coordinates']['lat'], temp['coordinates']['long']);

  }

  ///Get bait pictures
  void getBaitPics() async{
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('baits').doc(widget.baitPlant.id).collection('pictures').get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      pics = documents;
    });
  }

  ///Picture Slider
  Container adSlider(List<DocumentSnapshot> picList){
    return Container(
        height: MediaQuery.of(context).size.height * 0.4,
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
                          fit: BoxFit.cover,
                        )
                    )
                ),
              );
            });
          }).toList(),)
    );
  }

  ///load Local Storage Info
  void loadData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
    });

  }

  Widget restTypesDropDown(){
    return DropdownButton(

      /// Initial Value
      value: paymentMethod,

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: payments.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          paymentMethod = newValue!;
        });
      },
    );
  }

  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    getUsers();
    getBaitPics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      ///App Bar
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: ()=>{
            Navigator.pop(context)
          },
          icon:Icon(Icons.keyboard_backspace, color: getColor('black', 1.0),)),
        centerTitle: true,
        backgroundColor: getColor('white', 1.0),
        title: Text('${widget.baitPlant['name']}',
          style: TextStyle(
              color: getColor('black', 1.0)
          ),),
      ),

      bottomSheet:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Row(
              children: [
                Icon(Icons.monetization_on_outlined,
                  size: 33,
                  color: getColor('iconYellow', 1.0),
                ),
                Text('Get ${double.parse(widget.baitPlant['coins']).toStringAsFixed(2)} coins',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18
                  ),
                ),
              ],
            ),
            ///Book Now Button
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:  MaterialStatePropertyAll<Color>(Colors.lightBlue,),
                ),
                //color: colors[2],
                onPressed: (){
                  postData();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                      right: MediaQuery.of(context).size.width * 0.07),
                  child: Text("Buy Now",
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                  ),
                )
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Gallery
            pics.length != 0
            ?
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            pics[0]['location'],

                        ),
                        fit: BoxFit.fitWidth
                      )
                    ),
                  ),
                ),
              ),
            )
            :Container(),

            Flexible(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pics.length,
                  itemBuilder: (BuildContext context, int index){
                  return
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                    pics[index]['location'],

                                  ),
                                  fit: BoxFit.fitWidth
                              )
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ),

            ///Business Name
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Business Name: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                    ),
                    Text('${widget.baitPlant['businessName']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16
                    ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
