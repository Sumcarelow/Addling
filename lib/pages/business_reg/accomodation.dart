///Add Accommodation listing Page
///
///
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extras/colors.dart';
import '../../extras/data.dart';
import '../../extras/variables.dart';
import '../home.dart';
import 'dart:io';


class Accommodation extends StatefulWidget {
  final String group, bizID;
  const Accommodation({Key? key, required this.group, required this.bizID}) : super(key: key);

  @override
  State<Accommodation> createState() => _AccommodationState();
}

class _AccommodationState extends State<Accommodation> {
  ///Variables
  List<DocumentSnapshot> amenities = [];
  List<DocumentSnapshot> myAmenities = [];
  List<dynamic> productPictures = [];
  List<Bed> roomBeds = [];
  List<Price> roomPrices = [];
  late String id, name, description, price, productPic = logoURL, beds, sizes, bedSize = "Single",
      priceFrequency, bedQuantity, category;
  var profileImage;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descrController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController bedQuantityController = TextEditingController();
  final FocusNode focusNodeUserName= FocusNode();
  final FocusNode focusNodeUserDescr = FocusNode();
  final FocusNode focusNodeUserPrice = FocusNode();
  final FocusNode focusNodeBedQuantity = FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ///Shared Preferences instance
  late SharedPreferences prefs;


