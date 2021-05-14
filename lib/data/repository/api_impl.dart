import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:weatherflut/data/data_constants.dart';
import 'package:weatherflut/data/repository/api_repository.dart';
import 'package:weatherflut/model/city.dart';
import 'package:http/http.dart' as http;
import 'package:weatherflut/model/weather.dart';

class ApiImpl extends ApiRepository {
  @override
  String getDetailsUrl() {
    return 'https://www.metaweather.com/';
  }

  @override
  Future<List<City>> getCities(String text) async {
    final url = Uri.parse('${api}search/?query=$text');
    final response = await http.get(url);
    final body = Utf8Decoder().convert(response.bodyBytes);
    final data = jsonDecode(body) as List;
    final cities = data.map((e) {
      return City(
          id: Uuid().v4().toString(),
          remoteId: e['woeid'].toString(),
          title: e['title']);
    }).toList();
    return cities;
  }

  @override
  Future<City> getWeathers(City city) async {
    final url = Uri.parse('$api${city.remoteId}');
    final response = await http.get(url);
    final body = Utf8Decoder().convert(response.bodyBytes);
    final data = jsonDecode(body);
    final weatherData = data['consolidated_weather'] as List;
    final weathers = weatherData.map((e) => Weather.fromJson(e)).toList();
    final newCity = city.fromWeathers(weathers);
    return newCity;
  }
}
