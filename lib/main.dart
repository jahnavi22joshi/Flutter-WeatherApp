import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App ☁️',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String city = "Surat";
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  final String apiKey = "128dba5dfdac40d06fdcf25110fbd39e";

  Future<void> fetchWeather(String cityName) async {
    setState(() => isLoading = true);
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric";
        print("Fetching: $url");


    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          city = cityName;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("City not found ❌")),
        );
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error123: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city); // Load default city
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App ☁️")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter city",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      fetchWeather(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🌦 Weather Display
            isLoading
                ? const CircularProgressIndicator()
                : weatherData != null
                    ? Column(
                        children: [
                          Text(
                            city,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            "https://openweathermap.org/img/wn/${weatherData!['weather'][0]['icon']}@2x.png",
                            scale: 0.7,
                          ),
                          Text(
                            "${weatherData!['main']['temp']}°C",
                            style: const TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Humidity: ${weatherData!['main']['humidity']}%",
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            "Condition: ${weatherData!['weather'][0]['description']}",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : const Text("No data available"),
          ],
        ),
      ),
    );
  }
}
