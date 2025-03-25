import 'package:flutter/material.dart';

class CustomListScreen extends StatelessWidget {
  const CustomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //! Top Card with Star Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                height: 130,

                decoration: BoxDecoration(
                  color: Color.fromRGBO(211, 232, 246, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 120, color: Colors.white),
                    SizedBox(width: 8),
                    //Expanded(child: _buildPlaceholderBox(height: 20)),
                    Column(
                      children: [
                        SizedBox(height: 25),
                        Container(
                          width: 160,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: 160,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 160,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 160,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //! Divider
            SizedBox(height: 10),
            Container(
              width: w / 1.2,
              height: 1,
              color: Colors.black.withOpacity(0.2),
            ),
            SizedBox(height: 10),

            //! List of Cards
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 8, // Change this as needed
              itemBuilder: (context, index) {
                return _buildListItem();
              },
            ),
          ],
        ),
      ),
    );
  }

  //! Widget for List Item
  Widget _buildListItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color.fromRGBO(211, 232, 246, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // SizedBox(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaceholderBox1(height: 30, width: 160),
                  SizedBox(height: 15),
                  _buildPlaceholderBox(height: 10, width: 160),
                  SizedBox(height: 5),
                  _buildPlaceholderBox(height: 10, width: 160),
                  SizedBox(height: 5),
                  _buildPlaceholderBox(height: 10, width: 160),
                ],
              ),
            ),
            SizedBox(width: 10),
            //! Small Square Box (Right Side)
            Container(
              height: 110,
              width: 97,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ! Helper for Placeholder Boxes
  Widget _buildPlaceholderBox1({double height = 30, double width = 160}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildPlaceholderBox({double height = 10, double width = 160}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
