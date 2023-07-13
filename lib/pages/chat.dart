import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'full_photo.dart';
import 'login.dart';
import 'messaging/chat_provider.dart';


class AppConstants {
  static const appTitle = "Flutter Chat Demo";
  static const loginTitle = "Login";
  static const homeTitle = "Home";
  static const settingsTitle = "Settings";
  static const fullPhotoTitle = "Full Photo";
}

class ColorConstants {
  static const themeColor = Color(0xfff5a623);
  static Map<int, Color> swatchColor = {
    50: themeColor.withOpacity(0.1),
    100: themeColor.withOpacity(0.2),
    200: themeColor.withOpacity(0.3),
    300: themeColor.withOpacity(0.4),
    400: themeColor.withOpacity(0.5),
    500: themeColor.withOpacity(0.6),
    600: themeColor.withOpacity(0.7),
    700: themeColor.withOpacity(0.8),
    800: themeColor.withOpacity(0.9),
    900: themeColor.withOpacity(1),
  };
  static const primaryColor = Color(0xff203152);
  static const greyColor = Color(0xffaeaeae);
  static const greyColor2 = Color(0xffE8E8E8);
}

class FirestoreConstants {
  static const pathUserCollection = "users";
  static const pathMessageCollection = "messages";
  static const nickname = "nickname";
  static const aboutMe = "aboutMe";
  static const photoUrl = "photoUrl";
  static const id = "id";
  static const chattingWith = "chattingWith";
  static const idFrom = "idFrom";
  static const idTo = "idTo";
  static const timestamp = "timestamp";
  static const content = "content";
  static const type = "type";
}

class MessageChat {
  final String idFrom;
  final String idTo;
  final String timestamp;
  final String content;
  final int type;

  const MessageChat({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: this.idFrom,
      FirestoreConstants.idTo: this.idTo,
      FirestoreConstants.timestamp: this.timestamp,
      FirestoreConstants.content: this.content,
      FirestoreConstants.type: this.type,
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(FirestoreConstants.idFrom);
    String idTo = doc.get(FirestoreConstants.idTo);
    String timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    int type = doc.get(FirestoreConstants.type);
    return MessageChat(idFrom: idFrom, idTo: idTo, timestamp: timestamp, content: content, type: type);
  }
}

class PopupChoices {
  final String title;
  final IconData icon;

  const PopupChoices({required this.title, required this.icon});
}


class UserChat {
  final String id;
  final String photoUrl;
  final String nickname;
  final String aboutMe;

  const UserChat({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
    );
  }
}


enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore,
  });

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          // Writing data to server because here is a new user
          firebaseFirestore.collection(FirestoreConstants.pathUserCollection).doc(firebaseUser.uid).set({
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          // Write data to local storage
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(FirestoreConstants.nickname, currentUser.displayName ?? "");
          await prefs.setString(FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        } else {
          // Already sign up, just get data from firestore
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          // Write data to local
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  void handleException() {
    _status = Status.authenticateException;
    notifyListeners();
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}


class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({required this.firebaseFirestore, required this.prefs, required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(String content, int type, String groupChatId, String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}


class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(String pathCollection, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where(FirestoreConstants.nickname, isEqualTo: textSearch)
          .snapshots();
    } else {
      return firebaseFirestore.collection(pathCollection).limit(limit).snapshots();
    }
  }
}

class SettingProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  SettingProvider({
    required this.prefs,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  String? getPref(String key) {
    return prefs.getString(key);
  }

  Future<bool> setPref(String key, String value) async {
    return await prefs.setString(key, value);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.arguments});

  final ChatPageArguments arguments;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late final String currentUserId;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
      );
    }
    String peerId = widget.arguments.peerId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }



  Future getImage() async {
    var images = (
        await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.image,
            dialogTitle: "Please select room pictures."
        ))?.files;

    if(images != null && images.length != 0){
      setState(() {
        //imageFile = image;
      });
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(content, type, groupChatId, currentUserId, widget.arguments.peerId);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Row(
          children: <Widget>[
            messageChat.type == TypeMessage.text
            // Text
                ? Container(
              child: Text(
                messageChat.content,
                style: TextStyle(color: ColorConstants.primaryColor),
              ),
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              width: 200,
              decoration: BoxDecoration(color: ColorConstants.greyColor2, borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
            )
                : messageChat.type == TypeMessage.image
            // Image
                ? Container(
              child: OutlinedButton(
                child: Material(
                  child: Image.network(
                    messageChat.content,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: ColorConstants.greyColor2,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.themeColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return Material(
                        child: Image.asset(
                          'images/img_not_available.jpeg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                      );
                    },
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullPhotoPage(
                        url: messageChat.content,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
              ),
              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
            )
            // Sticker
                : Container(
              child: Image.asset(
                'images/${messageChat.content}.gif',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                    child: Image.network(
                      widget.arguments.peerAvatar,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.themeColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return Icon(
                          Icons.account_circle,
                          size: 35,
                          color: ColorConstants.greyColor,
                        );
                      },
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                    clipBehavior: Clip.hardEdge,
                  )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Container(
                    child: Text(
                      messageChat.content,
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration:
                    BoxDecoration(color: ColorConstants.primaryColor, borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(left: 10),
                  )
                      : messageChat.type == TypeMessage.image
                      ? Container(
                    child: TextButton(
                      child: Material(
                        child: Image.network(
                          messageChat.content,
                          loadingBuilder:
                              (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: ColorConstants.greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              width: 200,
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.themeColor,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) => Material(
                            child: Image.asset(
                              'images/img_not_available.jpeg',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullPhotoPage(url: messageChat.content),
                          ),
                        );
                      },
                      style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                    ),
                    margin: EdgeInsets.only(left: 10),
                  )
                      : Container(
                    child: Image.asset(
                      'images/${messageChat.content}.gif',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                  ),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                child: Text(
                  DateFormat('dd MMM kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.timestamp))),
                  style: TextStyle(color: ColorConstants.greyColor, fontSize: 12, fontStyle: FontStyle.italic),
                ),
                margin: EdgeInsets.only(left: 50, top: 5, bottom: 5),
              )
                  : SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.widget.arguments.peerNickname,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(),

                  // Sticker
                  isShowSticker ? buildSticker() : SizedBox.shrink(),

                  // Input content
                  buildInput(),
                ],
              ),

              // Loading
              buildLoading()
            ],
          ),
          onWillPop: onBackPress,
        ),
      ),
    );
  }

  Widget buildSticker() {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi1', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi1.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi2', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi2.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi3', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi3.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi4', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi4.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi5', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi5.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi6', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi6.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi7', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi7.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi8', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi8.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi9', TypeMessage.sticker),
                  child: Image.asset(
                    'images/mimi9.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)), color: Colors.white),
        padding: EdgeInsets.all(5),
        height: 180,
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child:  SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: getSticker,
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, TypeMessage.text);
                },
                style: TextStyle(color: ColorConstants.primaryColor, fontSize: 15),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: ColorConstants.greyColor),
                ),
                focusNode: focusNode,
                autofocus: true,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, TypeMessage.text),
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
        stream: chatProvider.getChatStream(groupChatId, _limit),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listMessage = snapshot.data!.docs;
            if (listMessage.length > 0) {
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                itemCount: snapshot.data?.docs.length,
                reverse: true,
                controller: listScrollController,
              );
            } else {
              return Center(child: Text("No message here yet..."));
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
        },
      )
          : Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatPageArguments({required this.peerId, required this.peerAvatar, required this.peerNickname});
}