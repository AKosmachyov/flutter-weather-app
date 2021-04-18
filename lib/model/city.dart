import 'package:weatherflut/model/weather.dart';

class City {
  final String id;
  final String title;
  final String country;
  final String remoteId;
  final List<Weather> weathers;

  City({
    this.id,
    this.title,
    this.country = "",
    this.remoteId,
    this.weathers,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'woeid': remoteId,
        'country': country,
        'weathers': weathers.map((e) => e.toJson()).toList(),
      };

  factory City.fromJson(Map<String, dynamic> map) {
    final myWeathers = map['weathers'];
    return City(
      id: map['id'],
      remoteId: map['woeid'],
      title: map['title'],
      country: map['country'],
      weathers: myWeathers != null
          ? (myWeathers as List).map((e) => Weather.fromJson(e)).toList()
          : null,
    );
  }

  String getFullTitle() =>
      country.isEmpty ? title : [title, country].join(', ');

  City fromWeathers(List<Weather> weathers) {
    return City(
      id: id,
      remoteId: remoteId,
      title: title,
      country: country,
      weathers: weathers,
    );
  }
}
