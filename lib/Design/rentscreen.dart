import 'package:flutter/material.dart';

class Rent extends StatefulWidget {
  @override
  _RentState createState() => _RentState();
}

class _RentState extends State<Rent> {
  @override
  Widget build(BuildContext context) {
    Color c1 = const Color.fromRGBO(211, 232, 246, 1);
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //! Top Black Section (230px)
          Container(width: w, height: 220, color: Colors.black),

          //! Main Content
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: w,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(238, 248, 255, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 45),

                      //! Main Container
                      Container(
                        width: w / 1.1,
                        height: 275,
                        decoration: BoxDecoration(
                          color: c1,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      //! Second Container
                      Container(
                        width: w / 1.1,
                        height: 175,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7, left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 180,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: c1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8), // Pushes button to the bottom
                      //! Rent it button
                      InkWell(
                        onTap: () {
                          // Handle button press
                        },
                        child: Container(
                          width: 170,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              "Rent It",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20), // Bottom Spacing
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
