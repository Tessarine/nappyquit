// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Toot\'N\'Tinkle';

  @override
  String get recordActivity => 'Tevékenység rögzítése';

  @override
  String get triedThePotty => 'Próbált bilire ülni';

  @override
  String get usedThePotty => 'Bilire ült';

  @override
  String get accident => 'Baleset';

  @override
  String get drankSomeWater => 'Ivott egy kis vizet';

  @override
  String get drankLotsOfWater => 'Sok vizet ivott';

  @override
  String get ateFood => 'Evett';

  @override
  String get nappy => 'Pelenka';

  @override
  String get pee => 'Pisi';

  @override
  String get poo => 'Kaki';

  @override
  String get both => 'Mindkettő';

  @override
  String get none => 'Egyik sem';

  @override
  String get toldParents => 'Szólt a szülőknek';

  @override
  String get wentByHimself => 'Egyedül ment';

  @override
  String get askedToSit => 'Le akart ülni';

  @override
  String get selectBodilyFunction => 'Mi történt?';

  @override
  String get selectInitiative => 'Hogyan történt?';

  @override
  String get selectDateAndTime => 'Dátum és időpont kiválasztása';

  @override
  String get cancel => 'Mégsem';

  @override
  String get save => 'Mentés';

  @override
  String get delete => 'Törlés';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get confirmDelete => 'Biztosan törölni szeretnéd ezt a bejegyzést?';

  @override
  String get noLogEntries => 'Még nincsenek rögzített tevékenységek';

  @override
  String get today => 'Ma';

  @override
  String get yesterday => 'Tegnap';

  @override
  String get help => 'Súgó';

  @override
  String get helpTitle => 'Hogyan használd a Toot\'N\'Tinkle alkalmazást';

  @override
  String get helpMainPage => 'Főoldal';

  @override
  String get helpMainPageDescription =>
      'A főoldal megjeleníti a Toot\'N\'Tinkle naplótörténeted. Minden bejegyzés tartalmazza az időt, tevékenység típusát, és a releváns részleteket. A jobb oldalon lévő gombokkal szerkeszthető vagy törölhető a bejegyzés.';

  @override
  String get helpButtons => 'Tevékenység gombok';

  @override
  String get helpButtonsDescription =>
      'Bármelyik alul lévő hét gombot lenyomva rögzíthetsz egy tevékenységet. Gyors lenyomás esetén az aktuális időponttal rögzítődik a tevékenység. Hosszabb lenyomás esetén dátum és időpont kiválasztása lehetséges.';

  @override
  String get helpActivityTypes => 'Tevékenység típusok';

  @override
  String get helpTriedThePotty =>
      'Próbált bilire ülni: Jelzi, amikor a gyermek próbálta használni a bílit';

  @override
  String get helpUsedThePotty => 'Bilire ült: Jelzi a sikeres bílihasználatot';

  @override
  String get helpAccident =>
      'Baleset: Jelzi, amikor a gyermek balesetet szenvedett';

  @override
  String get helpDrankSomeWater =>
      'Ivott egy kis vizet: Rögzíti, amikor a gyermek egy kis mennyiségű vizet ivott';

  @override
  String get helpDrankLotsOfWater =>
      'Sok vizet ivott: Rögzíti, amikor a gyermek nagy mennyiségű vizet ivott';

  @override
  String get helpAteFood => 'Evett: Rögzíti, amikor a gyermek evett';

  @override
  String get helpNappy =>
      'Pelenka: Rögzíti, amikor a gyermek pelenkát cserélték';

  @override
  String get helpSelections => 'Tevékenység kiválasztások';

  @override
  String get helpSelectionsDescription =>
      'Tevékenység kiválasztása után előfordulhat, hogy további részleteket kell megadni a történésről és a módjáról.';

  @override
  String get settings => 'Beállítások';

  @override
  String get language => 'Nyelv';
}
