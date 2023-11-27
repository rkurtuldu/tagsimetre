import 'package:flutter/material.dart';
import 'package:tagsimetre/add.dart';
import 'package:tagsimetre/expense.dart';
import 'package:tagsimetre/help.dart';
import 'package:tagsimetre/settings.dart';
import 'package:tagsimetre/total_km.dart';
import 'package:tagsimetre/trip_list.dart';
import 'expense_list.dart';
import 'sql_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart'
;
var addDate = DateFormat("dd-MM-yyyy").format(DateTime.now());

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialColor gri = MaterialColor(
      const Color.fromRGBO(66, 66, 66, 1).value,
      const <int, Color>{
        50: Color.fromRGBO(110, 110, 110, 0.1),
        100: Color.fromRGBO(110, 110, 110, 0.2),
        200: Color.fromRGBO(110, 110, 110, 0.3),
        300: Color.fromRGBO(110, 110, 110, 0.4),
        400: Color.fromRGBO(110, 110, 110, 0.5),
        500: Color.fromRGBO(110, 110, 110, 0.6),
        600: Color.fromRGBO(110, 110, 110, 0.7),
        700: Color.fromRGBO(110, 110, 110, 0.8),
        800: Color.fromRGBO(113, 113, 113, 0.9),
        900: Color.fromRGBO(113, 113, 113, 1),
      },
    );
    return MaterialApp(
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr'),
          Locale('en')
        ],
        title: 'TAGsimetre',
        theme: ThemeData(primarySwatch: gri,
            useMaterial3: false
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isSelected = [false, true, false];
  var eksikKmTarih = [];
  var missingKmDates = [];
  var eksikSureTarih = [];
  var missingTimeDates = [];
  late double yakitData;
  late double yakitTutariData;
  final TextEditingController yakitController = TextEditingController();

  bool _isLoading = true;
  bool isFuelLoading = true;
  bool isMissingDates = true;

  late int yolculukSayisiGunluk;
  late num yolculukMesafesiGunluk;
  late num ciroGunluk;
  late double netKazancGunluk;
  late double yakitTutariGunluk;

  var bugun = DateFormat("dd-MM-yyyy").format(DateTime.now());
  var ayYil = DateFormat("MM-yyyy").format(DateTime.now());

  late int yolculukSayisiAylik;
  late num yolculukMesafesiAylik;
  late num ciroAylik;
  late double netKazancAylik;
  late double yakitTutariAylik;
  late num toplamKm;
  late double ortalamaNet;
  late double ortalamaToplamNet;
  late double saatlikOrtalamaNet;
  late String toplamSure;
  late num toplamMasraf;
  late double ortalamaYolculukNet;
  late num minutes;
  late bool kmMode;
  late bool timeMode;

  Future<void> mailto() async {
    final Email email = Email(

      subject: "TAGsimetre",
      recipients: ["tagsimetre@gmail.com"],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hata! tagsimetre@gmail.com adresine mail göndermeyi deneyin"),
        ),
      );
    }
    if (!mounted) return;
  }

  void refreshTrips() async {
    List yakit;
    yakit = await SQLHelper.getFuelType();
    if (yakit.isEmpty) {
      await SQLHelper.setFuelType();
    }
    if (yakit.isNotEmpty) {
      if (yakit[0]['yakitTuru'] == 1) {
        isSelected = [true, false, false];
      } else if (yakit[0]['yakitTuru'] == 2) {
        isSelected = [false, true, false];
      } else if (yakit[0]['yakitTuru'] == 3) {
        isSelected = [false, false, true];
      }
    }

    List mod;
    mod = await SQLHelper.getMode();
    if (mod.isEmpty) {
      await SQLHelper.setMode();
      mod = await SQLHelper.getMode();
    }
    for (var element in mod) {
      if (element['kmMode'] == 1) {
        kmMode = true;
      } else {
        kmMode = false;
      }
      if (element['timeMode'] == 1) {
        timeMode = true;
      } else {
        timeMode = false;
      }
    }
    final consump = await SQLHelper.getConsumption();

    yolculukSayisiGunluk = 0;
    yolculukMesafesiGunluk = 0;
    ciroGunluk = 0;
    netKazancGunluk = 0.0;
    yakitTutariGunluk = 0.0;

    final daily = await SQLHelper.getDailyTrips(bugun);
    for (var element in daily) {
      yolculukSayisiGunluk++;
      yolculukMesafesiGunluk += element["mesafe"];
      ciroGunluk += element["brut"];
      yakitTutariGunluk += element["yakitTutari"];
    }
    netKazancGunluk = ciroGunluk - yakitTutariGunluk;

    yolculukSayisiAylik = 0;
    yolculukMesafesiAylik = 0;
    ciroAylik = 0;
    netKazancAylik = 0.0;
    yakitTutariAylik = 0.0;
    toplamKm = 0;
    ortalamaNet = 0.0;
    ortalamaToplamNet = 0.0;
    saatlikOrtalamaNet = 0.0;
    ortalamaYolculukNet = 0.0;
    toplamMasraf = 0;
    toplamSure = "0:00";
    minutes = 0;
    yakitTutariData = 0.0;

    final monthly = await SQLHelper.getTrips(ayYil);
    for (var element in monthly) {
      yolculukSayisiAylik++;
      yolculukMesafesiAylik += element["mesafe"];
      ciroAylik += element["brut"];
      yakitTutariData += element["yakitTutari"];
    }
    final total = await SQLHelper.getMonthlyTotal(ayYil);
    final masraf = await SQLHelper.getExpense(ayYil);
    for (var element in masraf) {
      toplamMasraf += element["masraf"];
    }

    if (total.isNotEmpty & kmMode == true) {
      for (var element in total) {
        toplamKm += element["toplamKm"];
        yakitTutariAylik += element['gunlukYakitTutari'];
      }
    } else {
      yakitTutariAylik = yakitTutariData;
    }

    if (monthly.isNotEmpty) {
      netKazancAylik = ciroAylik - yakitTutariAylik - toplamMasraf;
      ortalamaNet = netKazancAylik / yolculukMesafesiAylik;
      ortalamaYolculukNet = netKazancAylik / yolculukSayisiAylik;
      if (kmMode) {
        ortalamaToplamNet = netKazancAylik / toplamKm;
      } else {
        ortalamaToplamNet = 0.0;
      }
    }


    final sure = await SQLHelper.getMonthlyTime(ayYil);
    for (var element in sure) {
      minutes += element["sure"];
    }
    if (sure.isNotEmpty & timeMode == true) {
      toplamSure =
          "${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}";
      saatlikOrtalamaNet = netKazancAylik / (minutes / 60);
    }

    missingKmDates = await SQLHelper.getMissingKmDates();
    missingTimeDates = await SQLHelper.getMissingTimeDates();
    eksikKmTarih = missingKmDates.toSet().toList();
    eksikSureTarih = missingTimeDates.toSet().toList();
    eksikKmTarih.remove(bugun);
    eksikSureTarih.remove(bugun);

    if (eksikSureTarih.isNotEmpty || eksikKmTarih.isNotEmpty) {
      if (kmMode & timeMode) {
        addDate = {...eksikSureTarih, ...eksikKmTarih}.toList()[0].toString();
      } else if (kmMode & !timeMode) {
        if (eksikKmTarih.isNotEmpty) {
          addDate = eksikKmTarih[0].toString();
        }
      } else if (!kmMode & timeMode) {
        if (eksikSureTarih.isNotEmpty) {
          addDate = eksikSureTarih[0].toString();
        }
      }
    } else {
      addDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    }

    setState(() {
      _isLoading = false;

      if (consump.isNotEmpty) {
        isFuelLoading = false;
      }
      if (!kmMode & !timeMode) {
        isMissingDates = false;
      } else if (!kmMode & timeMode) {
        if (eksikSureTarih.isEmpty) {
          isMissingDates = false;
        }
      } else if (kmMode & !timeMode) {
        if (eksikKmTarih.isEmpty) {
          isMissingDates = false;
        }
      } else if (kmMode & timeMode) {
        if (eksikKmTarih.isEmpty & eksikSureTarih.isEmpty) {
          isMissingDates = false;
        }
      }
    });
  }

  void fuelUpdate() async {
    if (isSelected[0] == true) {
      await SQLHelper.updateFuelType(1);
    } else if (isSelected[1] == true) {
      await SQLHelper.updateFuelType(2);
    } else if (isSelected[2] == true) {
      await SQLHelper.updateFuelType(3);
    }
  }

  @override
  void initState() {
    super.initState();
    refreshTrips();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isFuelLoading ? false : true,
      child: Scaffold(
        drawer: isFuelLoading
            ? null
            : Drawer(
                child: ListView(
                children: [
                  const SizedBox(
                      height: 100,
                      child: DrawerHeader(
                          margin: EdgeInsets.only(top: 15),
                          child: Text(
                            "TAGsimetre",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Anasayfa"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const HomePage();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle),
                    title: const Text("Yolculuk Ekle"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const AddTrip();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text("İstatistikler"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const TripList();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.no_crash),
                    title: const Text("Gün Sonu Ekle"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const TotalKmTime();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.currency_lira),
                    title: const Text("Masraf Ekle"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const Expense();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text("Masraf Listesi"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const ExpenseList();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Ayarlar"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const Settings();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text("Yardım"),
                    onTap:() {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const Help();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.mail),
                    title: const Text("Destek (e-posta)"),
                    onTap:() {
                      mailto();
                    },
                  ),
                ],
              )),
        appBar: AppBar(
          title: const Text("TAGsimetre"),
          centerTitle: true,
        ),
        bottomNavigationBar: isFuelLoading
            ? null
            : Container(
                height: 70,
                color: const Color.fromRGBO(66, 66, 66, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const HomePage();
                        }));
                      },
                      icon: const Icon(Icons.home),
                      color: Colors.grey,
                      iconSize: 40,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const AddTrip();
                        }));
                      },
                      icon: const Icon(Icons.add_circle),
                      color: Colors.white,
                      iconSize: 40,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const TripList();
                        }));
                      },
                      icon: const Icon(Icons.bar_chart),
                      color: Colors.white,
                      iconSize: 40,
                    ),
                  ],
                )),
        body: _isLoading
            ?  const Center(
                child: CircularProgressIndicator()
              )
            : RefreshIndicator(
                onRefresh: () async {
                  refreshTrips();
                },
                child: isFuelLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 40),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Başlamak için aracınızın 100 kilometredeki yakıt "
                                "tüketimini litre olarak girin",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Küsurat için nokta kullanın (6.7 şeklinde)",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: yakitController,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.local_gas_station),
                                    label: Text("Litre/100 Km Yakıt Tüketimi")),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                  "Seçtiğiniz yakıt türüne göre yolculuk ekleme ekranında \"Yakıt Fiyatı\" bölümü "
                                  "otomatik olarak \"Opet Avrupa Yakası\" fiyatlarına göre doldurulacaktır. (LPG Hariç) ",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                  "Otomatik gelen fiyatı değiştirerek farklı bir fiyat girmeniz halinde aynı gün içerisinde yeni yolculuk "
                                  "eklerken son değiştirdiğiniz fiyat otomatik olarak gelecektir.",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(
                                height: 15,
                              ),
                              ToggleButtons(
                                constraints: const BoxConstraints(
                                    maxWidth: 100, minWidth: 70, minHeight: 35),
                                onPressed: (int index) {
                                  setState(() {
                                    for (int i = 0;
                                        i < isSelected.length;
                                        i++) {
                                      isSelected[i] = i == index;
                                    }
                                  });
                                  fuelUpdate();
                                },
                                selectedBorderColor:
                                    const Color.fromRGBO(66, 66, 66, 1),
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromRGBO(66, 66, 66, 1),
                                borderWidth: 2,
                                fillColor: const Color.fromRGBO(66, 66, 66, 1),
                                selectedColor: Colors.white,
                                isSelected: isSelected,
                                children: const [
                                  Text("Benzin"),
                                  Text("Dizel"),
                                  Text("LPG"),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  if (yakitController.text.isNotEmpty &
                                      (double.tryParse(yakitController.text
                                              .replaceAll(",", ".")) !=
                                          null)) {
                                    yakitData = double.parse(yakitController
                                        .text
                                        .replaceAll(",", "."));
                                    await SQLHelper.setConsumption(yakitData);
                                    yakitController.text = '';
                                    if (!mounted) return;
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) {
                                      return const HomePage();
                                    }));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("İşlem Kaydedildi")));
                                  } else if (yakitController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Eksik Bilgi Girdiniz")));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Yalnızca Rakam ve Nokta Kullanarak Giriniz (6.8 şeklinde) ")));
                                  }
                                },
                                label: const Text('Kaydet'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : isMissingDates
                        ? AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  kmMode
                                      ? timeMode
                                          ? Column(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20),
                                                  child: Text(
                                                      "Aşağıdaki Tarih(ler) için Çalışma Süresi ve Toplam Km Girmelisiniz",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Text(({
                                                  ...eksikSureTarih,
                                                  ...eksikKmTarih
                                                }.join(" , "))),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20),
                                                  child: Text(
                                                      "Aşağıdaki Tarih(ler) için Toplam Km Girmelisiniz",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Text(eksikKmTarih.join(" , ")),
                                              ],
                                            )
                                      : Column(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20),
                                              child: Text(
                                                  "Aşağıdaki Tarih(ler) için Çalışma Süresi Girmelisiniz",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Text(eksikSureTarih.join(" , ")),
                                          ],
                                        ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return const Settings();
                                          }));
                                        },
                                        label: const Text("Ayarlar",
                                            style: TextStyle(fontSize: 16)),
                                        icon: const Icon(Icons.settings),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          refreshTrips();
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return const TotalKmTime();
                                          }));
                                        },
                                        label: const Text("Ekle",
                                            style: TextStyle(fontSize: 16)),
                                        icon: const Icon(Icons.add_circle),
                                      )
                                    ],
                                  ),
                                  const Text(
                                      "Bu alanları kullanmak istemiyorsanız ayarlardan "
                                      "bu alanları kapatarak uyarı almayı durdurabilirsiniz.",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center),
                                ]),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Card(
                                    elevation: 5,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(children: [
                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          child: const Text(
                                              "Bugünün Yolculuk Özeti",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Yolculuk Sayısı",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    yolculukSayisiGunluk
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Yolculuk Mesafesi",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${yolculukMesafesiGunluk.toString()} Km",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Ciro",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${ciroGunluk.toString()} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Net Kazanç",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${netKazancGunluk.toStringAsFixed(0)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Card(
                                    elevation: 5,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(children: [
                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          child: const Text(
                                              "Bu Ayın Yolculuk Özeti",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Yolculuk Sayısı",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    yolculukSayisiAylik
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Yolculuk Mesafesi",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${yolculukMesafesiAylik.toString()} km",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Ciro",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${ciroAylik.toString()} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Net Kazanç",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${netKazancAylik.toStringAsFixed(0)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text("Toplam Km",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${toplamKm.toString()} Km",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 55,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text(
                                                    "Toplam Yakıt Tutarı",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${yakitTutariAylik.toStringAsFixed(0)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 90,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text(
                                                    "Km Başına Ortalama Net Kazanç",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                                const Text(
                                                    "(Yolculu Km Üzerinden)",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                Text(
                                                    "${ortalamaNet.toStringAsFixed(2)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 90,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text(
                                                    "Km Başına Ortalama Net Kazanç",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center),
                                                const Text(
                                                    "(Toplam Km Üzerinden)",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                Text(
                                                    "${ortalamaToplamNet.toStringAsFixed(2)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 90,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text(
                                                    "Saat Başına Ortalama Net Kazanç",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.center),
                                                Text(
                                                    "${saatlikOrtalamaNet.toStringAsFixed(2)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 90,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text(
                                                    "Yolculuk Başına Ortalama Net Kazanç ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center),
                                                Text(
                                                    "${ortalamaYolculukNet.toStringAsFixed(2)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 70,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text(
                                                    "Toplam Çalışma Süresi",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const Text("",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                Text(toplamSure,
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 70,
                                                minWidth: 150,
                                                maxWidth: 150),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Text(
                                                    "Toplam Masraf Tutarı",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const Text("(Yakıt Hariç)",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                                Text(
                                                    "${toplamMasraf.toStringAsFixed(0)} ₺",
                                                    style: const TextStyle(
                                                        fontSize: 23)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
      ),
    );
  }
}
