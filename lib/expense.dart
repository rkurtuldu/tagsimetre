import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagsimetre/add.dart';
import 'package:tagsimetre/expense_list.dart';
import 'package:tagsimetre/main.dart';
import 'package:tagsimetre/trip_list.dart';
import 'sql_helper.dart';

class Expense extends StatefulWidget {
  const Expense({Key? key}) : super(key: key);

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  var bugun = DateFormat("dd-MM-yyyy").format(DateTime.now());
  late TextEditingController tarihController;
  final TextEditingController masrafController = TextEditingController();
  final TextEditingController aciklamaController = TextEditingController();
  late int masrafData;
  late String tarihData;
  late String aciklamaData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    tarihController = TextEditingController(text: bugun);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Masraf Ekle"),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Köprü, Otoyol, Bakım vs. Masrafları",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                    "Bu bölümden girilen masraflar aylık cirodan düşülerek toplam ve ortalama net kazanca yansıyacaktır ",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12)),
                const SizedBox(
                  height: 15,
                ),
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
                      icon: Icon(Icons.calendar_month), label: Text("Tarih")),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: masrafController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.currency_lira),
                      label: Text("Masraf Tutarı")),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  controller: aciklamaController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.notes), label: Text("Açıklama")),
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (masrafController.text.isNotEmpty &
                            (int.tryParse(masrafController.text) != null) &
                            aciklamaController.text.isNotEmpty) {
                          masrafData = int.parse(masrafController.text);
                          tarihData = tarihController.text;
                          aciklamaData = aciklamaController.text;

                          masrafController.text = '';
                          tarihController.text = '';
                          aciklamaController.text = '';

                          await SQLHelper.setExpense(
                              tarihData, masrafData, aciklamaData);

                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                            return const HomePage();
                          }));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("İşlem Kaydedildi")));
                        } else if (masrafController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Eksik Bilgi Girdiniz!")));
                        } else if (aciklamaController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Açıklama Girmediniz")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Masrafları Sadece Tam Sayı ile Giriniz")));
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
                    icon: const Icon(Icons.list),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const ExpenseList();
                      }));
                    },
                    label: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 11, horizontal: 55),
                      child: Text("Masraf Listesi"),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
