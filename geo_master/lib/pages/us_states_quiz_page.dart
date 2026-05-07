import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import 'package:geo_master/widgets/us_states_quiz_page_state.dart';

class USStatesQuizPage extends StatefulWidget {
  final AppLanguage language;
  const USStatesQuizPage({super.key, required this.language});

  @override
  State<USStatesQuizPage> createState() => USStatesQuizPageState();
}
