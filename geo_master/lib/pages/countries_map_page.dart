import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import 'package:geo_master/widgets/countries_map_page_state.dart';

class CountriesMapPage extends StatefulWidget {
  final AppLanguage language;

  const CountriesMapPage({super.key, required this.language});

  @override
  State<CountriesMapPage> createState() => CountriesMapPageState();
}
