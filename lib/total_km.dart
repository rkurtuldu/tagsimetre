import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagsimetre/add.dart';
import 'package:tagsimetre/main.dart';
import 'package:tagsimetre/trip_list.dart';
import 'sql_helper.dart';
import 'package:intl/intl.dart';
import 'package:tagsimetre/main.dart' as main;

class TotalKmTime extends StatefulWidget {
  const TotalKmTime({Key? key}) : super(key: key);

  @override
  State<TotalKmTime> createState() => _TotalKmTimeState();
}

class _TotalKmTimeState extends State<TotalKmTime> {
  late double yakitTutariData;
  late double tuketimLitre;
  late double tuketim;
  var dailyFuelPrice;
  late List fuel;
  late int minutes;
  var total = [];
  var time = [];
  bool _isLoading = true;
  bool kmMode = true;
  bool timeMode = true;
  bool successKm = true;
  bool successTime = true;
  late String tarihData;
  late int mesafeData;
  int sureData = 0;
  var bugun = DateFormat("dd-MM-yyyy").format(DateTime.now());

  void refreshTrips() async {
    final mod = await SQLHelper.getMode();
    if (mod[0]['kmMode'] == 0) {
      kmMode = false;
    }
    if (mod[0]['timeMode'] == 0) {
      timeMode = false;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void getData() async {
    total = await SQLHelper.getDailyTotal(main.addDate);
    time = await SQLHelper.getDailyTime(main.addDate);
    total = await SQLHelper.getDailyTotal(
        tarihController.text);
    time = await SQLHelper.getDailyTime(
        tarihController.text);
    if (total.isNotEmpty) {
      _mesafeController.text =
          total[0]['toplamKm'].toString();
    }
    if (time.isNotEmpty) {
      minutes = time[0]['sure'];
      _sureController.text =
      "${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}";
      sureData = minutes;
    }
    fuel = await SQLHelper.getDailyFuel(main.addDate);
    for (var element in fuel) {
      dailyFuelPrice = element["yakitFiyati"];
    }
    final consumption = await SQLHelper.getConsumption();
    if (consumption[0]["tuketim"] is int) {
      tuketim = (consumption[0]["tuketim"] as int).toDouble();
    } else {
      tuketim = consumption[0]["tuketim"];
    }
  }

  @override
  void initState() {
    super.initState();
    refreshTrips();
    getData();
  }

  late TextEditingController _mesafeController = TextEditingController();
  late TextEditingController _sureController = TextEditingController();
  late TextEditingController tarihController;
  @override
  Widget build(BuildContext context) {
    tarihController = TextEditingController(text: main.addDate);
    _mesafeController = TextEditingController();
    _sureController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gün Sonu Ekle"),
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
                color: Colors.white,
                iconSize: 40,
              ),
            ],
          )),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('dd-MM-yyyy').format(pickedDate);
                            tarihController.text = formattedDate;
                          }

                          fuel = await SQLHelper.getDailyFuel(tarihController.text);
                          for (var element in fuel) {
                            dailyFuelPrice = element["yakitFiyati"];
                          }
                          total = await SQLHelper.getDailyTotal(
                              tarihController.text);
                          time = await SQLHelper.getDailyTime(
                              tarihController.text);
                          if (total.isNotEmpty) {
                            _mesafeController.text =
                                total[0]['toplamKm'].toString();
                          } else {
                            _mesafeController.text = '';
                          }
                          if (time.isNotEmpty) {
                            minutes = time[0]['sure'];
                            _sureController.text =
                                "${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}";
                            sureData = minutes;
                          } else {
                            _sureController.text = '';
                          }
                        },
                        readOnly: true,
                        controller: tarihController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_month),
                            label: Text("Tarih")),
                      ),
                      kmMode
                          ? Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _mesafeController,
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.directions_car),
                                      label: Text("Günlük Toplam Km")),
                                ),
                              ],
                            )
                          : Container(),
                      timeMode
                          ? Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  readOnly: true,
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return SimpleDialog(
                                            title: const Text(
                                                "Günlük Çalışma Süresi"),
                                            children: [
                                              SizedBox(
                                                  width: 250,
                                                  height: 150,
                                                  child: CupertinoTimerPicker(
                                                    onTimerDurationChanged:
                                                        (value) {
                                                      _sureController.text =
                                                          '${(value.inHours).toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}';
                                                      sureData =
                                                          value.inMinutes;
                                                    },
                                                    mode:
                                                        CupertinoTimerPickerMode
                                                            .hm,
                                                    minuteInterval: 10,
                                                  )),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Tamam",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                      ))
                                                ],
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  controller: _sureController,
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.access_time),
                                      label: Text("Günlük Çalışma Süresi")),
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 35,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                              icon: const Icon(Icons.cancel_outlined),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) {
                                  return const HomePage();
                                }));
                              },
                              label: const Text("Vazgeç")),
                          const SizedBox(
                            width: 50,
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
                              if (tarihController.text.isNotEmpty) {
                                tarihData = tarihController.text;
                                if (kmMode) {
                                  if (_mesafeController.text.isNotEmpty &
                                      (int.tryParse(_mesafeController.text) !=
                                          null) & (dailyFuelPrice != null)) {
                                    if (total.isNotEmpty) {
                                      tuketimLitre = (tuketim / 100) *
                                          int.parse(_mesafeController.text);
                                      yakitTutariData = tuketimLitre * dailyFuelPrice;
                                      mesafeData =
                                          int.parse(_mesafeController.text);
                                      await SQLHelper.updateDailyTotal(
                                          tarihData, mesafeData,yakitTutariData);
                                      successKm = true;
                                    } else {
                                      tuketimLitre = (tuketim / 100) *
                                          int.parse(_mesafeController.text);
                                      yakitTutariData = tuketimLitre * dailyFuelPrice;
                                      mesafeData =
                                          int.parse(_mesafeController.text);
                                      await SQLHelper.setDailyTotal(
                                          tarihData, mesafeData,yakitTutariData);
                                      successKm = true;
                                    }
                                  } else if (dailyFuelPrice == null) {
                                    successKm = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Seçili Güne Ait Yolculuk Yok")));
                                  }
                                  else if (_mesafeController.text.isEmpty &
                                      successTime) {
                                    successKm = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Günlük Toplam Km Girmediniz!")));
                                  } else if ((int.tryParse(
                                              _mesafeController.text) ==
                                          null) &
                                      successTime) {
                                    successKm = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Hatalı Bilgi Girdiniz! Toplam Km Bölümüne Sadece Tam Sayı Giriniz")));
                                  }
                                }
                                if (timeMode) {
                                  if (sureData != 0) {
                                    if (time.isNotEmpty) {
                                      await SQLHelper.updateDailyTime(
                                          tarihData, sureData);
                                      successTime = true;
                                    } else {
                                      await SQLHelper.setDailyTime(
                                          tarihData, sureData);
                                      successTime = true;
                                    }
                                  } else if ((sureData == 0) & successKm) {
                                    successTime = false;
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Günlük Çalışma Süresini Girmediniz!")));
                                  }
                                }
                                if (!mounted) return;
                                if (!successKm) return;
                                if (!successTime) return;
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) {
                                  return const HomePage();
                                }));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("İşlem Kaydedildi")));
                              }
                            },
                            label: const Text('Kaydet'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
