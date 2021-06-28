import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherflut/data/repository/api_repository.dart';
import 'package:weatherflut/model/city.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebView extends StatefulWidget {
  final City city;

  const AppWebView({Key key, this.city}) : super(key: key);

  @override
  AppWebViewState createState() => AppWebViewState();
}

class AppWebViewState extends State<AppWebView> {
  ApiRepository repository;

  @override
  void initState() {
    repository = context.read<ApiRepository>();
    super.initState();
  }

  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    final city = widget.city;
    final url = repository.getDetailsUrl(city);
    return Scaffold(
      appBar: AppBar(
        title: Text(city.getFullTitle()),
      ),
      body: WebView(
        initialUrl: url,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
    );
  }
}
