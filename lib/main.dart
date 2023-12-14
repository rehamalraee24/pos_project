import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String transAmount = "";
  String transResult = "";

  final GlobalKey webViewKey = GlobalKey();
  final MethodChannel platform = const MethodChannel('aumet.pos');
  Future<String> callSaleAPI() async {
    try {
      transResult =
          await platform.invokeMethod('sale', {"amount": transAmount});
      print('Result from Native: $transResult');
      return "success";
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return "";
    }
  }

  result(dynamic arg) {
    webViewController!.evaluateJavascript(
      source: 'posTerminalResponse("${arg.arguments}");',
    );
  }

  barcodeReader(dynamic barcode) {
    String read = barcode.arguments;
    if (read.isNotEmpty) {
      webViewController!.evaluateJavascript(
        source: 'onScanned("$read");',
      );
    }
  }

  Future<String> callScanAPI() async {
    try {
      final String result = await platform.invokeMethod('scan');
      print('barcode from Native: $result');
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return '';
    }
  }

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        // debuggingEnabled: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          safeBrowsingEnabled: false,
          mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW),
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
    platform.invokeMethod("loadArchFiles");

    platform.setMethodCallHandler((call) {
      if (call.method == "result") {
        return result(call);
      } else {
        return barcodeReader(call);
      }
    });
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
            String barcodeScanRes =
                ''; // Register a JavaScript handler with name "Barcode"
            controller.addJavaScriptHandler(
              handlerName: 'Barcode',
              callback: (args) async {
                // Print arguments coming from the JavaScript side!
                // barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                //   '#ff6666',
                //   'Cancel',
                //   true,
                //   ScanMode.BARCODE,
                // );
                barcodeScanRes = await callScanAPI();
                // if (barcodeScanRes.isNotEmpty) {
                //   controller.evaluateJavascript(
                //     source: 'onScanned("$barcodeScanRes");',
                //   );
                // }

                // return null;
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'Checkout',
              callback: (args) async {
                ///TODO: get amount
                transAmount = args[0].toString();
                await callSaleAPI();
                //.then((transResult) {
                //                   if (transResult.isNotEmpty) {
                //                     controller.evaluateJavascript(
                //                       source: 'posTerminalResponse("$transResult");',
                //                     );
                //                   }
                //                 });
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
