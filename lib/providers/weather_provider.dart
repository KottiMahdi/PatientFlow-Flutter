import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  Weather? _weather;
  bool _isLoadingWeather = false;
  String _weatherError = '';
  bool _hasLoadedWeather = false; // Add this flag

  // Getters
  Weather? get weather => _weather;
  bool get isLoadingWeather => _isLoadingWeather;
  String get weatherError => _weatherError;
  bool get hasLoadedWeather => _hasLoadedWeather; // Add this getter

  Future<void> loadWeather({bool forceReload = false}) async {
    // Don't reload if already loaded unless forced
    if (_hasLoadedWeather && !forceReload) {
      return;
    }

    _isLoadingWeather = true;
    _weatherError = '';
    notifyListeners();

    try {
      // Try to get current location first
      Position? position = await _getCurrentLocation();

      Weather weather;
      if (position != null) {
        weather = await _weatherService.getWeatherByCoordinates(
            position.latitude,
            position.longitude
        );
      } else {
        // Fallback to Tunis (user's location from context)
        weather = await _weatherService.getWeatherByCity('Tunis');
      }

      _weather = weather;
      // flag prevents unnecessary API calls when navigating back to the HomePage
      _hasLoadedWeather = true;
      _isLoadingWeather = false;
      notifyListeners();
    } catch (e) {
      _weatherError = 'Weather unavailable';
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  // Method to force reload (for refresh functionality)
  Future<void> refreshWeather() async {
    print('RefreshWeather called'); // Debug print
    _hasLoadedWeather = false; // Reset the flag
    await loadWeather(forceReload: true);
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(Duration(seconds: 10));
    } catch (e) {
      return null;
    }
  }

  void clearWeatherError() {
    _weatherError = '';
    notifyListeners();
  }
}