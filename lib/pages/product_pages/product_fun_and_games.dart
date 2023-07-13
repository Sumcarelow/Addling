///Page for displaying Accommodastion Businesses
import 'package:adlinc/extras/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../extras/data.dart';
import '../home.dart';
import '../payment.dart';


class ProductFun extends StatefulWidget {
  final String listingID;
  final DocumentSnapshot listingDoc;
  const ProductFun({Key? key, required this.listingID, required this.listingDoc}) : super(key: key);

  @override
  State<ProductFun> createState() => _ProductFunState();
}

class _ProductFunState extends State<ProductFun> {
  ///Variables
  late String checkIn, id, ageRestriction, userAge, bookingTime,yocoUrl;
  String moreInfo = '';
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> pictures = [];

  final TextEditingController checkInController = TextEditingController();
  final TextEditingController moreInfoController = TextEditingController();
  final TextEditingController userAgeController = TextEditingController();
  final TextEditingController bookingTimeController = TextEditingController();

  final FocusNode focusNodeMoreInfo = FocusNode();
  final FocusNode focusNodeCheckIn = FocusNode();
  final FocusNode focusNodeUserAge = FocusNode();
  final FocusNode focusNodeBookingTime = FocusNode();


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
          'amount': (int.parse(widget.listingDoc['price'])/0.01),
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
              builder: (context) => PaymentMethod(package: decodeHttp["redirectUrl"], price: widget.listingDoc['price'],)));
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
  postData() async{

    ///Unfocus all nodes
    focusNodeCheckIn.unfocus();

    ///Post to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('orders').doc();
    docRef.set({
      'id': docRef.id,
      'customerID': id,
      'productID': widget.listingDoc['id'],
      'price': widget.listingDoc['price'],
      'checkIn': checkIn,
      'age': userAge,
      'moreInfo': moreInfo,
      'bookingDate': checkIn,
      'status': 'pending',
    }).then((value)  {
      ///Fluttertoast
      Fluttertoast.showToast(msg: "Order Placed Successfully");

      ///Navigate to Home Page
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

    });
  }

  ///Fetch Listing information from Firebase
  ///Amenities
  fetchAmenities() async {
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('listings').doc(widget.listingID).collection('amenities').get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if list is empty
    if(documents.isNotEmpty){
      setState(() {
        amenities = documents;
      });
    }

  }


  ///Pictures
  fetchPics() async {
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('listings').doc(widget.listingID).collection('pictures').get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if list is empty
    if(documents.isNotEmpty){
      setState(() {
        pictures = documents;
      });
    }

  }


  ///Picture Slider
  Container adSlider(List<DocumentSnapshot> picList){
    return Container(
        height: MediaQuery.of(context).size.height * 0.29,
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
    fetchAmenities();
    fetchPics();
    loadData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      ///App Bar
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: getColor('orange', 1.0),
        title: Text('${widget.listingDoc['name']}'),
      ),

      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ///Room Description
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("${widget.listingDoc['description']}",
                  textAlign: TextAlign.center,
                ),
              ),

              ///Age Restriction
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Age Restriction: ${widget.listingDoc['age']}",
                  textAlign: TextAlign.center,
                ),
              ),


              ///Amenities
              Text("Amenities",
                style: TextStyle(
                    fontWeight: FontWeight.w700
                ),
              ),
              Flexible(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.09,
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                          childAspectRatio: 4 / 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20
                      ),
                      itemCount: amenities.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return Card(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(amenities[index]["name"],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont('Roboto', textStyle: const TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 10,))
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),

              ///Booking
              ///Age
              Container(
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
                child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                  child: TextFormField(
                    autocorrect: false,
                    cursorColor: Colors.grey,
                    style: const TextStyle(
                        color: Colors.grey
                    ),
                    decoration: const InputDecoration(

                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      focusColor: Colors.grey,
                      fillColor: Colors.grey,
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Your Age',
                      contentPadding: EdgeInsets.all(5.0),
                      hintStyle: TextStyle(color: Colors.grey),

                    ),
                    controller: userAgeController,
                    validator: (value) {

                    },
                    onChanged: (value) {
                      userAge = value;
                    },
                    focusNode: focusNodeUserAge,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ///Check In Date
                  Expanded  (
                    child: Container(
                      margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                        child: TextFormField(
                          onTap: () async{
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2100));

                            if (pickedDate != null) {
                              //pickedDate output format => 2021-03-10 00:00:00.000
                              String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                              //formatted date output using intl package =>  2021-03-16
                              setState(() {
                                checkInController.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {}
                          },
                          readOnly: true,
                          autocorrect: false,
                          cursorColor: Colors.grey,
                          style: const TextStyle(
                              color: Colors.grey
                          ),
                          decoration: const InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.grey,
                            fillColor: Colors.grey,
                            labelStyle: TextStyle(color: Colors.grey),
                            hintText: 'Booking Date',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,  fontSize: 14),

                          ),
                          controller: checkInController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter a valid value';
                            }
                            return null;
                          },
                          /*onChanged: (value) {
                            checkIn = value;
                          },*/
                          focusNode: focusNodeCheckIn,
                        ),
                      ),
                    ),
                  ),

                  ///Check in Time
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.09,
                      alignment: Alignment.center,
                      //decoration: BoxDecoration(color: Colors.grey[200]),
                      child: TextFormField(
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                        onSaved: (String? val) {
                          bookingTime = val!;
                        },
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        controller: bookingTimeController,
                        onTap: () async{
                          TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now());

                          if (pickedTime != null) {
                            DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                            //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedTime = DateFormat('HH:mm').format(parsedTime);
                            //formatted date output using intl package =>  2021-03-16
                            setState(() {
                              bookingTimeController.text =
                                  formattedTime; //set output date to TextField value.
                              bookingTime = formattedTime;
                            });
                          } else {}
                        },
                        decoration: const InputDecoration(
                            disabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide.none),
                            labelText: 'Time',
                            contentPadding: EdgeInsets.all(5)),
                        focusNode: focusNodeBookingTime,
                      ),
                    ),
                  ),

                ],
              ),
              ///More Info
              Container(
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
                child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                  child: TextFormField(
                    autocorrect: false,
                    cursorColor: Colors.grey,
                    style: const TextStyle(
                        color: Colors.grey
                    ),
                    decoration: const InputDecoration(

                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      focusColor: Colors.grey,
                      fillColor: Colors.grey,
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'More Info ...',
                      contentPadding: EdgeInsets.all(5.0),
                      hintStyle: TextStyle(color: Colors.grey),

                    ),
                    controller: moreInfoController,
                    validator: (value) {

                    },
                    onChanged: (value) {
                      moreInfo = value;
                    },
                    focusNode: focusNodeMoreInfo,
                  ),
                ),
              ),

              ///Book Now Button
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                  ),
                  //color: colors[2],
                  onPressed: (){
                    paymentGateWay();
                    //postData();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                        right: MediaQuery.of(context).size.width * 0.07),
                    child: Text("Book Now",
                        style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                    ),
                  )
              ),

              ///Gallery
              Flexible(child: adSlider(pictures),)

            ],
          ),
        ),
      ),
    );
  }
}
