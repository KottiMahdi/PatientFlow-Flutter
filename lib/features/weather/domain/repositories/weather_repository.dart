import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/entities/weather.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getWeatherByCity(String cityName);
  Future<Either<Failure, WeatherEntity>> getWeatherByCoordinates(
      double lat, double lon);
}
