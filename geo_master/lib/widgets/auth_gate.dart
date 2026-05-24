import 'package:flutter/material.dart';
import '../pages/auth_page.dart';
import '../services/auth_service.dart';
import '../services/score_service.dart';

Future<bool> saveScoreWithAuthGate({
  required BuildContext context,
  required String quizType,
  required int score,
  required int total,
}) async {
  if (!context.mounted) {
    return false;
  }

  final cs = Theme.of(context).colorScheme;
  final ratio = score / total;

  final scoreColor = ratio >= 0.8
      ? const Color(0xFF22c55e)
      : ratio >= 0.5
      ? const Color(0xFFf59e0b)
      : cs.error;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: cs.surface,
      title: Text(
        score == total ? 'Perfect score! 🎉' : 'Quiz Over!',
        style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You got $score out of $total.',
            style: TextStyle(fontSize: 16, color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: cs.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(scoreColor),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Continue'),
        ),
      ],
    ),
  );

  if (!context.mounted) {
    return false;
  }

  if (AuthService.isLoggedIn) {
    await ScoreService.saveScore(
      quizType: quizType,
      score: score,
      total: total,
    );
    return true;
  }

  final didLogin = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final scs = Theme.of(sheetContext).colorScheme;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scs.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Save your score?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $score out of $total.\nSign in to save your progress.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scs.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(sheetContext, false);
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthPage(isModal: false),
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context, result ?? false);
                  }

                  // _submitOAuth(AuthService.signInWithGoogle);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scs.primary,
                  foregroundColor: scs.onPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign In / Sign Up',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext, false),
              child: Text(
                'Skip for now',
                style: TextStyle(color: scs.onSurface.withOpacity(0.4)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );

  if (didLogin == true && AuthService.isLoggedIn) {
    await ScoreService.saveScore(
      quizType: quizType,
      score: score,
      total: total,
    );
  }

  return true;
}
