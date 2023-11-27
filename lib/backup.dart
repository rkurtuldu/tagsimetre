import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'main.dart';
import 'add.dart';
import 'trip_list.dart';

class DatabaseManagement extends StatefulWidget {
  const DatabaseManagement({Key? key}) : super(key: key);

  @override
  State <DatabaseManagement> createState() => _DatabaseManagementState();
}

class _DatabaseManagementState extends State<DatabaseManagement> {
  late Database _database;
  late String _currentDatabasePath;
  late String path;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    _currentDatabasePath = await getDatabasesPath();
    _database = await openDatabase(join(_currentDatabasePath, 'tagsidb.db'));
    path = join(_currentDatabasePath, 'tagsidb.db');
  }

  Future<void> copyDatabaseToDirectory(String filePath) async {
    File selectedFile = File(filePath);
    String newDatabasePath = join(_currentDatabasePath, 'tagsidb.db');
    await _database.close();
    await selectedFile.copy(newDatabasePath);
    _database = await openDatabase(newDatabasePath);
  }

  Future<void> backupDatabase(BuildContext context) async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String backupFileName = 'backup_$timestamp.db';

    var directory = Directory('/storage/emulated/0/');
    var pickedFilePath = await FilesystemPicker.open(
      title: 'Kaydedilecek Klasörü Seçin',
      context: context,
      rootDirectory: directory,
      fsType: FilesystemType.folder,
      pickText: 'Bu Klasöre Kaydet',
    );
    String backupFilePath = join(pickedFilePath!, backupFileName);
    
    try {
      await File(path).copy(backupFilePath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veritabanı yedeklendi: $backupFileName')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hata! Başka Bir Klasör Seçin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veritabanı İşlemleri'),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
          height: 70,
          color: const Color.fromRGBO(66, 66, 66, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context){return const HomePage();}));
              }, icon: const Icon(Icons.home),color: Colors.white,iconSize: 40,),
              IconButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context){return const AddTrip();}));
              }, icon: const Icon(Icons.add_circle),color: Colors.white,iconSize: 40,),
              IconButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context){return const TripList();}));
              }, icon: const Icon(Icons.bar_chart),color: Colors.white,iconSize: 40,),
            ],)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(icon: const Icon(Icons.save),
                  style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),),),
                  onPressed: () async {
                    await backupDatabase(context);
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){return const HomePage();}));
                  },
                  label:  const Padding(
                    padding:  EdgeInsets.symmetric(vertical: 12,horizontal: 29),
                    child: Text('Veritabanını Yedekle'),
                  ),
                ),
                const Text("Veritabanını seçtiğiniz konuma yedekler."
                    ,textAlign: TextAlign.justify,style: TextStyle(fontSize: 13)),
                const SizedBox(height: 20,),
                ElevatedButton.icon(icon: const Icon(Icons.restore),
                  style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),),),
                  onPressed: () async {
                    showDialog(
                        context: (context),
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 10),
                                    child:  Text("Veritabanını Değiştirmek İstediğinizden Emin misiniz?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const Text("Veritabanını değiştirdiğinizde seçtiğiniz veritabanı dosyası açılacak "
                                      "ve geçerli olan veritabanı dosyası silinecektir. Eğer yedeklemediyseniz geri "
                                      "dönüş mümkün olmayacaktır.",textAlign: TextAlign.center,style: TextStyle(fontSize: 13),),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(onPressed: () {
                                        Navigator.pop(context);
                                      }, label: const Text("Vazgeç"), icon: const Icon(Icons.clear),),
                                      TextButton.icon(onPressed: () async {
                                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                                        if (result != null)  {
                                          String selectedFilePath = result.files.first.path!;
                                          await copyDatabaseToDirectory(selectedFilePath);
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Yeni veritabanı dosyası seçildi: $selectedFilePath')),
                                          );
                                        }
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){return const HomePage();}));
                                      }, label: const Text("Dosya Seç"), icon: const Icon(Icons.check),)
                                    ],)
                                ]),
                          );
                        });
                  },
                  label: const Padding(
                    padding:  EdgeInsets.symmetric(vertical: 12,horizontal: 30),
                    child:  Text('Yedekten Geri Yükle'),
                  ),
                ),
                const Text("Seçtiğiniz veritabanı dosyasını kullanır."
                    ,textAlign: TextAlign.justify,style: TextStyle(fontSize: 13)),
                const SizedBox(height: 20,),
                ElevatedButton.icon(icon: const Icon(Icons.delete),
                  style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),),),
                  onPressed: () async {
                    showDialog(
                        context: (context),
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 10),
                                    child:  Text("Veritabanını Silmek İstediğinizden Emin misiniz?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const Text("Veritabanını sildiğinizde tüm verileriniz kalıcı olarak silinecek, "
                                      "eğer yedeklemediyseniz geri dönüş mümkün olmayacaktır.",textAlign: TextAlign.center,style: TextStyle(fontSize: 13),),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(onPressed: () {
                                        Navigator.pop(context);
                                      }, label: const Text("Vazgeç"), icon: const Icon(Icons.clear),),
                                      TextButton.icon(onPressed: () async {
                                        await deleteDatabase(path);
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){return const HomePage();}));
                                      }, label: const Text("Veritabanını Sil"), icon: const Icon(Icons.check),)
                                    ],)
                                ]),
                          );
                        });
                  },
                  label: const Padding(
                    padding:  EdgeInsets.symmetric(vertical: 12,horizontal: 45),
                    child:  Text('Veritabanını Sil'),
                  ),
                ),
                const Text("Geçerli veritabanı kalıcı olarak silinir. ",
                    textAlign: TextAlign.justify,style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}