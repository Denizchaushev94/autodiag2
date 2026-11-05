import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
// ---------- език ----------
final lang = ValueNotifier<String>(
    PlatformDispatcher.instance.locale.languageCode == 'bg' ? 'bg' : 'en');
const _S = <String, List<String>>{
  'scan': ['Грешки', 'Codes'],
  'live': ['На живо', 'Live'],
  'hist': ['История', 'History'],
  'search': ['Търси адаптер', 'Find adapter'],
  'connecting': ['Свързване…', 'Connecting…'],
  'connected': ['Свързан', 'Connected'],
  'disconnect': ['Прекъсни', 'Disconnect'],
  'read': ['Прочети грешки', 'Read codes'],
  'reading': ['Четене…', 'Reading…'],
  'none': ['Няма записани грешки', 'No stored codes'],
  'error': ['Грешка', 'Error'],
  'na': ['няма данни', 'no data'],
  'actions': ['Какво да направите', 'What you can do'],
  'noconn': ['Първо свържете адаптер от раздел „Грешки“', 'Connect an adapter in the Codes tab first'],
  'nohist': ['Още няма сканирания', 'No scans yet'],
  'unknown': ['Описанието на този код предстои да бъде добавено. Потърсете го в сервиз или в справочник.', 'The description for this code is not added yet. Check a repair manual or a workshop.'],
  'warn': ['Информацията е ориентировъчна. При съмнение за безопасност спрете и се консултирайте със сервиз.', 'Information is indicative. If safety is in doubt, stop and consult a workshop.'],
  'pick': ['Изберете параметри', 'Choose parameters'],
  'trans': ['Температурата на маслото в скоростната кутия не е стандартен OBD параметър и не се поддържа от всички коли.', 'Gearbox oil temperature is not a standard OBD parameter and is not supported by all cars.'],
  'ble': ['Поддържат се адаптери с Bluetooth LE.', 'Bluetooth LE adapters are supported.'],
  'demo': ['Демо режим (без кола)', 'Demo mode (no car)'],
  'garage': ['Гараж', 'Garage'],
  'nocar': ['Изберете автомобил', 'Select a car'],
  'nocarhint': ['По желание – за по-точни обяснения', 'Optional – for more accurate explanations'],
  'addcar': ['Добави кола', 'Add car'],
  'nocarsel': ['Без избрана кола', 'No car selected'],
  'nocars': ['Още няма добавени коли.\nДобавете кола, за да получавате обяснения според горивото и двигателя.', 'No cars yet.\nAdd a car to get explanations that match its fuel and engine.'],
  'edit': ['Редактирай', 'Edit'],
  'delete': ['Изтрий', 'Delete'],
  'delq': ['Да изтрием ли колата?', 'Delete this car?'],
  'cancel': ['Отказ', 'Cancel'],
  'make': ['Марка', 'Make'],
  'model': ['Модел', 'Model'],
  'year': ['Година на производство', 'Year of manufacture'],
  'fuel': ['Гориво', 'Fuel'],
  'engine': ['Двигател (по избор, напр. 2.0 TDI)', 'Engine (optional, e.g. 2.0 TDI)'],
  'km': ['Пробег, км (по избор)', 'Mileage, km (optional)'],
  'carname': ['Име (по избор)', 'Name (optional)'],
  'save': ['Запази', 'Save'],
  'fillreq': ['Изберете марка, година и гориво', 'Choose make, year and fuel'],
  'supnote': ['Показват се само параметрите, които колата поддържа.', 'Only parameters supported by the car are shown.'],
  'grp_eng': ['Двигател', 'Engine'],
  'grp_fuel': ['Гориво', 'Fuel'],
  'grp_exh': ['Изгорели газове и турбо', 'Exhaust and turbo'],
  'grp_el': ['Електрика', 'Electrical'],
  'stored': ['Запазени грешки', 'Stored faults'],
  'storedsub': ['Потвърдени грешки. Отстранете причината; след ремонт можете да ги изтриете.', 'Confirmed faults. Fix the cause; after repair you can clear them.'],
  'pending': ['Чакащи (временни)', 'Pending (temporary)'],
  'pendingsub': ['Засечени веднъж. Често са временни; ако се повторят, стават запазени. Можете да ги изтриете.', 'Detected once. Often temporary; if they repeat they become stored. You can clear them.'],
  'permanent': ['Постоянни грешки', 'Permanent faults'],
  'permsub': ['Не могат да се изтрият ръчно. Отстранете проблема или посетете сервиз – изчезват сами след ремонт и няколко цикъла на шофиране.', 'Cannot be cleared manually. Fix the problem or visit a workshop – they disappear on their own after repair and several drive cycles.'],
  'permnote': ['Не всички коли съобщават постоянни грешки.', 'Not all cars report permanent faults.'],
  'clear': ['Изтрий грешките', 'Clear codes'],
  'clrq': ['Да изтрием ли грешките?', 'Clear the codes?'],
  'clrinfo': ['Ще бъдат изтрити запазените и чакащите грешки, ще изгасне контролната лампа и ще се нулират данните за готовност на системите (нужни при годишен преглед).\n\nАко проблемът не е отстранен, грешките ще се върнат. Постоянните грешки не могат да се изтрият.\n\nИзтривайте само ако знаете причината или при еднократна грешка. Запалването да е включено, а двигателят загасен.', 'Stored and pending faults will be erased, the warning light will go off and the system readiness data will be reset (needed for inspection).\n\nIf the problem is not fixed, the faults will come back. Permanent faults cannot be cleared.\n\nClear only if you know the cause or for a one-off fault. Ignition on, engine off.'],
  'clearing': ['Изтриване…', 'Clearing…'],
  'cleared': ['Командата е изпълнена. Ако проблемът не е отстранен, грешките ще се върнат.', 'Command completed. If the problem is not fixed, the faults will return.'],
  'clearfail': ['Колата отказа изтриването. Включете запалването и загасете двигателя.', 'The car refused to clear. Turn the ignition on and stop the engine.'],
  'persist': ['Ако грешката се върне след изтриване, проблемът е постоянен: отстранете причината или посетете сервиз.', 'If the code returns after clearing, the problem is persistent: fix the cause or visit a workshop.'],
  'log': ['Технически журнал', 'Technical log'],
  'copy': ['Копирай', 'Copy'],
  'copied': ['Копирано', 'Copied'],
  'clearlog': ['Изчисти', 'Clear'],
  'logempty': ['Журналът е празен. Свържете се с адаптер и после го отворете отново.', 'The log is empty. Connect to an adapter and open it again.'],
  'sev0': ['Информативно', 'Informational'],
  'sev1': ['Проверете скоро', 'Check soon'],
  'sev2': ['Спешно – карайте внимателно или спрете', 'Urgent – drive carefully or stop'],
  'about': ['За приложението', 'About'],
  'privacy': ['Политика за поверителност', 'Privacy policy'],
  'terms': ['Условия за ползване', 'Terms of use'],
  'supported': ['Поддържани автомобили и адаптери', 'Supported cars and adapters'],
  'contact': ['Контакт', 'Contact'],
  'licenses': ['Лицензи на библиотеки', 'Open-source licenses'],
  'version': ['Версия', 'Version'],
  'tagline': ['Автодиагностика на български', 'Car diagnostics made clear'],
  'welcome': ['Добре дошли', 'Welcome'],
  'accept': ['Разбирам и приемам', 'I understand'],
  'warn2': ['TORQIQ показва грешки от автомобила и обяснява какво може да означават. Информацията е ориентировъчна и не заменя преглед от механик. Не използвайте телефона, докато шофирате.', 'TORQIQ reads fault codes from your vehicle and explains what they may mean. The information is indicative and does not replace a mechanic. Do not use your phone while driving.'],
  'hint': ['Закачете адаптера в OBD порта, включете запалването и натиснете „Търси адаптер“.', 'Plug the adapter into the OBD port, turn the ignition on and tap "Find adapter".'],
};
String t(String k) => _S[k]![lang.value == 'bg' ? 0 : 1];
 
// ---------- обяснения: [bg, en] -> [заглавие, описание, действия, разделени с |] ----------
final Map<String, List<List<String>>> dtcDb = {
  'P0087': [
    ['Налягане в горивната рейка – твърде ниско', 'Системата за високо налягане отчита по-ниско налягане от заповяданото. Двигателят може да губи мощност, да „дърпа“ или да не запали.', 'Карайте само внимателно и на кратко разстояние – възможна е загуба на мощност|Проверете нивото на горивото и състоянието на горивния филтър|Помолете сервиз да провери помпата за ниско налягане, регулатора на налягане и за течове'],
    ['Fuel rail pressure too low', 'The high-pressure fuel system reads lower pressure than commanded. The engine may lose power, hesitate or fail to start.', 'Drive carefully and only a short distance – power loss is possible|Check the fuel level and the fuel filter condition|Ask a workshop to check the low-pressure pump, pressure regulator and leaks'],
  ],
  'P0101': [
    ['Разходомер на въздух (MAF) – извън диапазона', 'Показанията на сензора за масата на въздуха не съответстват на очакваното.', 'Обикновено може да се кара, с възможна по-малка мощност и по-голям разход|Проверете въздушния филтър и почистете MAF сензора със специален спрей|Проверете за теч във всмукателния тракт'],
    ['MAF sensor circuit range/performance', 'The mass air flow sensor reading does not match what the engine expects.', 'Usually drivable, with possible power loss and higher consumption|Check the air filter and clean the MAF sensor with a dedicated spray|Check for leaks in the intake system'],
  ],
  'P0171': [
    ['Бедна смес (банка 1)', 'Двигателят получава твърде много въздух или твърде малко гориво.', 'Обикновено може да се кара, но не го отлагайте за дълго|Проверете за всмукване на въздух (маркучи, уплътнения) и замърсен MAF сензор|Проверете налягането на горивото и инжекторите'],
    ['System too lean (bank 1)', 'The engine gets too much air or too little fuel.', 'Usually drivable, but do not delay for long|Check for air leaks (hoses, gaskets) and a dirty MAF sensor|Check fuel pressure and injectors'],
  ],
  'P0300': [
    ['Случайни или множество пропуски в запалването', 'Един или повече цилиндри не горят правилно. Ако контролната лампа мига, катализаторът е в опасност.', 'Ако лампата мига – спрете и не карайте|Проверете свещите, бобините и инжекторите|При нужда проверете за подсмукване на въздух и компресия'],
    ['Random/multiple cylinder misfire', 'One or more cylinders are not firing properly. If the warning light flashes, the catalytic converter is at risk.', 'If the light flashes – stop and do not drive|Check spark plugs, coils and injectors|If needed check for air leaks and compression'],
  ],
  'P0420': [
    ['Ефективност на катализатора под прага (банка 1)', 'Според сензорите катализаторът не чисти изгорелите газове достатъчно добре.', 'Обикновено може да се кара, но не го пренебрегвайте за дълго|Първо проверете за пропуски в запалването, теч в изгорелите газове и лямбда сондите|Катализаторът е последното, което се подменя, не първото'],
    ['Catalyst efficiency below threshold (bank 1)', 'According to the sensors the catalytic converter does not clean the exhaust well enough.', 'Usually drivable, but do not ignore it for long|First check for misfires, exhaust leaks and the oxygen sensors|The catalytic converter is the last part to replace, not the first'],
  ],
};
 
final sev = <String, int>{'P0087': 2, 'P0101': 1, 'P0171': 1, 'P0300': 2, 'P0420': 1};
Color sevColor(int v) => v >= 2 ? Colors.red : (v == 1 ? Colors.orange : Colors.blueGrey);
 
// ---------- Технически журнал ----------
final List<String> _logHead = [];
final List<String> _logTail = [];
void logAdd(String s) {
  final line = '${DateTime.now().toIso8601String().substring(11, 19)} $s';
  if (_logHead.length < 80) {
    _logHead.add(line);
    return;
  }
  _logTail.add(line);
  if (_logTail.length > 300) _logTail.removeAt(0);
}
 
String logText() => [..._logHead, if (_logTail.isNotEmpty) '... ...', ..._logTail].join('\n');
void logClear() {
  _logHead.clear();
  _logTail.clear();
}
 
