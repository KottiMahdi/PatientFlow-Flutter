import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'd57af3ed53322faa7c2c0d5da072fbed';

  Future<Weather> getWeatherByCity(String cityName) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Weather> getWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}