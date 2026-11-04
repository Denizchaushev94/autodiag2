import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
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
  'warn2': ['AutoDiag показва грешки от автомобила и обяснява какво може да означават. Информацията е ориентировъчна и не заменя преглед от механик. Не използвайте телефона, докато шофирате.', 'AutoDiag reads fault codes from your vehicle and explains what they may mean. The information is indicative and does not replace a mechanic. Do not use your phone while driving.'],
  'hint': ['Закачете адаптера в OBD порта, включете запалването и натиснете „Търси адаптер“.', 'Plug the adapter into the OBD port, turn the ignition on and tap "Find adapter".'],
};
String t(String k) => _S[k]![lang.value == 'bg' ? 0 : 1];
 
// ---------- обяснения: [bg, en] -> [заглавие, описание, действия, разделени с |] ----------
const Map<String, List<List<String>>> dtcDb = {
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
 
const sev = <String, int>{'P0087': 2, 'P0101': 1, 'P0171': 1, 'P0300': 2, 'P0420': 1};
Color sevColor(int v) => v >= 2 ? Colors.red : (v == 1 ? Colors.orange : Colors.blueGrey);
 
// ---------- ELM327 по Bluetooth LE ----------
class Elm {
  final BluetoothDevice dev;
  BluetoothCharacteristic? wr, nt;
  final _buf = StringBuffer();
  Completer<String>? _c;
  StreamSubscription? _sub;
  Future<void> _last = Future.value();
  final bool demo;
  Elm(this.dev) : demo = false;
  Elm.demo()
      : dev = BluetoothDevice.fromId('00:00:00:00:00:00'),
        demo = true;
  String get name => demo ? 'Demo' : dev.platformName;
 
  Future<void> open() async {
    if (demo) return;
    await dev.connect(timeout: const Duration(seconds: 15));
    final svcs = await dev.discoverServices();
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
    if (nt == null || wr == null) throw Exception('UART');
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
    if (cmd == '03') return '43 03 00 87 01 71 04 20';
    if (cmd == 'ATRV') return '13.8V';
    if (cmd.startsWith('AT')) return 'OK';
    switch (cmd) {
      case '0100': return '41 00 BE 3F A8 13';
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
final connected = ValueNotifier<bool>(false);
final lastCodes = ValueNotifier<List<String>?>(null);
 
List<String> parseDtc(String raw) {
  final sb = StringBuffer();
  for (var line in raw.toUpperCase().split(RegExp(r'[\r\n]+'))) {
    line = line.replaceAll(' ', '').replaceFirst(RegExp(r'^[0-9A-F]:'), '');
    if (line.isEmpty || line.length == 3 || !RegExp(r'^[0-9A-F]+$').hasMatch(line)) continue;
    sb.write(line);
  }
  final h = sb.toString();
  final i = h.indexOf('43');
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
  for (var k = 0; k + 2 <= d.length && b.length < 4; k += 2) {
    b.add(int.parse(d.substring(k, k + 2), radix: 16));
  }
  if (b.isEmpty) return null;
  try { return f(b); } catch (_) { return null; }
}
 
Future<void> saveHist(List<String> codes) async {
  final p = await SharedPreferences.getInstance();
  final l = p.getStringList('hist') ?? [];
  l.insert(0, jsonEncode({'t': DateTime.now().toIso8601String(), 'c': codes}));
  await p.setStringList('hist', l.take(10).toList());
}
 
// ---------- параметри на живо ----------
class Pid {
  final String id, bg, en, unit;
  final int dec;
  final double Function(List<int>) f;
  Pid(this.id, this.bg, this.en, this.unit, this.dec, this.f);
  String get name => lang.value == 'bg' ? bg : en;
}
 
final pids = <Pid>[
  Pid('05', 'Температура на водата', 'Coolant temperature', '°C', 0, (b) => b[0] - 40.0),
  Pid('5C', 'Температура на маслото', 'Engine oil temperature', '°C', 0, (b) => b[0] - 40.0),
  Pid('0B', 'MAP – налягане във всмукателния колектор', 'MAP – intake pressure', 'kPa', 0, (b) => b[0].toDouble()),
  Pid('0C', 'Обороти', 'Engine speed', 'rpm', 0, (b) => (b[0] * 256 + b[1]) / 4),
  Pid('0D', 'Скорост', 'Speed', 'km/h', 0, (b) => b[0].toDouble()),
  Pid('0F', 'Температура на всмукания въздух', 'Intake air temperature', '°C', 0, (b) => b[0] - 40.0),
  Pid('11', 'Дроселова клапа', 'Throttle position', '%', 0, (b) => b[0] * 100 / 255),
  Pid('04', 'Натоварване на двигателя', 'Engine load', '%', 0, (b) => b[0] * 100 / 255),
  Pid('0A', 'Налягане на горивото (ниско)', 'Fuel pressure (gauge)', 'kPa', 0, (b) => b[0] * 3.0),
  Pid('23', 'Налягане в горивната рейка', 'Fuel rail pressure', 'kPa', 0, (b) => (b[0] * 256 + b[1]) * 10.0),
  Pid('10', 'Масов разход на въздух (MAF)', 'Mass air flow (MAF)', 'g/s', 1, (b) => (b[0] * 256 + b[1]) / 100),
  Pid('2F', 'Ниво на горивото', 'Fuel level', '%', 0, (b) => b[0] * 100 / 255),
  Pid('RV', 'Напрежение на акумулатора', 'Battery voltage', 'V', 1, (b) => 0),
];
 
// ---------- приложение ----------
void main() => runApp(App());
 
class App extends StatelessWidget {
  App({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<String>(
      valueListenable: lang,
      builder: (_, __, ___) => MaterialApp(
            title: 'AutoDiag',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(colorSchemeSeed: const Color(0xFF0B5FA5), useMaterial3: true),
            darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF0B5FA5), brightness: Brightness.dark, useMaterial3: true),
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
          title: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.car_repair), const SizedBox(width: 8), const Text('AutoDiag')]),
          actions: [
            IconButton(icon: const Icon(Icons.info_outline), tooltip: t('about'), onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => AboutPage()))),
            TextButton(onPressed: () => lang.value = lang.value == 'bg' ? 'en' : 'bg', child: Text(lang.value == 'bg' ? 'EN' : 'БГ')),
          ],
        ),
        body: [ScanTab(), LiveTab(), HistTab()][i],
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: (v) => setState(() => i = v),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.car_repair), label: t('scan')),
            NavigationDestination(icon: const Icon(Icons.speed), label: t('live')),
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
      elm = e;
      connected.value = true;
      msg = '';
    } catch (x) {
      msg = '${t('error')}: $x';
    }
    if (mounted) setState(() => busy = false);
  }
 
  void startDemo() {
    elm = Elm.demo();
    connected.value = true;
  }
 
  Future<void> readCodes() async {
    setState(() { busy = true; msg = t('reading'); });
    try {
      final codes = parseDtc(await elm!.send('03', ms: 8000));
      lastCodes.value = codes;
      await saveHist(codes);
      msg = '';
    } catch (x) {
      msg = '${t('error')}: $x';
    }
    if (mounted) setState(() => busy = false);
  }
 
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
      valueListenable: connected,
      builder: (_, on, __) => ListView(padding: const EdgeInsets.all(16), children: [
            if (msg.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(msg)),
            if (busy) const LinearProgressIndicator(),
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
              ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text('${t('connected')}: ${elm?.name ?? ''}')),
              FilledButton.icon(onPressed: busy ? null : readCodes, icon: const Icon(Icons.search), label: Text(t('read'))),
              TextButton(
                onPressed: () async { await elm?.close(); elm = null; connected.value = false; },
                child: Text(t('disconnect')),
              ),
              ValueListenableBuilder<List<String>?>(
                valueListenable: lastCodes,
                builder: (_, cs, __) => cs == null
                    ? const SizedBox()
                    : cs.isEmpty
                        ? Padding(padding: const EdgeInsets.all(16), child: Text(t('none')))
                        : Column(children: [
                            for (final k in cs)
                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.warning_amber, color: sevColor(sev[k] ?? 1)),
                                  title: Text(k),
                                  subtitle: Text(dtcDb[k]?[lang.value == 'bg' ? 0 : 1][0] ?? '—'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CodePage(k))),
                                ),
                              ),
                          ]),
              ),
            ],
          ]));
}
 