// ---------- ELM327 по Bluetooth LE ----------
class Elm {
  final BluetoothDevice dev;
  BluetoothCharacteristic? wr, nt;
  final _buf = StringBuffer();
  Completer<String>? _c;
  StreamSubscription? _sub;
  Future<void> _last = Future.value();
  final bool demo;
  bool _dc = false;
  Elm(this.dev) : demo = false;
  Elm.demo()
      : dev = BluetoothDevice.fromId('00:00:00:00:00:00'),
        demo = true;
  String get name => demo ? 'Demo' : dev.platformName;
 
  Future<void> open() async {
    if (demo) return;
    await dev.connect(timeout: const Duration(seconds: 15));
    final svcs = await dev.discoverServices();
    logAdd('connect ${dev.platformName}');
    for (final s in svcs) {
      final chars = s.characteristics.map((c) {
        final p = c.properties;
        return '${c.uuid}[${p.notify ? 'N' : ''}${p.write ? 'W' : ''}${p.writeWithoutResponse ? 'w' : ''}]';
      }).join(' ');
      logAdd('svc ${s.uuid}: $chars');
    }
    for (final s in svcs) {
      final u = s.uuid.toString().toLowerCase();
      if (u == '1800' || u == '1801' || u == '180a') continue;
      BluetoothCharacteristic? n, w;
      for (final c in s.characteristics) {
        final p = c.properties;
        final canW = p.write || p.writeWithoutResponse;
        if (p.notify && canW) { n = c; w = c; break; }
        if (p.notify) n ??= c;
        if (canW) w ??= c;
      }
      if (n != null && w != null) { nt = n; wr = w; break; }
    }
    if (nt == null || wr == null) {
      logAdd('NO UART channel found');
      throw Exception('UART');
    }
    logAdd('uart notify=${nt!.uuid} write=${wr!.uuid}');
    await nt!.setNotifyValue(true);
    _sub = nt!.onValueReceived.listen((v) {
      _buf.write(String.fromCharCodes(v));
      final s = _buf.toString();
      if (s.contains('>')) {
        _buf.clear();
        _c?.complete(s.replaceAll('>', ''));
        _c = null;
      }
    });
    for (final c in ['ATZ', 'ATE0', 'ATL0', 'ATS0', 'ATH0', 'ATSP0']) {
      await send(c, ms: c == 'ATZ' ? 3000 : 1500);
    }
    await send('0100', ms: 10000);
  }
 
  Future<String> send(String cmd, {int ms = 4000}) {
    final done = _last.then((_) => _send(cmd, ms));
    _last = done.then((_) {}, onError: (_) {});
    return done;
  }
 
  Future<String> _send(String cmd, int ms) async {
    logAdd('> $cmd');
    String r;
    try {
      r = await _send0(cmd, ms);
    } catch (e) {
      logAdd('! $e');
      rethrow;
    }
    final one = r.replaceAll(RegExp(r'[\r\n]+'), ' | ').trim();
    logAdd('< ${one.isEmpty ? '(empty/timeout)' : one}');
    return r;
  }
 
  Future<String> _send0(String cmd, int ms) async {
    if (demo) {
      await Future.delayed(const Duration(milliseconds: 250));
      return _demo(cmd);
    }
    _buf.clear();
    final c = Completer<String>();
    _c = c;
    final w = wr!;
    await w.write(utf8.encode('$cmd\r'), withoutResponse: w.properties.writeWithoutResponse);
    return c.future.timeout(Duration(milliseconds: ms), onTimeout: () {
      _c = null;
      return _buf.toString();
    });
  }
 
  String _demo(String cmd) {
    final s = DateTime.now().millisecondsSinceEpoch / 1000.0;
    String hx(int x) => x.toRadixString(16).toUpperCase().padLeft(2, '0');
    String h(int pid, List<int> b) => '41 ${hx(pid)} ${b.map(hx).join(' ')}';
    List<int> w(num v) {
      final n = v.round();
      return [n >> 8, n & 255];
    }
    if (cmd == '04') { _dc = true; return '44'; }
    if (cmd == '03') return _dc ? '43 00' : '43 03 00 87 01 71 04 20';
    if (cmd == '07') return _dc ? '47 00' : '47 01 01 01';
    if (cmd == '0A') return '4A 01 04 20';
    if (cmd == 'ATRV') return '13.8V';
    if (cmd.startsWith('AT')) return 'OK';
    switch (cmd) {
      case '0100': return '41 00 FF FF FF FF';
      case '0120': return '41 20 FF FF FF FF';
      case '0140': return '41 40 FF FF FF FF';
      case '0160': return '41 60 FF FF FF FF';
      case '0180': return '41 80 00 00 00 00';
      case '0105': return h(0x05, [(128 + 4 * sin(s / 7)).round()]);
      case '015C': return h(0x5C, [(135 + 3 * sin(s / 5)).round()]);
      case '010B': return h(0x0B, [(45 + 20 * sin(s / 3)).round()]);
      case '010C': return h(0x0C, w((1800 + 200 * sin(s / 2)) * 4));
      case '010D': return h(0x0D, [(50 + 10 * sin(s / 4)).round()]);
      case '010F': return h(0x0F, [68]);
      case '0111': return h(0x11, [(56 + 10 * sin(s / 3)).round()]);
      case '0104': return h(0x04, [(100 + 20 * sin(s / 3)).round()]);
      case '010A': return h(0x0A, [100]);
      case '0123': return h(0x23, w(1500 + 100 * sin(s / 4)));
      case '0110': return h(0x10, w(520 + 60 * sin(s / 3)));
      case '012F': return h(0x2F, [158]);
      case '0106': return h(0x06, [(128 + 3 * sin(s / 3)).round()]);
      case '0107': return h(0x07, [131]);
      case '010E': return h(0x0E, [152]);
      case '0133': return h(0x33, [100]);
      case '0146': return h(0x46, [58]);
      case '015A': return h(0x5A, [(150 + 20 * sin(s / 3)).round()]);
      case '015E': return h(0x5E, w(160));
      case '015D': return h(0x5D, w(28672));
      case '0159': return h(0x59, w(1800 + 50 * sin(s / 4)));
      case '013C': return h(0x3C, w((520 + 40) * 10));
      case '013E': return h(0x3E, w((480 + 40) * 10));
      case '0178': return h(0x78, [0x07, ...w((420 + 30 * sin(s / 5) + 40) * 10), ...w((380 + 40) * 10), ...w((350 + 40) * 10), 0, 0]);
      case '017C': return h(0x7C, [0x03, ...w((320 + 40) * 10), ...w((300 + 40) * 10), 0, 0, 0, 0]);
      case '0124': return h(0x24, [...w(32768), 0, 0]);
      case '012C': return h(0x2C, [77]);
      case '0142': return h(0x42, w(14100));
      default: return 'NO DATA';
    }
  }
 
  Future<void> close() async {
    if (demo) return;
    await _sub?.cancel();
    try { await dev.disconnect(); } catch (_) {}
  }
}
 
Elm? elm;
Set<int>? supported;
final connected = ValueNotifier<bool>(false);
final lastCodes = ValueNotifier<List<String>?>(null);
 
List<String> parseDtc(String raw, [String hdr = '43']) {
  final sb = StringBuffer();
  for (var line in raw.toUpperCase().split(RegExp(r'[\r\n]+'))) {
    line = line.replaceAll(' ', '').replaceFirst(RegExp(r'^[0-9A-F]:'), '');
    if (line.isEmpty || line.length == 3 || !RegExp(r'^[0-9A-F]+$').hasMatch(line)) continue;
    sb.write(line);
  }
  final h = sb.toString();
  if (h.startsWith('7F')) return [];
  final i = h.indexOf(hdr);
  if (i < 0) return [];
  var d = h.substring(i + 2);
  if (d.length % 4 == 2) d = d.substring(2); // CAN: първият байт е брой грешки
  const kinds = 'PCBU';
  final out = <String>[];
  for (var k = 0; k + 4 <= d.length; k += 4) {
    final hi = int.parse(d.substring(k, k + 2), radix: 16);
    final lo = int.parse(d.substring(k + 2, k + 4), radix: 16);
    if (hi == 0 && lo == 0) continue;
    out.add('${kinds[hi >> 6]}${(hi >> 4) & 3}${(hi & 15).toRadixString(16)}${lo.toRadixString(16).padLeft(2, '0')}'.toUpperCase());
  }
  return out.toSet().toList();
}
 
double? pidVal(String raw, String pid, double Function(List<int>) f) {
  final h = raw.toUpperCase().replaceAll(RegExp(r'[^0-9A-F]'), '');
  final i = h.indexOf('41$pid');
  if (i < 0) return null;
  final d = h.substring(i + 4);
  final b = <int>[];
  for (var k = 0; k + 2 <= d.length && b.length < 9; k += 2) {
    b.add(int.parse(d.substring(k, k + 2), radix: 16));
  }
  if (b.isEmpty) return null;
  try { return f(b); } catch (_) { return null; }
}
 
Future<void> saveHist(List<String> stored, List<String> pending, List<String> perm) async {
  final p = await SharedPreferences.getInstance();
  final l = p.getStringList('hist') ?? [];
  l.insert(0, jsonEncode({'t': DateTime.now().toIso8601String(), 'c': stored, 'p': pending, 'x': perm, 'car': currentCar()?.title ?? '', 'fuel': currentCar()?.fuel ?? ''}));
  await p.setStringList('hist', l.take(10).toList());
}
 
// ---------- параметри на живо ----------
class Pid {
  final String id, q, grp, bg, en, unit;
  final int dec;
  final double Function(List<int>) f;
  Pid(this.id, this.grp, this.bg, this.en, this.unit, this.dec, this.f, {String? q}) : q = q ?? id;
  String get name => lang.value == 'bg' ? bg : en;
}
 
double _t10(List<int> b, int i) {
  final r = b[1 + 2 * i] * 256 + b[2 + 2 * i];
  if (r == 0) throw Exception('n/a');
  return r / 10 - 40;
}
 
final pids = <Pid>[
  Pid('05', 'eng', 'Температура на водата', 'Coolant temperature', '°C', 0, (b) => b[0] - 40.0),
  Pid('5C', 'eng', 'Температура на маслото', 'Engine oil temperature', '°C', 0, (b) => b[0] - 40.0),
  Pid('0C', 'eng', 'Обороти', 'Engine speed', 'rpm', 0, (b) => (b[0] * 256 + b[1]) / 4),
  Pid('0D', 'eng', 'Скорост', 'Speed', 'km/h', 0, (b) => b[0].toDouble()),
  Pid('04', 'eng', 'Натоварване на двигателя', 'Engine load', '%', 0, (b) => b[0] * 100 / 255),
  Pid('11', 'eng', 'Дроселова клапа', 'Throttle position', '%', 0, (b) => b[0] * 100 / 255),
  Pid('5A', 'eng', 'Положение на педала', 'Accelerator pedal', '%', 0, (b) => b[0] * 100 / 255),
  Pid('0E', 'eng', 'Ъгъл на запалване', 'Timing advance', '°', 1, (b) => b[0] / 2 - 64),
  Pid('0F', 'eng', 'Температура на всмукания въздух', 'Intake air temperature', '°C', 0, (b) => b[0] - 40.0),
  Pid('46', 'eng', 'Външна температура', 'Ambient temperature', '°C', 0, (b) => b[0] - 40.0),
  Pid('33', 'eng', 'Атмосферно налягане', 'Barometric pressure', 'kPa', 0, (b) => b[0].toDouble()),
  Pid('0B', 'eng', 'MAP – налягане във всмукателния колектор', 'MAP – intake manifold pressure', 'kPa', 0, (b) => b[0].toDouble()),
  Pid('10', 'eng', 'Масов разход на въздух (MAF)', 'Mass air flow (MAF)', 'g/s', 1, (b) => (b[0] * 256 + b[1]) / 100),
  Pid('06', 'fuel', 'Краткосрочна корекция на горивото', 'Short-term fuel trim', '%', 1, (b) => (b[0] - 128) * 100 / 128),
  Pid('07', 'fuel', 'Дългосрочна корекция на горивото', 'Long-term fuel trim', '%', 1, (b) => (b[0] - 128) * 100 / 128),
  Pid('2F', 'fuel', 'Ниво на горивото', 'Fuel level', '%', 0, (b) => b[0] * 100 / 255),
  Pid('0A', 'fuel', 'Налягане на горивото (ниско)', 'Fuel pressure (gauge)', 'kPa', 0, (b) => b[0] * 3.0),
  Pid('23', 'fuel', 'Налягане в горивната рейка', 'Fuel rail pressure', 'kPa', 0, (b) => (b[0] * 256 + b[1]) * 10.0),
  Pid('59', 'fuel', 'Налягане в рейката (абсолютно)', 'Fuel rail pressure (absolute)', 'kPa', 0, (b) => (b[0] * 256 + b[1]) * 10.0),
  Pid('5E', 'fuel', 'Разход на гориво', 'Fuel rate', 'L/h', 1, (b) => (b[0] * 256 + b[1]) / 20),
  Pid('5D', 'fuel', 'Начало на впръскване', 'Injection timing', '°', 1, (b) => (b[0] * 256 + b[1]) / 128 - 210),
  Pid('BOOST', 'exh', 'Наддувно налягане (турбо)', 'Boost pressure (turbo)', 'bar', 2, (b) => 0),
  Pid('78', 'exh', 'Температура на изгорелите газове (EGT 1)', 'Exhaust gas temperature (EGT 1)', '°C', 0, (b) => _t10(b, 0)),
  Pid('78_2', 'exh', 'Температура на изгорелите газове (EGT 2)', 'Exhaust gas temperature (EGT 2)', '°C', 0, (b) => _t10(b, 1), q: '78'),
  Pid('78_3', 'exh', 'Температура на изгорелите газове (EGT 3)', 'Exhaust gas temperature (EGT 3)', '°C', 0, (b) => _t10(b, 2), q: '78'),
  Pid('7C', 'exh', 'Температура на DPF – вход', 'DPF inlet temperature', '°C', 0, (b) => _t10(b, 0)),
  Pid('7C_o', 'exh', 'Температура на DPF – изход', 'DPF outlet temperature', '°C', 0, (b) => _t10(b, 1), q: '7C'),
  Pid('3C', 'exh', 'Температура на катализатора (преди)', 'Catalyst temperature (upstream)', '°C', 0, (b) => (b[0] * 256 + b[1]) / 10 - 40),
  Pid('3E', 'exh', 'Температура на катализатора (след)', 'Catalyst temperature (downstream)', '°C', 0, (b) => (b[0] * 256 + b[1]) / 10 - 40),
  Pid('24', 'exh', 'Лямбда (сензор 1)', 'Lambda (sensor 1)', 'λ', 2, (b) => (b[0] * 256 + b[1]) * 2 / 65536),
  Pid('2C', 'exh', 'EGR – зададена', 'EGR commanded', '%', 0, (b) => b[0] * 100 / 255),
  Pid('RV', 'el', 'Напрежение на акумулатора', 'Battery voltage', 'V', 1, (b) => 0),
  Pid('42', 'el', 'Напрежение на модула (ECU)', 'Control module voltage', 'V', 1, (b) => (b[0] * 256 + b[1]) / 1000),
];
 
