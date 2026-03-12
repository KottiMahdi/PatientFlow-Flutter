import '../../domain/entities/weather.dart';

class WeatherModel extends WeatherEntity {
  WeatherModel({
    required super.cityName,
    required super.temperature,
    required super.description,
    required super.icon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'main': {'temp': temperature},
      'weather': [
        {'description': description, 'icon': icon}
      ],
    };
  }
}
