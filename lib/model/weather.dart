import 'dart:convert';

Weather weatherFromJson(String str) => Weather.fromJson(
      json.decode(str),
    );

String weatherToJson(Weather data) => json.encode(
      data.toJson(),
    );

class Weather {
  Weather({
    this.id,
    this.weatherStateName,
    this.weatherStateAbbr,
    this.windDirectionCompass,
    this.created,
    this.applicableDate,
    this.minTemp,
    this.maxTemp,
    this.theTemp,
    this.windSpeed,
    this.airPressure,
    this.humidity,
  });

  String id;
  String weatherStateName;
  String weatherStateAbbr;
  String windDirectionCompass;
  DateTime created;
  DateTime applicableDate;
  int minTemp;
  int maxTemp;
  int theTemp;
  double windSpeed;
  double airPressure;
  num humidity;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        id: json["id"],
        weatherStateName: json["weather_state_name"],
        weatherStateAbbr: json["weather_state_abbr"],
        windDirectionCompass: json["wind_direction_compass"],
        created: DateTime.parse(json["created"]),
        applicableDate: DateTime.parse(json["applicable_date"]),
        minTemp: json["min_temp"],
        maxTemp: json["max_temp"],
        theTemp: json["the_temp"],
        windSpeed: json["wind_speed"].toDouble(),
        airPressure: json["air_pressure"],
        humidity: json["humidity"]);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "weather_state_name": weatherStateName,
        "weather_state_abbr": weatherStateAbbr,
        "wind_direction_compass": windDirectionCompass,
        "created": created.toIso8601String(),
        "applicable_date":
            "${applicableDate.year.toString().padLeft(4, '0')}-${applicableDate.month.toString().padLeft(2, '0')}-${applicableDate.day.toString().padLeft(2, '0')}",
        "min_temp": minTemp,
        "max_temp": maxTemp,
        "the_temp": theTemp,
        "wind_speed": windSpeed,
        "air_pressure": airPressure,
        "humidity": humidity
      };

  String getUIMinTemperature() =>
      minTemp == null ? "-" : minTemp.toStringAsFixed(0);

  String getUIMaxTemperature() =>
      maxTemp == null ? "-" : maxTemp.toStringAsFixed(0);
}

enum WeatherStateAbbr {
  sn, // Snow
  sl, // Sleet
  h, // Hail
  t, // Thunderstorm,
  hr, // Heavy Rain
  lr, // Light Rain
  s, // Showers
  hc, // Heavy Cloud
  lc, // Light Cloud
  c, // Clear
}