bool isSup(Pid p, Set<int> s) {
  if (p.id == 'RV') return true;
  if (p.id == 'BOOST') return s.contains(0x0B) && s.contains(0x33);
  final n = int.tryParse(p.q, radix: 16);
  return n != null && s.contains(n);
}
 
Future<Set<int>> probePids(Elm e) async {
  final out = <int>{};
  for (var base = 0; base <= 0x80; base += 0x20) {
    final hb = base.toRadixString(16).toUpperCase().padLeft(2, '0');
    final h = (await e.send('01$hb', ms: 5000)).toUpperCase().replaceAll(RegExp(r'[^0-9A-F]'), '');
    final i = h.indexOf('41$hb');
    if (i < 0 || h.length < i + 12) break;
    final m = int.parse(h.substring(i + 4, i + 12), radix: 16);
    for (var k = 0; k < 32; k++) {
      if (((m >> (31 - k)) & 1) == 1) out.add(base + k + 1);
    }
    if (!out.contains(base + 0x20)) break;
  }
  return out;
}
 
// ---------- приложение ----------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadGarage();
  logAdd('TORQIQ $kVersion');
  loadDtcData();
  logAdd('DTC database: ${dtcDb.length} codes');
  runApp(App());
}
 
class App extends StatelessWidget {
  App({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<String>(
      valueListenable: lang,
      builder: (_, __, ___) => MaterialApp(
            title: 'TORQIQ',
            debugShowCheckedModeBanner: false,
            theme: brandTheme(),
            darkTheme: brandTheme(),
            themeMode: ThemeMode.dark,
            home: Home(),
          ));
}
 
class Home extends StatefulWidget {
  Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}
 
class _HomeState extends State<Home> {
  int i = 0;
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = await SharedPreferences.getInstance();
      if (p.getBool('accepted') == true || !mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (d) => AlertDialog(
          title: Text(t('welcome')),
          content: Text(t('warn2')),
          actions: [FilledButton(onPressed: () { p.setBool('accepted', true); Navigator.pop(d); }, child: Text(t('accept')))],
        ),
      );
    });
  }
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: wordmark(24),
          actions: [
            IconButton(icon: const Icon(Icons.info_outline), tooltip: t('about'), onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => AboutPage()))),
            TextButton(onPressed: () => lang.value = lang.value == 'bg' ? 'en' : 'bg', child: Text(lang.value == 'bg' ? 'EN' : 'БГ')),
          ],
        ),
        body: [ScanTab(), LiveTab(), GarageTab(), HistTab()][i],
        floatingActionButton: i == 2 ? FloatingActionButton.extended(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => CarForm())), icon: const Icon(Icons.add), label: Text(t('addcar'))) : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => setState(() => i = v),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.car_repair), label: t('scan')),
            NavigationDestination(icon: const Icon(Icons.speed), label: t('live')),
            NavigationDestination(icon: const Icon(Icons.garage_outlined), label: t('garage')),
            NavigationDestination(icon: const Icon(Icons.history), label: t('hist')),
          ],
        ),
      );
}
 
class ScanTab extends StatefulWidget {
  ScanTab({super.key});
  @override
  State<ScanTab> createState() => _ScanTabState();
}
 
class _ScanTabState extends State<ScanTab> {
  List<ScanResult> found = [];
  bool busy = false;
  String msg = '';
  StreamSubscription? sub;
  List<String>? stored, pending, perm;
 
  @override
  void dispose() { sub?.cancel(); super.dispose(); }
 
  Future<void> search() async {
    setState(() { found = []; msg = ''; });
    sub?.cancel();
    sub = FlutterBluePlus.scanResults.listen((r) {
      if (mounted) setState(() => found = r.where((x) => x.device.platformName.isNotEmpty).toList());
    });
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
    } catch (x) {
      if (mounted) setState(() => msg = '${t('error')}: $x');
    }
  }
 
  Future<void> connect(BluetoothDevice d) async {
    await FlutterBluePlus.stopScan();
    setState(() { busy = true; msg = t('connecting'); });
    try {
      final e = Elm(d);
      await e.open();
      supported = await probePids(e);
      elm = e;
      connected.value = true;
      msg = '';
    } catch (x) {
      logAdd('connect error: $x');
      msg = '${t('error')}: $x';
    }
    if (mounted) setState(() => busy = false);
  }
 
  Future<void> startDemo() async {
    setState(() => busy = true);
    elm = Elm.demo();
    supported = await probePids(elm!);
    connected.value = true;
    if (mounted) setState(() => busy = false);
  }
 
  Future<void> readCodes() async {
    setState(() { busy = true; msg = t('reading'); });
    try {
      final e = elm!;
      final s = parseDtc(await e.send('03', ms: 8000));
      final p = parseDtc(await e.send('07', ms: 8000), '47');
      final x = parseDtc(await e.send('0A', ms: 8000), '4A');
      stored = s;
      pending = p.where((k) => !s.contains(k)).toList();
      perm = x;
      logAdd('DTC stored=$s pending=$pending permanent=$x');
      await saveHist(s, pending!, x);
      msg = '';
    } catch (err) {
      msg = '${t('error')}: $err';
    }
    if (mounted) setState(() => busy = false);
  }
 
  Future<void> clearCodes() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(t('clrq')),
        content: SingleChildScrollView(child: Text(t('clrinfo'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t('clear'))),
        ],
      ),
    );
    if (ok != true) return;
    setState(() { busy = true; msg = t('clearing'); });
    try {
      final r = (await elm!.send('04', ms: 8000)).toUpperCase();
      if (r.contains('44') && !r.contains('7F')) {
        await Future.delayed(const Duration(seconds: 1));
        await readCodes();
        msg = t('cleared');
      } else {
        msg = t('clearfail');
      }
    } catch (err) {
      msg = '${t('error')}: $err';
    }
    if (mounted) setState(() => busy = false);
  }
 
  List<Widget> _group(String tk, String sk, List<String>? list, IconData icon, Color col) {
    if (list == null || list.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Row(children: [Icon(icon, color: col, size: 20), const SizedBox(width: 8), Text(t(tk), style: Theme.of(context).textTheme.titleMedium)]),
      ),
      Text(t(sk), style: Theme.of(context).textTheme.bodySmall),
      for (final k in list)
        Card(
          child: ListTile(
            leading: Icon(Icons.warning_amber, color: sevColor(sev[k] ?? 1)),
            title: Text(k),
            subtitle: Text(dtcInfo(k)[0]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CodePage(k))),
          ),
        ),
    ];
  }
 
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
      valueListenable: connected,
      builder: (_, on, __) {
        final none = (stored ?? []).isEmpty && (pending ?? []).isEmpty && (perm ?? []).isEmpty;
        final canClear = (stored ?? []).isNotEmpty || (pending ?? []).isNotEmpty;
        return ListView(padding: const EdgeInsets.all(16), children: [
          if (msg.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(msg)),
          if (busy) const LinearProgressIndicator(),
          carTile(context),
          if (!on) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const Icon(Icons.bluetooth_searching, size: 48),
                  const SizedBox(height: 8),
                  Text(t('hint'), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(t('ble'), style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: busy ? null : search, icon: const Icon(Icons.bluetooth_searching), label: Text(t('search'))),
            OutlinedButton.icon(onPressed: busy ? null : startDemo, icon: const Icon(Icons.play_circle_outline), label: Text(t('demo'))),
            for (final r in found)
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(r.device.platformName),
                subtitle: Text(r.device.remoteId.str),
                onTap: busy ? null : () => connect(r.device),
              ),
          ] else ...[
            ListTile(leading: const Icon(Icons.check_circle, color: kGreen), title: Text('${t('connected')}: ${elm?.name ?? ''}')),
            FilledButton.icon(onPressed: busy ? null : readCodes, icon: const Icon(Icons.search), label: Text(t('read'))),
            TextButton(
              onPressed: () async { await elm?.close(); elm = null; supported = null; stored = null; pending = null; perm = null; connected.value = false; },
              child: Text(t('disconnect')),
            ),
            if (stored != null && none) Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.check_circle, color: kGreen), const SizedBox(width: 8), Expanded(child: Text(t('none')))])),
            ..._group('stored', 'storedsub', stored, Icons.error_outline, Colors.red),
            ..._group('pending', 'pendingsub', pending, Icons.schedule, Colors.orange),
            ..._group('permanent', 'permsub', perm, Icons.lock_outline, Colors.deepOrange),
            if (canClear)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OutlinedButton.icon(onPressed: busy ? null : clearCodes, icon: const Icon(Icons.delete_sweep), label: Text(t('clear'))),
              ),
            if (stored != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(t('permnote'), style: Theme.of(context).textTheme.bodySmall)),
          ],
        ]);
      });
}
 
class CodePage extends StatelessWidget {
  final String code;
  final String? fuel;
  CodePage(this.code, {this.fuel, super.key});
  @override
  Widget build(BuildContext c) {
    final List<String>? d = dtcInfo(code);
    final f = fuel ?? currentCar()?.fuel;
    return Scaffold(
      appBar: AppBar(title: Text(code)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(d?[0] ?? code, style: Theme.of(c).textTheme.headlineSmall),
        if (sev[code] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(avatar: Icon(Icons.circle, size: 14, color: sevColor(sev[code]!)), label: Text(t('sev${sev[code]}'))),
            ),
          ),
        const SizedBox(height: 12),
        Text(d?[1] ?? t('unknown')),
        ..._fuelNotes(c, code, f),
        if (d != null) ...[
          const SizedBox(height: 16),
          Text(t('actions'), style: Theme.of(c).textTheme.titleMedium),
          for (final a in d[2].split('|')) ListTile(dense: true, leading: const Icon(Icons.check_circle_outline), title: Text(a)),
        ],
        const SizedBox(height: 24),
        Card(child: ListTile(leading: const Icon(Icons.build_circle_outlined), subtitle: Text(t('persist')))),
        const SizedBox(height: 8),
        Text(t('warn'), style: Theme.of(c).textTheme.bodySmall),
      ]),
    );
  }
}
 
