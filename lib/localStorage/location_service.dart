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
  static const String _locationEnabledKey = 'locationEnabled';

  // Cache validity duration (10 minutes)
  static const int _cacheValidityDuration = 10 * 60 * 1000; // in milliseconds

  static bool _isLocationEnabled = true;

  // Get current location setting
  bool get isLocationEnabled => _isLocationEnabled;

  // Load saved location preference
  Future<void> loadLocationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLocationEnabled = prefs.getBool(_locationEnabledKey) ?? true;
    } catch (e) {
      debugPrint('Error loading location preference: $e');
      _isLocationEnabled = true;
    }
  }

  // Save location preference
  Future<void> saveLocationPreference(bool enabled) async {
    try {
      _isLocationEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_locationEnabledKey, enabled);
    } catch (e) {
      debugPrint('Error saving location preference: $e');
    }
  }

  // Toggle location service
  Future<void> toggleLocationService() async {
    await saveLocationPreference(!_isLocationEnabled);
  }

  // Get the current location if enabled
  Future<Position?> getCurrentLocation() async {
    if (!_isLocationEnabled) {
      return null;
    }

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can get the location
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Check if location permission is granted
  Future<bool> checkLocationPermission() async {
    if (!_isLocationEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    if (!_isLocationEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Check if device location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    if (!_isLocationEnabled) {
      return false;
    }

    return await Geolocator.isLocationServiceEnabled();
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