class CodePage extends StatelessWidget {
  final String code;
  CodePage(this.code, {super.key});
  @override
  Widget build(BuildContext c) {
    final d = dtcDb[code]?[lang.value == 'bg' ? 0 : 1];
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
        if (d != null) ...[
          const SizedBox(height: 16),
          Text(t('actions'), style: Theme.of(c).textTheme.titleMedium),
          for (final a in d[2].split('|')) ListTile(dense: true, leading: const Icon(Icons.check_circle_outline), title: Text(a)),
        ],
        const SizedBox(height: 24),
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
 
  Future<void> loop() async {
    while (run && mounted && elm != null) {
      final ids = sel.toList();
      if (ids.isEmpty) { await Future.delayed(const Duration(milliseconds: 500)); continue; }
      for (final id in ids) {
        if (!run || !mounted || elm == null) return;
        String v;
        try {
          if (id == 'RV') {
            v = (await elm!.send('ATRV', ms: 1500)).replaceAll(RegExp(r'[\r\n]'), ' ').trim();
          } else {
            final p = pids.firstWhere((x) => x.id == id);
            final n = pidVal(await elm!.send('01$id', ms: 2500), id, p.f);
            v = n == null ? t('na') : '${n.toStringAsFixed(p.dec)} ${p.unit}';
          }
        } catch (_) {
          v = t('na');
        }
        if (mounted) setState(() => vals[id] = v);
      }
    }
  }
 
  @override
  Widget build(BuildContext c) {
    if (elm == null) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(t('noconn'))));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(t('pick'), style: Theme.of(c).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final p in pids)
          FilterChip(
            label: Text(p.name),
            selected: sel.contains(p.id),
            onSelected: (s) => setState(() => s ? sel.add(p.id) : sel.remove(p.id)),
          ),
      ]),
      const SizedBox(height: 8),
      Text(t('trans'), style: Theme.of(c).textTheme.bodySmall),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
        children: [
          for (final id in sel)
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
    final codes = List<String>.from(m['c']);
    final d = DateTime.parse(m['t']).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return Card(
      child: ListTile(
        title: Text('${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}'),
        subtitle: codes.isEmpty
            ? Text(t('none'))
            : Wrap(spacing: 6, children: [
                for (final k in codes)
                  ActionChip(label: Text(k), onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => CodePage(k)))),
              ]),
      ),
    );
  }
}
 
 
// ---------- За приложението ----------
const kVersion = '0.2.0';
const kContact = 'support@example.com'; // СМЕНЕТЕ с вашия имейл за контакт
 