class LiveTab extends StatefulWidget {
  LiveTab({super.key});
  @override
  State<LiveTab> createState() => _LiveTabState();
}
 
class _LiveTabState extends State<LiveTab> {
  final sel = <String>{'05', '0C'};
  final vals = <String, String>{};
  bool run = true;
 
  @override
  void initState() {
    super.initState();
    if (elm != null) loop();
  }
 
  @override
  void dispose() { run = false; super.dispose(); }
 
  Future<String> read(Pid p) async {
    if (p.id == 'RV') return (await elm!.send('ATRV', ms: 1500)).replaceAll(RegExp(r'[\r\n]'), ' ').trim();
    double? n;
    if (p.id == 'BOOST') {
      final m = pidVal(await elm!.send('010B', ms: 2500), '0B', (b) => b[0].toDouble());
      final a = pidVal(await elm!.send('0133', ms: 2500), '33', (b) => b[0].toDouble());
      n = (m == null || a == null) ? null : (m - a) / 100;
    } else {
      n = pidVal(await elm!.send('01${p.q}', ms: 2500), p.q, p.f);
    }
    return n == null ? t('na') : '${n.toStringAsFixed(p.dec)} ${p.unit}';
  }
 
  Future<void> loop() async {
    while (run && mounted && elm != null) {
      final ids = sel.toList();
      if (ids.isEmpty) { await Future.delayed(const Duration(milliseconds: 500)); continue; }
      for (final id in ids) {
        if (!run || !mounted || elm == null) return;
        String v;
        try { v = await read(pids.firstWhere((x) => x.id == id)); } catch (_) { v = t('na'); }
        if (mounted) setState(() => vals[id] = v);
      }
    }
  }
 
  @override
  Widget build(BuildContext c) {
    if (elm == null) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(t('noconn'))));
    final sup = supported;
    final avail = pids.where((p) => sup == null || sup.isEmpty || isSup(p, sup)).toList();
    final groups = {'eng': t('grp_eng'), 'fuel': t('grp_fuel'), 'exh': t('grp_exh'), 'el': t('grp_el')};
    final shown = sel.where((x) => avail.any((p) => p.id == x)).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
        children: [
          for (final id in shown)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(pids.firstWhere((x) => x.id == id).name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(c).textTheme.bodySmall),
                  Text(vals[id] ?? '…', style: Theme.of(c).textTheme.headlineSmall),
                ]),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text(t('supnote'), style: Theme.of(c).textTheme.bodySmall),
      for (final g in groups.entries)
        if (avail.any((p) => p.grp == g.key)) ...[
          const SizedBox(height: 16),
          Text(g.value, style: Theme.of(c).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final p in avail.where((x) => x.grp == g.key))
              FilterChip(
                label: Text(p.name),
                selected: sel.contains(p.id),
                onSelected: (v) => setState(() => v ? sel.add(p.id) : sel.remove(p.id)),
              ),
          ]),
        ],
      const SizedBox(height: 16),
      Text(t('trans'), style: Theme.of(c).textTheme.bodySmall),
    ]);
  }
}
 
class HistTab extends StatelessWidget {
  HistTab({super.key});
  @override
  Widget build(BuildContext c) => FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (c, s) {
        final l = s.data?.getStringList('hist') ?? [];
        if (l.isEmpty) return Center(child: Text(t('nohist')));
        return ListView(padding: const EdgeInsets.all(8), children: [for (final x in l) _item(c, jsonDecode(x))]);
      });
 
  Widget _item(BuildContext c, Map m) {
    final d = DateTime.parse(m['t']).toLocal();
    final car = (m['car'] ?? '').toString();
    final fuel = (m['fuel'] ?? '').toString();
    final items = <MapEntry<String, int>>[
      for (final k in List<String>.from(m['c'] ?? [])) MapEntry(k, 0),
      for (final k in List<String>.from(m['p'] ?? [])) MapEntry(k, 1),
      for (final k in List<String>.from(m['x'] ?? [])) MapEntry(k, 2),
    ];
    String two(int n) => n.toString().padLeft(2, '0');
    return Card(
      child: ListTile(
        title: Text('${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}'),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (car.isNotEmpty) Text(car),
          if (items.isEmpty)
            Text(t('none'))
          else
            Wrap(spacing: 6, children: [
              for (final e in items)
                ActionChip(
                  avatar: Icon(e.value == 2 ? Icons.lock_outline : (e.value == 1 ? Icons.schedule : Icons.error_outline), size: 16),
                  label: Text(e.key),
                  onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => CodePage(e.key, fuel: fuel.isEmpty ? null : fuel))),
                ),
            ]),
        ]),
      ),
    );
  }
}
 
// ---------- За приложението ----------
const kVersion = '0.3.2';
const kContact = 'support@example.com'; // СМЕНЕТЕ с вашия имейл за контакт
 
const _T = <String, List<String>>{
  'privacy': [
    'TORQIQ не изисква регистрация и не събира лични данни.\n\nДанните от автомобила (грешки и показания), историята на сканиранията и колите, които добавите в Гаража, се съхраняват само на вашия телефон и не се изпращат към сървър или трети страни.\n\nBluetooth се използва само за връзка с вашия OBD адаптер. Android изисква разрешение за местоположение, за да търси Bluetooth устройства; приложението не следи и не записва местоположението ви.\n\nМожете да изтриете историята, като изчистите данните на приложението от настройките на телефона.\n\nАко в бъдеще бъдат добавени реклами или покупки, тази политика ще бъде обновена и ще бъде поискано вашето съгласие, където е необходимо.',
    'TORQIQ does not require registration and does not collect personal data.\n\nVehicle data (fault codes and readings), your scan history and the cars you add to the Garage are stored only on your phone and are not sent to any server or third party.\n\nBluetooth is used only to connect to your OBD adapter. Android requires the location permission to search for Bluetooth devices; the app does not track or record your location.\n\nYou can delete the history by clearing the app data in your phone settings.\n\nIf ads or purchases are added in the future, this policy will be updated and your consent will be requested where required.',
  ],
  'terms': [
    'Приложението е предназначено за информация и общо запознаване с диагностичните кодове. Описанията и препоръките са ориентировъчни и не заменят преглед от квалифициран механик.\n\nНе карайте автомобила при предупреждения за безопасност. Не използвайте телефона, докато шофирате.\n\nПриложението се предоставя „както е“, без гаранции. Авторът не носи отговорност за щети, причинени от използването му.\n\nИзползвайте приложението само за собствен автомобил или с разрешението на собственика.',
    'The app is intended for information and general understanding of diagnostic codes. Descriptions and recommendations are indicative and do not replace inspection by a qualified mechanic.\n\nDo not drive the vehicle when safety warnings are present. Do not use your phone while driving.\n\nThe app is provided "as is" without warranties. The author is not liable for damage caused by its use.\n\nUse the app only on your own vehicle or with the owner permission.',
  ],
  'supported': [
    'Автомобили с OBD-II (EOBD) порт: бензинови от 2001 г. и дизелови от 2004 г. насам.\n\nАдаптери: с Bluetooth LE (например Veepeak OBDCheck BLE). Адаптери с класически Bluetooth не се поддържат.\n\nПриложението чете общите двигателни грешки и стандартни показания на живо. Функции, специфични за марка (ABS, въздушни възглавници, скоростна кутия, кодиране), не се поддържат.',
    'Vehicles with an OBD-II (EOBD) port: petrol from 2001 and diesel from 2004 onwards.\n\nAdapters: Bluetooth LE (for example Veepeak OBDCheck BLE). Classic Bluetooth adapters are not supported.\n\nThe app reads generic engine fault codes and standard live data. Manufacturer-specific functions (ABS, airbags, transmission, coding) are not supported.',
  ],
};
 
class TextPage extends StatelessWidget {
  final String title, body;
  TextPage(this.title, this.body, {super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(padding: const EdgeInsets.all(16), children: [Text(body, style: Theme.of(c).textTheme.bodyLarge)]),
      );
}
 
class AboutPage extends StatelessWidget {
  AboutPage({super.key});
  Widget _row(BuildContext c, IconData i, String k) => ListTile(
        leading: Icon(i),
        title: Text(t(k)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => TextPage(t(k), _T[k]![lang.value == 'bg' ? 0 : 1]))),
      );
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text(t('about'))),
        body: ListView(children: [
          const SizedBox(height: 24),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('assets/icon.png', width: 132, errorBuilder: (_, __, ___) => const Icon(Icons.car_repair, size: 64)),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: wordmark(34)),
          Center(child: Text(t('tagline'))),
          Center(child: Text('${t('version')} $kVersion', style: Theme.of(c).textTheme.bodySmall)),
          const SizedBox(height: 16),
          _row(c, Icons.directions_car, 'supported'),
          _row(c, Icons.privacy_tip_outlined, 'privacy'),
          _row(c, Icons.gavel, 'terms'),
          ListTile(leading: const Icon(Icons.bug_report_outlined), title: Text(t('log')), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => LogPage()))),
          ListTile(leading: const Icon(Icons.mail_outline), title: Text(t('contact')), subtitle: Text(kContact)),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(t('licenses')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: c, applicationName: 'TORQIQ', applicationVersion: kVersion),
          ),
          Padding(padding: const EdgeInsets.all(16), child: Text(t('warn'), style: Theme.of(c).textTheme.bodySmall)),
        ]),
      );
}
 
 
// ---------- Марка TORQIQ ----------
const kBlue = Color(0xFF2D8CFF);
const kGreen = Color(0xFF6BFF1A);
 
ThemeData brandTheme() {
  final cs = ColorScheme.fromSeed(seedColor: kBlue, brightness: Brightness.dark).copyWith(primary: kBlue, secondary: kGreen, surface: const Color(0xFF0B111B));
  return ThemeData(colorScheme: cs, useMaterial3: true, scaffoldBackgroundColor: const Color(0xFF070B12));
}
 
Widget wordmark(double size) => RichText(
      text: TextSpan(
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1),
        children: const [
          TextSpan(text: 'TORQ', style: TextStyle(color: Colors.white)),
          TextSpan(text: 'IQ', style: TextStyle(color: kGreen)),
        ],
      ),
    );
 
