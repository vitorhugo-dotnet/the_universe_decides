import 'package:flutter/widgets.dart';

/// Minimal EN/PT strings for the hidden Entropy Drift screen, following the
/// same locale-check pattern already used for the privacy policy link on
/// AboutMeScreen rather than adding keys to every localized arb file for a
/// hidden, opt-in easter egg.
class EntropyDriftStrings {
  const EntropyDriftStrings._({required bool isPortuguese})
    : _isPortuguese = isPortuguese;

  factory EntropyDriftStrings.of(BuildContext context) {
    return EntropyDriftStrings._(
      isPortuguese: Localizations.localeOf(context).languageCode == 'pt',
    );
  }

  final bool _isPortuguese;

  String get score => _isPortuguese ? 'Pontuação' : 'Score';
  String get highScore => _isPortuguese ? 'Recorde' : 'High score';
  String get newHighScore =>
      _isPortuguese ? 'Novo recorde!' : 'New high score!';
  String get gameOverTitle => 'The universe has decided.';
  String get playAgain => _isPortuguese ? 'Jogar novamente' : 'Play again';
  String get backToApp => _isPortuguese ? 'Voltar' : 'Back';
}
