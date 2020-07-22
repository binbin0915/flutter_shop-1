import 'package:flutter/material.dart';
import './pages/index_page.dart';
import './config/index.dart';
import './provide/current_index_provide.dart';
import 'package:provide/provide.dart';

void main() {
  var currentIndexProvide = CurrentIndexProvider();
  var providers = Providers();
  providers..provide(Provider<CurrentIndexProvider>.value(currentIndexProvide));
  runApp(ProviderNode(child: MyApp(), providers: providers));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: KString.mainTitle, // Flutter_女装商城
        debugShowCheckedModeBanner: false,
        // 定制主题
        theme: ThemeData(
          primaryColor: KColor.primaryColor,
        ),
        home: IndexPage(),
      ),
    );
  }
}
