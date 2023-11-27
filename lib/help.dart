import 'package:flutter/material.dart';
import 'package:tagsimetre/trip_list.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'add.dart';
import 'main.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Yardım"),
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
          child: ImageSlideshow(
              height: double.maxFinite,
              children: [
            Image.asset("assets/ana.png",fit: BoxFit.fitHeight),
            Image.asset("assets/2ekle.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/3gunsonu.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/4masraf.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/5maslist.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/6ist1.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/7ist2.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/8ist3.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/9ist4.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/10ayarlar.png",fit: BoxFit.fitHeight,),
            Image.asset("assets/11veritabani.png",fit: BoxFit.fitHeight,),
          ]),
        )
    );
  }
}
