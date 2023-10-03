import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../extras/colors.dart';
import '../extras/data.dart';
import '../extras/variables.dart';
import 'main_tabs/home.dart';


class PaymentMethod extends StatefulWidget {
  final String package, price;
  PaymentMethod({required this.package, required this.price});


  @override
  _PaymentMethodState createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {

  late String cardToken;
  //Webview Controller
  late WebViewController _controller;
  late SharedPreferences prefs;

  late String? id, nickname = '', email, address, payment = '', paymentMethod;

  var url = Uri.parse('https://checkout-online.yoco.com/checkouts');
  void paymentGateWay(String token) async {
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
          "token": token,
          'amount': int.parse(widget.price)/0.01, //grandTotal,
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
      Fluttertoast.showToast(msg: "Payment Completed Successfully");

      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      ///Place order on Firebase
      placeYocoOrder();

    } else {
      setState(() {
        //isLoading = false;
      });
      //print(decodeHttp);
      Fluttertoast.showToast(msg: "There was an error completing your payment.");
    }

    //print(response.body);
  }
  _loadHtmlFile() async {
    //String fileText = await rootBundle.loadString(widget.html.body);
    _controller.loadUrl(widget.package);
  }


  void placeYocoOrder(){
    DocumentReference docRef = FirebaseFirestore.instance.collection(id!).doc();
    docRef.update({
      'id': docRef.id,
      'customerId': id,
      'customerName': nickname,
      'deliveryAddress': address,
      'payment': payment,
      'package': widget.package,
      'paymentStatus': "paidWithYoco",
      'total': 100,
      'orderDate': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString() + " " + DateFormat('hh:mm:ss').format(DateTime.now()).toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    ///Change Package on Profile
    DocumentReference myDoc = FirebaseFirestore.instance.collection("users").doc(id);
    myDoc.update({
      'package': widget.package,
    });

    ///Navigate to home page
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
   // print("We are here ............................\n.........................\n");
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          onPaymentReturn(message.message);
           print("I am here with.....................................................: " + message.message);
          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );*/
        });
  }

  ///On Payment return
  onPaymentReturn(String result){
    print("we make it gents!...............................");
    if (result == 'failed'){
      Fluttertoast.showToast(msg: "Failed ");
    }else {
      setState(() {
        cardToken = result;
      });
      paymentGateWay(result);
      Fluttertoast.showToast(msg: "Done with $result");
    }
  }

  ///Load Local Data
  void readLocal() async{
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('name') ?? '';
    email = prefs.getString('email')?? '';
    setState(() {

    });
  }

  ///Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLocal();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue, //colors[2],
        title: Text(
          "Checkout",
            style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
        ),
        leading: IconButton(
          onPressed: (){
            setState(() {
              appBodyIndex = 2;
            });
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WebView(
          javascriptChannels: {
            _toasterJavascriptChannel(context),
          },
          initialUrl: yocoHtml,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
            _loadHtmlFile();
          },
          gestureNavigationEnabled: true,
          onPageFinished: (value){
            print("Check me out: ...........$value");
          },
          navigationDelegate: (req){
            print("This is it: .................... ${req.url}");
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
