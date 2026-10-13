/// Calendario della natura: ogni giorno il bambino segna che tempo fa e cosa
/// ha visto fuori. Nessuna serie di giorni da non rompere, nessun premio:
/// il calendario è un quaderno di osservazioni, si guarda e se ne parla.
library;

import '../l10n/app_localizations.dart';

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

/// Dove vive la famiglia: decide quale suggerimento stagionale dare. La lingua
/// non basta (lo spagnolo vale per Madrid e per Santiago), quindi è
/// un'impostazione della famiglia, dedotta all'inizio dalla regione del dispositivo.
enum Hemisphere {
  north,
  south,
  equator;

  /// Paesi (ISO 3166) dove gennaio è estate.
  static const _south = {
    'AR', 'AU', 'BO', 'BR', 'BW', 'CL', 'LS', 'MG', 'MW', 'MZ', //
    'NA', 'NZ', 'PE', 'PY', 'SZ', 'UY', 'ZA', 'ZM', 'ZW', 'AO', 'FK',
  };

  /// Paesi vicini all'equatore: pioggia e secco invece delle quattro stagioni.
  static const _equator = {
    'BI', 'BN', 'CD', 'CF', 'CG', 'CI', 'CM', 'CO', 'CR', 'EC', 'ET', 'GA', 'GF', 'GH', //
    'GQ', 'GY', 'ID', 'KE', 'KI', 'LK', 'LR', 'MV', 'MY', 'NG', 'NR', 'PA', 'PG', 'PH', //
    'RW', 'SB', 'SC', 'SG', 'SL', 'SO', 'SR', 'SS', 'ST', 'TG', 'BJ', 'TL', 'TV', 'TZ', 'UG', 'VE',
  };

  /// Il valore iniziale dalla regione del dispositivo. Senza regione: nord,
  /// e il genitore può cambiarlo.
  static Hemisphere fromRegion(String? countryCode) {
    final c = countryCode?.toUpperCase();
    if (_south.contains(c)) return south;
    if (_equator.contains(c)) return equator;
    return north;
  }

  static Hemisphere? byName(String? name) => values.asNameMap()[name];
}

/// Il mese dei suggerimenti stagionali (scritti per il nord): al sud le
/// stagioni sono spostate di sei mesi, quindi gennaio usa il testo di luglio.
/// Vicino all'equatore non si usa: vedi [equatorTip].
int seasonalMonth(int month, Hemisphere h) => h == Hemisphere.south ? (month + 5) % 12 + 1 : month;

/// Quanti suggerimenti ci sono per chi vive vicino all'equatore.
const equatorTipCount = 8;

/// Il suggerimento per l'equatore (1…[equatorTipCount]): non dipende dal mese,
/// cambia ogni lunedì.
int equatorTip(DateTime day) {
  final days = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  // Il giorno 0 (1/1/1970) era giovedì: +3 fa iniziare la settimana di lunedì.
  return (days + 3) ~/ 7 % equatorTipCount + 1;
}

/// Il suggerimento del compagno per il calendario di [month], nell'emisfero
/// della famiglia. Vicino all'equatore conta la settimana di [today], non il mese.
String natureTip(AppLocalizations l, Hemisphere h, {required DateTime month, required DateTime today}) =>
    h == Hemisphere.equator ? l.natureEquatorTip('e${equatorTip(today)}') : l.natureMonthTip('m${seasonalMonth(month.month, h)}');