// ---------- Гараж ----------
class Car {
  String id, make, model, fuel, engine, name;
  int year;
  int? km;
  Car({required this.id, required this.make, required this.model, required this.year, required this.fuel, this.engine = '', this.name = '', this.km});
  String get title => name.isNotEmpty ? name : '$make $model'.trim();
  Map<String, dynamic> toJson() => {'id': id, 'make': make, 'model': model, 'year': year, 'fuel': fuel, 'engine': engine, 'name': name, 'km': km};
  factory Car.fromJson(Map m) => Car(
        id: (m['id'] ?? '').toString(),
        make: (m['make'] ?? '').toString(),
        model: (m['model'] ?? '').toString(),
        year: (m['year'] as num?)?.toInt() ?? 0,
        fuel: (m['fuel'] ?? '').toString(),
        engine: (m['engine'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        km: (m['km'] as num?)?.toInt(),
      );
}
 
final cars = ValueNotifier<List<Car>>([]);
final carId = ValueNotifier<String?>(null);
 
Future<void> loadGarage() async {
  final p = await SharedPreferences.getInstance();
  cars.value = (p.getStringList('cars') ?? []).map((x) => Car.fromJson(jsonDecode(x))).toList();
  carId.value = p.getString('carId');
}
 
Future<void> saveGarage() async {
  final p = await SharedPreferences.getInstance();
  await p.setStringList('cars', cars.value.map((c) => jsonEncode(c.toJson())).toList());
  final id = carId.value;
  if (id == null) {
    await p.remove('carId');
  } else {
    await p.setString('carId', id);
  }
}
 
Car? currentCar() {
  for (final c in cars.value) {
    if (c.id == carId.value) return c;
  }
  return null;
}
 
const fuels = <String, List<String>>{
  'petrol': ['Бензин', 'Petrol'],
  'diesel': ['Дизел', 'Diesel'],
  'lpg': ['Газ / метан', 'LPG / CNG'],
  'hybrid': ['Хибрид', 'Hybrid'],
};
String fuelName(String k) => fuels[k]?[lang.value == 'bg' ? 0 : 1] ?? k;
String carSub(Car c) => '${c.year > 0 ? '${c.year} · ' : ''}${fuelName(c.fuel)}${c.engine.isNotEmpty ? ' · ${c.engine}' : ''}';
 
const makes = <String>[
  'Alfa Romeo', 'Audi', 'BMW', 'Chevrolet', 'Chrysler', 'Citroën', 'Cupra', 'Dacia', 'Daewoo', 'Dodge', 'Fiat', 'Ford', 'Honda', 'Hyundai',
  'Infiniti', 'Isuzu', 'Jaguar', 'Jeep', 'Kia', 'Lada', 'Lancia', 'Land Rover', 'Lexus', 'Mazda', 'Mercedes-Benz', 'Mini', 'Mitsubishi',
  'Nissan', 'Opel', 'Peugeot', 'Porsche', 'Renault', 'Rover', 'Saab', 'Seat', 'Škoda', 'Smart', 'SsangYong', 'Subaru', 'Suzuki', 'Toyota',
  'Volkswagen', 'Volvo', 'Друга / Other',
];
 
const dtcNote = <String, Map<String, List<String>>>{
  'P0087': {
    'diesel': ['При дизел (Common Rail) най-често причина са горивният филтър, въздух в системата, слаба помпа за ниско налягане, износена помпа за високо налягане или теч на инжектор.', 'On diesel (common rail) the usual causes are the fuel filter, air in the system, a weak low-pressure pump, a worn high-pressure pump or an injector leak.'],
    'petrol': ['При бензин с директно впръскване причина може да е слаба горивна помпа, износена помпа за високо налягане или неизправен регулатор. При бензин с многоточково впръскване този код е рядкост.', 'On direct-injection petrol engines the cause may be a weak fuel pump, a worn high-pressure pump or a faulty regulator. On port-injection petrol engines this code is rare.'],
  },
  'P0101': {
    'diesel': ['При дизел с турбо проверете също въздушния тракт след турбото, EGR клапата и замърсяването на MAF сензора.', 'On turbo diesels also check the air path after the turbo, the EGR valve and MAF sensor contamination.'],
    'petrol': ['При бензин най-често е замърсен MAF сензор или теч във всмукателния тракт след него.', 'On petrol engines it is most often a dirty MAF sensor or a leak in the intake after it.'],
  },
  'P0171': {
    'diesel': ['При дизел този код е по-рядък. Проверете за теч във всмукателния тракт и показанията на MAF сензора.', 'This code is less common on diesels. Check for intake leaks and the MAF sensor readings.'],
    'petrol': ['При бензин най-честите причини са подсмукване на въздух, замърсен MAF сензор и недостатъчно налягане на горивото.', 'On petrol engines the most common causes are air leaks, a dirty MAF sensor and low fuel pressure.'],
  },
  'P0300': {
    'diesel': ['При дизел пропуските се свързват с инжектори, подгревни свещи (при студен двигател) и компресия, а не със свещи за запалване.', 'On diesels misfires are linked to injectors, glow plugs (cold engine) and compression, not spark plugs.'],
    'petrol': ['При бензин проверете свещите, бобините и инжекторите, после за подсмукване на въздух.', 'On petrol engines check spark plugs, coils and injectors, then for air leaks.'],
  },
  'P0420': {
    'diesel': ['При дизел този код е нетипичен. Причината може да е в окислителния катализатор или сензорите за изгорели газове и е нужна диагностика в сервиз.', 'On diesels this code is unusual. The cause may be the oxidation catalyst or exhaust sensors and a workshop diagnosis is needed.'],
    'petrol': ['При бензин най-честата причина е износен катализатор или стара лямбда сонда след него. Първо изключете пропуски и теч в ауспуха.', 'On petrol engines the usual cause is a worn catalytic converter or an old downstream oxygen sensor. First rule out misfires and exhaust leaks.'],
  },
};
 
List<Widget> _fuelNotes(BuildContext c, String code, String? fuel) {
  final n = dtcNote[code];
  if (n == null) return [];
  final l = lang.value == 'bg' ? 0 : 1;
  final keys = (fuel == 'diesel' || fuel == 'petrol') ? <String>[fuel!] : <String>['petrol', 'diesel'];
  return [
    const SizedBox(height: 16),
    for (final k in keys)
      if (n[k] != null) Card(child: ListTile(leading: const Icon(Icons.local_gas_station), title: Text(fuelName(k)), subtitle: Text(n[k]![l]))),
  ];
}
 
Future<String?> pick(BuildContext c, String title, List<String> items) => showModalBottomSheet<String>(
      context: c,
      isScrollControlled: true,
      builder: (b) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(b).size.height * 0.7),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(title, style: Theme.of(b).textTheme.titleMedium)),
            Flexible(child: ListView(shrinkWrap: true, children: [for (final i in items) ListTile(title: Text(i), onTap: () => Navigator.pop(b, i))])),
          ]),
        ),
      ),
    );
 
Future<void> chooseCar(BuildContext c) async {
  await showModalBottomSheet(
    context: c,
    builder: (b) => SafeArea(
      child: ListView(shrinkWrap: true, children: [
        for (final k in cars.value)
          ListTile(
            leading: Icon(k.id == carId.value ? Icons.radio_button_checked : Icons.radio_button_off),
            title: Text(k.title),
            subtitle: Text(carSub(k)),
            onTap: () { carId.value = k.id; saveGarage(); Navigator.pop(b); },
          ),
        ListTile(leading: const Icon(Icons.add), title: Text(t('addcar')), onTap: () { Navigator.pop(b); Navigator.push(c, MaterialPageRoute(builder: (_) => CarForm())); }),
        if (carId.value != null) ListTile(leading: const Icon(Icons.close), title: Text(t('nocarsel')), onTap: () { carId.value = null; saveGarage(); Navigator.pop(b); }),
      ]),
    ),
  );
}
 
Widget carTile(BuildContext context) => ListenableBuilder(
      listenable: Listenable.merge([cars, carId]),
      builder: (_, __) {
        final car = currentCar();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.directions_car),
            title: Text(car == null ? t('nocar') : car.title),
            subtitle: Text(car == null ? t('nocarhint') : carSub(car)),
            trailing: const Icon(Icons.expand_more),
            onTap: () => chooseCar(context),
          ),
        );
      },
    );
 
class GarageTab extends StatelessWidget {
  GarageTab({super.key});
  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: Listenable.merge([cars, carId]),
        builder: (_, __) => ListView(padding: const EdgeInsets.fromLTRB(8, 8, 8, 88), children: [
          if (cars.value.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(t('nocars'), textAlign: TextAlign.center))),
          for (final k in cars.value)
            Card(
              child: ListTile(
                leading: Icon(k.id == carId.value ? Icons.check_circle : Icons.directions_car_outlined, color: k.id == carId.value ? kGreen : null),
                title: Text(k.title),
                subtitle: Text(carSub(k)),
                onTap: () { carId.value = k.id; saveGarage(); },
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      Navigator.push(c, MaterialPageRoute(builder: (_) => CarForm(car: k)));
                    } else {
                      final ok = await showDialog<bool>(
                        context: c,
                        builder: (d) => AlertDialog(
                          title: Text(t('delq')),
                          content: Text(k.title),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t('cancel'))),
                            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t('delete'))),
                          ],
                        ),
                      );
                      if (ok == true) {
                        cars.value = cars.value.where((x) => x.id != k.id).toList();
                        if (carId.value == k.id) carId.value = null;
                        saveGarage();
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(t('edit'))),
                    PopupMenuItem(value: 'del', child: Text(t('delete'))),
                  ],
                ),
              ),
            ),
        ]),
      );
}
 
class CarForm extends StatefulWidget {
  final Car? car;
  CarForm({this.car, super.key});
  @override
  State<CarForm> createState() => _CarFormState();
}
 
class _CarFormState extends State<CarForm> {
  late String make = widget.car?.make ?? '';
  late int year = widget.car?.year ?? 0;
  late String fuel = widget.car?.fuel ?? '';
  late final model = TextEditingController(text: widget.car?.model ?? '');
  late final engine = TextEditingController(text: widget.car?.engine ?? '');
  late final km = TextEditingController(text: widget.car?.km?.toString() ?? '');
  late final name = TextEditingController(text: widget.car?.name ?? '');
 
  void save() {
    if (make.isEmpty || year == 0 || fuel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('fillreq'))));
      return;
    }
    final car = Car(
      id: widget.car?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      make: make,
      model: model.text.trim(),
      year: year,
      fuel: fuel,
      engine: engine.text.trim(),
      name: name.text.trim(),
      km: int.tryParse(km.text.trim()),
    );
    final l = [...cars.value];
    final i = l.indexWhere((x) => x.id == car.id);
    if (i >= 0) {
      l[i] = car;
    } else {
      l.add(car);
    }
    cars.value = l;
    carId.value = car.id;
    saveGarage();
    Navigator.pop(context);
  }
 
  InputDecoration deco(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder());
 
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text(widget.car == null ? t('addcar') : t('edit'))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          ListTile(
            title: Text(t('make')),
            subtitle: Text(make.isEmpty ? '—' : make),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async { final v = await pick(c, t('make'), makes); if (v != null) setState(() => make = v); },
          ),
          TextField(controller: model, decoration: deco(t('model'))),
          ListTile(
            title: Text(t('year')),
            subtitle: Text(year == 0 ? '—' : '$year'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final now = DateTime.now().year;
              final v = await pick(c, t('year'), [for (var y = now + 1; y >= 1996; y--) '$y']);
              if (v != null) setState(() => year = int.parse(v));
            },
          ),
          Text(t('fuel'), style: Theme.of(c).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final k in fuels.keys) ChoiceChip(label: Text(fuelName(k)), selected: fuel == k, onSelected: (_) => setState(() => fuel = k)),
          ]),
          const SizedBox(height: 16),
          TextField(controller: engine, decoration: deco(t('engine'))),
          const SizedBox(height: 12),
          TextField(controller: km, keyboardType: TextInputType.number, decoration: deco(t('km'))),
          const SizedBox(height: 12),
          TextField(controller: name, decoration: deco(t('carname'))),
          const SizedBox(height: 20),
          FilledButton(onPressed: save, child: Text(t('save'))),
        ]),
      );
}
 
 
// ---------- Журнал (екран) ----------
class LogPage extends StatefulWidget {
  LogPage({super.key});
  @override
  State<LogPage> createState() => _LogPageState();
}
 
class _LogPageState extends State<LogPage> {
  @override
  Widget build(BuildContext c) {
    final txt = logText();
    return Scaffold(
      appBar: AppBar(title: Text(t('log')), actions: [
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: t('copy'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: txt));
            ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t('copied'))));
          },
        ),
        IconButton(icon: const Icon(Icons.delete_outline), tooltip: t('clearlog'), onPressed: () => setState(logClear)),
      ]),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        SelectableText(txt.isEmpty ? t('logempty') : txt, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
      ]),
    );
  }
}
 
 
// ---------- База с кодове на грешки ----------
const _sysP = <String, List<String>>{
  '0': ['подаване на гориво и въздух', 'fuel and air metering'],
  '1': ['подаване на гориво и въздух', 'fuel and air metering'],
  '2': ['впръскване на гориво', 'fuel injection'],
  '3': ['запалване и пропуски', 'ignition and misfires'],
  '4': ['контрол на емисиите', 'emission controls'],
  '5': ['скорост, празен ход и входове', 'speed, idle and inputs'],
  '6': ['компютър и изходни вериги', 'computer and output circuits'],
  '7': ['скоростна кутия', 'transmission'],
  '8': ['скоростна кутия', 'transmission'],
  '9': ['скоростна кутия', 'transmission'],
};
 
const _actsTxt = <List<String>>[
  ['Обикновено не е опасно, но проверете скоро|Ако контролната лампа свети постоянно, посетете сервиз', 'Usually not dangerous, but check soon|If the warning light stays on, visit a workshop'],
  ['Обикновено може да се кара внимателно, но не го отлагайте за дълго|Проверете причините или посетете сервиз|Не изтривайте кода, докато не разберете причината', 'Usually drivable with care, but do not delay for long|Check the causes or visit a workshop|Do not clear the code until you know the cause'],
  ['Спрете или карайте само до най-близкия сервиз|Не натоварвайте двигателя|Не изтривайте кода преди ремонт', 'Stop or drive only to the nearest workshop|Do not load the engine|Do not clear the code before repair'],
];
String _acts(int sv, int l) => _actsTxt[(sv < 0 || sv > 2) ? 1 : sv][l];
 
