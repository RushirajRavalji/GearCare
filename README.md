# GearCare - Equipment Rental Marketplace

GearCare is a modern, user-friendly Flutter application designed to facilitate equipment rental between users. The platform allows users to list their own equipment for rent and browse through items offered by others, with a beautiful and intuitive user interface.

## Features

### User Authentication & Profile
- Secure login and registration system using Firebase Authentication
- User profile management with customizable profile pictures
- Persistent session management
- Profile screen with user details and rental history

### Product Management
- Add new products with high-quality images (camera or gallery)
- Edit existing product listings with real-time updates
- Delete unwanted products 
- Products categorized in two display sections:
  - Featured (upper section) with auto-scrolling carousel
  - Recommended (bottom section) with grid layout
- Detailed product information with pricing and availability

### Rental System
- Intuitive rental process with date selection
- Flexible rental duration options
- Real-time price calculation
- Automatic rental status updates
- Return item functionality with confirmation

### Rental History
- Comprehensive rental tracking system
- Three-tab view for rental history:
  - All rentals with chronological sorting
  - Active rentals with return functionality
  - Completed rentals with return dates
- Detailed rental cards showing:
  - Product image and name
  - Rental status with color coding
  - Rental dates and duration
  - Price details (daily rate and total cost)
  - Return functionality for active rentals

### Location Services
- Real-time location detection and display
- Smart permission handling for location services
- Location caching for better performance
- Detailed location information view
- Location-based product filtering

### User Interface
- Modern, intuitive UI with material design
- Smooth animations and transitions
- Auto-scrolling featured products carousel
- Category-based product browsing
- Responsive design for all screen sizes
- Custom navigation drawer with smooth animations
- Beautiful product cards with shadow effects
- Status indicators with color coding
- Custom dialog boxes for actions

## Technical Implementation

### State Management
- Efficient state management using Provider/Bloc
- Optimized image loading and caching
- Memory-efficient handling of base64 images
- Real-time updates using Streams

### Firebase Integration
- Cloud Firestore for data storage
- Firebase Authentication for user management
- Cloud Storage for image storage
- Real-time data synchronization

### Storage & Caching
- Local storage using SharedPreferences
- Efficient image caching system
- Optimized data persistence
- Memory-efficient base64 image handling

### Navigation & UI
- Custom page transitions
- Intuitive navigation flow
- Material Design components
- Responsive layouts
- Custom animations

### Error Handling
- Comprehensive error management
- User-friendly error messages
- Graceful fallbacks
- Network state handling

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase account and project setup
- Internet connection for initial setup

### Installation
1. Clone this repository:
```bash
git clone https://github.com/RushirajRavalji/GearCare.git
```

2. Navigate to the project directory:
```bash
cd gearcare
```

3. Install dependencies:
```bash
flutter pub get
```

4. Configure Firebase:
   - Create a new Firebase project
   - Add Android/iOS apps in Firebase console
   - Download and add configuration files
   - Enable Authentication and Firestore

5. Run the app:
```bash
flutter run
```

## Usage Guide

### Adding a Product
1. Open the menu drawer and select "Add your product"
2. Fill in the product details:
   - Name
   - Price per day
   - Description
3. Add a product image:
   - Take a new photo
   - Choose from gallery
4. Select display section:
   - Featured (upper)
   - Recommended (bottom)
5. Submit to publish your listing

### Renting a Product
1. Browse products on the home screen
2. Tap on a product to view details
3. Select rental dates
4. Confirm rental details
5. Complete the rental process

### Managing Rentals
1. Access rental history through:
   - Menu drawer
   - Profile screen
2. View rentals in three categories:
   - All rentals
   - Active rentals
   - Completed rentals
3. Return items:
   - Find the active rental
   - Tap "Return Item"
   - Confirm return

## Project Structure
```
lib/
├── localStorage/    # Storage and caching logic
├── models/         # Data models and classes
├── pages/         # UI screens and widgets
├── services/      # Business logic and API services
└── widgets/       # Reusable UI components
```

## Performance Optimizations
- Lazy loading for images
- Efficient state management
- Cached network images
- Optimized database queries
- Minimal rebuild strategy

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements
- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who helped improve this app