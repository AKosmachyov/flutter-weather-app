import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:weatherflut/data/data_constants.dart';
import 'package:weatherflut/model/city.dart';

final dayFormat = DateFormat('EEEE');

class WeatherDetailsWidget extends StatelessWidget {
  final City city;

  const WeatherDetailsWidget({Key key, this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              AppLocalizations.of(context)
                  .weatherForecastLabel(city.weathers.length),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 25,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: city.weathers.length,
                itemBuilder: (context, index) {
                  final weather = city.weathers[index];
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Text(
                                  dayFormat.format(
                                    weather.applicableDate,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Image.network(
                                    '${server}static/img/weather/png/64/${weather.weatherStateAbbr}.png',
                                    height: 25,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${weather.getUIMaxTemperature()}°',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  ' ${weather.getUIMinTemperature()}°C',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context).windLabel,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context).pressureLabel,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context).humidityLabel,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${weather.windSpeed.toStringAsFixed(2)} mph',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${weather.airPressure} mbar',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${weather.humidity}%',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
