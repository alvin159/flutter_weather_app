import 'dart:convert';

import 'globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({Key? key}) : super(key: key);

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  late List? weatherList = [];
  late var dateTime = 0;
  String cityName = "";
  @override
  void initState(){
    super.initState();
    fetchweatherList();
  }

  void fetchweatherList() async{
    Uri url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=Helsinki&units=metric&appid=9aaa96ed8d87f4128bf218210727e75e');
    if (globals.lat != "" && globals.lon != ""){
      url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat='+globals.lat+'&lon='+globals.lon+'&units=metric&appid=9aaa96ed8d87f4128bf218210727e75e');
    } else if (globals.cityName != ""){
       url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q='+globals.cityName+'&units=metric&appid=9aaa96ed8d87f4128bf218210727e75e');
    }
    final response = await http.get(url);
    var weatherData = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {        
        weatherList = weatherData["list"];
        cityName = weatherData["city"]["name"];
      }); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forecast ' + cityName),
      ),
      body: weatherList!.isNotEmpty ? ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: weatherList!.length,
        itemBuilder: (BuildContext context, int index) {
          dateTime = weatherList![index]['dt'];
          return Stack(
            children: <Widget> [
              Image.network("http://openweathermap.org/img/wn/"+weatherList![index]['weather'][0]['icon']+"@2x.png",
                fit: BoxFit.cover,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Date: " + DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(weatherList![index]['dt'] * 1000))),
                    Text("Temperature: " + weatherList![index]['main']['temp'].toString() + " °C"),
                    Text("Weather: " + weatherList![index]['weather'][0]['main']),
                    Text("Description: " + weatherList![index]['weather'][0]['description']),
                    Text("Wind Speed: " + weatherList![index]['wind']['speed'].toString() + " m/s"),                  
                  ],
                ),
              ),
            ]
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ) : const Text("Waiting for data")
    );
  }
}
