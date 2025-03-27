import 'package:flutter/material.dart';
import 'package:gearcare/pages/about.dart';
import 'package:gearcare/pages/addproduct.dart';
import 'package:gearcare/pages/categotry.dart';
import 'package:gearcare/pages/help_support.dart';
import 'package:gearcare/pages/home.dart';
import 'package:gearcare/pages/request_product.dart';

//! Custom Drawer (UI Matches Screenshot)
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(right: 70),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 212, 235, 250),
            borderRadius: BorderRadius.only(topRight: Radius.circular(70)),
          ),
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.menu, color: Colors.black),
              ),
              SizedBox(height: 50),

              drawerItem(context, Icons.home, "Home", Home()),
              SizedBox(height: 25),

              drawerItem(context, Icons.grid_view, "Categories", Category()),
              SizedBox(height: 25),

              drawerItem(
                context,
                Icons.add_circle_outline,
                "Add your product",
                Addproduct(),
              ),
              SizedBox(height: 25),

              drawerItem(
                context,
                Icons.request_page,
                "Request a Product",
                RequestProduct(),
              ),
              SizedBox(height: 25),

              drawerItem(
                context,
                Icons.help_outline,
                "Help and Support",
                HelpSupport(),
              ),
              SizedBox(height: 25),
              drawerItem(context, Icons.info_outline, "About", About()),
            ],
          ),
        ),
      ),
    );
  }

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
