import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:taskapp/Screens/map.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late BannerAd myBanner;
  bool isLoaded=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myBanner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (ad){
            setState(() {
              isLoaded=true;
            });
            print('=============================================');
            print('banner is loaded');
          },
          onAdFailedToLoad: (ad,error){
            ad.dispose();
          }
      ),
    );
    myBanner.load();
    Future.delayed(const Duration(seconds: 5),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Maps()));
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(

        child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/magma.jpg',height: 130,),
          const SizedBox(height: 30,),
          CircularProgressIndicator(color: Colors.amber,),
          const SizedBox(height: 300,),
          isLoaded? Container(
            height: 50,
            child:AdWidget(ad: myBanner,),
          ):SizedBox()
        ]),
      ),
    );
  }
}