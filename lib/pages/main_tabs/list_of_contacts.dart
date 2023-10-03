///Shows the full list of users to start a chat with
///
///
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../extras/ui_elements.dart';
import '../../extras/variables.dart';
import 'chat.dart';

class ListOfContacts extends StatefulWidget {
  const ListOfContacts({super.key});

  @override
  State<ListOfContacts> createState() => _ListOfContactsState();
}

class _ListOfContactsState extends State<ListOfContacts> {
  ///Variables
   List<DocumentSnapshot> users = [];

   ///Get list of users from Firebase
   void getUsers() async{
     ///Set Loading Screen
     setState(() {
       isLoading = true;
     });
     final QuerySnapshot result =
         await FirebaseFirestore.instance.collection('users').get();
     final List<DocumentSnapshot> documents = result.docs;

     setState(() {
       users = documents;
       isLoading = false;
     });
   }

   ///Initial State
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          ListView.builder(itemBuilder: (BuildContext context, index){
            var user = users[index];
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                elevation: 6.0,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        ChatPage(arguments: ChatPageArguments(peerAvatar: user['profilePic'], peerId: user['id'], peerNickname: user['name']), )));
                  },
                  child: Row(
                    children: [
                      ///Profile picture side
                      Container(
                        height: 50,
                        width: 30,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(users[index]['profilePic'])
                          )
                        ),
                      ),

                      ///Name Side
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${users[index]['name']} ${users[index]['lastName']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                          ),
                          Text("${users[index]['email']}"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: users.length,
          ),

          ///Loading Screen
          Positioned(child: loadingScreen())
        ],
      ),
    );
  }
}
