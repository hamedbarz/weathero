import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:weathero/model/ForecastWeatherModel.dart';
import 'package:weathero/model/currentWeatherModel.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController searchController = TextEditingController();
  late Future<CurrentWeatherModel> cwmFuture;
  StreamController<List<ForecastWeatherModel>> fwStream =
      StreamController<List<ForecastWeatherModel>>();
  String cityName = 'tehran';
  String apiKey = '59371b508e456a063cc9ee95288aa8a9';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cwmFuture = getCurrentWeather(cityName);
  }

  void getForecastWeather(lat, lon) async {
    List<ForecastWeatherModel> fwList = [];
    final response = await Dio().get(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric");
    var result = response.data;
    for (int i = 0; i< 40;) {
      var day = result["list"][i];
      final formatter = DateFormat.MMMd();
      var datetime = formatter
          .format(DateTime.fromMillisecondsSinceEpoch(day["dt"] * 1000));
      var fwModel = ForecastWeatherModel(
        datetime,
        day["main"]["temp"],
        day["weather"][0]["main"],
        day["weather"][0]["description"],
        day["weather"][0]["icon"],
      );
      fwList.add(fwModel);
      i = i + 7;
    }
    fwStream.add(fwList);
  }

  Future<CurrentWeatherModel> getCurrentWeather(cityName) async {
    final response = await Dio().get(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric");
    var result = response.data;

    var cwm = CurrentWeatherModel(
        result["name"],
        result["coord"]["lon"],
        result["coord"]["lat"],
        result["weather"][0]["main"],
        result["weather"][0]["description"],
        result["main"]["temp"],
        result["main"]["temp_min"],
        result["main"]["temp_max"],
        result["main"]["pressure"],
        result["main"]["humidity"],
        result["wind"]["speed"],
        result["dt"],
        result["sys"]["country"],
        result["sys"]["sunrise"],
        result["sys"]["sunset"],
        result["weather"][0]["icon"]);
    return cwm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("weathero"),
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (context) {
                return {'profile', 'setting'}.map((txt) {
                  return PopupMenuItem(
                    value: txt,
                    child: Text(txt),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: cwmFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              CurrentWeatherModel? cwData = snapshot.data;

              getForecastWeather(cwData!.lat, cwData.long);

              final formatter = DateFormat.jm();
              var sunset = formatter.format(
                  DateTime.fromMillisecondsSinceEpoch(cwData.sunset * 1000));
              var sunrise = formatter.format(
                  DateTime.fromMillisecondsSinceEpoch(cwData.sunrise * 1000));
              Image weatherImg = Image.network(
                  "http://openweathermap.org/img/wn/${cwData.icon}@2x.png",
                  color: Colors.white,
              );

              return Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("images/bg.jpg"),
                  fit: BoxFit.cover,
                )),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                    hintText: "Enter city name ...",
                                    hintStyle: TextStyle(color: Colors.white),
                                    fillColor: Colors.grey[200]
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  cwmFuture = getCurrentWeather(searchController.text);
                                  searchController.clear();
                                });
                              },
                              child: Text("Find")
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(cwData!.cityName,
                            style:
                                TextStyle(color: Colors.white, fontSize: 30)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(cwData.description,
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ),
                      weatherImg,
                      Text("${cwData.temp.round()}\u00B0",
                          style:
                              TextStyle(color: Colors.white, fontSize: 50)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("max",
                                  style: TextStyle(
                                      color: Colors.grey[300], fontSize: 14)),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text("${cwData.temp_max.round()}\u00B0",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey[700],
                            ),
                          ),
                          Column(
                            children: [
                              Text("min",
                                  style: TextStyle(
                                      color: Colors.grey[300], fontSize: 14)),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text("${cwData.temp_min.round()}\u00B0",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(
                          width: double.maxFinite,
                          height: 100,
                          child: StreamBuilder(
                            stream: fwStream.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<ForecastWeatherModel>? fwDays =
                                    snapshot.data;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return showDayWheater(fwDays![index]);
                                  },
                                );
                              } else {
                                return Center(
                                    child: JumpingDotsProgressIndicator(
                                        milliseconds: 100,
                                        color: Colors.white,
                                        fontSize: 50,
                                        numberOfDots: 5));
                              }
                            },
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text("wind speed",
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14)),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text("${cwData.windSpeed} m/s",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 1,
                                height: 30,
                                color: Colors.grey[700],
                              ),
                            ),
                            Column(
                              children: [
                                Text("sunrise",
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14)),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text("$sunrise",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 1,
                                height: 30,
                                color: Colors.grey[700],
                              ),
                            ),
                            Column(
                              children: [
                                Text("sunset",
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14)),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text("$sunset",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 1,
                                height: 30,
                                color: Colors.grey[700],
                              ),
                            ),
                            Column(
                              children: [
                                Text("humidity",
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14)),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text("${cwData.humidity} %",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("sssss"))) as Widget;
            } else {
              return Center(
                  child: JumpingDotsProgressIndicator(
                      milliseconds: 100,
                      color: Colors.blueAccent,
                      fontSize: 200,
                      numberOfDots: 5));
            }
          },
        ));
  }

  SizedBox showDayWheater(ForecastWeatherModel fwDay) {
    Image weatherDayImg = Image.network(
      "http://openweathermap.org/img/wn/${fwDay.icon}.png",
      color: Colors.white,
    );
    return SizedBox(
      width: 70,
      height: 80,
      child: Card(
        color: Colors.white10,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(fwDay.datetime,
                  style: TextStyle(color: Colors.grey[300], fontSize: 12)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1),
              child: weatherDayImg,
            ),
            Text("${fwDay.temp.round()}\u00B0",
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
