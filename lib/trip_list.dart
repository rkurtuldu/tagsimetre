import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagsimetre/add.dart';
import 'package:tagsimetre/main.dart';
import 'package:tagsimetre/sql_helper.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class TripList extends StatefulWidget {
  const TripList({Key? key}) : super(key: key);

  @override
  State<TripList> createState() => _TripListState();
}

class _TripListState extends State<TripList> {
  List<Map<String, dynamic>> _yolculuklarAylik = [];
  List<Map<String, dynamic>> _yolculuklarGunluk = [];
  late num yolculukMesafesiAylik;
  late int yolculukSayisiAylik;
  late num ciroAylik;
  late double netKazancAylik;
  late double yakitTutariAylik;
  late double ortalamaNet;
  late num toplamKm;
  late double ortalamaToplamNet;
  late double saatlikOrtalamaNet;
  late String toplamSure;
  late num toplamMasraf;
  late double ortalamaYolculukNet;
  late num minutes;
  late bool kmMode;
  late bool timeMode;
  late double yakitTutariData;

  late int yolculukSayisiGunluk;
  late num yolculukMesafesiGunluk;
  late num ciroGunluk;
  late double netKazancGunluk;
  late double yakitTutariGunluk;
  late double ortalamaNetGunluk;
  late double ortalamaYolculukNetGunluk;

  bool _isLoading = true;
  bool detail = true;
  bool monthlyMode = true;
  var ayYil = DateFormat("MM-yyyy").format(DateTime.now());
  late String ay;
  var gunAyYil = DateFormat("dd-MM-yyyy").format(DateTime.now());

