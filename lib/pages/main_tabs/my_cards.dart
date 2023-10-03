import 'package:adlinc/extras/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../extras/functions.dart';
import '../../extras/ui_elements.dart';
import '../../extras/variables.dart';


class MyCards extends StatefulWidget {
  final String id;
  const MyCards({super.key, required this.id});

  @override
  State<MyCards> createState() => _MyCardsState();
}

class _MyCardsState extends State<MyCards> {
  ///Variables
  List<DocumentSnapshot> myCards = [];
  late String cardNr, cardName, cvc, expDate;
  final GlobalKey<FormState> walletNewFormKey = GlobalKey<FormState>();

  ///Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController dateController = TextEditingController();


  ///Form Focus Nodes
  final FocusNode focusNodeUserName = FocusNode();
  final FocusNode focusNodeUserNumber = FocusNode();
  final FocusNode focusNodeUserCVC = FocusNode();
  final FocusNode focusNodeUserDate = FocusNode();

  ///Get Cards
  void getCards() async {
    setState(() {
      myCards = [];
      isLoading = true;
    });
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').doc(widget.id).collection('cards').get();
    final List<DocumentSnapshot> documents = result.docs;

    setState(() {
      myCards = documents;
      isLoading = false;
    });
  }

  Future<bool> onAddCardPress() {
    addCard();
    return Future.value(false);
  }

  Future<Null> addCard() async{
    await showDialog(
        context: context,
        builder: (BuildContext context){
          return SimpleDialog(
            contentPadding:
            EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
          children: [
            ///Top Decoration
            Container(
              color: getColor('green', 1.0),
              child: Padding(
                padding: EdgeInsets.only(top:8.0, bottom: 8.0),
                child: Column(
                  children: [
                    Icon(Icons.add_card_rounded,
                      color: getColor('white', 1.0),
                      size: 45,
                    ),
                    Text("Add Credit Card",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: getColor('white', 1.0)
                      ),
                    )
                  ],
                ),
              ),
            ),

            ///Form
            Form(
              key: walletNewFormKey,
              child: Column(
                children: [
                  ///Card Name
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(

                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Account Holder Name',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: nameController,

                          onChanged: (value) {
                            setState(() {
                              cardName = value;
                            });
                          },
                          focusNode: focusNodeUserName,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ),

                  ///Card Number
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(19),
                            CardNumberInputFormatter(),
                          ],
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Card Number',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: numberController,

                          onChanged: (value) {
                            setState(() {
                              cardNr = value;
                            });
                          },
                          focusNode: focusNodeUserNumber,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ),

                  ///Card Exp Date
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),

                            CardMonthInputFormatter(),
                          ],
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Expiration date',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: dateController,

                          onChanged: (value) {
                            setState(() {
                              expDate = value;
                            });
                          },
                          focusNode: focusNodeUserDate,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ),

                  ///Card CVC
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          autocorrect: false,
                          cursorColor: Colors.blueAccent,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(

                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            focusColor: Colors.blueAccent,
                            fillColor: Colors.blueAccent,
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            hintText: 'Card CVC',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                          controller: cvcController,

                          onChanged: (value) {
                            setState(() {
                              cvc = value;
                            });
                          },
                          focusNode: focusNodeUserCVC,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ),

                  ///Submit Button
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0)),
                      ),
                      //color: colors[2],
                      onPressed: (){
                        postBuyCoins();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                            right: MediaQuery.of(context).size.width * 0.07),
                        child: Text("ADD Card",
                            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                        ),
                      )
                  ),

                ],

              ),
            )
          ],
          );
        }
    );
  }
  ///Post Function
  void postBuyCoins() async {
    setState(() {
      isLoading = true;
    });
    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(widget.id).collection('cards').doc();
    docRef.set({
      'cardName': cardName,
      'cardNr': cardNr,
      'expDate': expDate,
      'id': docRef.id
    });
    Fluttertoast.showToast(msg: "Card Successfully loaded.");
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
    getCards();
  }



  ///Remove card
  Future<bool> onRemoveCardPress(DocumentSnapshot card) {
    removeCard(card);
    return Future.value(false);
  }

  Future<Null> removeCard(DocumentSnapshot card) async{
    await showDialog(
        context: context,
        builder: (BuildContext context){
          return SimpleDialog(
            contentPadding:
            EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
          children: [
            ///Top Decoration
            Container(
              color: getColor('red', 1.0),
              child: Padding(
                padding: EdgeInsets.only(top:8.0, bottom: 8.0),
                child: Column(
                  children: [
                    Icon(Icons.delete_outline,
                      color: getColor('white', 1.0),
                      size: 45,
                    ),
                    Text("Remove Credit Card",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: getColor('white', 1.0)
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Are you sure you want delete card:\n ${card['cardName']} with exp. Date: ${card['expDate']} ",
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ///Submit Button
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:  MaterialStatePropertyAll<Color>(getColor('green', 1.0)),
                    ),
                    //color: colors[2],
                    onPressed: (){
                      postRemoveCard(card['id']);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                          right: MediaQuery.of(context).size.width * 0.07),
                      child: Text("Remove",
                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                      ),
                    )
                ),
                ///Cancel Button
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:  MaterialStatePropertyAll<Color>(getColor('red', 1.0)),
                    ),
                    //color: colors[2],
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                          right: MediaQuery.of(context).size.width * 0.07),
                      child: Text("Cancel",
                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                      ),
                    )
                ),
              ],
            )
          ],
          );
        }
    );
  }


  void postRemoveCard(String cardID) async {
    setState(() {
      isLoading = true;
    });
    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(widget.id).collection('cards').doc(cardID);
    docRef.delete();
    Fluttertoast.showToast(msg: "Card Successfully removed.");
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
    getCards();
  }

  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        backgroundColor: getColor('blue', 1.0),
        onPressed: onAddCardPress,
        child: Icon(Icons.add_card_rounded),
      ),

      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              ///AppBar
              SliverAppBar(
                title: Text("My Cards"),
              ),


              ///List of cards
              SliverList(
                  delegate: SliverChildBuilderDelegate(
              (BuildContext context, index){
                var item = myCards[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      onRemoveCardPress(item);
                    },
                    child: Card(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${item['cardName']}"),
                              Text("${item['cardNr']}"),
                              Text("${item['expDate']}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
                    childCount: myCards.length
                  ))
            ],
          ),


          ///Loading Screen
          Positioned(child: loadingScreen())
        ],
      ),
    );
  }
}
