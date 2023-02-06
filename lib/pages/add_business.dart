import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/variables.dart';
import 'home.dart';
import 'dart:io';
import '../extras/colors.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({Key? key}) : super(key: key);

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  ///Form Variables
  late String name, businessEmail, phone, logo = logoURL, address, category = 'Please select your business category', subCategory = 'Please select your business sub-category';
  List<String> categoriesList = ['Please select your business category'];
  List<String> subCategoriesList = ['Please select your business sub-category'];
  List<DocumentSnapshot> categories = [];
  List<DocumentSnapshot> subCategories = [];
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final FocusNode focusNodeUserEmail = FocusNode();
  final FocusNode focusNodeUserName = FocusNode();
  final FocusNode focusNodeUserLastName = FocusNode();
  final FocusNode focusNodePhone= FocusNode();
  final FocusNode focusNodeAddress = FocusNode();

  ///Shared Preferences instance
  late SharedPreferences prefs;

  ///Toggle show password
  bool showPassword = false;
  bool showAcceptTC = false;
  var profileImage;

  ///Fetch Categories from Firebase using level as key
  void getCategories(String level) async{
    ///Get Firebase Docs
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('categories').where('level', isEqualTo: level).get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if documents were loaeded successfully
    if(documents.length != 0){
      ///Load to the relevant list
      if(level == 'main'){
        //Load to main categories list
        documents.forEach((categ) {

          this.setState(() {
            categoriesList.add(categ['name']);
            categories = documents;
          });
        });
      } else if(level == 'sub'){
        documents.forEach((categ) {
          this.setState(() {
            subCategories = documents;
          });
        });
      }

    } else {
      Fluttertoast.showToast(msg: "There was an error loading requested information");
    }
  }

  ///When Add Business Button is pressed
  void onRegisterBusinessPress() async{
    ///Unfocus all nodes
    focusNodeUserEmail.unfocus();
    focusNodeUserName.unfocus();
    focusNodePhone.unfocus();
    focusNodeAddress.unfocus();

    ///Initialize Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///Get Firebase Docs
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('businesses').where('email', isEqualTo: businessEmail)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    ///Check if business with email exists on Firebase
    if(documents.length != 0){
      Fluttertoast.showToast(msg: "Business already exists, please use login or forgot password.");
    } else {
      ///Check if T&C's are Accepted
      if(showAcceptTC){
        postData();
      } else {
        Fluttertoast.showToast(msg: "Please accept the terms and conditions to proceed.");
      }
    }
  }

  ///Post data to Firebase
  void postData() async{
    ///Add new user to Firebase
    DocumentReference docRef = FirebaseFirestore.instance.collection('businesses').doc();
    docRef.set({
      'id': docRef.id,
      'name': name,
      'email': businessEmail,
      'phone': phone,
      'address': address,
      'category': category,
      'subCategory': subCategory,
      'logo': logo,
      'status': 'pending',
      'dateRegistered': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
    }).then((value) async {

      Fluttertoast.showToast(msg: "Business Registration Successful");

      ///Navigate to Home Page
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

    });
  }

  ///Select Business Logo
  ///Upload Business Logo to firebase storage
  Future uploadProfilePicture() async {
    ///Set OnLoading Screen
    setState(() {
      isLoading = true;
      loadigScreenMsg = "Uploading profile picture...";
    });

    ///Shared Preferences Instance
    prefs = await SharedPreferences.getInstance();

    ///File Name on Firebase storage
    String fileName = 'Logo' + DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();

    ///Create storage reference and upload image
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(profileImage);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value){
      ///If Upload was successful
      storageTaskSnapshot = value;

      ///Get Url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)async{
        setState(() {
          logo = downloadUrl;
          isLoading = false;
        });

        //await prefs.setString('profilePic', profilePic);
        Fluttertoast.showToast(msg: "Business logo Uploaded Successfully.");
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

  ///Load image from phone storage
  Future getImage() async {
    var images = (
        await FilePicker.platform.pickFiles(
            type: FileType.image,
            dialogTitle: "Please select a logo as a picture."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        profileImage = File((images.first.path).toString());
      });
      uploadProfilePicture();
    }
  }

  ///Filter Sub Categories
  void filterSubCategories(String value){
    this.setState(() {
      subCategory = 'Please select your business sub-category';
      subCategoriesList = ['Please select your business sub-category'];
    });
    subCategories.forEach((element) {
      if(element['from'] == value){
        subCategoriesList.add(element['name']);
      }
    });
  }

  ///On Main Category Drop Down Select
  void mainCategorySelect(String? value){
    //Set category variable
    this.setState(() {
      category = value!;
    });

    //fetch sub categories
    filterSubCategories(value!);
  }

  ///Dropdown Widgets
  Widget categoryDropDown(){
    return DropdownButton<String>(
        value: category,
        items: categoriesList.map<DropdownMenuItem<String>>((String element) {
      return DropdownMenuItem<String>(
      value: element,
        child: Text(element),
      );
    }).toList(),
        onChanged: (String? newValue){
          mainCategorySelect(newValue);
        });
  }
  Widget subCategoryDropDown(){
    return DropdownButton<String>(
        value: subCategory,
        items: subCategoriesList.map<DropdownMenuItem<String>>((String element) {
      return DropdownMenuItem<String>(
      value: element,
        child: Text(element),
      );
    }).toList(),
        onChanged: (String? newValue){
          this.setState(() {
            subCategory = newValue!;
          });;
        });
  }

  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategories('main');
    getCategories('sub');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getColor('white', 1.0),
        leading: IconButton(
          onPressed: ()=>{
            Navigator.pop(context)
          },
          icon: Icon(Icons.close), color: getColor('red', 1.0),),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/logo2.png'),
                          fit: BoxFit.fill
                      )
                  ),
                ),
              ),
              Text("Business\nInformation",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('black', 1.0), fontSize: 28, ))
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),

              ///Registration Form
              Form(
                  key: registerFormKey,
                  child: Column(
                    children: [
                      ///Business Name
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            autocorrect: false,
                            cursorColor: Colors.grey,
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(

                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: Colors.grey,
                              fillColor: Colors.grey,
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: 'Business Name',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),

                            ),
                            controller: nameController,
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter your Business Name';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              name = value;
                            },
                            focusNode: focusNodeUserName,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),


                      ///Business Email Address
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: getColor('green', 1.0), splashColor: getColor('green', 1.0)),
                          child: TextFormField(
                            autocorrect: false,
                            cursorColor: Colors.grey,
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              focusColor: getColor('green', 1.0),
                              fillColor: getColor('green', 1.0),
                              labelStyle: TextStyle(color: getColor('green', 1.0),),
                              hintText: 'Email',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),

                            ),
                            controller: emailController,
                            validator: (value) {
                              if (!EmailValidator.validate(value!)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              businessEmail = value;
                            },
                            focusNode: focusNodeUserEmail,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      ///Phone Number
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(
                              hintText: 'Phone',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: phoneController,
                            validator: (value) {
                              if (value!.length != 10) {
                                return 'Please enter valid phone number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              phone = value;
                            },
                            focusNode: focusNodePhone,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      ///Address
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.grey),
                          child: TextFormField(
                            style: TextStyle(
                                color: Colors.grey
                            ),
                            decoration: InputDecoration(
                              hintText: 'Business Address',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),

                            ),
                            controller: addressController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Cannot be empty';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              address = value;
                            },
                            focusNode: focusNodeAddress,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      ///Category selection
                      categoryDropDown(),
                      subCategoryDropDown(),

                      ///Accept terms and conditions
                      Row(
                        children: [
                          Checkbox(
                              value: showAcceptTC,
                              onChanged: (bool? show){
                                setState(() {
                                  showAcceptTC = !showAcceptTC;
                                });

                              }),
                          Text("I accept the terms and conditions.")
                        ],
                      ),

                      ///Upload Pic Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ///Company Logo Section
                          Expanded(
                            child: Container(
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    (profileImage == null)
                                        ? (logo != ''
                                        ? Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ),
                                          width: 120.0,
                                          height: 120.0,
                                          padding: EdgeInsets.all(20.0),
                                        ),
                                        imageUrl: logo,
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                      clipBehavior: Clip.hardEdge,
                                    )
                                        : Icon(
                                      Icons.account_circle,
                                      size: 120.0,
                                    ))
                                        : Material(
                                      child: Image.file(
                                        profileImage,
                                        width: 120.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: getImage,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                            ),
                                            Text('Upload logo')
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              width: double.infinity,
                              margin: EdgeInsets.all(20.0),
                            ),
                          ),
                        ],
                      ),
                      ///Bottom Section
                      ///Continue Button
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0),),
                          ),
                          //color: colors[2],
                          onPressed: (){
                            registerFormKey.currentState!.validate()
                                ? onRegisterBusinessPress()
                                : Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                                right: MediaQuery.of(context).size.width * 0.07),
                            child: Text("Register Business",
                                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: getColor('white', 1.0), fontSize: 16, fontWeight: FontWeight.bold))
                            ),
                          )
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
