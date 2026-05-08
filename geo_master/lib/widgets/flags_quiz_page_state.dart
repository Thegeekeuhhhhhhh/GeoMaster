import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/models/country.dart';
import 'package:geo_master/pages/flags_quiz_page.dart';
import 'package:geo_master/services/country_service.dart';
import 'package:geo_master/widgets/auth_gate.dart';

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

  void _loadCountries() {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = CountryService.memory ?? [];
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
    final pool = List<Country>.from(_allCountries.where((c) => c.unMember))
      ..shuffle(_random);
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
    _choices = [...others.take(7), _current]..shuffle(_random);
  }

  void _selectAnswer(int index) {
    if (_answered) {
      return;
    }
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (_choices[index].cca3 == _current.cca3) {
        _score++;
      }
    });
  }

  Future<void> _next() async {
    if (_currentIndex < _quizPool.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = null;
        _buildChoices();
      });
    } else {
      await saveScoreWithAuthGate(
        context: context,
        quizType: 'flags',
        score: _score,
        total: _quizPool.length,
      );
    }
  }

  Color _choiceColor(int index, ColorScheme colorScheme) {
    if (!_answered) {
      return colorScheme.surface;
    }
    if (_choices[index].cca3 == _current.cca3)
      return Colors.green.withOpacity(0.15);
    if (index == _selectedAnswer) {
      return Colors.red.withOpacity(0.1);
    }
    return colorScheme.surface;
  }

  Color _choiceBorderColor(int index, ColorScheme colorScheme) {
    if (!_answered) {
      return colorScheme.outlineVariant;
    }
    if (_choices[index].cca3 == _current.cca3) {
      return Colors.green.shade700;
    }
    if (index == _selectedAnswer) {
      return Colors.red.shade700;
    }
    return colorScheme.outlineVariant;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.quizTitle,
          style: TextStyle(
            color: colorScheme.primary,
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
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? _buildLoading(colorScheme)
          : _error != null
          ? _buildError(colorScheme)
          : _buildQuiz(colorScheme),
    );
  }

  Widget _buildLoading(ColorScheme colorScheme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.loading,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 15,
          ),
        ),
      ],
    ),
  );

  Widget _buildError(ColorScheme colorScheme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⚠️', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _loadCountries, child: Text(l10n.retry)),
      ],
    ),
  );

  Widget _buildQuiz(ColorScheme colorScheme) {
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
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.score}: $_score',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Flag image
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.08),
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
                  if (progress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                },
                errorBuilder: (_, _, _) => const Center(
                  child: Text('🏳️', style: TextStyle(fontSize: 64)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            l10n.quizQuestion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final itemHeight = 60.0;
              final rows = (_choices.length / 2).ceil();
              final totalHeight = rows * itemHeight + (rows - 1) * 12;

              return SizedBox(
                height: totalHeight,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: constraints.maxWidth / 2 / itemHeight,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _choices.asMap().entries.map((entry) {
                    final i = entry.key;
                    final country = entry.value;
                    final isCorrect = country.cca3 == _current.cca3;
                    return GestureDetector(
                      onTap: () => _selectAnswer(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _choiceColor(i, colorScheme),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _choiceBorderColor(i, colorScheme),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          country.nameIn(widget.language),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _answered && isCorrect
                                ? Colors.green.shade700
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const Spacer(),

          if (_answered)
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
