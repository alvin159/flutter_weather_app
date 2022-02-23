import 'dart:convert';

import 'globals.dart' as globals;
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrentWeatherScreen extends StatefulWidget {
  const CurrentWeatherScreen({Key? key}) : super(key: key);

  @override
  State<CurrentWeatherScreen> createState() => _CurrentWeatherScreenState();
}

class _CurrentWeatherScreenState extends State<CurrentWeatherScreen> {
  Location location = Location();
  String image = "";
  String cityName = "";
  String currentWeather = "";
  double temperature = 0;
  double windSpeed = 0;
  
  Future<void> _updatePosition() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      globals.lat = _locationData.latitude.toString();      
      globals.lon = _locationData.longitude.toString();
    });

    fetchWeatherData();
  }

  void fetchWeatherData() async{
    Uri url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=Helsinki&units=metric&appid=9aaa96ed8d87f4128bf218210727e75e');
    if (globals.lat != "" && globals.lon != ""){
      url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat='+globals.lat+'&lon='+globals.lon+'&units=metric&appid=9aaa96ed8d87f4128bf218210727e75e');
      globals.cityName = "";
    } else if (globals.cityName != ""){
       url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q='+globals.cityName+'&units=metric&appid=9aaa96ed8d87f4128bf218210727e75e');
    }
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var weatherData = json.decode(response.body);
      setState(() {
        image = weatherData['weather'][0]['icon'];
        cityName = weatherData['name'];
        currentWeather = weatherData['weather'][0]['description'];
        temperature = weatherData['main']['temp'];
        windSpeed = weatherData['wind']['speed'];    
      });     
    }
  }

  void openWeatherForecast(){
    Navigator.pushNamed(context, '/forecast');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              onChanged: (value) => globals.cityName = value,
              style: const TextStyle(
                color: Colors.black,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => {globals.lat = "",globals.lon = "",fetchWeatherData()},
              decoration: InputDecoration(
                suffix: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                hintStyle: const TextStyle(color: Colors.black),
                hintText: 'Enter a city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            image.isNotEmpty ? Image.network("http://openweathermap.org/img/wn/"+image+"@2x.png",
                fit: BoxFit.cover,
              ) : const Text('Press Get weather data ↓ or enter a city name ↑', style : TextStyle(fontSize: 30)),
            Text(currentWeather, style : const TextStyle(fontSize: 40)),            
            Text('$temperature °C', style : const TextStyle(fontSize: 40)),
            Text('$windSpeed m/s', style : const TextStyle(fontSize: 40)),
            ElevatedButton(
              child: const Text('Get weather data', style : TextStyle(fontSize: 40)),
              onPressed: () {
                _updatePosition();
              },
            ),
            ElevatedButton(
              child: const Text('Forecast', style : TextStyle(fontSize: 40)),
              onPressed: () {
                openWeatherForecast();
              },
            ),
          ],
        ),
      ),
    );
  }
}
