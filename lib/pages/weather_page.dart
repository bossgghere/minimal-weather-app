import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minimal_weather_app/models/weather_model.dart';
import 'package:minimal_weather_app/service/weather_service.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with TickerProviderStateMixin {
  final _weatherService = WeatherService('aa968771961702e1efaa84288107133a');
  Weather? _weather;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  Future<void> _fetchWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
      _controller.forward(); // trigger animation
    } catch (e) {
      print('Weather error: $e');
    }
  }

  String getWeatherAnimation(String? condition) {
    if (condition == null) return 'assets/sunny.json';
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'smoke':
      case 'fog':
      case 'haze':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'mist':
        return 'assets/mist.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
        ],
      ),
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _opacityAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _weather!.cityName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Lottie.asset(
                            getWeatherAnimation(_weather!.mainCondition),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 20),
                          ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOutBack,
                            ),
                            child: Text(
                              '${_weather!.temperature.round()}°C',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 60,
                                fontWeight: FontWeight.w300,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _weather!.mainCondition,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Opacity(
                            opacity: 0.7,
                            child: Text(
                              'Powered by OpenWeatherMap',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark ? Colors.white30 : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
