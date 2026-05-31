import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geo_master/models/country.dart';
import 'package:geo_master/pages/countries_map_page.dart';
import 'package:geo_master/services/country_service.dart';
import 'package:geo_master/widgets/auth_gate.dart';
import 'package:geo_master/widgets/small_country_dot_painter.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class CountriesMapPageState extends State<CountriesMapPage>
    with SingleTickerProviderStateMixin {
  late List<Country> _shuffled;
  int _score = 0;
  List<Country> _countries = [];

  final Set<String> _correctCodes = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  String? _svgRaw;

  final Random _random = Random();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _quizFinished = false;

  var _iterationInitialization = true;

  @override
  void initState() {
    super.initState();
    var temp = CountryService.memory ?? [];
    _countries = temp.where((country) => country.unMember).toList();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shuffled = List.from(_countries)..shuffle(_random);
    _loadSvg();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Map<String, Offset> _smallCountryDots = {};
  Map<String, Rect> _countryBounds = {};

  Future<void> _loadSvg() async {
    var raw = await rootBundle.loadString('assets/world_map.svg');
    raw = _inlineCssToAttributes(raw);

    final bounds = _parseCountryBounds(raw);
    _countryBounds = bounds;

    setState(() {
      _svgRaw = raw;
      _smallCountryDots = _computeSmallCountryDots(bounds);
    });
  }

  Map<String, Rect> _parseCountryBounds(String svgRaw) {
    final doc = XmlDocument.parse(svgRaw);
    final paths = doc.findAllElements('path');
    final Map<String, Rect> bounds = {};

    for (final path in paths) {
      final id = path.getAttribute('id');
      final d = path.getAttribute('d');
      if (id == null || d == null) continue;

      try {
        final parsedPath = parseSvgPathData(d);
        final rect = parsedPath.getBounds();
        if (rect.isEmpty) continue;

        final key = id.toUpperCase();
        if (bounds.containsKey(key)) {
          bounds[key] = bounds[key]!.expandToInclude(rect);
        } else {
          bounds[key] = rect;
        }
      } catch (_) {}
    }

    return bounds;
  }

  static const double _smallCountryThreshold = 25.0;

  static const Set<String> _forceSmallCountries = {
    "AD",
    "AG",
    "BB",
    "BH",
    "BN",
    "BS",
    "CV",
    "CY",
    "DM",
    "FJ",
    "FM",
    "GD",
    "KI",
    "KM",
    "KN",
    "LC",
    "LI",
    "LU",
    "MC",
    "MH",
    "MT",
    "MU",
    "MV",
    "NR",
    "PW",
    "SB",
    "SC",
    "SG",
    "SM",
    "ST",
    "TL",
    "TO",
    "TT",
    "TV",
    "VA",
    "VC",
    "VU",
    "WS",
  };

  Map<String, Offset> _computeSmallCountryDots(Map<String, Rect> bounds) {
    final validCodes = _countries.map((c) => c.cca2.toUpperCase()).toSet();

    final Map<String, Offset> dots = {};
    for (final entry in bounds.entries) {
      if (!validCodes.contains(entry.key)) continue;

      final r = entry.value;
      if (_forceSmallCountries.contains(entry.key)) {
        dots[entry.key] = r.center;
      }
    }
    return dots;
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

  Country? get _currentTarget {
    for (final state in _shuffled) {
      if (!_correctCodes.contains(state.cca2.toLowerCase())) {
        return state;
      }
    }
    return null;
  }

  Future<void> _onTextChanged(String value) async {
    if (_quizFinished) {
      return;
    }

    final normalized = Country.normalize(value);

    final match = _countries.firstWhere(
      (s) =>
          (s.trimmedName == normalized ||
              (CountryService.countryNames[normalized] != null &&
                  CountryService.countryNames[normalized]!.cca2 == s.cca2)) &&
          !_correctCodes.contains(s.cca2.toLowerCase()),
      orElse: () => Country(
        flagLink: '',
        countryName: '',
        internetExtensions: <String>[],
        cca3: '',
        unMember: false,
        capital: [],
        borders: [],
        area: 0,
        iddRoot: '',
        iddSuffixes: [],
        translations: <String, String>{},
        trimmedName: '',
        cca2: '',
      ),
    );

    if (match.cca2.isNotEmpty) {
      setState(() {
        _score++;
        _correctCodes.add(match.cca2.toLowerCase());
        _textController.clear();
      });

      if (_correctCodes.length == _countries.length) {
        final close = await saveScoreWithAuthGate(
          context: context,
          quizType: 'states',
          score: _score,
          total: _countries.length,
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
    if (_svgRaw == null) {
      return '';
    }
    var svg = _svgRaw!;

    if (_iterationInitialization) {
      for (final state in _countries) {
        final code = state.cca2.toUpperCase();
        final isCorrect = _correctCodes.contains(state.cca2.toLowerCase());

        String fill;

        if (isCorrect) {
          fill = '#22c55e';
        } else {
          fill = '#D0D0D0';
        }

        svg = svg.replaceFirst(
          'id="$code" fill="#D0D0D0"',
          'id="$code" fill="$fill"',
        );
        svg = svg.replaceFirst('id="$code" />', 'id="$code" fill="$fill" />');
      }

      _svgRaw = svg;
      _iterationInitialization = false;
    } else {
      for (final state in _correctCodes.toList()) {
        final code = state.toUpperCase();

        svg = svg.replaceFirst(
          'id="$code" fill="#D0D0D0"',
          'id="$code" fill="#22c55e"',
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
    final progress =
        _correctCodes.length / (_countries.isEmpty ? 1 : _countries.length);
    final currentTarget = _currentTarget;
    final _svgViewBoxSize = const Size(1009.6727, 665.96301);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Countries of the world',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score / ${_countries.length}',
                style: const TextStyle(color: Color(0xFF555555), fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _quizFinished
                  ? null
                  : () async {
                      final missedCountries = _countries
                          .where(
                            (country) => !_correctCodes.contains(
                              country.cca2.toLowerCase(),
                            ),
                          )
                          .toList();

                      missedCountries.sort(
                        (a, b) => a.countryName.compareTo(b.countryName),
                      );

                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Countries you missed'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: missedCountries.isEmpty
                                ? const Text('You guessed them all!')
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: missedCountries.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          missedCountries[index].countryName,
                                        ),
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
                        total: _countries.length,
                      );

                      if (!mounted) {
                        return;
                      }

                      if (close) {
                        Navigator.pop(context);
                      }

                      setState(() => _quizFinished = true);
                    },
              child: const Text(
                'Give Up',
                style: TextStyle(
                  color: Color(0xFFC62828),
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
                    backgroundColor: const Color(0xFFDDDDDD),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1A73E8)),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _legendDot(const Color(0xFF3b82f6)),
                        const SizedBox(width: 4),
                        const Text(
                          'Next target',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _legendDot(const Color(0xFF22c55e)),
                        const SizedBox(width: 4),
                        const Text(
                          'Guessed',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
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
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A237E)),
                  )
                : AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) {
                      final svg = _buildPulsingSvg();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final scaleX =
                                constraints.maxWidth / _svgViewBoxSize.width;
                            final scaleY =
                                constraints.maxHeight / _svgViewBoxSize.height;
                            final scale = scaleX < scaleY ? scaleX : scaleY;

                            final renderedW = _svgViewBoxSize.width * scale;
                            final renderedH = _svgViewBoxSize.height * scale;

                            final offsetX =
                                (constraints.maxWidth - renderedW) / 2;
                            final offsetY =
                                (constraints.maxHeight - renderedH) / 2;

                            return Stack(
                              children: [
                                Positioned(
                                  left: offsetX,
                                  top: offsetY,
                                  width: renderedW,
                                  height: renderedH,
                                  child: SvgPicture.string(
                                    svg,
                                    fit: BoxFit.fill,
                                    alignment: Alignment.topLeft,
                                  ),
                                ),
                                CustomPaint(
                                  size: Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                  painter: SmallCountryDotPainter(
                                    dotPositions: _smallCountryDots,
                                    correctCodes: _correctCodes,
                                    pulseValue: _pulseAnim.value,
                                    svgOffset: Offset(offsetX, offsetY),
                                    svgScale: scale,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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
                        color: const Color(0xFF1A237E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Type the name of any country',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
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
                    hintText: 'e.g. France',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A237E),
                        width: 2,
                      ),
                    ),
                    suffixIcon: const Icon(
                      Icons.edit,
                      color: Color(0xFF888888),
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
