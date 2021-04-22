import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:intl/intl.dart';

import 'package:weatherflut/model/city.dart';
import 'package:weatherflut/model/weather.dart';
import 'api_repository.dart';

class BBCProvider extends ApiRepository {
  final _forecastDateFormat = DateFormat('EEE, d MMM yyyy HH:mm:ss');
  final _minMaxTempRegExp = RegExp(r'(\d+)..C');

  @override
  Future<List<City>> getCities(String text) async {
    final params = {
      'api_key': 'AGbFAKx58hyjQScCXIYrxuEwJh2W2cmv',
      'stack': 'aws',
      'locale': 'en',
      'filter': 'international',
      'place-types': 'settlement,airport,district',
      'order': 'importance',
      's': text,
      'a': 'true',
      'format': 'json'
    };
    final url =
        Uri.https('locator-service.api.bbci.co.uk', 'locations', params);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _parseCities(data);
    } else {
      throw Exception('Failed to fetch cities');
    }
  }

  List<City> _parseCities(Map<String, dynamic> map) {
    final results = map['response']['results']['results'] as List;
    return results.map((e) {
      final title = e['name'];
      return City(
          id: Uuid().v4().toString(),
          title: title,
          country: e['container'],
          remoteId: e['id'],
          weathers: []);
    }).toList();
  }

  @override
  Future<City> getWeathers(City city) async {
    final currentWeatherUrl = Uri.https('weather-broker-cdn.api.bbci.co.uk',
        'en/observation/rss/${city.remoteId}');
    final forecastUrl = Uri.https('weather-broker-cdn.api.bbci.co.uk',
        'en/forecast/rss/3day/${city.remoteId}');

    final responses =
        await Future.wait([http.get(currentWeatherUrl), http.get(forecastUrl)]);

    if (responses.every((res) => res.statusCode == 200)) {
      final todayForecast = responses[0].body;
      final forecast3DayResponse = responses[1].body;
      var forecast = _parseForecast(forecast3DayResponse);
      _fillWeatherWithCurrentTemp(todayForecast, forecast[0]);
      return city.fromWeathers(forecast);
    } else {
      throw Exception('Failed to fetch forecast');
    }
  }

  void _fillWeatherWithCurrentTemp(String data, Weather weather) {
    final rssFeed = new RssFeed.parse(data);
    final forecast = rssFeed.items[0].title;
    weather.theTemp = _parseCurrentTemperature(forecast);
  }

  List<Weather> _parseForecast(String data) {
    final rssFeed = new RssFeed.parse(data);
    final items = rssFeed.items;
    var dayNumber = 0;
    return items.map((item) {
      var weather = _parseWeather(item, dayNumber);
      dayNumber++;
      return weather;
    }).toList();
  }

  Weather _parseWeather(RssItem item, int daysOffset) {
    final titleRow = item.title,
        pubDate = item.pubDate,
        descriptionRow = item.description;

    // pubDate - always contains the date the forecast was requested
    var localDate = _forecastDateFormat.parse(pubDate);
    localDate =
        localDate.add(localDate.timeZoneOffset).add(Duration(days: daysOffset));

    final weatherState = _parseStateName(titleRow);
    final weatherStateAbbr = (weatherState == null
            ? WeatherStateAbbr.c
            : _parseStateAbbr(weatherState))
        .toString()
        .split('.')[1];

    final temperatureRange = _parseTemperatureRange(titleRow);

    final windDirectionRegExp = RegExp(r'Wind Direction: (\w+ \w+),');
    final windDirection =
        windDirectionRegExp.firstMatch(descriptionRow)?.group(1);

    final windSpeedRegExp = RegExp(r'Wind Speed: (\d+)');
    final windSpeed =
        double.parse(windSpeedRegExp.firstMatch(descriptionRow)?.group(1));

    final pressureRegExp = RegExp(r'Pressure: (\d+)');
    final pressure =
        double.parse(pressureRegExp.firstMatch(descriptionRow)?.group(1));

    final humidityRegExp = RegExp(r'Humidity: (\d+)');
    final humidity =
        double.parse(humidityRegExp.firstMatch(descriptionRow)?.group(1));

    return Weather(
        id: Uuid().v4().toString(),
        weatherStateName: weatherState,
        weatherStateAbbr: weatherStateAbbr,
        windDirectionCompass: windDirection,
        created: DateTime.now(),
        applicableDate: localDate,
        minTemp: temperatureRange[0],
        maxTemp: temperatureRange[1],
        theTemp: null,
        windSpeed: windSpeed,
        airPressure: pressure,
        humidity: humidity);
  }

  String _parseStateName(String row) {
    final firstPart = row.split(',')[0];
    final separateIndex = firstPart.lastIndexOf(':');
    return firstPart.substring(separateIndex + 1).trim();
  }

  List<int> _parseTemperatureRange(String row) {
    final matches = _minMaxTempRegExp.allMatches(row);
    if (matches.length == 2) {
      final minTemp = int.parse(matches.elementAt(0).group(1));
      final maxTemp = int.parse(matches.elementAt(1).group(1));
      return [minTemp, maxTemp];
    }
    if (matches.length == 1) {
      final temp = int.parse(matches.elementAt(0).group(1));
      if (row.indexOf("Maximum Temperature") > -1) {
        return [null, temp];
      } else {
        return [temp, null];
      }
    }
    return [null, null];
  }

  int _parseCurrentTemperature(String row) {
    final match = _minMaxTempRegExp.firstMatch(row);
    return int.parse(match.group(1));
  }

  WeatherStateAbbr _parseStateAbbr(String value) {
    switch (value.toLowerCase()) {
      case 'light cloud':
        return WeatherStateAbbr.lc;
      case 'sunny intervals':
      case 'sunny':
      case 'clear sky':
        return WeatherStateAbbr.c;
      case 'light rain':
        return WeatherStateAbbr.lr;
      case 'light rain showers':
      case 'hail showers':
        return WeatherStateAbbr.s;
      case 'partly cloudy':
        return WeatherStateAbbr.lc;
      default:
        print("Unsupported weather type: " + value);
        return WeatherStateAbbr.c;
    }
  }
}

// enum WeatherStateAbbr {
//   sn, // Snow
//   sl, // Sleet
//   h, // Hail
//   t, // Thunderstorm,
//   hr, // Heavy Rain
//   lr, // Light Rain
//   s, // Showers
//   hc, // Heavy Cloud
//   lc, // Light Cloud
//   c, // Clear
// }
