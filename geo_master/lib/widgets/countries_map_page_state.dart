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

  final Map<String, Country> _byTrimmedName = {};
  final Map<String, Country> _byShortName = {};

  void _buildLookups() {
    for (final c in _countries) {
      _byTrimmedName[c.trimmedName] = c;
      if (c.shortName.isNotEmpty) {
        _byShortName[c.shortName] = c;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    var temp = CountryService.memory ?? [];
    _countries = temp.where((country) => country.unMember).toList();
    _buildLookups();

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

  ColorScheme get _colorScheme => Theme.of(context).colorScheme;

  Map<String, Offset> _smallCountryDots = {};

  Future<void> _loadSvg() async {
    var raw = await rootBundle.loadString('assets/world_map.svg');
    raw = _inlineCssToAttributes(raw);

    final bounds = _parseCountryBounds(raw);

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

  String get _unguessedCountryHex {
    final c = _colorScheme.surfaceContainerHighest;
    return '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
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

    final Country? match =
        _byTrimmedName[normalized] ??
        _byShortName[normalized] ??
        CountryService.countryNames[normalized];

    if (match == null || _correctCodes.contains(match.cca2.toLowerCase())) {
      return;
    }

    setState(() {
      _score++;
      _correctCodes.add(match.cca2.toLowerCase());
      _textController.clear();
    });

    if (_correctCodes.length == _countries.length) {
      final close = await saveScoreWithAuthGate(
        context: context,
        quizType: 'countries',
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

  String _buildPulsingSvg() {
    if (_svgRaw == null) return '';
    var svg = _svgRaw!;

    final unguessedHex = _unguessedCountryHex;
    const stroke =
        'stroke="#000000" stroke-width="0.4" stroke-linejoin="round"';

    for (final state in _countries) {
      final code = state.cca2.toUpperCase();
      final isCorrect = _correctCodes.contains(state.cca2.toLowerCase());

      final fill = isCorrect ? '#22c55e' : unguessedHex;

      svg = svg.replaceFirst(
        'id="$code" fill="#D0D0D0"',
        'id="$code" fill="$fill" $stroke',
      );
      svg = svg.replaceFirst(
        'id="$code" />',
        'id="$code" fill="$fill" $stroke />',
      );
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
    final colorScheme = _colorScheme;
    final progress =
        _correctCodes.length / (_countries.isEmpty ? 1 : _countries.length);
    final currentTarget = _currentTarget;
    final _svgViewBoxSize = const Size(1009.6727, 665.96301);

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
          'Countries of the world',
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
                '$_score / ${_countries.length}',
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
                        quizType: 'countries',
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
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Type the name of any country',
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
                    hintText: 'e.g. France',
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
