import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tagsimetre/expense.dart';
import 'package:tagsimetre/main.dart';
import 'package:tagsimetre/total_km.dart';
import 'package:tagsimetre/trip_list.dart';
import 'sql_helper.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddTrip extends StatefulWidget {
  const AddTrip({Key? key}) : super(key: key);

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  var benzinMazot;
  var yakitTuru;
  var benzinFiyati;
  var mazotFiyati;
  var dailyFuelPrice;
  late List fuel;
  bool _isLoading = true;
  bool kmMode = true;
  bool timeMode = true;
  late String tarihData;
  late int mesafeData;
  late int brutData;
  late double yakitFiyatiData;
  late double yakitTutariData;
  late double tuketimLitre;
  late double tuketim;
  var bugun = DateFormat("dd-MM-yyyy").format(DateTime.now());

  void refreshTrips() async {
    await fetchData();
    final fuelType = await SQLHelper.getFuelType();
    yakitTuru = fuelType[0]['yakitTuru'];
    fuel = await SQLHelper.getDailyFuel(bugun.toString());
    for (var element in fuel) {
      dailyFuelPrice = element["yakitFiyati"];
    }
    final consumption = await SQLHelper.getConsumption();
    if (consumption[0]["tuketim"] is int) {
      tuketim = (consumption[0]["tuketim"] as int).toDouble();
    } else {
      tuketim = consumption[0]["tuketim"];
    }

    if (yakitTuru == 1) {
      benzinMazot = benzinFiyati.toString();
    } else if (yakitTuru == 2) {
      benzinMazot = mazotFiyati.toString();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    refreshTrips();
  }

  Future<void> _addItem() async {
    var data = Yolculuk(
        tarihData, mesafeData, brutData, yakitFiyatiData, yakitTutariData);
    await SQLHelper.createTrip(data);
    refreshTrips();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          "https://api.opet.com.tr/api/fuelprices/prices?ProvinceCode=934"));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body);
        benzinFiyati = list[0]['prices'][0]['amount'];
        mazotFiyati = list[0]['prices'][1]['amount'];
      } else {
        benzinFiyati = '';
        mazotFiyati = '';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Bağlantı Hatası $error")));
      benzinFiyati = '';
      mazotFiyati = '';
    }
  }

  final TextEditingController _mesafeController = TextEditingController();
  final TextEditingController _brutController = TextEditingController();
  late TextEditingController yakitController;
  late TextEditingController tarihController;
  @override
  Widget build(BuildContext context) {
    if (dailyFuelPrice != null) {
      yakitController = TextEditingController(text: dailyFuelPrice.toString());
    } else if (benzinMazot != null) {
      yakitController = TextEditingController(text: benzinMazot.toString());
    } else {
      yakitController = TextEditingController();
    }
    tarihController = TextEditingController(text: bugun);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yolculuk Ekle"),
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
                color: Colors.grey,
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
                        },
                        readOnly: true,
                        controller: tarihController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_month),
                            label: Text("Tarih")),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: _mesafeController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.directions_car),
                            label: Text("Yolculuk Mesafesi")),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: _brutController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.currency_lira),
                            label: Text("Tutar")),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: yakitController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.local_gas_station),
                            label: Text("Yakıt Fiyatı")),
                      ),
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
                            width: 55,
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
                                  tarihController.text.isNotEmpty &
                                  _brutController.text.isNotEmpty &
                                  _mesafeController.text.isNotEmpty &
                                  (double.tryParse(yakitController.text
                                          .replaceAll(",", ".")) !=
                                      null) &
                                  (int.tryParse(_brutController.text) != null) &
                                  (int.tryParse(_mesafeController.text) !=
                                      null)) {
                                yakitFiyatiData = double.parse(
                                    yakitController.text.replaceAll(",", "."));
                                tarihData = tarihController.text;
                                brutData = int.parse(_brutController.text);
                                mesafeData = int.parse(_mesafeController.text);

                                tuketimLitre = (tuketim / 100) *
                                    int.parse(_mesafeController.text);
                                yakitTutariData = tuketimLitre *
                                    double.parse(yakitController.text);

                                await _addItem();

                                tarihController.text = '';
                                _mesafeController.text = '';
                                _brutController.text = '';
                                yakitController.text = '';

                                if (!mounted) return;
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) {
                                  return const HomePage();
                                }));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("İşlem Kaydedildi")));
                              } else if (yakitController.text.isEmpty &
                                  tarihController.text.isEmpty &
                                  _brutController.text.isEmpty &
                                  _mesafeController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Eksik Bilgi Girdiniz!")));
                              } else if ((int.tryParse(_brutController.text) ==
                                      null) &
                                  (int.tryParse(_mesafeController.text) ==
                                      null)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Hatalı Bilgi Girdiniz! Mesafe ve Tutar Bölümlerinde Sadece Tam Sayı Giriniz")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Yakıt Fiyatını Yalnızca Rakam ve Nokta Kullanarak Giriniz (36.74 şeklinde) ")));
                              }
                            },
                            label: const Text('Kaydet'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton.icon(
                          icon: const Icon(Icons.no_crash),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const TotalKmTime();
                            }));
                          },
                          label: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 11, horizontal: 0),
                            child: Text("Çalışma Süresi - Toplam Km Ekle"),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton.icon(
                          icon: const Icon(Icons.currency_lira_outlined),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const Expense();
                            }));
                          },
                          label: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 11, horizontal: 65),
                            child: Text("Masraf Ekle"),
                          ))
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