  ///Load image from phone storage
  Future getImage() async {
    var images = (
        await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.image,
            dialogTitle: "Please select room pictures."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        productPictures = images;
      });
    }
  }

  ///Upload Profile Image to firebase storage
  Future uploadProfilePicture(File image, String docID, String name) async {
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadingScreenMsg = "Uploading room pictures...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = name + 'pr-accom' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

    ///Create storage reference and upload image
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value){
      ///If Upload was successful
      storageTaskSnapshot = value;

      ///Get Url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)async{

        FirebaseFirestore.instance.collection("listings").doc(docID).collection('pictures').doc()
            .set({
          "location": downloadUrl
        });
        setState(() {
          //profilePic = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Pictures Uploaded Successfully.");
      }, onError: (err){
        ///Set Off Loading Screen
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    }, onError: (err){
      ///Set Off Loading Screen
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }



  ///Drop down Button for BedSizes
  Widget bedSizeDropDown(String value){
    return DropdownButton(

      /// Initial Value
      value: value,

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: bedSizes.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          value = newValue!;
        });
      },
    );
  }

  ///Drop down Button for priceFreqs
  Widget priceFreqDropDown(){
    return DropdownButton(

      /// Initial Value
      value: priceFreqs[0],

      /// Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      /// Array list of items
      items: priceFreqs.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: Text(items),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (String? newValue) {
        setState(() {
          priceFrequency = newValue!;
        });
      },
    );
  }

  ///Upload Beds Information
  void uploadBedsInformation(String roomID) async{
    ///Go through Beds List and add each bed to room

    roomBeds.forEach((bed) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('listings').doc(roomID).collection('beds').doc();
      docRef.set({
        'id': docRef.id,
        'size': bed.size,
        'quantity': bed.quantity
      });
    });
  }

  ///Upload Prices Information
  void uploadPricesInformation(String roomID) async{
    ///Go through Beds List and add each bed to room

    roomPrices.forEach((price) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('listings').doc(roomID).collection('beds').doc();
      docRef.set({
        'id': docRef.id,
        'amount': price.amount,
        'frequency': price.frequency
      });
    });
  }


  ///Upload Beds Information
  void uploadAmenities(String roomID) async{
    ///Go through Beds List and add each bed to room
    myAmenities.forEach((amenity) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('listings').doc(roomID).collection('amenities').doc();
      docRef.set({
        'id': docRef.id,
        'name': amenity['name'],
      });
    });
  }
  ///Dropdown for prices
  Widget priceTypeDropDown() {
    return DropdownButton<String>(
      value: price,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        //color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          price = value!;
        });
      },
      items: prices.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('R$value'),
        );
      }).toList(),
    );
  }

  ///Post data to Firebase
  void postData() async{

    ///Add new user to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('listings').doc();

    docRef.set({
      'id': docRef.id,
      'name': name,
      'description': description,
      'price': price,
      'businessID': widget.bizID,
      'dateRegistered': "${DateFormat('dd MMMM yyyy').format(DateTime.now())} ${DateFormat('hh:mm:ss').format(DateTime.now())}",
    }).then((value) async {

      ///Upload Product Pictures
      productPictures.forEach((element) {
        uploadProfilePicture(File(element.path), docRef.id, name);
      });

      ///Upload Beds List or Price List
      if(widget.bizID == 'PFU0is7zxXfX8kMAzZFa' ){
        uploadPricesInformation(docRef.id);
      } else {
        uploadBedsInformation(docRef.id);
      }

      ///Upload Amenities List
      uploadAmenities(docRef.id);

      Fluttertoast.showToast(msg: "Listing created Successfully");

      ///Navigate to Home Page
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));

    });
  }

  ///Get amenities list from Firebase
  void getAmenities() async{
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('amenities').doc('PnOa8rGv8rUZYk6dHrVt').collection('amenities').get();
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

  ///Load Local Saved Data to page
  void readLocal() async{
    setState((){
      isLoading = false;
    });
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    category = prefs.getString('bizSubCategory') ?? '';
    setState(() {

    });
  }

  ///Initial state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ///Load Local Storage
    readLocal();

    ///Get Amenities Data From Firebase
    getAmenities();
    this.setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: getColor('white', 1.0),
              ///AppBar Title
              centerTitle: true,
              title: Text("Add Accommodation Listing",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 18, ))
              ),
              leading: IconButton(
                onPressed: ()=>{
                  Navigator.pop(context)
                },
                icon: const Icon(Icons.close), color: getColor('red', 1.0),),
            ),

            ///Page Body
            body: Container(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    ///Product Images
                    productPictures.isEmpty
                        ? GestureDetector(
                      onTap: getImage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                          ),
                          const Text('Upload Images')
                        ],
                      ),
                    )
                        : Wrap(
                      spacing: MediaQuery.of(context).size.width * 0.05,
                      children: productPictures.map((picture) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.width * 0.15,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(File(picture.path)),
                                fit: BoxFit.fill
                            ),
                          ),
                          child: const Text(""),
                        );
                      }).toList(),
                    ),

                    ///Product Name
                    Container(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
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
                            hintText: 'Room Name',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: nameController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter your Product Name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            name = value;
                          },
                          focusNode: focusNodeUserName,
                        ),
                      ),
                    ),

                    ///Product Description
                    Container(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
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
                            hintText: 'Room Description',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: descrController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter your listing description';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            description = value;
                          },
                          focusNode: focusNodeUserDescr,
                        ),
                      ),
                    ),

                    ///product price

                    widget.bizID == 'PFU0is7zxXfX8kMAzZFa'
                    ? Container()
                    :
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Price: "),
                        priceTypeDropDown(),
                      ],
                    ),
                    /*Container(
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
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
                            hintText: 'Cost Per Night',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                          controller: priceController,
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter your Listing Price';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            price = value;
                          },
                          focusNode: focusNodeUserPrice,
                        ),
                      ),
                    ),*/
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Center(
                        child: Text(
                            widget.bizID == 'PFU0is7zxXfX8kMAzZFa'
                            ? "Room Prices"
                            :
                                "Bed Sizes",
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                        ),
                      ),
                    ),


                    ///Check if it's a Vacation Destination
                    widget.bizID == 'PFU0is7zxXfX8kMAzZFa'
                        ? roomPrices.isNotEmpty
                          ?
                    Wrap(
                      children:
                      roomPrices.map((index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(index.amount,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            Text(index.frequency,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    roomPrices.remove(index);
                                  });
                                },
                                icon: Icon(Icons.remove, color: getColor('red', 1.0),)),
                          ],
                        );
                      }).toList()
                      ,
                    )
                    : Container()
                        :
                    roomBeds.isNotEmpty
                        ?
                    Wrap(
                      children:
                      roomBeds.map((index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(index.quantity,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            Text(index.size,
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 12, ))
                            ),
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    roomBeds.remove(index);
                                  });
                                },
                                icon: Icon(Icons.remove, color: getColor('red', 1.0),)),
                          ],
                        );
                      }).toList()
                      ,
                    )

                        : Container(),

                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                        ///Check if it's a Vacation Destination
                        widget.bizID == 'PFU0is7zxXfX8kMAzZFa'
                        ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ///Charge
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 30.0, right: 30.0),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                                primaryColor: Colors.grey),
                                            child: TextFormField(
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                              decoration: const InputDecoration(
                                                hintText: 'Quantity',
                                                contentPadding:
                                                EdgeInsets.all(5.0),
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              controller: bedQuantityController,
                                              onChanged: (value) {
                                                bedQuantity = value;
                                              },
                                              focusNode: focusNodeBedQuantity,
                                            ),
                                          ),
                                        ),
                                      ),

                                      /// Payment Frequency
                                      Expanded(child: priceFreqDropDown()),


                                      ///Add button
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              roomBeds.add(Bed(
                                                  size: bedSize,
                                                  quantity: bedQuantity));
                                            });
                                            bedQuantityController.clear();
                                          },
                                          icon: Icon(
                                            Icons.add,
                                            color: getColor('green', 1.0),
                                          ))
                                    ],
                                  )
                                :
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            ///Bed Size
                            Expanded(child: bedSizeDropDown(bedSize)),

                            ///Charge
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                                  child: TextFormField(
                                    style: const TextStyle(
                                        color: Colors.grey
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Quantity',
                                      contentPadding: EdgeInsets.all(5.0),
                                      hintStyle: TextStyle(color: Colors.grey),

                                    ),
                                    controller: bedQuantityController,
                                    onChanged: (value) {
                                      bedQuantity = value;
                                    },
                                    focusNode: focusNodeBedQuantity,
                                  ),
                                ),
                              ),
                            ),

                            ///Add button
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    roomBeds.add(
                                        Bed(size: bedSize, quantity: bedQuantity)
                                    );
                                  });
                                  bedQuantityController.clear();
                                },
                                icon: Icon(Icons.add, color: getColor('green', 1.0),))
                          ],
                        ),
                      ),
                    ),

                    ///Amenities section
                    Expanded(
                      child: GridView.builder(
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
                                if(
                                myAmenities.contains(amenities[index])){
                                  setState(() {
                                    myAmenities.remove(amenities[index]);
                                  });
                                } else {
                                  setState(() {
                                    myAmenities.add(amenities[index]);
                                  });
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: myAmenities.contains(amenities[index])? Colors.green : Colors.grey,
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

                    ///Submit Button
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: (){
                          formKey.currentState!.validate() && productPictures.isNotEmpty
                              ? postData()
                              : null;
                        },
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                        ),
                        child: const Text("Add Room Listing"),
                      ),
                    )

                  ],
                ),
              ),
            ),
          ),

          ///Loading Screen
          isLoading
              ? Positioned(
            child: Container(
              color: getColor("black", 0.5),
              child: Center(
                child: Text(loadingScreenMsg, style: TextStyle(
                    color: getColor("white", 1.0)
                ),),
              ),
            ),
          )
              : Container()
        ],
      ),
    );
  }
}
