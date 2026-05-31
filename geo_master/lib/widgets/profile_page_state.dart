import 'package:flutter/material.dart';
import 'package:geo_master/pages/profile_page.dart';
import 'package:geo_master/services/score_service.dart';
import '../services/auth_service.dart';

class ProfilePageState extends State<ProfilePage> {
  List<BestScore> _bestScores = [];
  List<ScoreEntry> _history = [];
  bool _loading = true;

  static const Map<String, String> _quizLabels = {
    'flags': '🏳️  Flags of the World',
    'capitals': '🏛️  World Capitals',
    'states': '🗺️  US States',
    'countries': '🌍  Countries game',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final best = await ScoreService.fetchBestScores();
    final history = await ScoreService.fetchHistory();
    setState(() {
      _bestScores = best;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text('Sign out', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // User info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.onPrimary.withOpacity(
                            0.15,
                          ),
                          radius: 28,
                          child: Icon(
                            Icons.person,
                            color: colorScheme.onPrimary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explorer',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AuthService.currentUser?.email ?? '',
                                style: TextStyle(
                                  color: colorScheme.onPrimary.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Best scores
                  Text(
                    'Best Scores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_bestScores.isEmpty)
                    Text(
                      'No scores yet, complete a quiz first !',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    )
                  else
                    ..._bestScores.map((s) => _BestScoreCard(score: s)),

                  const SizedBox(height: 28),

                  // History
                  Text(
                    'Recent Attempts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_history.isEmpty)
                    Text(
                      'No attempts yet.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    )
                  else
                    ..._history
                        .take(20)
                        .map(
                          (e) => _HistoryTile(
                            entry: e,
                            label: _quizLabels[e.quizType] ?? e.quizType,
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

class _BestScoreCard extends StatelessWidget {
  final BestScore score;

  static const Map<String, String> _labels = {
    'flags': '🏳️  Flags of the World',
    'states': '🗺️  US States',
    'capitals': '🏛️  World Capitals',
  };

  const _BestScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = score.bestScore / score.total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labels[score.quizType] ?? score.quizType,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      pct >= 0.8
                          ? const Color(0xFF22c55e)
                          : pct >= 0.5
                          ? const Color(0xFFf59e0b)
                          : const Color(0xFFef4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${score.bestScore}/${score.total}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ScoreEntry entry;
  final String label;

  const _HistoryTile({required this.entry, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (entry.score / entry.total * 100).round();
    final date =
        '${entry.playedAt.day}/${entry.playedAt.month}/${entry.playedAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}/${entry.total} ($pct%)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: pct >= 80
                  ? const Color(0xFF22c55e)
                  : pct >= 50
                  ? const Color(0xFFf59e0b)
                  : const Color(0xFFef4444),
            ),
          ),
        ],
      ),
    );
  }
}
