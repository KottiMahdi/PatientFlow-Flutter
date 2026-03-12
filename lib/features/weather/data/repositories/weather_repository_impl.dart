import 'package:dartz/dartz.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/entities/weather.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/repositories/weather_repository.dart';
import 'package:management_cabinet_medical_mobile/features/weather/data/models/weather_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final http.Client client;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'd57af3ed53322faa7c2c0d5da072fbed';

  WeatherRepositoryImpl({required this.client});

  @override
  Future<Either<Failure, WeatherEntity>> getWeatherByCity(
      String cityName) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return Right(WeatherModel.fromJson(json.decode(response.body)));
      } else {
        return const Left(ServerFailure());
      }
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, WeatherEntity>> getWeatherByCoordinates(
      double lat, double lon) async {
    try {
      final response = await client.get(
        Uri.parse(
            '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return Right(WeatherModel.fromJson(json.decode(response.body)));
      } else {
        return const Left(ServerFailure());
      }
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
