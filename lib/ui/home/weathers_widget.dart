import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:weatherflut/model/city.dart';
import 'package:weatherflut/model/weather.dart';
import 'package:weatherflut/ui/common/app_webview_widget.dart';
import 'package:weatherflut/ui/home/weather_details_widget.dart';
import 'package:weatherflut/ui/ui_constants.dart';

DateFormat format = DateFormat('E, dd MMM yyyy');

class WeathersWidget extends StatefulWidget {
  final List<City> cities;
  final VoidCallback onTap;

  const WeathersWidget({
    Key key,
    this.cities,
    this.onTap,
  }) : super(key: key);

  @override
  _WeathersWidgetState createState() => _WeathersWidgetState();
}

class _WeathersWidgetState extends State<WeathersWidget> {
  int _currentIndex = 0;

  void handleArrowPressed(City city) {
    showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            40.0,
          ),
        ),
      ),
      builder: (_) {
        return WeatherDetailsWidget(city: city);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var index = _currentIndex;
    if (_currentIndex > widget.cities.length) {
      index = widget.cities.length - 1;
    }
    final city = widget.cities[index];
    final weather = city.weathers.first;
    final fileName =
        (weather?.weatherStateAbbr ?? WeatherStateAbbr.c).toString() + '.jpg';
    final backgroundImagePath = 'assets/background_states/' + fileName;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
                alignment: Alignment.center,
              );
            },
            duration: Duration(
              milliseconds: 600,
            ),
            child: Image.asset(
              backgroundImagePath,
              fit: BoxFit.cover,
              key: Key(city.id),
            ),
          ),
        ),
        PageView.builder(
          onPageChanged: (val) {
            setState(() {
              _currentIndex = val;
            });
          },
          physics: const ClampingScrollPhysics(),
          itemCount: widget.cities.length,
          itemBuilder: (context, index) {
            final city = widget.cities[index];
            return WeatherItem(
              city: city,
              onTap: () => handleArrowPressed(city),
            );
          },
        ),
        Positioned(
          left: 20,
          top: 20,
          child: SafeArea(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: widget.onTap,
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 20,
          child: SafeArea(
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: widget.onTap,
            ),
          ),
        ),
      ],
    );
  }
}

class WeatherItem extends StatelessWidget {
  final City city;
  final VoidCallback onTap;

  const WeatherItem({
    Key key,
    this.city,
    this.onTap,
  }) : super(key: key);

  void openWebView(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AppWebView(city: this.city)));
  }

  @override
  Widget build(BuildContext context) {
    final weather = city.weathers.first;

    var pageContent = [
      const SizedBox(
        height: 50,
      ),
      Text(
        city.title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
    ];
    if (weather != null) {
      final weatherUI = [
        Text(
          format.format(weather.applicableDate),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            shadows: shadows,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Align(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(
                  begin: 0,
                  end: weather.theTemp.toInt(),
                ),
                duration: const Duration(
                  milliseconds: 800,
                ),
                builder: (context, value, child) {
                  return Text(
                    value.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      shadows: shadows,
                      fontSize: 75,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '°C',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: shadows,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          weather.weatherStateName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            shadows: shadows,
            fontSize: 22,
          ),
        ),
        TextButton(
            onPressed: () {
              openWebView(context);
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalizations.of(context).openForecastLink,
                  style: TextStyle(color: Colors.white)),
              Icon(Icons.launch_rounded, color: Colors.white)
            ]))
      ];
      pageContent = pageContent + weatherUI;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: pageContent,
          ),
        ),
        const SizedBox(
          height: 70,
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                IconButton(
                  onPressed: onTap,
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                _BottomCard(weather: weather)
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ))
      ],
    );
  }
}

class _BottomCard extends StatelessWidget {
  final Weather weather;

  const _BottomCard({Key key, this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(29, 29, 29, 0.4)),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  Expanded(
                    child: _WeatherItemDetails(
                      title: AppLocalizations.of(context).windLabel,
                      value: "${weather.windSpeed.toStringAsFixed(2)} mph",
                    ),
                  ),
                  Expanded(
                    child: _WeatherItemDetails(
                      title: AppLocalizations.of(context).pressureLabel,
                      value: '${weather.airPressure.toStringAsFixed(2)} mbar',
                    ),
                  ),
                  Expanded(
                    child: _WeatherItemDetails(
                      title: AppLocalizations.of(context).humidityLabel,
                      value: '${weather.humidity}%',
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _WeatherItemDetails(
                      title: AppLocalizations.of(context).tempMinLabel,
                      value: weather.getUIMinTemperature(),
                    ),
                    _WeatherItemDetails(
                      title: AppLocalizations.of(context).tempMaxLabel,
                      value: weather.getUIMaxTemperature(),
                    ),
                  ],
                ),
              ],
            )));
  }
}

class _WeatherItemDetails extends StatelessWidget {
  final String title;
  final String value;

  const _WeatherItemDetails({Key key, this.title, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              color: Colors.white,
              shadows: shadows,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                shadows: shadows,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ],
    );
  }
}
