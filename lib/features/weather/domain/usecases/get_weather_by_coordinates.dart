import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/entities/weather.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/repositories/weather_repository.dart';

class GetWeatherByCoordinates {
  final WeatherRepository repository;

  GetWeatherByCoordinates(this.repository);

  Future<Either<Failure, WeatherEntity>> call(double lat, double lon) async {
    return await repository.getWeatherByCoordinates(lat, lon);
  }
}