  void refreshTrips() async {
    List mod;
    mod = await SQLHelper.getMode();
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

    if (ayYil.substring(0, 2) == "01") {
      ay = "Ocak";
    } else if (ayYil.substring(0, 2) == "02") {
      ay = "Şubat";
    } else if (ayYil.substring(0, 2) == "03") {
      ay = "Mart";
    } else if (ayYil.substring(0, 2) == "04") {
      ay = "Nisan";
    } else if (ayYil.substring(0, 2) == "05") {
      ay = "Mayıs";
    } else if (ayYil.substring(0, 2) == "06") {
      ay = "Haziran";
    } else if (ayYil.substring(0, 2) == "07") {
      ay = "Temmuz";
    } else if (ayYil.substring(0, 2) == "08") {
      ay = "Ağustos";
    } else if (ayYil.substring(0, 2) == "09") {
      ay = "Eylül";
    } else if (ayYil.substring(0, 2) == "10") {
      ay = "Ekim";
    } else if (ayYil.substring(0, 2) == "11") {
      ay = "Kasım";
    } else if (ayYil.substring(0, 2) == "12") {
      ay = "Aralık";
    }
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
    yolculukSayisiGunluk = 0;
    yolculukMesafesiGunluk = 0;
    ciroGunluk = 0;
    netKazancGunluk = 0.0;
    yakitTutariGunluk = 0.0;
    ortalamaYolculukNetGunluk = 0.0;
    ortalamaNetGunluk = 0.0;

    final daily = await SQLHelper.getDailyTrips(gunAyYil);
    for (var element in daily) {
      yolculukSayisiGunluk++;
      yolculukMesafesiGunluk += element["mesafe"];
      ciroGunluk += element["brut"];
      yakitTutariGunluk += element["yakitTutari"];
    }
    netKazancGunluk = ciroGunluk - yakitTutariGunluk;

    if (daily.isNotEmpty) {
      ortalamaNetGunluk = netKazancGunluk / yolculukMesafesiGunluk;
      ortalamaYolculukNetGunluk = netKazancGunluk / yolculukSayisiGunluk;
    }

    setState(() {
      _yolculuklarAylik = monthly;
      _yolculuklarGunluk = daily;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İstatistikler"),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
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
                color: Colors.white,
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
                color: Colors.grey,
                iconSize: 40,
              ),
            ],
          )),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                refreshTrips();
              },
              child: detail
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_month),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  if (monthlyMode) {
                                    DateTime? pickedDate =
                                        await showMonthPicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('MM-yyyy')
                                              .format(pickedDate);
                                      ayYil = formattedDate;
                                      refreshTrips();
                                    }
                                  } else {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      gunAyYil = formattedDate;
                                      refreshTrips();
                                    }
                                  }
                                },
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 5),
                                  child: Text("Tarih"),
                                )),
                            ElevatedButton.icon(
                                icon: const Icon(Icons.format_list_numbered),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  detail = false;
                                  refreshTrips();
                                },
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 5),
                                  child: Text("Liste"),
                                )),
                            ElevatedButton.icon(
                                icon: Icon(monthlyMode
                                    ? Icons.filter_1
                                    : Icons.filter_none),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  monthlyMode = !monthlyMode;
                                  refreshTrips();
                                },
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 5),
                                  child: Text(monthlyMode ? "Günlük" : "Aylık"),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                            monthlyMode
                                ? "$ay Ayı Yolculukları"
                                : "$gunAyYil Yolculukları",
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        monthlyMode
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Card(
                                      elevation: 5,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: Column(children: [
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text("Yolculuk Sayısı",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text(
                                                      "Yolculuk Mesafesi",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "${yolculukMesafesiAylik.toString()} km",
                                                      style: const TextStyle(
                                                          fontSize: 23)),
                                                ],
                                              ),
                                            ),
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text("Ciro",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text("Net Kazanç",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text("Toplam Km",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text(
                                                      "Toplam Yakıt Tutarı",
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontStyle: FontStyle
                                                              .italic)),
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontStyle: FontStyle
                                                              .italic)),
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text(
                                                      "Toplam Çalışma Süresi",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const Text("",
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontStyle: FontStyle
                                                              .italic)),
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text(
                                                      "Toplam Masraf Tutarı",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const Text("(Yakıt Hariç)",
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontStyle: FontStyle
                                                              .italic)),
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
                                ),
                              )
                            : Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Card(
                                      elevation: 5,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: Column(children: [
                                        const SizedBox(
                                          height: 15,
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
                                          height: 15,
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
                                                  Text("${ciroGunluk.toString()} ₺",
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
                                          height: 15,
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
                                                      textAlign: TextAlign.center),
                                                  const Text(
                                                      "(Yolculu Km Üzerinden)",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontStyle:
                                                              FontStyle.italic)),
                                                  Text(
                                                      "${ortalamaNetGunluk.toStringAsFixed(2)} ₺",
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
                                                    MainAxisAlignment.spaceAround,
                                                children: [
                                                  const Text(
                                                      "Yolculuk Başına Ortalama Net Kazanç ",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center),
                                                  Text(
                                                      "${ortalamaYolculukNetGunluk.toStringAsFixed(2)} ₺",
                                                      style: const TextStyle(
                                                          fontSize: 23)),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                      ]),
                                    ),
                                  ),
                              ),
                            ),
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_month),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  if (monthlyMode) {
                                    DateTime? pickedDate =
                                        await showMonthPicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('MM-yyyy')
                                              .format(pickedDate);
                                      ayYil = formattedDate;
                                      refreshTrips();
                                    }
                                  } else {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      gunAyYil = formattedDate;
                                      refreshTrips();
                                    }
                                  }
                                },
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 5),
                                  child: Text("Tarih"),
                                )),
                            ElevatedButton.icon(
                                icon: const Icon(Icons.view_cozy_outlined),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  detail = true;
                                  refreshTrips();
                                },
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 5),
                                  child: Text("Özet"),
                                )),
                            ElevatedButton.icon(
                                icon: Icon(monthlyMode
                                    ? Icons.filter_1
                                    : Icons.filter_none),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  monthlyMode = !monthlyMode;
                                  refreshTrips();
                                },
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 5),
                                  child: Text(monthlyMode ? "Günlük" : "Aylık"),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                            monthlyMode
                                ? "$ay Ayı Yolculukları"
                                : "$gunAyYil Yolculukları",
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: monthlyMode
                                ? _yolculuklarAylik.length
                                : _yolculuklarGunluk.length,
                            itemBuilder: (context, index) => Card(
                                elevation: 2,
                                color: Colors.white70,
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(7.0),
                                              child: Text(monthlyMode
                                                  ? "# ${_yolculuklarAylik[index]["id"]} "
                                                  : "# ${_yolculuklarGunluk[index]["id"]} "),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      monthlyMode
                                                          ? _yolculuklarAylik[
                                                              index]['tarih']
                                                          : _yolculuklarGunluk[
                                                              index]['tarih'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16)),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 80,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text("Mesafe",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                            monthlyMode
                                                                ? "${_yolculuklarAylik[index]['mesafe']} Km"
                                                                : "${_yolculuklarGunluk[index]['mesafe']} Km",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15)),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text("Tutar",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                            monthlyMode
                                                                ? "${_yolculuklarAylik[index]['brut']} ₺"
                                                                : "${_yolculuklarGunluk[index]['brut']} ₺",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15)),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text("Net Tutar",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                            monthlyMode
                                                                ? "${(_yolculuklarAylik[index]['brut'] - _yolculuklarAylik[index]['yakitTutari']).toStringAsFixed(2)} ₺"
                                                                : "${(_yolculuklarGunluk[index]['brut'] - _yolculuklarGunluk[index]['yakitTutari']).toStringAsFixed(2)} ₺",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: (context),
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20))),
                                                          content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              20),
                                                                  child: Text(
                                                                      "Yolculuğu Silmek İstediğinizden Emin misiniz?",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    TextButton
                                                                        .icon(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      label: const Text(
                                                                          "Vazgeç"),
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .clear),
                                                                    ),
                                                                    TextButton
                                                                        .icon(
                                                                      onPressed:
                                                                          () {
                                                                        if (monthlyMode) {
                                                                          SQLHelper.deleteTrip(_yolculuklarAylik[index]
                                                                              [
                                                                              'id']);
                                                                          refreshTrips();
                                                                          Navigator.pop(
                                                                              context);
                                                                        } else {
                                                                          SQLHelper.deleteTrip(_yolculuklarGunluk[index]
                                                                              [
                                                                              'id']);
                                                                          refreshTrips();
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      },
                                                                      label: const Text(
                                                                          "Sil"),
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .check),
                                                                    )
                                                                  ],
                                                                )
                                                              ]),
                                                        );
                                                      });
                                                },
                                                icon: const Icon(Icons.delete))
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    )),
    );
  }
}
