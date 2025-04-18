# GearCare - Equipment Rental Marketplace

GearCare is a modern, user-friendly Flutter application designed to facilitate equipment rental between users. The platform allows users to list their own equipment for rent and browse through items offered by others, with a beautiful and intuitive user interface. All data is securely stored and synchronized using Firebase services.

## Features

### Data Visibility & Privacy
- Public Data:
  - All products added by users are visible to everyone
  - Product details including images, prices, and descriptions are public
  - Product availability status is visible to all users
- Private Data:
  - User profiles are private and only visible to the owner
  - Rental history is user-specific and private
  - Personal information is securely stored and protected

### User Authentication & Profile
- Secure login and registration system using Firebase Authentication
- User profile management with customizable profile pictures
- Persistent session management
- Profile screen with user details and rental history
- Private user data storage in Firebase

### Product Management
- Add new products with high-quality images (camera or gallery)
- Edit existing product listings with real-time updates
- Delete unwanted products 
- Products categorized in two display sections:
  - Featured (upper section) with auto-scrolling carousel
  - Recommended (bottom section) with grid layout
- Detailed product information with pricing and availability
- All products are publicly visible to all users

### Rental System
- Intuitive rental process with date selection
- Flexible rental duration options
- Real-time price calculation
- Automatic rental status updates
- Return item functionality with confirmation
- Private rental records for each user
- Rental bill generation with PDF support
- Digital signature capability for rental agreements

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
- Private rental history for each user

### Location Services
- Real-time location detection and display
- Smart permission handling for location services
- Location caching for better performance
- Detailed location information view
- Location-based product filtering
- Integration with Geolocator and Geocoding packages

### Payment Integration
- UPI payment integration using flutter_upi_india
- Secure payment processing
- Payment verification
- Transaction history tracking

### User Interface
- Modern, intuitive UI with material design
- Dynamic theme support with light and dark modes
- Smooth animations and transitions
- Auto-scrolling featured products carousel
- Category-based product browsing
- Responsive design for all screen sizes
- Custom navigation drawer with smooth animations
- Beautiful product cards with shadow effects
- Status indicators with color coding
- Custom dialog boxes for actions

## Technical Implementation

### Firebase Integration
- Cloud Firestore for data storage:
  - Public products collection
  - Private user profiles collection
  - Private rental history collection
- Firebase Authentication for user management
- Cloud Storage for image storage
- Real-time data synchronization
- Secure data access rules

### State Management
- Efficient state management using Provider
- Optimized image loading and caching
- Memory-efficient handling of base64 images
- Real-time updates using Streams

### Storage & Caching
- Local storage using SharedPreferences for theme preferences and user settings
- Firebase Storage for product images
- Efficient image caching using cached_network_image
- Optimized data persistence
- Memory-efficient base64 image handling

### Navigation & UI
- Custom page transitions
- Intuitive navigation flow
- Material Design components
- Responsive layouts
- Custom animations
- Support for portrait orientation only

### Error Handling
- Comprehensive error management
- User-friendly error messages
- Graceful fallbacks
- Network state handling
- Custom error widget for handling exceptions

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.0)
- Dart SDK (^3.7.0)
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
   - Set up Firestore security rules:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         // Public products collection
         match /products/{productId} {
           allow read: if true;
           allow write: if request.auth != null;
         }
         
         // Private user profiles
         match /users/{userId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
         
         // Private rental history
         match /rentals/{rentalId} {
           allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
         }
       }
     }
     ```

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
5. Submit to publish your listing (visible to all users)

### Renting a Product
1. Browse products on the home screen
2. Tap on a product to view details
3. Select rental dates
4. Confirm rental details
5. Complete the rental process (private to your account)
6. Generate rental bill and sign the agreement

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
├── authentication/  # Authentication services and gates
├── localStorage/    # Storage, caching logic, and Firebase services
├── models/         # Data models for products and rental history
├── pages/          # UI screens including home, profile, rental screens
├── widget/         # Reusable UI components
├── firebase_options.dart # Firebase configuration
├── main.dart       # Application entry point
└── theme.dart      # App theme configuration with light/dark mode support
```

### Key Files Overview

#### Main Application Files
- `main.dart`: Application entry point with Firebase initialization
- `theme.dart`: Comprehensive theme system with light and dark mode support
- `firebase_options.dart`: Firebase configuration details

#### Pages
- `app_layout.dart`: Main application layout structure
- `home.dart`: Home screen with featured and recommended products
- `profile.dart`: User profile management and settings
- `login.dart` & `registerstate.dart`: Authentication screens
- `addproduct.dart` & `updateProduct.dart`: Product management screens
- `rental_history.dart`: Comprehensive rental tracking interface
- `rental_bill.dart`: Bill generation for rentals
- `booking_confirmation.dart`: Rental confirmation process
- `menu.dart`: Navigation drawer and application menu
- `splashscree.dart`: Application splash screen

#### Services and Models
- `product_models.dart`: Data models for product information
- `rental_history_model.dart`: Models for rental tracking
- `firebase_auth_service.dart`: Firebase authentication implementation
- `FirebaseStorageService.dart`: Firebase storage for images
- `location_service.dart`: Geolocation functionality
- `rental_history_service.dart`: Rental tracking and management

## Performance Optimizations
- Lazy loading for images
- Efficient state management
- Cached network images
- Optimized database queries
- Minimal rebuild strategy
- Optimized image compression using flutter_image_compress
- Efficient location caching

## Dependencies
- Firebase Core, Auth, Firestore, Storage: Backend services
- Flutter UI Libraries: carousel_slider, cached_network_image
- Image Handling: image_picker, flutter_image_compress
- Location Services: geolocator, geocoding
- Storage: shared_preferences, path_provider
- PDF Generation: pdf, open_file
- Digital Signature: signature
- Payment: flutter_upi_india
- Utilities: uuid, intl, permission_handler, url_launcher

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements
- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who helped improve this app