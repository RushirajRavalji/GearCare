import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Keys for storing location data in SharedPreferences
  static const String _locationCacheKey = 'cached_location_address';
  static const String _locationTimestampKey = 'location_timestamp';
  static const String _locationLatKey = 'location_latitude';
  static const String _locationLngKey = 'location_longitude';

  // Cache validity duration (10 minutes)
  static const int _cacheValidityDuration = 10 * 60 * 1000; // in milliseconds

  // Check if location permissions are granted
  Future<bool> checkLocationPermission() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        return false;
      }

      // Then check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // Request location permissions and services
  Future<bool> requestLocationPermission() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to request location service
        // This will prompt the user but we need to check again
        await Geolocator.openLocationSettings();
        // The result of the above call depends on user action, so we need to check again
        // but we'll do that in the calling method
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission from the user
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        return false;
      }

      // Permission granted
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Open app settings
  Future<void> openLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  // Get the current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Get the current position with a timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(
          seconds: 10,
        ), // Add timeout to prevent hanging
      );
    } catch (e) {
      print('Error getting location: $e');

      // Try with lower accuracy if high accuracy fails
      if (e is TimeoutException) {
        try {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e2) {
          print('Error getting location with medium accuracy: $e2');
          return null;
        }
      }

      return null;
    }
  }

  // Get a human-readable address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Try to build a more meaningful location string
        List<String> addressParts = [];

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        if (addressParts.isEmpty &&
            place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // Join parts to create a user-friendly location name
        String address = addressParts.join(', ');
        return address.isNotEmpty ? address : 'Unknown location';
      }
      return 'Location found';
    } catch (e) {
      print('Error getting address: $e');
      return 'Location found'; // Return a default message instead of null
    }
  }

  // Get current location with address (with caching support)
  Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check for cached location data
      final cachedTimestamp = prefs.getInt(_locationTimestampKey);
      final cachedAddress = prefs.getString(_locationCacheKey);
      final cachedLat = prefs.getDouble(_locationLatKey);
      final cachedLng = prefs.getDouble(_locationLngKey);

      // If we have cached data that's recent enough, use it
      if (cachedTimestamp != null &&
          cachedAddress != null &&
          cachedLat != null &&
          cachedLng != null) {
        if (now - cachedTimestamp < _cacheValidityDuration) {
          return {
            'address': cachedAddress,
            'latitude': cachedLat,
            'longitude': cachedLng,
            'timestamp': cachedTimestamp,
          };
        }
      }

      // Check if we have permission
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          throw Exception('Location permission not granted');
        }
      }

      // Get fresh location data
      final position = await getCurrentLocation();
      if (position == null) {
        // Fall back to cached data if available
        if (cachedAddress != null && cachedLat != null && cachedLng != null) {
          return {
            'address': cachedAddress,
            'latitude': cachedLat,
            'longitude': cachedLng,
            'timestamp': cachedTimestamp ?? now,
            'isCache': true,
          };
        }
        throw Exception('Failed to get current location');
      }

      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Cache the result
      await prefs.setString(_locationCacheKey, address ?? 'Unknown location');
      await prefs.setInt(_locationTimestampKey, now);
      await prefs.setDouble(_locationLatKey, position.latitude);
      await prefs.setDouble(_locationLngKey, position.longitude);

      return {
        'address': address ?? 'Unknown location',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': now,
      };
    } catch (e) {
      print('Error in getCurrentLocationWithAddress: $e');

      // Try to return cached data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedAddress = prefs.getString(_locationCacheKey);
        final cachedLat = prefs.getDouble(_locationLatKey);
        final cachedLng = prefs.getDouble(_locationLngKey);
        final cachedTimestamp = prefs.getInt(_locationTimestampKey);

        if (cachedAddress != null && cachedLat != null && cachedLng != null) {
          return {
            'address': cachedAddress,
            'latitude': cachedLat,
            'longitude': cachedLng,
            'timestamp':
                cachedTimestamp ?? DateTime.now().millisecondsSinceEpoch,
            'isCache': true,
          };
        }
      } catch (cacheError) {
        print('Error getting cached location: $cacheError');
      }

      return {'address': 'Location unavailable', 'error': e.toString()};
    }
  }

  // Show dialog to request location permissions
  Future<bool> showLocationPermissionDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Access Required'),
          content: const Text(
            'This app needs access to your location to show nearby services. '
            'Please grant location permission in app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('OPEN SETTINGS'),
              onPressed: () async {
                Navigator.of(context).pop(true);
                await Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // Show dialog to request enabling location services (GPS)
  Future<bool> showLocationServicesDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Location Services'),
          content: const Text(
            'Location services (GPS) are disabled. '
            'Please enable location services to use this feature.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('OPEN SETTINGS'),
              onPressed: () {
                Navigator.of(context).pop(true);
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
