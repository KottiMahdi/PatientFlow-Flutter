import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/entities/weather.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/repositories/weather_repository.dart';

class GetWeatherByCity {
  final WeatherRepository repository;

  GetWeatherByCity(this.repository);

  Future<Either<Failure, WeatherEntity>> call(String cityName) async {
    return await repository.getWeatherByCity(cityName);
  }
}
