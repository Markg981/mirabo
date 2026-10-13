/// Calendario della natura: ogni giorno il bambino segna che tempo fa e cosa
/// ha visto fuori. Nessuna serie di giorni da non rompere, nessun premio:
/// il calendario è un quaderno di osservazioni, si guarda e se ne parla.
library;

enum Weather {
  sun('☀️'),
  clouds('☁️'),
  rain('🌧️'),
  snow('❄️'),
  wind('🌬️'),
  fog('🌫️');

  const Weather(this.emoji);
  final String emoji;
}

/// Le cose della natura che si possono segnare (fino a [NatureDay.maxSeen] al giorno).
enum NatureThing {
  leaf('🍂'),
  flower('🌸'),
  bird('🐦'),
  bug('🐞'),
  snail('🐌'),
  fruit('🍎'),
  mushroom('🍄'),
  rainbow('🌈'),
  moon('🌙');

  const NatureThing(this.emoji);
  final String emoji;
}

/// Un giorno del calendario di un bambino.
class NatureDay {
  const NatureDay({required this.profileId, required this.day, this.weather, this.seen = const {}});

  final int profileId;

  /// Solo la data (ora a mezzanotte).
  final DateTime day;
  final Weather? weather;
  final Set<NatureThing> seen;

  static const maxSeen = 3;

  bool get isEmpty => weather == null && seen.isEmpty;

  /// La chiave del giorno nel database: AAAA-MM-GG.
  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  NatureDay copyWith({Weather? weather, bool clearWeather = false, Set<NatureThing>? seen}) => NatureDay(
        profileId: profileId,
        day: day,
        weather: clearWeather ? null : (weather ?? this.weather),
        seen: seen ?? this.seen,
      );

  /// Tocca una cosa vista: la toglie se c'era, la aggiunge se c'è posto.
  NatureDay toggle(NatureThing t) {
    if (seen.contains(t)) return copyWith(seen: {...seen}..remove(t));
    if (seen.length >= maxSeen) return this;
    return copyWith(seen: {...seen, t});
  }

  Map<String, Object?> toRow() => {
        'profile_id': profileId,
        'day': key(day),
        'weather': weather?.name,
        'seen': seen.map((t) => t.name).join(','),
      };

  factory NatureDay.fromRow(Map<String, Object?> r) => NatureDay(
        profileId: r['profile_id'] as int,
        day: DateTime.parse(r['day'] as String),
        weather: switch (r['weather']) { final String w => Weather.values.byName(w), _ => null },
        seen: (r['seen'] as String? ?? '').split(',').where((s) => s.isNotEmpty).map(NatureThing.values.byName).toSet(),
      );
}

/// Il riassunto di un mese: quanti giorni per tempo e quante volte ogni cosa
/// vista. Sono osservazioni da guardare insieme, non punti.
class NatureMonth {
  NatureMonth(this.days);
  final List<NatureDay> days;

  Map<Weather, int> get weather => {
        for (final w in Weather.values)
          if (days.where((d) => d.weather == w).length case final n when n > 0) w: n,
      };

  Map<NatureThing, int> get seen => {
        for (final t in NatureThing.values)
          if (days.where((d) => d.seen.contains(t)).length case final n when n > 0) t: n,
      };

  /// Giorni del mese con almeno un'osservazione.
  int get observed => days.where((d) => !d.isEmpty).length;
}

/// Quanti giorni ha il mese di [d].
int daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;
