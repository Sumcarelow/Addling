import 'dart:convert';

import 'package:adlinc/extras/colors.dart';
import 'package:adlinc/pages/main_tabs/my_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../extras/data.dart';
import '../../../extras/functions.dart';
import '../../../extras/ui_elements.dart';
import '../../../extras/variables.dart';
import '../../payment.dart';
import '../buy/receipts.dart';
import '../home.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key,});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  ///Form Variables
  late String id, coinsCurrent, walletCurrent;
   String coins = '0', walletNew = '0';
  final GlobalKey<FormState> coinsBuyFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> walletNewFormKey = GlobalKey<FormState>();

  ///Form Controllers
  final TextEditingController coinsController = TextEditingController();
  final TextEditingController walletNewController = TextEditingController();

  ///Form Focus Nodes
  final FocusNode focusNodeUserCoins = FocusNode();
  final FocusNode focusNodeUserWalletNew = FocusNode();



  ///Pop-Ups

  ///1. Add/Link Bank Card

  Future<bool> onAddCardPress() {
    addCard();
    return Future.value(false);
  }

  Future<Null> addCard() async{
    await showDialog(
    context: context,
    builder: (BuildContext context){
      return SimpleDialog();
    }
    );
  }

  ///2. Transfer Funds to wallet
  Future<bool> onTransferFundsPress() {
    transferFunds();
    return Future.value(false);
  }
  Future<Null> transferFunds() async{
    await showDialog(
    context: context,
    builder: (BuildContext context){
      return SimpleDialog(
        contentPadding:
        EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
      children: [
        ///Top Decoration
        Container(
          color: getColor('greenFundsLight', 1.0),
          child: Padding(
            padding: EdgeInsets.only(top:8.0, bottom: 8.0),
            child: Column(
              children: [
               Icon(Icons.compare_arrows,
               color: getColor('white', 1.0),
                 size: 45,
               ),
                Text("Transfer Funds to your Adlinc Wallet.",
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
              ///Current Wallet Value

              Text("You currently have: ${walletCurrent} "),

              ///Number of coins
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
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
                        hintText: 'amount to transfer',
                        contentPadding: EdgeInsets.all(5.0),
                        hintStyle: TextStyle(color: Colors.grey,
                            fontSize: 17,
                            fontWeight: FontWeight.bold
                        ),

                      ),
                      controller: walletNewController,

                      onChanged: (value) {
                        setState(() {
                          walletNew = value;
                        });
                      },
                      focusNode: focusNodeUserWalletNew,
                    ),
                  ),
                  margin: EdgeInsets.only(left: 30.0, right: 30.0),
                ),
              ),


              ///Submit Button
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:  MaterialStatePropertyAll<Color>(getColor('greenFundsLight', 1.0)),
                  ),
                  //color: colors[2],
                  onPressed: (){

                      paymentGateWay(walletNew);

                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                        right: MediaQuery.of(context).size.width * 0.07),
                    child: Text("Transfer",
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


  ///3. Transfer coins to wallet
  Future<bool> onTransferCoinsPress() {
    transferCoin();
    return Future.value(false);
  }
  Future<Null> transferCoin() async{
    await showDialog(
    context: context,
    builder: (BuildContext context){
      return SimpleDialog(
        contentPadding:
        EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
      children: [
        ///Top Decoration
        Container(
          color: getColor('greenFundsLight', 1.0),
          child: Padding(
            padding: EdgeInsets.only(top:8.0, bottom: 8.0),
            child: Column(
              children: [
               Icon(Icons.compare_arrows,
               color: getColor('white', 1.0),
                 size: 45,
               ),
                Text("Transfer coins to your Adlinc Wallet.",
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
          key: coinsBuyFormKey,
          child: Column(
            children: [
              ///Current Wallet Value

              Text("You currently have: ${coinsCurrent} coins"),

              ///Number of coins
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
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
                        hintText: 'amount of coins to transfer',
                        contentPadding: EdgeInsets.all(5.0),
                        hintStyle: TextStyle(color: Colors.grey,
                            fontSize: 17,
                            fontWeight: FontWeight.bold
                        ),

                      ),
                      controller: coinsController,

                      onChanged: (value) {
                        setState(() {
                          coins = value;
                        });
                      },
                      focusNode: focusNodeUserCoins
                    ),
                  ),
                  margin: EdgeInsets.only(left: 30.0, right: 30.0),
                ),
              ),


              ///Submit Button
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:  MaterialStatePropertyAll<Color>(getColor('greenFundsLight', 1.0)),
                  ),
                  //color: colors[2],
                  onPressed: (){

                    postTransferCoins(double.parse(coins));

                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                        right: MediaQuery.of(context).size.width * 0.07),
                    child: Text("Transfer",
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

  void postTransferCoins(double numberOfCoins) async {

    String emailBody = "Hi, \n Thank you for using Adlinc Slasch App. The details for your transactions are as follows.\n "
        "Number of Coins Transferred: $numberOfCoins\n"
        "Regards\n Adlinc Slasch App Team.";
    var tempWallet = double.parse(walletCurrent) + numberOfCoins;
    var tempCoins = double.parse(coinsCurrent) - numberOfCoins;
    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(id);
    docRef.update({
      'wallet': tempWallet.toString(),
      'coins': tempCoins.toString()
    });
    ///Add reciept
    DocumentReference receiptDoc = FirebaseFirestore.instance.collection('users').doc(id).collection('receipts').doc();
    receiptDoc.set({
      'title': 'Coins Transfer to Wallet',
      'type': 'transfer',
      'amount': numberOfCoins,
      'date':  DateFormat('dd MMMM yyyy').format(DateTime.now()).toString()
    });

    postNotification("Coins Purchased", emailBody);
    Fluttertoast.showToast(msg: "Coins Successfully loaded.");
    setState(() {
      appBodyIndex = 1;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    //Fluttertoast.showToast(msg: "Coins Successfully loaded.");

  }


  void paymentGateWay(String price) async {
    //print("We are here on the final stage............................\n.........................\n");
    setState(() {
      //isLoading = true;
    });

    String basicAuth = 'Bearer sk_test_960bfde0VBrLlpK098e4ffeb53e1';
    var response = await http.post(url,
        headers: <String, String>{
          'X-Auth-Secret-Key': 'sk_test_960bfde0VBrLlpK098e4ffeb53e1',
          'publicKey': 'pk_test_ed3c54a6gOol69qa7f45',
          'authorization': basicAuth,
          "content-type":"application/json"
        },
        body: jsonEncode({
          'amount': int.parse(price)/0.01, //grandTotal,
          'currency': 'ZAR',
          "cancelUrl": 'https://www.google.co.za'
        })

    );
    print('Response status 2nd part: ${response.body}');


    var decodeHttp = json.decode(response.body);
    print("The data: ${decodeHttp["status"]}");

    if(decodeHttp["status"] == "created"){
      setState(() {
        //isLoading = false;
      });
      //Fluttertoast.showToast(msg: "Payment Completed Successfully");
      String tempPrice = (int.parse(price)/0.01).toString();
      Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentMethod(package: decodeHttp["redirectUrl"], price: tempPrice,)));
      ///Place order on Firebase
      postTransfer(double.parse(price));
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

  ///Post Function
  void postTransfer(double walletCost) async {

    var tempWallet = double.parse(walletCurrent) + walletCost;
    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(id);
    docRef.update({
      'wallet': tempWallet.toString()
    });
    //Fluttertoast.showToast(msg: "Coins Successfully loaded.");

  }

  ///3. Buy Splasch Points
  Future<bool> onTransferSplaschPress() {
    buyPoints();
    return Future.value(false);
  }
      ///Pop Up Screen
  Future<Null> buyPoints() async {
    await showDialog(
        context: context,
        builder: (BuildContext context){
          return SimpleDialog(
            contentPadding:
            EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: [
              ///Top Part
              Container(
                color: getColor('purpleIcon', 1.0),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Column(
                    children: [
                      FaIcon(FontAwesomeIcons.wallet, color: getColor('white', 1.0),),
                      Text(
                        "Buy Splasch Points",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: getColor('white', 1.0)
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ///Form
              Form(
                key: coinsBuyFormKey,
                child: Column(
                  children: [
                    ///Current Wallet Value

                    Text("You can for: ${walletCurrent} "),

                    ///Number of coins
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.blueAccent, splashColor:Colors.blueAccent),
                          child: TextFormField( keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
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
                              hintText: 'amount of coins',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),

                            ),
                            controller: coinsController,

                            onChanged: (value) {
                              setState(() {
                                coins = value;
                              });
                            },
                            focusNode: focusNodeUserCoins,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),
                    ),

                    ///Wallet Cost
                    Text("Wallet Cost: ${walletCalculator(double.parse(coins))}"),

                    ///Submit Button
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:  MaterialStatePropertyAll<Color>(getColor('purpleIcon', 1.0)),
                        ),
                        //color: colors[2],
                        onPressed: (){
                          ///Check wallet Balance
                          if(double.parse(walletCurrent) < walletCalculator(double.parse(coins)) ) {
                            Fluttertoast.showToast(msg: "You do not have enough in your wallet to buy coins.");
                          } else {
                            postBuyCoins(double.parse(coins), walletCalculator(double.parse(coins)));
                          }


                          //Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
                          //loginFormKey.currentState!.validate()
                          //Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.07,
                              right: MediaQuery.of(context).size.width * 0.07),
                          child: Text("Buy Coins",
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
   void postBuyCoins(double coinNumber, double walletCost) async {

    String emailBody = "Hi, \n Thank you for using Adlinc Slasch App. The details for your transactions are as follows.\n "
        "Number of Coins Purchased: $coinNumber\n"
        "Cost to Wallet: R $walletCost\n"
        "Regards\n Adlinc Slasch App Team.";
    var tempCoin = double.parse(coinsCurrent) + coinNumber;
    var tempWallet = double.parse(walletCurrent) - walletCost;
     DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(id);
     docRef.update({
       'coins': tempCoin.toString(),
       'wallet': tempWallet.toString()
     });

     ///Add reciept
    DocumentReference receiptDoc = FirebaseFirestore.instance.collection('users').doc(id).collection('receipts').doc();
    receiptDoc.set({
      'title': 'Coins Purchase',
      'type': 'purchase',
      'amount': walletCost,
      'date':  DateFormat('dd MMMM yyyy').format(DateTime.now()).toString()
    });

    postNotification("Coins Purchased", emailBody);
    Fluttertoast.showToast(msg: "Coins Successfully loaded.");
    setState(() {
      appBodyIndex = 1;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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
    //print("We are here trying this... ${documents[0].id}");

    if(documents.isNotEmpty){
      setState(() {
        coinsCurrent = documents[0]['coins'];
        walletCurrent = documents[0]['wallet'];
      });
    }
    ///Set Loading Screen
    setState(() {
      isLoading = false;
    });
  }

  ///posting notification
  void postNotification(String title, String msg) async{
    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(id).collection('notifications').doc();
    docRef.set({
      'title': title,
      'mesage': msg,
    });

  }

   ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDataFromFB(globalUserID);
  }

  ///dispose
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ///Add Card Tile
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyCards(id: globalUserID)));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(211, 235, 243, 0.7),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.credit_card_rounded,
                              size: 45,
                                color: Color.fromRGBO(48, 168, 255, 1.0),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("Add/Link Bank Card",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ///Transfer funds to wallet
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: GestureDetector(
                      onTap: onTransferFundsPress,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        //margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: getColor('greenFunds',1.0)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.compare_arrows,
                              size: 45,
                              color: Color.fromRGBO(0, 218, 113, 1.0),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("Transfer Funds to Wallet",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ///Transfer coins to wallet
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: GestureDetector(
                      onTap: onTransferCoinsPress,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        //margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: getColor('red',0.3)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.monetization_on_outlined,
                              size: 45,
                              color: getColor('red', 1.0),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("Redeem Coins",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ///Buy Splash Coins
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: GestureDetector(
                      onTap: onTransferSplaschPress,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        //margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: getColor('purple', 1.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined,
                              size: 50,
                                color: getColor('purpleIcon', 1.0),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("Buy Slasch Coins",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ///Receipts
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Reciepts(id: globalUserID,)));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        //margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: getColor('cardYellow', 0.3),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list_alt_rounded,
                              size: 50,
                                color: getColor('iconYellow', 1.0),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("My Receipts",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        ///Loading Screen
        Positioned(child: loadingScreen())

      ],
    );
  }
}
