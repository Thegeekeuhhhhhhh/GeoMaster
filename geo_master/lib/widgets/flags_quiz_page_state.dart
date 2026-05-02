import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/models/country.dart';
import 'package:geo_master/pages/flags_quiz_page.dart';
import 'package:geo_master/services/country_service.dart';

class FlagsQuizPageState extends State<FlagsQuizPage> {
  bool _loading = true;
  String? _error;

  List<Country> _allCountries = [];
  List<Country> _quizPool = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  List<Country> _choices = [];

  final Random _random = Random();
  static const int _quizSize = 20;

  late final l10n = AppStrings.of(widget.language);

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await CountryService.fetchAll();
      setState(() {
        _allCountries = all;
        _loading = false;
      });
      _startNewGame();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _startNewGame() {
    final pool = List<Country>.from(_allCountries)..shuffle(_random);
    setState(() {
      _quizPool = pool.take(_quizSize).toList();
      _currentIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
    });
    _buildChoices();
  }

  Country get _current => _quizPool[_currentIndex];

  void _buildChoices() {
    final others = _allCountries.where((c) => c.cca3 != _current.cca3).toList()
      ..shuffle(_random);
    _choices = [...others.take(3), _current]..shuffle(_random);
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (_choices[index].cca3 == _current.cca3) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _quizPool.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = null;
        _buildChoices();
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.doneTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${l10n.scored} $_score ${l10n.outOf} ${_quizPool.length}.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.backHome),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: Text(l10n.playAgain),
          ),
        ],
      ),
    );
  }

  Color _choiceColor(int index) {
    if (!_answered) return Colors.white;
    if (_choices[index].cca3 == _current.cca3) return const Color(0xFFE8F5E9);
    if (index == _selectedAnswer) return const Color(0xFFFFEBEE);
    return Colors.white;
  }

  Color _choiceBorderColor(int index) {
    if (!_answered) return const Color(0xFFDDDDDD);
    if (_choices[index].cca3 == _current.cca3) return const Color(0xFF2E7D32);
    if (index == _selectedAnswer) return const Color(0xFFC62828);
    return const Color(0xFFDDDDDD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.quizTitle,
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${_quizPool.length}',
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _buildQuiz(),
    );
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: Color(0xFF1A237E)),
        const SizedBox(height: 16),
        Text(
          l10n.loading,
          style: const TextStyle(color: Color(0xFF555555), fontSize: 15),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⚠️', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF666666)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _loadCountries, child: Text(l10n.retry)),
      ],
    ),
  );

  Widget _buildQuiz() {
    final progress = (_currentIndex + 1) / _quizPool.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFDDDDDD),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1A73E8)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.score}: $_score',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF555555), fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Flag image retrieved from internet
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _current.flagLink,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('🏳️', style: TextStyle(fontSize: 64)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            l10n.quizQuestion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF444444),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // Answer choices rendered in the selected language
          ..._choices.asMap().entries.map((entry) {
            final i = entry.key;
            final country = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectAnswer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: _choiceColor(i),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _choiceBorderColor(i), width: 2),
                  ),
                  child: Text(
                    country.nameIn(widget.language),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _answered && country.cca3 == _current.cca3
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF222222),
                    ),
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          if (_answered)
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _currentIndex < _quizPool.length - 1
                    ? l10n.next
                    : l10n.seeResults,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
