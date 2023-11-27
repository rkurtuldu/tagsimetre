import 'package:flutter/material.dart';
import 'package:tagsimetre/add.dart';
import 'package:tagsimetre/backup.dart';
import 'package:tagsimetre/main.dart';
import 'package:tagsimetre/trip_list.dart';
import 'sql_helper.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late List<bool> isSelected;
  bool _isLoading = true;
  late double yakitData;
  bool sure = true;
  bool km = true;
  late bool sureData;
  late bool kmData;
  var gelenTuketim;

  void refreshTrips() async {
    final fuel = await SQLHelper.getConsumption();
    gelenTuketim = fuel[0]['tuketim'];
    final fuelType = await SQLHelper.getFuelType();
    if (fuelType[0]['yakitTuru'] == 1) {
      isSelected = [true, false, false];
    } else if (fuelType[0]['yakitTuru'] == 2) {
      isSelected = [false, true, false];
    } else if (fuelType[0]['yakitTuru'] == 3) {
      isSelected = [false, false, true];
    }
    final mode = await SQLHelper.getMode();
    if (mode[0]['kmMode'] == 1) {
      kmData = true;
    } else {
      kmData = false;
    }
    if (mode[0]['timeMode'] == 1) {
      sureData = true;
    } else {
      sureData = false;
    }

    setState(() {
      _isLoading = false;
      sure = sureData;
      km = kmData;
    });
  }

  void update() async {
    await SQLHelper.updateMode(km ? 1 : 0, sure ? 1 : 0);
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

  late TextEditingController yakitController;
  @override
  Widget build(BuildContext context) {
    if (gelenTuketim != null) {
      yakitController = TextEditingController(text: gelenTuketim.toString());
    } else {
      yakitController = TextEditingController();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
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
                      const Text(
                          "Günlük çalışma süresi ve/veya günlük toplam km girmek istemiyorsanız "
                          "eksik bilgi uyarısı almamak için bu alanların bilgi girişini kapatabilirsiniz. "
                          "Kapatıldığında aylık özetlerde kapatılan kısımlara ait değerler "
                          "\"0\" olarak görünür.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                          "Bu alanlar açık olduğu sürece; bir güne yolculuk eklenir ve o günün sonuna "
                          "kadar ilgili alan için bilgi girişi yapılmazsa ertesi gün uygulama açıldığında eksik bilginin girilmesi "
                          "ya da özelliğin kapatılmasına dair uyarı görüntülenir.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Günlük Çalışma Süresi",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          Switch(
                            activeColor: const Color.fromRGBO(66, 66, 66, 1),
                            value: sure,
                            onChanged: (value) {
                              setState(() {
                                sure = value;
                                update();
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Günlük Toplam Km",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          Switch(
                            activeColor: const Color.fromRGBO(66, 66, 66, 1),
                            value: km,
                            onChanged: (value) {
                              setState(() {
                                km = value;
                                update();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ToggleButtons(
                        constraints: const BoxConstraints(
                            maxWidth: 100, minWidth: 70, minHeight: 35),
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
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
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: yakitController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.local_gas_station),
                            label: Text("Litre/100 Km Yakıt Tüketimi")),
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
                              if (yakitController.text.isNotEmpty &
                                  (double.tryParse(yakitController.text
                                          .replaceAll(",", ".")) !=
                                      null)) {
                                yakitData = double.parse(
                                    yakitController.text.replaceAll(",", "."));
                                await SQLHelper.updateConsumption(yakitData);
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
                                            Text("Eksik Bilgi Girdiniz!")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Yalnızca Rakam ve Nokta Kullanarak Giriniz (6.7 şeklinde) ")));
                              }
                            },
                            label: const Text('Kaydet'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton.icon(
                          icon: const Icon(Icons.settings_backup_restore),
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
                              return const DatabaseManagement();
                            }));
                          },
                          label: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 40),
                            child: Text("Veritabanı İşlemleri"),
                          )),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
