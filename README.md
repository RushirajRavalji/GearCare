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
- Efficient state management using Provider/Bloc
- Optimized image loading and caching
- Memory-efficient handling of base64 images
- Real-time updates using Streams

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
├── authentication/ # Authentication services
├── widget/        # Reusable UI components
├── main.dart      # Application entry point
├── firebase_options.dart # Firebase configuration
└── theme.dart     # App theme configuration
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