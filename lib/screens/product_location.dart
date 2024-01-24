import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfcheckoutapp/constants.dart';
import 'package:selfcheckoutapp/services/firebase_services.dart';

class ProductLocationPage extends StatefulWidget {
  @override
  _ProductLocationPageState createState() => _ProductLocationPageState();
}

class _ProductLocationPageState extends State<ProductLocationPage> {
  FirebaseServices _firebaseServices = FirebaseServices();

  Future<QuerySnapshot> _getData() async {
    print(_firebaseServices.productsLocationRef.get());
    return _firebaseServices.productsLocationRef.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product Location",
          style: Constants.boldHeadingAppBar,
        ), toolbarTextStyle: GoogleFonts.poppinsTextTheme().bodyText2, titleTextStyle: GoogleFonts.poppinsTextTheme().headline6,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            width: double.infinity,
            child: FutureBuilder<QuerySnapshot>(
                future: _getData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text("Error: ${snapshot.error}"),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data != null) {
                      return ListView(
                        children: snapshot.data!.docs.map((documents) {
                          return ListTile(
                            leading: Image.network("${documents['image']}"),
                            title: Text("${documents['name']}"),
                            subtitle: Text("Aisle - ${documents['aisle']}"
                                "\nShelf - ${documents['shelf']}"),
                            isThreeLine: true,
                          );
                        }).toList(),
                      );
                    } else
                      emptyBodyBuild();
                  }
                  return Scaffold(
                    body: Center(
                      child: Text("No products"),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  Container emptyBodyBuild() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.remove_shopping_cart_outlined,
              size: 50.0,
              color: Colors.black26,
            ),
            Text(
              "No history to show!",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
