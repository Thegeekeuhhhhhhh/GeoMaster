import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geo_master/models/us_state.dart';
import 'package:geo_master/pages/us_states_quiz_page.dart';
import 'package:geo_master/services/us_states_service.dart';
import 'package:geo_master/widgets/auth_gate.dart';

class USStatesQuizPageState extends State<USStatesQuizPage>
    with SingleTickerProviderStateMixin {
  late List<USState> _shuffled;
  int _score = 0;
  List<USState> _usStates = [];

  final Set<String> _correctCodes = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  String? _svgRaw;

  final Random _random = Random();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _quizFinished = false;

  late ColorScheme _colorScheme;

  @override
  void initState() {
    super.initState();
    _usStates = USStatesService.memory ?? [];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shuffled = List.from(_usStates)..shuffle(_random);
    _loadSvg();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSvg() async {
    var raw = await rootBundle.loadString('assets/us_map.svg');
    raw = _inlineCssToAttributes(raw);
    setState(() => _svgRaw = raw);
  }

  String _inlineCssToAttributes(String svg) {
    svg = svg.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    final styleRegex = RegExp(
      r'\.([\w]+)\s*\{[^}]*fill\s*:\s*(#[0-9a-fA-F]+)[^}]*\}',
    );

    final Map<String, String> classFills = {};

    for (final match in styleRegex.allMatches(svg)) {
      classFills[match.group(1)!] = match.group(2)!;
    }

    final defaultFill = classFills['state'] ?? '#D0D0D0';

    svg = svg.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');

    svg = svg.replaceAllMapped(RegExp(r'<path class="([\w\s]+)"'), (match) {
      final classes = match.group(1)!.trim().split(RegExp(r'\s+'));

      String fill = defaultFill;
      for (final cls in classes) {
        if (classFills.containsKey(cls) && cls != 'state') {
          fill = classFills[cls]!;
          break;
        }
      }

      return '<path fill="$fill" class="${classes.join(' ')}"';
    });

    return svg;
  }

  String get _unguessedStateHex {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? '#4A5568' : '#CBD5E0';
  }

  USState? get _currentTarget {
    for (final state in _shuffled) {
      if (!_correctCodes.contains(state.id.toLowerCase())) {
        return state;
      }
    }
    return null;
  }

  Future<void> _onTextChanged(String value) async {
    if (_quizFinished) return;

    final normalized = USState.normalize(value);

    final match = _usStates.firstWhere(
      (s) =>
          s.trimmedName == normalized &&
          !_correctCodes.contains(s.id.toLowerCase()),
      orElse: () => USState(
        id: '',
        name: '',
        capital: '',
        population: 0,
        trimmedName: '',
      ),
    );

    if (match.id.isNotEmpty) {
      setState(() {
        _score++;
        _correctCodes.add(match.id.toLowerCase());
        _textController.clear();
      });

      if (_correctCodes.length == _usStates.length) {
        final close = await saveScoreWithAuthGate(
          context: context,
          quizType: 'states',
          score: _score,
          total: _usStates.length,
        );

        if (!mounted) {
          return;
        }

        if (close) {
          Navigator.pop(context);
        }

        setState(() => _quizFinished = true);
      }
    }
  }

  String _buildPulsingSvg() {
    if (_svgRaw == null) return '';
    var svg = _svgRaw!;

    final unguessedHex = _unguessedStateHex;

    for (final state in _usStates) {
      final code = state.id.toLowerCase();
      final isCorrect = _correctCodes.contains(code);

      // Exception for washington D.C.
      if (code == 'dc') {
        final fill = isCorrect ? '#198A42' : unguessedHex;
        svg = svg.replaceFirst(
          'fill="#000000" class="$code"',
          'fill="$fill" class="$code"',
        );
        svg = svg.replaceFirst(
          '<circle class="state borders dccircle dc"',
          '<circle class="state borders dccircle dc" fill="$fill"',
        );
        svg = svg.replaceFirst(
          '<circle class="state borders dccircle dc" fill="#000000"',
          '<circle class="state borders dccircle dc" fill="$fill"',
        );
      } else {
        final fill = isCorrect ? '#22c55e' : unguessedHex;
        svg = svg.replaceFirst(
          'fill="#D0D0D0" class="$code"',
          'fill="$fill" class="$code"',
        );
      }
    }

    return svg;
  }

  Widget _legendDot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    final colorScheme = _colorScheme;

    final progress =
        _correctCodes.length / (_usStates.isEmpty ? 1 : _usStates.length);
    final currentTarget = _currentTarget;

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
          'US States',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score / ${_usStates.length}',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _quizFinished
                  ? null
                  : () async {
                      final missedStates = _usStates
                          .where(
                            (country) => !_correctCodes.contains(
                              country.id.toLowerCase(),
                            ),
                          )
                          .toList();

                      missedStates.sort((a, b) => a.id.compareTo(b.id));

                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Countries you missed'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: missedStates.isEmpty
                                ? const Text('You guessed them all!')
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: missedStates.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        dense: true,
                                        title: Text(missedStates[index].name),
                                      );
                                    },
                                  ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                      final close = await saveScoreWithAuthGate(
                        context: context,
                        quizType: 'states',
                        score: _score,
                        total: _usStates.length,
                      );

                      if (!mounted) {
                        return;
                      }

                      if (close) {
                        Navigator.pop(context);
                      }

                      setState(() => _quizFinished = true);
                    },
              child: Text(
                'Give Up',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
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
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _legendDot(colorScheme.tertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Next target',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _legendDot(Colors.green.shade500),
                        const SizedBox(width: 4),
                        Text(
                          'Guessed',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Score: $_score',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            flex: 5,
            child: _svgRaw == null
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, _) {
                      final svg = _buildPulsingSvg();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SvgPicture.string(svg, fit: BoxFit.contain),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                if (currentTarget != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Type the name of any US state',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  autofocus: true,
                  enabled: !_quizFinished,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'e.g. California',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.edit,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  onChanged: _onTextChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