String _sysLine(String code, int l) {
  final c0 = code.isEmpty ? 'P' : code[0];
  final c3 = code.length > 2 ? code[2] : '';
  String sys;
  if (c0 == 'P') {
    sys = _sysP[c3]?[l] ?? (l == 0 ? 'задвижване' : 'powertrain');
  } else if (c0 == 'B') {
    sys = l == 0 ? 'каросерия (въздушни възглавници, заключване, светлини)' : 'body (airbags, locks, lighting)';
  } else if (c0 == 'C') {
    sys = l == 0 ? 'шаси (ABS, управление, окачване)' : 'chassis (ABS, steering, suspension)';
  } else {
    sys = l == 0 ? 'комуникация между модулите' : 'module communication';
  }
  final mfr = code.length > 1 && (code[1] == '1' || code[1] == '3');
  final note = mfr
      ? (l == 0 ? ' Кодът е специфичен за производителя и значението му е различно при различните марки.' : ' This code is manufacturer-specific and its meaning differs between makes.')
      : '';
  return (l == 0 ? 'Група: $sys.' : 'Group: $sys.') + note;
}
 
List<String> _generic(String code, int l) => [
      l == 0 ? 'Код $code' : 'Code $code',
      '${_sysLine(code, l)} ${l == 0 ? 'Подробно описание за този код още не е добавено.' : 'A detailed description for this code has not been added yet.'}',
      _acts(1, l),
    ];
 
List<String> dtcInfo(String code) {
  final l = lang.value == 'bg' ? 0 : 1;
  final e = dtcDb[code];
  return e != null ? e[l] : _generic(code, l);
}
 
void loadDtcData() {
  for (final line in dtcRaw.split('\n')) {
    final f = line.trim().split('|');
    if (f.length < 4) continue;
    final code = f[0];
    if (dtcDb.containsKey(code)) continue;
    final sv = int.tryParse(f[1]) ?? 1;
    final hb = f.length > 4 ? f[4] : '';
    final he = f.length > 5 ? f[5] : '';
    dtcDb[code] = [
      [f[2], hb.isNotEmpty ? hb : _sysLine(code, 0), _acts(sv, 0)],
      [f[3], he.isNotEmpty ? he : _sysLine(code, 1), _acts(sv, 1)],
    ];
    sev[code] = sv;
  }
}
 
