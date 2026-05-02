import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import 'package:geo_master/widgets/flags_quiz_page_state.dart';

class FlagsQuizPage extends StatefulWidget {
  final AppLanguage language;
  const FlagsQuizPage({super.key, required this.language});

  @override
  State<FlagsQuizPage> createState() => FlagsQuizPageState();
}
