import 'package:flutter/material.dart';
import 'package:gearcare/pages/menu.dart';

class Category extends StatefulWidget {
  const Category({super.key});
  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    // Define the colors for styling
    Color c1 = const Color.fromRGBO(211, 232, 246, 1);
    Color accentColor = Color.fromARGB(17, 200, 206, 210);

    // Medical equipment categories
    List<Map<String, dynamic>> medicalCategories = [
      {
        "title": "Diagnostic and Imaging Equipment",
        "items": [
          "MRI Scanners",
          "CT Scanners",
          "Ultrasound Machines",
          "Portable X-Ray Units",
          "Nuclear Imaging Systems",
          "Fluoroscopy Units",
          "Mammography Units",
        ],
        "icon": Icons.medical_services,
      },
      {
        "title": "Patient Monitoring and Critical Care",
        "items": [
          "Vital Signs Monitors",
          "ICU Monitors",
          "ECG/EKG Machines",
          "Infusion Pumps",
          "Ventilators",
          "CPAP/BiPAP Machines",
          "Pulse Oximeters",
          "Capnography Devices",
        ],
        "icon": Icons.monitor_heart,
      },
      {
        "title": "Surgical and Operating Room Equipment",
        "items": [
          "Operating Tables",
          "Surgical Lights",
          "Anesthesia Machines",
          "Electrosurgical Units",
          "Endoscopic Systems",
        ],
        "icon": Icons.local_hospital,
      },
      {
        "title": "Life Support and Emergency Equipment",
        "items": [
          "Defibrillators",
          "Cardiac Resuscitation Devices",
          "Emergency Resuscitation Kits",
        ],
        "icon": Icons.emergency,
      },
      {
        "title": "Rehabilitation and Therapy Devices",
        "items": [
          "Physical Therapy Equipment",
          "Patient Lifts",
          "Transfer Devices",
          "Rehabilitation Beds",
        ],
        "icon": Icons.accessibility_new,
      },
      {
        "title": "Inpatient and Patient Care Support",
        "items": [
          "Hospital Beds",
          "Stretchers",
          "Mobile Medical Carts",
          "Workstations",
          "IV Poles",
          "Bedside Accessories",
        ],
        "icon": Icons.bed,
      },
      {
        "title": "Auxiliary and Specialty Equipment",
        "items": [
          "Sterilization Units",
          "Autoclave Units",
          "Telemedicine Tools",
          "Remote Diagnostic Tools",
          "Mobile Clinics",
          "Radiology Trucks",
        ],
        "icon": Icons.biotech,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 26),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomDrawer()),
              ),
        ),
        title: const Text(
          "Medical Equipment",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: accentColor, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              // Header text
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Browse by category",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Scrollable Category List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: medicalCategories.length,
                itemBuilder: (context, index) {
                  return MedicalCategoryCard(
                    category: medicalCategories[index],
                    index: index,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Medical Category Card Widget
class MedicalCategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final int index;

  const MedicalCategoryCard({
    super.key,
    required this.category,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a list of gradient colors for the cards
    List<List<Color>> gradients = [
      [const Color(0xFFE0F2FE), const Color(0xFFBFDBFE)], // Blue
      [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)], // Cyan
      [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)], // Green
      [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)], // Purple
      [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)], // Orange
      [const Color(0xFFE1F5FE), const Color(0xFFB3E5FC)], // Light Blue
      [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)], // Teal
    ];

    // Select gradient based on index
    List<Color> currentGradient = gradients[index % gradients.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title bar with improved design
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 45,
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            gradient: LinearGradient(
              colors: [currentGradient[0], currentGradient[1]],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: currentGradient[1].withOpacity(0.4),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  category['icon'] ?? Icons.medical_services,
                  color: Color(0xFF2D3142),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['title'],
                    style: const TextStyle(
                      color: Color(0xFF2D3142),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Main card with subcategories
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentGradient[0].withOpacity(0.7),
                currentGradient[1].withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          // List of subcategory items
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(category['items'].length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: currentGradient[1].withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.medical_information,
                          size: 18,
                          color: Color.lerp(
                            const Color(0xFF3D7EFF),
                            const Color(0xFF2D3142),
                            (i % 7) / 7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        category['items'][i],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