const String dtcRaw = r'''
C0035|1|Сензор за скорост на колелото – предно ляво|Left front wheel speed sensor circuit
C0040|1|Сензор за скорост на колелото – предно дясно|Right front wheel speed sensor circuit
C0045|1|Сензор за скорост на колелото – задно ляво|Left rear wheel speed sensor circuit
C0050|1|Сензор за скорост на колелото – задно дясно|Right rear wheel speed sensor circuit
P0010|1|Задвижване на разпределителен вал A (банка 1) – верига|Camshaft position actuator A circuit (bank 1)
P0011|1|Разпределителен вал A (банка 1) – фази твърде напред|Camshaft timing A over-advanced (bank 1)|Често е ниско или замърсено масло, неизправен VVT клапан или износена верига.|Often low or dirty oil, a faulty VVT valve or a worn chain.
P0012|1|Разпределителен вал A (банка 1) – фази твърде назад|Camshaft timing A over-retarded (bank 1)|Често е ниско или замърсено масло, неизправен VVT клапан или износена верига.|Often low or dirty oil, a faulty VVT valve or a worn chain.
P0013|1|Задвижване на разпределителен вал B (банка 1) – верига|Camshaft position actuator B circuit (bank 1)
P0014|1|Разпределителен вал B (банка 1) – фази твърде напред|Camshaft timing B over-advanced (bank 1)|Често е ниско или замърсено масло, неизправен VVT клапан или износена верига.|Often low or dirty oil, a faulty VVT valve or a worn chain.
P0015|1|Разпределителен вал B (банка 1) – фази твърде назад|Camshaft timing B over-retarded (bank 1)|Често е ниско или замърсено масло, неизправен VVT клапан или износена верига.|Often low or dirty oil, a faulty VVT valve or a worn chain.
P0016|2|Корелация колянов – разпределителен вал (банка 1, сензор A)|Crankshaft/camshaft position correlation (bank 1, sensor A)|Често е обтегнат ремък или верига на ангренажа, или неизправен сензор. Проверете в сервиз, преди да продължите да карате.|Often a stretched timing belt or chain, or a faulty sensor. Have it checked at a workshop before driving on.
P0017|2|Корелация колянов – разпределителен вал (банка 1, сензор B)|Crankshaft/camshaft position correlation (bank 1, sensor B)|Често е обтегнат ремък или верига на ангренажа, или неизправен сензор. Проверете в сервиз, преди да продължите да карате.|Often a stretched timing belt or chain, or a faulty sensor. Have it checked at a workshop before driving on.
P0018|2|Корелация колянов – разпределителен вал (банка 2, сензор A)|Crankshaft/camshaft position correlation (bank 2, sensor A)|Често е обтегнат ремък или верига на ангренажа, или неизправен сензор. Проверете в сервиз, преди да продължите да карате.|Often a stretched timing belt or chain, or a faulty sensor. Have it checked at a workshop before driving on.
P0019|2|Корелация колянов – разпределителен вал (банка 2, сензор B)|Crankshaft/camshaft position correlation (bank 2, sensor B)|Често е обтегнат ремък или верига на ангренажа, или неизправен сензор. Проверете в сервиз, преди да продължите да карате.|Often a stretched timing belt or chain, or a faulty sensor. Have it checked at a workshop before driving on.
P0045|1|Турбо: клапан за управление на наддуването – верига|Turbo boost control solenoid circuit
P0046|1|Турбо: управление на наддуването – извън диапазона|Turbo boost control performance
P0047|1|Турбо: управление на наддуването – ниско напрежение|Turbo boost control circuit low
P0048|1|Турбо: управление на наддуването – високо напрежение|Turbo boost control circuit high
P0070|1|Сензор за външна температура – верига|Ambient air temperature sensor circuit
P0071|1|Сензор за външна температура – извън диапазона|Ambient air temperature sensor range/performance
P0072|1|Сензор за външна температура – ниско напрежение|Ambient air temperature sensor circuit low
P0073|1|Сензор за външна температура – високо напрежение|Ambient air temperature sensor circuit high
P0088|2|Налягане в горивната рейка – твърде високо|Fuel rail pressure too high|Рискът е от повреда на системата за високо налягане. Не продължавайте да карате с натоварване.|Risk of damage to the high-pressure system. Do not keep driving under load.
P0089|1|Регулатор на горивното налягане 1 – неизправност|Fuel pressure regulator 1 performance
P0090|1|Регулатор на горивното налягане 1 – верига|Fuel pressure regulator 1 control circuit
P0100|1|MAF сензор – верига|Mass air flow sensor circuit
P0101|1|MAF сензор – извън диапазона|Mass air flow sensor range/performance
P0102|1|MAF сензор – ниско напрежение|Mass air flow sensor circuit low
P0103|1|MAF сензор – високо напрежение|Mass air flow sensor circuit high
P0104|1|MAF сензор – периодично|Mass air flow sensor intermittent
P0105|1|MAP/барометричен сензор – верига|MAP/barometric pressure sensor circuit
P0106|1|MAP/барометричен сензор – извън диапазона|MAP/barometric pressure sensor range/performance
P0107|1|MAP/барометричен сензор – ниско напрежение|MAP/barometric pressure sensor circuit low
P0108|1|MAP/барометричен сензор – високо напрежение|MAP/barometric pressure sensor circuit high
P0109|1|MAP/барометричен сензор – периодично|MAP/barometric pressure sensor intermittent
P0110|1|Температура на всмукания въздух – верига|Intake air temperature sensor circuit
P0111|1|Температура на всмукания въздух – извън диапазона|Intake air temperature sensor range/performance
P0112|1|Температура на всмукания въздух – ниско напрежение|Intake air temperature sensor circuit low
P0113|1|Температура на всмукания въздух – високо напрежение|Intake air temperature sensor circuit high
P0114|1|Температура на всмукания въздух – периодично|Intake air temperature sensor intermittent
P0115|1|Температура на охладителната течност – верига|Coolant temperature sensor circuit
P0116|1|Температура на охладителната течност – извън диапазона|Coolant temperature sensor range/performance
P0117|1|Температура на охладителната течност – ниско напрежение|Coolant temperature sensor circuit low
P0118|1|Температура на охладителната течност – високо напрежение|Coolant temperature sensor circuit high
P0119|1|Температура на охладителната течност – периодично|Coolant temperature sensor intermittent
P0120|1|Сензор на дросела/педала A – верига|Throttle/pedal position sensor A circuit
P0121|1|Сензор на дросела/педала A – извън диапазона|Throttle/pedal position sensor A range/performance
P0122|1|Сензор на дросела/педала A – ниско напрежение|Throttle/pedal position sensor A circuit low
P0123|1|Сензор на дросела/педала A – високо напрежение|Throttle/pedal position sensor A circuit high
P0124|1|Сензор на дросела/педала A – периодично|Throttle/pedal position sensor A intermittent
P0125|1|Недостатъчна температура на двигателя за регулиране|Insufficient coolant temperature for closed loop|Най-често е термостатът (залепнал отворен).|Most often the thermostat (stuck open).
P0128|1|Термостат – температурата не достига работната|Coolant thermostat below regulating temperature|Най-често е термостатът (залепнал отворен).|Most often the thermostat (stuck open).
P0130|1|Лямбда сонда (банка 1, сензор 1) – верига|O2 sensor (bank 1, sensor 1) circuit malfunction
P0131|1|Лямбда сонда (банка 1, сензор 1) – ниско напрежение|O2 sensor (bank 1, sensor 1) low voltage
P0132|1|Лямбда сонда (банка 1, сензор 1) – високо напрежение|O2 sensor (bank 1, sensor 1) high voltage
P0133|1|Лямбда сонда (банка 1, сензор 1) – бавна реакция|O2 sensor (bank 1, sensor 1) slow response
P0134|1|Лямбда сонда (банка 1, сензор 1) – няма активност|O2 sensor (bank 1, sensor 1) no activity detected
P0135|1|Лямбда сонда (банка 1, сензор 1) – нагревател – верига|O2 sensor (bank 1, sensor 1) heater circuit
P0136|1|Лямбда сонда (банка 1, сензор 2) – верига|O2 sensor (bank 1, sensor 2) circuit malfunction
P0137|1|Лямбда сонда (банка 1, сензор 2) – ниско напрежение|O2 sensor (bank 1, sensor 2) low voltage
P0138|1|Лямбда сонда (банка 1, сензор 2) – високо напрежение|O2 sensor (bank 1, sensor 2) high voltage
P0139|1|Лямбда сонда (банка 1, сензор 2) – бавна реакция|O2 sensor (bank 1, sensor 2) slow response
P0140|1|Лямбда сонда (банка 1, сензор 2) – няма активност|O2 sensor (bank 1, sensor 2) no activity detected
P0141|1|Лямбда сонда (банка 1, сензор 2) – нагревател – верига|O2 sensor (bank 1, sensor 2) heater circuit
P0150|1|Лямбда сонда (банка 2, сензор 1) – верига|O2 sensor (bank 2, sensor 1) circuit malfunction
P0151|1|Лямбда сонда (банка 2, сензор 1) – ниско напрежение|O2 sensor (bank 2, sensor 1) low voltage
P0152|1|Лямбда сонда (банка 2, сензор 1) – високо напрежение|O2 sensor (bank 2, sensor 1) high voltage
P0153|1|Лямбда сонда (банка 2, сензор 1) – бавна реакция|O2 sensor (bank 2, sensor 1) slow response
P0154|1|Лямбда сонда (банка 2, сензор 1) – няма активност|O2 sensor (bank 2, sensor 1) no activity detected
P0155|1|Лямбда сонда (банка 2, сензор 1) – нагревател – верига|O2 sensor (bank 2, sensor 1) heater circuit
P0156|1|Лямбда сонда (банка 2, сензор 2) – верига|O2 sensor (bank 2, sensor 2) circuit malfunction
P0157|1|Лямбда сонда (банка 2, сензор 2) – ниско напрежение|O2 sensor (bank 2, sensor 2) low voltage
P0158|1|Лямбда сонда (банка 2, сензор 2) – високо напрежение|O2 sensor (bank 2, sensor 2) high voltage
P0159|1|Лямбда сонда (банка 2, сензор 2) – бавна реакция|O2 sensor (bank 2, sensor 2) slow response
P0160|1|Лямбда сонда (банка 2, сензор 2) – няма активност|O2 sensor (bank 2, sensor 2) no activity detected
P0161|1|Лямбда сонда (банка 2, сензор 2) – нагревател – верига|O2 sensor (bank 2, sensor 2) heater circuit
P0170|1|Корекция на горивото (банка 1) – неизправност|Fuel trim malfunction (bank 1)
P0172|1|Богата смес (банка 1)|System too rich (bank 1)|Често: течащ инжектор, замърсен или повреден MAF, лямбда сонда или високо налягане на горивото.|Often a leaking injector, a dirty or faulty MAF, an oxygen sensor or high fuel pressure.
P0173|1|Корекция на горивото (банка 2) – неизправност|Fuel trim malfunction (bank 2)
P0174|1|Бедна смес (банка 2)|System too lean (bank 2)
P0175|1|Богата смес (банка 2)|System too rich (bank 2)
P0190|1|Сензор за налягане в горивната рейка – верига|Fuel rail pressure sensor circuit
P0191|1|Сензор за налягане в горивната рейка – извън диапазона|Fuel rail pressure sensor range/performance
P0192|1|Сензор за налягане в горивната рейка – ниско напрежение|Fuel rail pressure sensor circuit low
P0193|1|Сензор за налягане в горивната рейка – високо напрежение|Fuel rail pressure sensor circuit high
P0194|1|Сензор за налягане в горивната рейка – периодично|Fuel rail pressure sensor intermittent
P0200|1|Инжектор – верига|Injector circuit malfunction
P0201|1|Инжектор – цилиндър 1 – верига|Injector circuit – cylinder 1
P0202|1|Инжектор – цилиндър 2 – верига|Injector circuit – cylinder 2
P0203|1|Инжектор – цилиндър 3 – верига|Injector circuit – cylinder 3
P0204|1|Инжектор – цилиндър 4 – верига|Injector circuit – cylinder 4
P0205|1|Инжектор – цилиндър 5 – верига|Injector circuit – cylinder 5
P0206|1|Инжектор – цилиндър 6 – верига|Injector circuit – cylinder 6
P0207|1|Инжектор – цилиндър 7 – верига|Injector circuit – cylinder 7
P0208|1|Инжектор – цилиндър 8 – верига|Injector circuit – cylinder 8
P0209|1|Инжектор – цилиндър 9 – верига|Injector circuit – cylinder 9
P0210|1|Инжектор – цилиндър 10 – верига|Injector circuit – cylinder 10
P0211|1|Инжектор – цилиндър 11 – верига|Injector circuit – cylinder 11
P0212|1|Инжектор – цилиндър 12 – верига|Injector circuit – cylinder 12
P0217|2|Прегряване на двигателя|Engine overtemperature condition|Спрете безопасно и изключете двигателя. Не отваряйте капачката на горещ радиатор.|Stop safely and switch the engine off. Do not open the cap of a hot radiator.
P0219|2|Превишени обороти на двигателя|Engine overspeed condition
P0220|1|Сензор на дросела/педала B – верига|Throttle/pedal position sensor B circuit
P0221|1|Сензор на дросела/педала B – извън диапазона|Throttle/pedal position sensor B range/performance
P0222|1|Сензор на дросела/педала B – ниско напрежение|Throttle/pedal position sensor B circuit low
P0223|1|Сензор на дросела/педала B – високо напрежение|Throttle/pedal position sensor B circuit high
P0224|1|Сензор на дросела/педала B – периодично|Throttle/pedal position sensor B intermittent
P0230|1|Горивна помпа – първична верига|Fuel pump primary circuit
P0231|1|Горивна помпа – ниско напрежение|Fuel pump secondary circuit low
P0232|1|Горивна помпа – високо напрежение|Fuel pump secondary circuit high
P0234|2|Турбо: свръхналягане|Turbo overboost condition|Може да е залепнала управляваща клапа или теч в управлението на турбото. Не натоварвайте двигателя.|May be a stuck control valve or a leak in the turbo control. Do not load the engine.
P0235|1|Сензор за наддувно налягане A – верига|Turbo boost pressure sensor A circuit
P0236|1|Сензор за наддувно налягане A – извън диапазона|Turbo boost pressure sensor A range/performance
P0237|1|Сензор за наддувно налягане A – ниско напрежение|Turbo boost pressure sensor A circuit low
P0238|1|Сензор за наддувно налягане A – високо напрежение|Turbo boost pressure sensor A circuit high
P0243|1|Wastegate клапан A – неизправност|Turbo wastegate solenoid A malfunction
P0245|1|Wastegate клапан A – ниско напрежение|Turbo wastegate solenoid A low
P0246|1|Wastegate клапан A – високо напрежение|Turbo wastegate solenoid A high
P0299|1|Турбо: недостатъчно наддуване|Turbo underboost condition|Чести причини: теч във въздушния тракт или интеркулера, неизправен клапан на турбото, запушен DPF или катализатор.|Common causes: a leak in the air path or intercooler, a faulty turbo valve, a clogged DPF or catalyst.
P0301|2|Пропуски в запалването – цилиндър 1|Cylinder 1 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0302|2|Пропуски в запалването – цилиндър 2|Cylinder 2 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0303|2|Пропуски в запалването – цилиндър 3|Cylinder 3 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0304|2|Пропуски в запалването – цилиндър 4|Cylinder 4 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0305|2|Пропуски в запалването – цилиндър 5|Cylinder 5 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0306|2|Пропуски в запалването – цилиндър 6|Cylinder 6 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0307|2|Пропуски в запалването – цилиндър 7|Cylinder 7 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0308|2|Пропуски в запалването – цилиндър 8|Cylinder 8 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0309|2|Пропуски в запалването – цилиндър 9|Cylinder 9 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0310|2|Пропуски в запалването – цилиндър 10|Cylinder 10 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0311|2|Пропуски в запалването – цилиндър 11|Cylinder 11 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0312|2|Пропуски в запалването – цилиндър 12|Cylinder 12 misfire detected|Проверете свещ, бобина и инжектор (бензин) или инжектор, подгревна свещ и компресия (дизел).|Check spark plug, coil and injector (petrol) or injector, glow plug and compression (diesel).
P0335|2|Сензор на коляновия вал A – верига|Crankshaft position sensor A circuit|Може да не запали или да загасне при движение.|The engine may not start or may stall while driving.
P0336|2|Сензор на коляновия вал A – извън диапазона|Crankshaft position sensor A range/performance|Може да не запали или да загасне при движение.|The engine may not start or may stall while driving.
P0337|2|Сензор на коляновия вал A – ниско напрежение|Crankshaft position sensor A circuit low|Може да не запали или да загасне при движение.|The engine may not start or may stall while driving.
P0338|2|Сензор на коляновия вал A – високо напрежение|Crankshaft position sensor A circuit high|Може да не запали или да загасне при движение.|The engine may not start or may stall while driving.
P0339|2|Сензор на коляновия вал A – периодично|Crankshaft position sensor A intermittent|Може да не запали или да загасне при движение.|The engine may not start or may stall while driving.
P0340|1|Сензор на разпределителния вал A (банка 1) – верига|Camshaft position sensor A (bank 1) circuit
P0341|1|Сензор на разпределителния вал A (банка 1) – извън диапазона|Camshaft position sensor A (bank 1) range/performance
P0342|1|Сензор на разпределителния вал A (банка 1) – ниско напрежение|Camshaft position sensor A (bank 1) circuit low
P0343|1|Сензор на разпределителния вал A (банка 1) – високо напрежение|Camshaft position sensor A (bank 1) circuit high
P0344|1|Сензор на разпределителния вал A (банка 1) – периодично|Camshaft position sensor A (bank 1) intermittent
P0351|2|Бобина за запалване A – верига|Ignition coil A primary/secondary circuit
P0352|2|Бобина за запалване B – верига|Ignition coil B primary/secondary circuit
P0353|2|Бобина за запалване C – верига|Ignition coil C primary/secondary circuit
P0354|2|Бобина за запалване D – верига|Ignition coil D primary/secondary circuit
P0355|2|Бобина за запалване E – верига|Ignition coil E primary/secondary circuit
P0356|2|Бобина за запалване F – верига|Ignition coil F primary/secondary circuit
P0380|1|Подгревна свещ/нагревател A – верига|Glow plug/heater circuit A
P0381|0|Лампа на подгревните свещи – верига|Glow plug indicator circuit
P0385|1|Сензор на коляновия вал B – верига|Crankshaft position sensor B circuit
P0400|1|EGR – неизправност на потока|EGR flow malfunction
P0401|1|EGR – недостатъчен поток|EGR flow insufficient|Често е запушен или залепнал EGR клапан или тръбопровод с нагар, особено при дизел.|Often a clogged or stuck EGR valve or a carbon-blocked pipe, especially on diesels.
P0402|1|EGR – прекомерен поток|EGR flow excessive|Често е залепнал отворен EGR клапан.|Often an EGR valve stuck open.
P0403|1|EGR – верига|EGR circuit malfunction
P0404|1|EGR – извън диапазона|EGR circuit range/performance
P0405|1|EGR сензор A – ниско напрежение|EGR sensor A circuit low
P0406|1|EGR сензор A – високо напрежение|EGR sensor A circuit high
P0410|1|Система за вторичен въздух – неизправност|Secondary air injection system malfunction
P0411|1|Система за вторичен въздух – неправилен поток|Secondary air injection incorrect flow
P0421|1|Катализатор (загряване) – ефективност под прага (банка 1)|Warm-up catalyst efficiency below threshold (bank 1)|Първо изключете пропуски и теч в ауспуха, после лямбда сондите.|First rule out misfires and exhaust leaks, then the oxygen sensors.
P0430|1|Катализатор – ефективност под прага (банка 2)|Catalyst efficiency below threshold (bank 2)|Първо изключете пропуски и теч в ауспуха, после лямбда сондите.|First rule out misfires and exhaust leaks, then the oxygen sensors.
P0431|1|Катализатор (загряване) – ефективност под прага (банка 2)|Warm-up catalyst efficiency below threshold (bank 2)|Първо изключете пропуски и теч в ауспуха, после лямбда сондите.|First rule out misfires and exhaust leaks, then the oxygen sensors.
P0440|0|Система за пари на горивото – неизправност|Evaporative emission system malfunction
P0441|0|Система за пари – неправилен поток при продухване|Evap incorrect purge flow
P0442|0|Система за пари – малък теч|Evap system small leak detected|Често е разхлабена капачка на резервоара – проверете я първо.|Often a loose fuel cap – check it first.
P0443|0|Клапан за продухване – верига|Evap purge control valve circuit
P0444|0|Клапан за продухване – отворена верига|Evap purge control valve circuit open
P0445|0|Клапан за продухване – късо съединение|Evap purge control valve circuit shorted
P0446|0|Вентилационен клапан – верига|Evap vent control circuit
P0447|0|Вентилационен клапан – отворена верига|Evap vent control circuit open
P0448|0|Вентилационен клапан – късо съединение|Evap vent control circuit shorted
P0449|0|Вентилационен клапан/електромагнит – верига|Evap vent valve/solenoid circuit
P0450|0|Сензор за налягане в системата за пари – верига|Evap system pressure sensor circuit
P0451|0|Сензор за налягане в системата за пари – извън диапазона|Evap system pressure sensor range/performance
P0452|0|Сензор за налягане в системата за пари – ниско напрежение|Evap system pressure sensor circuit low
P0453|0|Сензор за налягане в системата за пари – високо напрежение|Evap system pressure sensor circuit high
P0454|0|Сензор за налягане в системата за пари – периодично|Evap system pressure sensor intermittent
P0455|0|Система за пари – голям теч|Evap system large leak detected|Проверете капачката на резервоара и маркучите на системата за пари.|Check the fuel cap and the evap system hoses.
P0456|0|Система за пари – много малък теч|Evap system very small leak detected
P0457|0|Теч в системата за пари (разхлабена или липсваща капачка)|Evap leak detected (fuel cap loose or missing)|Затегнете или сменете капачката на резервоара и изчакайте няколко цикъла на шофиране.|Tighten or replace the fuel cap and allow several drive cycles.
P0460|0|Сензор за ниво на горивото – верига|Fuel level sensor circuit
P0461|0|Сензор за ниво на горивото – извън диапазона|Fuel level sensor range/performance
P0462|0|Сензор за ниво на горивото – ниско напрежение|Fuel level sensor circuit low
P0463|0|Сензор за ниво на горивото – високо напрежение|Fuel level sensor circuit high
P0464|0|Сензор за ниво на горивото – периодично|Fuel level sensor intermittent
P0480|1|Вентилатор на охлаждането 1 – верига|Cooling fan 1 control circuit
P0481|1|Вентилатор на охлаждането 2 – верига|Cooling fan 2 control circuit
P0500|1|Сензор за скорост на колата – верига|Vehicle speed sensor circuit
P0501|1|Сензор за скорост на колата – извън диапазона|Vehicle speed sensor range/performance
P0502|1|Сензор за скорост на колата – ниско напрежение|Vehicle speed sensor circuit low
P0503|1|Сензор за скорост на колата – периодично|Vehicle speed sensor intermittent
P0504|1|Спирачен превключвател A/B – несъответствие|Brake switch A/B correlation
P0505|1|Регулиране на празния ход – неизправност|Idle control system malfunction
P0506|1|Обороти на празен ход – по-ниски от очакваните|Idle speed lower than expected
P0507|1|Обороти на празен ход – по-високи от очакваните|Idle speed higher than expected|Често е замърсен дросел или теч във всмукването.|Often a dirty throttle body or an intake leak.
P0510|1|Превключвател на закрит дросел – верига|Closed throttle position switch circuit
P0520|1|Сензор за налягане на маслото – верига|Engine oil pressure sensor circuit
P0521|1|Сензор за налягане на маслото – извън диапазона|Engine oil pressure sensor range/performance
P0522|1|Сензор за налягане на маслото – ниско напрежение|Engine oil pressure sensor circuit low
P0523|1|Сензор за налягане на маслото – високо напрежение|Engine oil pressure sensor circuit high
P0524|2|Налягане на маслото – твърде ниско|Engine oil pressure too low|Спрете веднага и проверете нивото на маслото. Рискът е от сериозна повреда на двигателя.|Stop immediately and check the oil level. There is a risk of serious engine damage.
P0544|1|Сензор за температура на изгорелите газове (EGT) – верига (банка 1, сензор 1)|Exhaust gas temperature sensor circuit (bank 1, sensor 1)
P0545|1|Сензор за температура на изгорелите газове (EGT) – ниско напрежение|Exhaust gas temperature sensor circuit low (bank 1, sensor 1)
P0546|1|Сензор за температура на изгорелите газове (EGT) – високо напрежение|Exhaust gas temperature sensor circuit high (bank 1, sensor 1)
P0560|1|Напрежение на системата – неизправност|System voltage malfunction
P0561|1|Напрежение на системата – нестабилно|System voltage unstable
P0562|1|Напрежение на системата – ниско|System voltage low|Често: слаб акумулатор или генератор, лоша маса или клеми.|Often a weak battery or alternator, a poor ground or loose terminals.
P0563|1|Напрежение на системата – високо|System voltage high
P0571|0|Спирачен превключвател на круиз контрола – верига|Cruise control brake switch A circuit
P0600|1|Серийна комуникация между модулите – неизправност|Serial communication link malfunction
P0601|2|Памет на управляващия модул – грешка в контролната сума|Control module memory checksum error
P0602|2|Грешка в програмирането на управляващия модул|Control module programming error
P0603|1|Памет KAM на модула – грешка|Control module keep-alive memory error
P0604|2|RAM памет на модула – грешка|Control module RAM error
P0605|2|ROM памет на модула – грешка|Control module ROM error
P0606|2|Процесор на управляващия модул – неизправност|Control module processor fault
P0607|1|Управляващ модул – производителност|Control module performance
P0620|1|Генератор – верига за управление|Generator control circuit malfunction
P0630|0|VIN не е програмиран или не съвпада|VIN not programmed or mismatched
P0641|1|Захранване на сензорите A – прекъсната верига|Sensor reference voltage A circuit open
P0651|1|Захранване на сензорите B – прекъсната верига|Sensor reference voltage B circuit open
P0670|1|Модул на подгревните свещи – верига|Glow plug module control circuit
P0671|1|Подгревна свещ – цилиндър 1 – верига|Cylinder 1 glow plug circuit
P0672|1|Подгревна свещ – цилиндър 2 – верига|Cylinder 2 glow plug circuit
P0673|1|Подгревна свещ – цилиндър 3 – верига|Cylinder 3 glow plug circuit
P0674|1|Подгревна свещ – цилиндър 4 – верига|Cylinder 4 glow plug circuit
P0683|1|Връзка между модула на подгревните свещи и ECU|Glow plug control module to PCM communication circuit
P0685|1|Реле на захранването на ECU – прекъсната верига|ECM power relay control circuit open
P0700|1|Система за управление на скоростната кутия – неизправност|Transmission control system malfunction|Показва, че в кутията има по-подробни кодове – прочетете ги със специализиран скенер.|Indicates the transmission has more detailed codes – read them with a specialised scanner.
P0701|1|Управление на скоростната кутия – извън диапазона|Transmission control system range/performance
P0702|1|Управление на скоростната кутия – електрическа грешка|Transmission control system electrical
P0703|1|Спирачен превключвател B – верига|Brake switch B circuit
P0705|1|Сензор за положение на лоста на кутията – верига|Transmission range sensor circuit
P0706|1|Сензор за положение на лоста на кутията – извън диапазона|Transmission range sensor range/performance
P0710|1|Сензор за температура на маслото в кутията – верига|Transmission fluid temperature sensor circuit
P0711|1|Сензор за температура на маслото в кутията – извън диапазона|Transmission fluid temperature sensor range/performance
P0712|1|Сензор за температура на маслото в кутията – ниско|Transmission fluid temperature sensor circuit low
P0713|1|Сензор за температура на маслото в кутията – високо|Transmission fluid temperature sensor circuit high
P0715|1|Сензор за входящи обороти на кутията – верига|Input/turbine speed sensor circuit
P0716|1|Сензор за входящи обороти на кутията – извън диапазона|Input/turbine speed sensor range/performance
P0720|1|Сензор за изходящи обороти на кутията – верига|Output speed sensor circuit
P0721|1|Сензор за изходящи обороти на кутията – извън диапазона|Output speed sensor range/performance
P0725|1|Вход за обороти на двигателя към кутията – верига|Engine speed input circuit
P0730|1|Грешно предавателно отношение|Incorrect gear ratio
P0731|1|Грешно предавателно отношение – предавка 1|Gear 1 incorrect ratio
P0732|1|Грешно предавателно отношение – предавка 2|Gear 2 incorrect ratio
P0733|1|Грешно предавателно отношение – предавка 3|Gear 3 incorrect ratio
P0734|1|Грешно предавателно отношение – предавка 4|Gear 4 incorrect ratio
P0735|1|Грешно предавателно отношение – предавка 5|Gear 5 incorrect ratio
P0740|1|Съединител на хидротрансформатора – верига|Torque converter clutch circuit
P0741|1|Съединител на хидротрансформатора – не се включва|Torque converter clutch stuck off or performance
P0742|1|Съединител на хидротрансформатора – залепнал включен|Torque converter clutch stuck on
P0743|1|Съединител на хидротрансформатора – електрическа грешка|Torque converter clutch electrical
P0746|1|Електромагнит за налягане A – неизправност|Pressure control solenoid A performance
P0750|1|Превключващ електромагнит A – верига|Shift solenoid A circuit
P0751|1|Превключващ електромагнит A – неизправност|Shift solenoid A performance
P0755|1|Превключващ електромагнит B – верига|Shift solenoid B circuit
P0760|1|Превключващ електромагнит C – верига|Shift solenoid C circuit
P0765|1|Превключващ електромагнит D – верига|Shift solenoid D circuit
P0770|1|Превключващ електромагнит E – верига|Shift solenoid E circuit
P0780|1|Неизправност при превключване на предавките|Shift malfunction
P0781|1|Неизправност при превключване 1-2|1-2 shift malfunction
P0782|1|Неизправност при превключване 2-3|2-3 shift malfunction
P0783|1|Неизправност при превключване 3-4|3-4 shift malfunction
P0784|1|Неизправност при превключване 4-5|4-5 shift malfunction
P0790|1|Превключвател нормален/спортен режим – верига|Normal/performance switch circuit
P2002|1|DPF – ефективност под прага (банка 1)|Diesel particulate filter efficiency below threshold (bank 1)|Често е запушен DPF: може да помогне регенерация (по-дълго пътуване при по-високи обороти) или нужен сервиз.|Often a clogged DPF: a regeneration (a longer drive at higher revs) may help, or a workshop is needed.
P2080|1|EGT сензор – извън диапазона (банка 1, сензор 1)|EGT sensor range/performance (bank 1, sensor 1)
P2081|1|EGT сензор – периодично (банка 1, сензор 1)|EGT sensor intermittent (bank 1, sensor 1)
P2096|1|Корекция след катализатора – твърде бедна (банка 1)|Post catalyst fuel trim too lean (bank 1)
P2097|1|Корекция след катализатора – твърде богата (банка 1)|Post catalyst fuel trim too rich (bank 1)
P20EE|1|SCR катализатор (NOx) – ефективност под прага (банка 1)|SCR NOx catalyst efficiency below threshold (bank 1)|Проверете нивото и качеството на AdBlue; ако кодът продължава, посетете сервиз.|Check the AdBlue level and quality; if the code persists, visit a workshop.
P2100|1|Мотор на дроселовата клапа – верига|Throttle actuator control motor circuit
P2101|1|Мотор на дроселовата клапа – извън диапазона|Throttle actuator control motor range/performance
P2102|1|Мотор на дроселовата клапа – ниско напрежение|Throttle actuator control motor circuit low
P2103|1|Мотор на дроселовата клапа – високо напрежение|Throttle actuator control motor circuit high
P2106|2|Дросел – принудително ограничена мощност|Throttle actuator forced limited power
P2135|1|Сензори на дросела/педала – несъответствие|Throttle/pedal position sensor correlation
P2195|1|Лямбда сонда – застинала бедна (банка 1, сензор 1)|O2 sensor signal stuck lean (bank 1, sensor 1)
P2196|1|Лямбда сонда – застинала богата (банка 1, сензор 1)|O2 sensor signal stuck rich (bank 1, sensor 1)
P2279|1|Теч във всмукателния тракт|Intake air system leak
P2413|1|EGR – неизправност|EGR system performance
P244A|1|DPF – диференциално налягане твърде ниско|DPF differential pressure too low
P244B|1|DPF – диференциално налягане твърде високо|DPF differential pressure too high|Често е запушен DPF: може да помогне регенерация (по-дълго пътуване при по-високи обороти) или нужен сервиз.|Often a clogged DPF: a regeneration (a longer drive at higher revs) may help, or a workshop is needed.
P2452|1|Сензор за налягане на DPF – верига|DPF pressure sensor circuit
P2453|1|Сензор за налягане на DPF – извън диапазона|DPF pressure sensor range/performance
P2454|1|Сензор за налягане на DPF – ниско напрежение|DPF pressure sensor circuit low
P2455|1|Сензор за налягане на DPF – високо напрежение|DPF pressure sensor circuit high
P2458|1|DPF – продължителност на регенерацията|DPF regeneration duration
P2459|1|DPF – честота на регенерацията|DPF regeneration frequency
P2463|1|DPF – запушване със сажди|DPF restriction soot accumulation|Често е запушен DPF: може да помогне регенерация (по-дълго пътуване при по-високи обороти) или нужен сервиз.|Often a clogged DPF: a regeneration (a longer drive at higher revs) may help, or a workshop is needed.
U0001|1|CAN шина (висока скорост) – комуникация|High-speed CAN communication bus
U0073|1|Шина за комуникация A – изключена|Control module communication bus A off
U0100|1|Загубена връзка с ECU/PCM|Lost communication with ECM/PCM A|Често е проблем със захранване, маса или CAN връзка; проверете акумулатора и клемите.|Often a power, ground or CAN wiring problem; check the battery and terminals.
U0101|1|Загубена връзка с модула на скоростната кутия|Lost communication with TCM
U0121|1|Загубена връзка с ABS модула|Lost communication with ABS control module
U0140|1|Загубена връзка с модула на каросерията|Lost communication with body control module
U0155|1|Загубена връзка с таблото|Lost communication with instrument cluster
''';
