import 'package:flutter/material.dart';
import 'package:gearcare/Design/categotry.dart';
import 'package:gearcare/Design/home.dart';

//! Custom Drawer (UI Matches Screenshot)
class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(right: 70),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(232, 244, 252, 1),
            borderRadius: BorderRadius.only(topRight: Radius.circular(70)),
          ),
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //! Menu Icon
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.menu, color: Colors.black),
              ),
              SizedBox(height: 50),

              //! Drawer Items with Navigation
              //! Navigate on Homescreen
              drawerItem(context, Icons.home, "Home", Home()),
              SizedBox(height: 25), 
            //! Navigate on Category page
              drawerItem(
                context,
                Icons.grid_view,
                "Categories",
                Category(),
              ),
              SizedBox(height: 25),
              //! Navigate on add product
              drawerItem(
                context,
                Icons.add_circle_outline,
                "Add your product",
                AddProductScreen(),
              ),
              SizedBox(height: 25),
              //! Navigate on request product
              drawerItem(
                context,
                Icons.request_page,
                "Request a Product",
                RequestProductScreen(),
              ),
              SizedBox(height: 25),
              //! Navigate on help - support
              drawerItem(
                context,
                Icons.help_outline,
                "Help and Support",
                HelpSupportScreen(),
              ),
              SizedBox(height: 25),
              //! Navigate on about
              drawerItem(context, Icons.info_outline, "About", AboutScreen()),
            ],
          ),
        ),
      ),
    );
  }

  //! Drawer Item Widget with Navigation
  Widget drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Row(
        children: [
          SizedBox(width: 15),
          CircleAvatar(
            radius: 15,
            backgroundColor: Color.fromRGBO(198, 222, 239, 1),
            child: Icon(icon, color: Colors.black, size: 18),
          ),
          SizedBox(width: 25),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}
//!--------------------------------------------------------------

class AddProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: Center(child: Text("Add Product Screen")),
    );
  }
}

class RequestProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Product")),
      body: Center(child: Text("Request Product Screen")),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help & Support")),
      body: Center(child: Text("Help & Support Screen")),
    );
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      body: Center(child: Text("About Screen")),
    );
  }
}
