import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import 'package:geo_master/widgets/capitals_quiz_page_state.dart';

class CapitalsQuizPage extends StatefulWidget {
  final AppLanguage language;
  const CapitalsQuizPage({super.key, required this.language});

  @override
  State<CapitalsQuizPage> createState() => CapitalsQuizPageState();
}
