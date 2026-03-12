import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/entities/weather.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/usecases/get_weather_by_city.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/usecases/get_weather_by_coordinates.dart';

class WeatherProviderGlobal with ChangeNotifier {
  final GetWeatherByCity getWeatherByCity;
  final GetWeatherByCoordinates getWeatherByCoordinates;

  WeatherEntity? _weather;
  bool _isLoadingWeather = false;
  String _weatherError = '';
  bool _hasLoadedWeather = false;

  WeatherProviderGlobal({
    required this.getWeatherByCity,
    required this.getWeatherByCoordinates,
  });

  // Getters
  WeatherEntity? get weather => _weather;
  bool get isLoadingWeather => _isLoadingWeather;
  String get weatherError => _weatherError;
  bool get hasLoadedWeather => _hasLoadedWeather;

  Future<void> loadWeather({bool forceReload = false}) async {
    if (_hasLoadedWeather && !forceReload) {
      return;
    }

    _isLoadingWeather = true;
    _weatherError = '';
    notifyListeners();

    try {
      Position? position = await _getCurrentLocation();

      final result = position != null
          ? await getWeatherByCoordinates(position.latitude, position.longitude)
          : await getWeatherByCity('Tunis');

      result.fold(
        (failure) {
          _weatherError = 'Weather unavailable';
          _weather = null;
        },
        (weather) {
          _weather = weather;
          _hasLoadedWeather = true;
        },
      );
    } catch (e) {
      _weatherError = 'Weather unavailable';
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    _hasLoadedWeather = false;
    await loadWeather(forceReload: true);
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      return null;
    }
  }

  void clearWeatherError() {
    _weatherError = '';
    notifyListeners();
  }
}
