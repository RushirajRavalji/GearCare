# GearCare - Equipment Rental Marketplace

GearCare is a modern, user-friendly Flutter application designed to facilitate equipment rental between users. The platform allows users to list their own equipment for rent and browse through items offered by others.

## Features

### User Authentication
- Secure login and registration system using Firebase Authentication
- User profile management with customizable profile pictures
- Persistent session management

### Product Management
- Add new products with images (camera or gallery)
- Edit existing product listings
- Delete unwanted products 
- Products categorized in two display sections: Featured (upper) and Recommended (bottom)

### Location Services
- Real-time location detection
- Permission handling for location services
- Location caching to reduce API calls
- Detailed location information view

### User Interface
- Modern, intuitive UI with smooth animations
- Slide-up transitions between screens
- Auto-scrolling featured products carousel
- Category-based browsing experience
- Responsive design that works across device sizes

### Product Details
- Comprehensive product information display
- Pricing information per day
- Product descriptions and images
- Quick-access actions through contextual menus

### Rental History
- Complete rental history tracking for users
- Active rentals management with return functionality
- Rental duration and cost calculation
- Categorized view of all, active, and completed rentals
- Detailed rental information with product images and rental dates

## Technical Implementation

### State Management
- Efficient state management for a smooth user experience
- Optimized image loading and caching
- Memory-efficient handling of base64 images

### Storage
- Local storage using SharedPreferences for caching
- Firebase Cloud Storage for persistent data
- Optimized image compression for faster loading

### Navigation
- Custom page transitions for enhanced UX
- Intuitive navigation flow throughout the app

### Permissions
- Runtime permission handling for camera and location
- User-friendly permission request workflows with clear explanations

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase account

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

4. Run the app:
```bash
flutter run
```

## Usage Guide

### Adding a Product
1. Tap the + button on the main screen
2. Fill in the product details (name, price, description)
3. Add a product image (take a photo or choose from gallery)
4. Select where to display your product (Upper or Bottom section)
5. Tap "Add Product" to publish your listing

### Editing/Deleting Products
1. Find your product on the home screen
2. Tap the three-dot menu on the product card
3. Select "Edit" to modify or "Delete" to remove the product

### Viewing Product Details
1. Tap on any product card
2. View detailed information in the slide-up screen
3. Check pricing and product specifications

### Viewing Your Location
1. The current location is displayed in the app bar
2. Tap to refresh your location
3. Long press to view detailed location information

### Viewing Rental History
1. Access rental history from the menu drawer or profile screen
2. View all rentals, active rentals, or completed rentals using the tabs
3. Check rental details including duration, cost, and rental dates
4. Return active rentals by tapping the "Return Item" button

## Project Structure
- `/lib` - Main source code directory
  - `/localStorage` - Storage and cache related code
  - `/models` - Data models 
  - `/pages` - UI screens
  - `/widget` - Reusable UI components

## Performance Optimizations
- Memory optimization for image handling
- Location service caching to reduce API calls
- Efficient UI rebuilding to prevent jitter
- Custom animations with proper timing controls

## Screenshots
(Add screenshots here)

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.


## Acknowledgements
- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who helped improve this app