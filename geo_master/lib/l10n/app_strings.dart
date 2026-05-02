import '../enums/app_language.dart';

class AppStrings {
  // Common
  final String soon;
  final String tagline;
  final String welcomeTitle;
  final String welcomeSubtitle;

  // Home
  final String topicsHeader;
  final String flagsTitle;
  final String flagsDesc;
  final String capitalsTitle;
  final String capitalsDesc;
  final String continentsTitle;
  final String continentsDesc;

  // Quiz
  final String quizTitle;
  final String quizQuestion;
  final String score;
  final String next;
  final String seeResults;
  final String loading;
  final String retry;
  final String doneTitle;
  final String scored;
  final String outOf;
  final String backHome;
  final String playAgain;

  const AppStrings({
    required this.soon,
    required this.tagline,
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.topicsHeader,
    required this.flagsTitle,
    required this.flagsDesc,
    required this.capitalsTitle,
    required this.capitalsDesc,
    required this.continentsTitle,
    required this.continentsDesc,
    required this.quizTitle,
    required this.quizQuestion,
    required this.score,
    required this.next,
    required this.seeResults,
    required this.loading,
    required this.retry,
    required this.doneTitle,
    required this.scored,
    required this.outOf,
    required this.backHome,
    required this.playAgain,
  });

  factory AppStrings.of(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.french:
        return _fr;
      case AppLanguage.spanish:
        return _es;
      case AppLanguage.german:
        return _de;
      case AppLanguage.portuguese:
        return _pt;
      case AppLanguage.english:
        return _en;
    }
  }

  static const _en = AppStrings(
    soon: 'Soon',
    tagline: 'Explore the world, one quiz at a time.',
    welcomeTitle: 'Welcome, Explorer!',
    welcomeSubtitle: 'Start a topic below to begin your journey.',
    topicsHeader: 'Topics',
    flagsTitle: 'Flags of the World',
    flagsDesc: 'Can you match the flag to its country?',
    capitalsTitle: 'World Capitals',
    capitalsDesc: 'Test your knowledge of capital cities.',
    continentsTitle: 'Continents & Oceans',
    continentsDesc: 'Learn the major landmasses and seas.',
    quizTitle: 'Flags of the World',
    quizQuestion: 'Which country does this flag belong to?',
    score: 'Score',
    next: 'Next Flag →',
    seeResults: 'See Results 🎉',
    loading: 'Loading countries…',
    retry: 'Retry',
    doneTitle: 'Quiz Complete! 🎉',
    scored: 'You scored',
    outOf: 'out of',
    backHome: 'Back to Home',
    playAgain: 'Play Again',
  );

  static const _fr = AppStrings(
    soon: 'Bientôt',
    tagline: 'Explore le monde, un quiz à la fois.',
    welcomeTitle: 'Bienvenue, Explorateur !',
    welcomeSubtitle: 'Commence un sujet ci-dessous pour partir à l\'aventure.',
    topicsHeader: 'Sujets',
    flagsTitle: 'Drapeaux du Monde',
    flagsDesc: 'Sauras-tu associer le drapeau à son pays ?',
    capitalsTitle: 'Capitales du Monde',
    capitalsDesc: 'Teste tes connaissances sur les capitales.',
    continentsTitle: 'Continents & Océans',
    continentsDesc: 'Apprends les grandes terres et les mers.',
    quizTitle: 'Drapeaux du Monde',
    quizQuestion: 'À quel pays appartient ce drapeau ?',
    score: 'Score',
    next: 'Drapeau suivant →',
    seeResults: 'Voir les résultats 🎉',
    loading: 'Chargement des pays…',
    retry: 'Réessayer',
    doneTitle: 'Quiz terminé ! 🎉',
    scored: 'Tu as obtenu',
    outOf: 'sur',
    backHome: 'Retour à l\'accueil',
    playAgain: 'Rejouer',
  );

  static const _es = AppStrings(
    soon: 'Próximamente',
    tagline: 'Explora el mundo, un quiz a la vez.',
    welcomeTitle: '¡Bienvenido, Explorador!',
    welcomeSubtitle: 'Empieza un tema abajo para comenzar tu viaje.',
    topicsHeader: 'Temas',
    flagsTitle: 'Banderas del Mundo',
    flagsDesc: '¿Puedes asociar la bandera con su país?',
    capitalsTitle: 'Capitales del Mundo',
    capitalsDesc: 'Pon a prueba tu conocimiento de capitales.',
    continentsTitle: 'Continentes y Océanos',
    continentsDesc: 'Aprende las grandes masas terrestres y mares.',
    quizTitle: 'Banderas del Mundo',
    quizQuestion: '¿A qué país pertenece esta bandera?',
    score: 'Puntuación',
    next: 'Siguiente →',
    seeResults: 'Ver resultados 🎉',
    loading: 'Cargando países…',
    retry: 'Reintentar',
    doneTitle: '¡Quiz completo! 🎉',
    scored: 'Obtuviste',
    outOf: 'de',
    backHome: 'Volver al inicio',
    playAgain: 'Jugar de nuevo',
  );

  static const _de = AppStrings(
    soon: 'Demnächst',
    tagline: 'Erkunde die Welt, ein Quiz nach dem anderen.',
    welcomeTitle: 'Willkommen, Entdecker!',
    welcomeSubtitle: 'Wähle unten ein Thema, um deine Reise zu beginnen.',
    topicsHeader: 'Themen',
    flagsTitle: 'Flaggen der Welt',
    flagsDesc: 'Kannst du die Flagge dem Land zuordnen?',
    capitalsTitle: 'Hauptstädte der Welt',
    capitalsDesc: 'Teste dein Wissen über Hauptstädte.',
    continentsTitle: 'Kontinente & Ozeane',
    continentsDesc: 'Lerne die großen Landmassen und Meere.',
    quizTitle: 'Flaggen der Welt',
    quizQuestion: 'Zu welchem Land gehört diese Flagge?',
    score: 'Punkte',
    next: 'Nächste →',
    seeResults: 'Ergebnisse 🎉',
    loading: 'Länder werden geladen…',
    retry: 'Erneut versuchen',
    doneTitle: 'Quiz abgeschlossen! 🎉',
    scored: 'Du hast',
    outOf: 'von',
    backHome: 'Zur Startseite',
    playAgain: 'Nochmal spielen',
  );

  static const _pt = AppStrings(
    soon: 'Em breve',
    tagline: 'Explora o mundo, um quiz de cada vez.',
    welcomeTitle: 'Bem-vindo, Explorador!',
    welcomeSubtitle: 'Começa um tema abaixo para iniciar a tua jornada.',
    topicsHeader: 'Tópicos',
    flagsTitle: 'Bandeiras do Mundo',
    flagsDesc: 'Consegues associar a bandeira ao seu país?',
    capitalsTitle: 'Capitais do Mundo',
    capitalsDesc: 'Testa os teus conhecimentos sobre capitais.',
    continentsTitle: 'Continentes e Oceanos',
    continentsDesc: 'Aprende as grandes massas terrestres e mares.',
    quizTitle: 'Bandeiras do Mundo',
    quizQuestion: 'A que país pertence esta bandeira?',
    score: 'Pontuação',
    next: 'Próxima →',
    seeResults: 'Ver resultados 🎉',
    loading: 'A carregar países…',
    retry: 'Tentar novamente',
    doneTitle: 'Quiz concluído! 🎉',
    scored: 'Obtiveste',
    outOf: 'de',
    backHome: 'Voltar ao início',
    playAgain: 'Jogar novamente',
  );
}
