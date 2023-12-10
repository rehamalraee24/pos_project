import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  final MethodChannel platform = MethodChannel('aumet.pos');
  void fetchDataFromNative() async {
    try {
      final String result = await platform.invokeMethod('getDataFromNative',{"amount":"5000"});
      print('Result from Native: $result');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        // debuggingEnabled: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(
            url: Uri.parse("https://ksa.erpstg.aumet.com/POSterminal?noSearch"),
          ),
          initialOptions: options,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) async {
            webViewController = controller;

            String barcodeScanRes = '';

            // Register a JavaScript handler with name "Barcode"
            controller.addJavaScriptHandler(
              handlerName: 'Barcode',
              callback: (args) async {
                // Print arguments coming from the JavaScript side!
                barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                  '#ff6666',
                  'Cancel',
                  true,
                  ScanMode.BARCODE,
                );
                print(barcodeScanRes);
                fetchDataFromNative();
                // Call the JavaScript function onScanned with the scanned result
                controller.evaluateJavascript(
                  source: 'onScanned("$barcodeScanRes");',
                );

                // Return data to the JavaScript side if needed
                return null;
              },
            );
          },
          onLoadStart: (controller, url) {
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            // Add any additional logic after the page is loaded
          },
          onLoadError: (controller, url, code, message) {
            pullToRefreshController.endRefreshing();
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              pullToRefreshController.endRefreshing();
            }
            setState(() {
              this.progress = progress / 100;
              urlController.text = this.url;
            });
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage);
          },
        ),
      ),
    );
  }
}
