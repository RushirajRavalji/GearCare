import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color c1 = const Color.fromRGBO(211, 232, 246, 1);
  double w = 0;

  // List to store switch states
  List<bool> switchValues = List.generate(8, (index) => false);

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 25),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Your Profile",
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //! Profile Section
            _buildProfileSection(),

            SizedBox(height: 15),
            _buildDivider(),
            SizedBox(height: 15),

            //! Subscription Box with Progress
            _buildSubscriptionBox(),

            SizedBox(height: 15),

            //! Rewards Section
            _buildRewardsSection(),

            SizedBox(height: 15),

            //! Settings Section (with Toggles)
            _buildSettingsSection(),

            SizedBox(height: 20),

            //! Logout Button
            Container(
              width: 170,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.only(),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.logout, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //! Profile Section
  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.all(10),
      width: w,
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 50, backgroundColor: Colors.white),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlaceholderBox(height: 30),
              SizedBox(height: 15),
              _buildPlaceholderBox(),
              SizedBox(height: 5),
              _buildPlaceholderBox(),
              SizedBox(height: 5),
              _buildPlaceholderBox(),
            ],
          ),
        ],
      ),
    );
  }

  //! Subscription Section
  Widget _buildSubscriptionBox() {
    return Container(
      padding: EdgeInsets.all(15),
      width: w,
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlaceholderBox(height: 30),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Column(
              children: [
                _buildPlaceholderBox(),
                SizedBox(height: 5),
                _buildPlaceholderBox(),
                SizedBox(height: 5),
                _buildPlaceholderBox(),
              ],
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text("Time Remaining", style: TextStyle(fontSize: 12)),
            ),
          ),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! Rewards Section
  Widget _buildRewardsSection() {
    return Container(
      padding: EdgeInsets.all(11),
      width: w,
      height: 130,
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, size: 120, color: Colors.white),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              _buildPlaceholderBox(height: 30),
              SizedBox(height: 15),
              _buildPlaceholderBox(),
              SizedBox(height: 5),
              _buildPlaceholderBox(),
              SizedBox(height: 5),
              _buildPlaceholderBox(),
            ],
          ),
        ],
      ),
    );
  }

  //! Settings Section (with Switches)
  Widget _buildSettingsSection() {
    return Container(
      padding: EdgeInsets.all(15),
      width: w,
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 15),
              child: Text("Settings", style: TextStyle(fontSize: 12)),
            ),
          ),
          SizedBox(height: 10),
          //! ListView for switches
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: switchValues.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Toggle switch
                    Transform.scale(
                      scale: 0.5,
                      child: Switch(
                        value: switchValues[index],
                        onChanged: (value) {
                          setState(() {
                            switchValues[index] = value;
                          });
                        },
                        activeColor: Colors.grey,
                        activeTrackColor: Colors.white,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.white,
                      ),
                    ),

                    SizedBox(width: 10),
                    //! White placeholder bar
                    Column(
                      children: [
                        Container(
                          height: 10,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //! Helper: Divider
  Widget _buildDivider() {
    return Container(
      width: w / 1.3,
      height: 1,
      color: Colors.black.withOpacity(0.2),
    );
  }

  //! Helper: Placeholder Box
  Widget _buildPlaceholderBox({double height = 10}) {
    return Container(
      height: height,
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
    );
  }
}
