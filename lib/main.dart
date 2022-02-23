import 'package:flutter/material.dart';
import 'screens/current_weather_screen.dart';
import 'screens/weather_forecast_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Weather App',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const CurrentWeatherScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/forecast': (context) => const WeatherForecastScreen(),
      },
    ),
  );
}
