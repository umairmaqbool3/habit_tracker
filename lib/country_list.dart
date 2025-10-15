import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> fetchCountries() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? savedCountries = prefs.getStringList('countries');

  if (savedCountries != null && savedCountries.isNotEmpty) {
    print("Loaded ${savedCountries.length} countries from local storage");
    return savedCountries;
  } else {
    List<String> countries = await fetchCountriesfromApi();
    await prefs.setStringList('countries', countries);
    print("Saved ${countries.length} countries to local storage");
    return countries;
  }
}

Future<List<String>> fetchCountriesfromApi() async {
  final response = await http.get(
    Uri.parse('https://www.apicountries.com/countries'),
  );

  if (response.statusCode == 200) {
    // Decode the JSON response
    final List<dynamic> countriesJson = json.decode(response.body);

    // Extract only the 'name' field and ensure it's a string
    final List<String> countryList = countriesJson
        .map((country) => country['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    print("Fetched ${countryList.length} countries}");
    return countryList;
  } else {
    throw Exception('Failed to load countries. Status code: ${response.statusCode}');
  }
}
