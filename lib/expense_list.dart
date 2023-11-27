import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:tagsimetre/add.dart';
import 'package:tagsimetre/main.dart';
import 'package:tagsimetre/sql_helper.dart';
import 'package:tagsimetre/trip_list.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({Key? key}) : super(key: key);

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Map<String, dynamic>> masraflar = [];
  late num aylikMasraf;

  bool _isLoading = true;

  var ayYil = DateFormat("MM-yyyy").format(DateTime.now());
  late String ay;

  void refreshTrips() async {
    final data = await SQLHelper.getExpense(ayYil);
    aylikMasraf = 0;

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
    for (var element in data) {
      aylikMasraf += element["masraf"];
    }
    setState(() {
      masraflar = data;
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
        title: const Text("Masraf Listesi"),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
          height: 60,
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
          : RefreshIndicator(
              onRefresh: () async {
                refreshTrips();
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton.icon(
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
                              DateTime? pickedDate = await showMonthPicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                String formattedDate =
                                    DateFormat('MM-yyyy').format(pickedDate);
                                ayYil = formattedDate;
                                refreshTrips();
                              }
                            },
                            label: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 5),
                              child: Text("Ay Seçimi"),
                            )),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text("$ay Ayı Toplam Masraf : $aylikMasraf ₺",
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: masraflar.length,
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
                                        padding: const EdgeInsets.all(7.0),
                                        child: Text(
                                            "# ${masraflar[index]["id"]} "),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(masraflar[index]['tarih'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5, left: 10),
                                          child: Text(
                                              masraflar[index]['aciklama'],
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                            "${masraflar[index]['masraf'].toString()} ₺",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            textAlign: TextAlign.right),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: (context),
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
                                                    content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        20),
                                                            child: Text(
                                                                "Masrafı Silmek İstediğinizden Emin misiniz?",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              TextButton.icon(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                label: const Text(
                                                                    "Vazgeç"),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .clear),
                                                              ),
                                                              TextButton.icon(
                                                                onPressed: () {
                                                                  SQLHelper.deleteExpense(
                                                                      masraflar[
                                                                              index]
                                                                          [
                                                                          'id']);
                                                                  refreshTrips();
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                label:
                                                                    const Text(
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