const _T = <String, List<String>>{
  'privacy': [
    'AutoDiag не изисква регистрация и не събира лични данни.\n\nДанните от автомобила (грешки и показания) и историята на сканиранията се съхраняват само на вашия телефон и не се изпращат към сървър или трети страни.\n\nBluetooth се използва само за връзка с вашия OBD адаптер. Android изисква разрешение за местоположение, за да търси Bluetooth устройства; приложението не следи и не записва местоположението ви.\n\nМожете да изтриете историята, като изчистите данните на приложението от настройките на телефона.\n\nАко в бъдеще бъдат добавени реклами или покупки, тази политика ще бъде обновена и ще бъде поискано вашето съгласие, където е необходимо.',
    'AutoDiag does not require registration and does not collect personal data.\n\nVehicle data (fault codes and readings) and your scan history are stored only on your phone and are not sent to any server or third party.\n\nBluetooth is used only to connect to your OBD adapter. Android requires the location permission to search for Bluetooth devices; the app does not track or record your location.\n\nYou can delete the history by clearing the app data in your phone settings.\n\nIf ads or purchases are added in the future, this policy will be updated and your consent will be requested where required.',
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
          const Center(child: Icon(Icons.car_repair, size: 64)),
          const SizedBox(height: 8),
          Center(child: Text('AutoDiag', style: Theme.of(c).textTheme.headlineMedium)),
          Center(child: Text(t('tagline'))),
          Center(child: Text('${t('version')} $kVersion', style: Theme.of(c).textTheme.bodySmall)),
          const SizedBox(height: 16),
          _row(c, Icons.directions_car, 'supported'),
          _row(c, Icons.privacy_tip_outlined, 'privacy'),
          _row(c, Icons.gavel, 'terms'),
          ListTile(leading: const Icon(Icons.mail_outline), title: Text(t('contact')), subtitle: Text(kContact)),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(t('licenses')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: c, applicationName: 'AutoDiag', applicationVersion: kVersion),
          ),
          Padding(padding: const EdgeInsets.all(16), child: Text(t('warn'), style: Theme.of(c).textTheme.bodySmall)),
        ]),
      );
}
 
