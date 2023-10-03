import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FullPhotosPage extends StatelessWidget {
  //final String url;
  final List<DocumentSnapshot> baits;

  const FullPhotosPage({super.key, required this.baits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body:

      ListView.builder(
        itemCount: baits.length,
        itemBuilder: (BuildContext context, int indexp){
          return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            baits[indexp]['location']
                        ),
                        fit: BoxFit.cover
                    ),
                    color: Colors.white ,
                    // border: Border.all(color: Colors.grey),
                    // borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ));
        },
        scrollDirection: Axis.horizontal,

        //children: topNav,
      ),

      /*Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),*/
    );
  }
}