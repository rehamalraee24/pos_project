import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  result(dynamic arg) async {
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

  Future<bool> callPrinterAPI() async {
    try {
       bool result =
          await platform.invokeMethod('print', {"printString": transResult,"image":"UklGRjo0AABXRUJQVlA4WAoAAAAQAAAAuwMAcgEAQUxQSJEhAAABHAZtG0ly+MPe/45AREyAn/cI7bXT5H7qWr7aI7otBJFpls2VSlNtkhqEUEmhVVtPIOmKhEhAAhKQUBKQUBKQgAQkIAEJSEBCHORhprvrC3TV/JeHGxET4K3Wpjzatm0rCUhAAhKQEAlIiISSEAlIiAQkIAEJ5WD90fVB0r3t1/d9R8QE0N12Zxuqo52Otmsu+mYLm9Uh+n7lnSrrx8PvU0UvFL9LRb10bFJeL057VLtKeIvSy+MO5a/rO1S8TnmDyoBjg2qAvEEpcOxPHqFue4qQuD1lSN2eGkS2J8X6zcmBzs3pALXNKYF0c2qoY28SVN6anKL71nTA1O1MCRd3poYrO5Pgxsbk1KDflw4L576ULNR9qVnQfUlMhF3Jqcm8Kx02+q6UbChvSs3IsSmJkbInOTU69qTDirotKZk5t6Rmpm5JYkZ2JKd2/YZ0GEobUjLUNqRmSHk/GpaO7YjVct6OgqmxHSVT6najaivuRsNW2YxYbctmFIyp34uStXMvqtbaXjSs6VbEav7YiYK9vBMle30nqvaUN6IxQdyHWCcs+1CYYexDaQb121Cd4tyGxhR1F2KdcxcKk4RNKE2SNqEKaJC+CQ1AhChvQazXN8YcW1AAZOqQsgUlwEkJMragCgjkIep2oA4gIoGc/+kKCenulF4/iKhA6n+6kiLDjQqASkQRIhvQCUhExBD1+08BHEREHZL2nw5wPxKk7T8KpJ8eorz7BED7hQRy7D4nIP9WIHn7KHyPMfjgWQrg/C1C+ubRFuwa5uiA8JuDqNs5yoQ/8wwKpJcdEjeOIoh2thcA41WGlH2jYGNncyegvgoQ2TaK7NBqrgDSKxKE+l1jYm+w1gHHGxVybhqMzc2aAt0bEdL2jCS71NsKCHrTQXTPiHp5tnUChofmI2HL6NcNWwVwua5H8o7hFOhMdcDpqo/0HSMjoikFVhfJE8obhiCKpYAg//1I3C8ORQ5LJ2AF2iNlv6gQdYYK4A7kR8Z24RQbDXUAB2g+oX63OEHFkAKPyPXIuVsM0LATEDlSH6mbRVC0M3MiKCwI2SwKLJrJgBG7ERq2ChZYMdMAV6xB0lYRFT7MKPCMZUjfKjpOnRGPqDHqCOWNwqnBaCQiaGOGHBtFtlCMZMDaESBloxALw0gD3DtIEGOfONSks6FA3lIR6raJaiOa8IhjS4TEXYLVZjEREXmLg9R/OxxC+j0GP5EPR/r9CG5JPqRUW2v6U1prNaUj3K3TyDCREbS3I+QJhJha0zel1RT98+EjNdEPe45szp+l66e9RLcQF3PTy0dN4UYNI+osNMDYlBHqb17ITa9up38wPnW9uke2w7GIXj2yX8JRhuJb8vfIq9VoQYHXpgBJd+4ootiR/QUN+l6DejsNeflyQ17g8lBscTaOouAeZwtF1OrIHqaG54heyyhmigGPODeRINptc2moxXHyJwp9T6HBjiKHrynyo9jUYHEwTkMNSuJ5+Bxqu8dlxMcqWMwMAxFRd1WE8j1zRc1KcQ+Ck6hNSRhOokYlTsJJ1L4kvjVR7TpcRtDuCDnumCtqO/FTOEXtjgBIooa7n4CT6JyS+MY0QxHXAGubg+T7xUnNy/EIQlfb6aow1HgyF0XnlfO2ODVccAq8t1FH9NsVhs5Y+f5lNd/4kqz2O5vyTefu4aZkSwPmEbwvI9TdK846qRw3z3WdsPNnruuM4g0lnT/zLRmW1KEi4tgXIPFW+aHz5lt3iE7Z+RMvOqcEK9x0hd3fkENNR1RG5H0kiGIq+C8XRWeufN+iztr5vSg67WEjiK5R4v2otgqqIQhYEWLmKKKqOrL7Xlkn73zXis7b+Z2oE4u3EHWd5W6w2h4oBTbEiVBv4xj6ZnFfquj04u9Z0ZnLG1GnFocrutLG9+I0pg7jERnhIKcFrvq+xG/EXRco3gzfiaJzny+CTt5hRdfa+VYMaxETESeCBqIa8EM/Lt+Huy5RzIQbUXR2/4uX2TRhuOlqO98Ir9YLJiMCJCMU50UvLN+Gu37BmzJ/ZyLiofM7SNf1dr4PxdzANARBD0hAOdFLy5ep+mejiYiaLrAhiq64811gMacOosCBIUhGVb34+CpF/3DUU9IlhuuKrrnzTYhqPyI8ooIqooOcXl2+yal/Oi3oGttlSVddb0KboCAiIoFOhDImX6b8PQ7921mnuyjquvMtcDqhIBJiNGyHRAjLdfFrOPlHkK/xsjA97kCeQT2gIWYukKjX96/R9B/BuISHrlzcDRhTnABZ04AMgLovkfRfgforqhpuraSUUmnNjvbvd+iU9Tqni3aAoMj8HZz+OzgviGp0lOjpbR/LsKHp69U55LpjVSegQsZ3aH8Q0kpKKbX2depnTkyM5OhSX8SC+i/HOqm/LK2qXucUe3yDqJZ7TekIIaSUmzyWGh29GbLMM0oM9KuPRYzoZ1UNtkDXcxID7cuds5yXtVXJdRlUvwAPMyMf9KGLRZ6HJKZPOckUUjx9eDQb/pND8dURlpPANNLnCdI52mbrEEHUy2RVGq5iASmvL6nREujaoz6MxHSl7xMUpgujWIifDFgPhHcNJmyr0n4XS5tQoRkhVzlddroqKvpcHouN4uh6VyZJt6R7upi7tRHoWtcN5A+SguUkmydK0xpC1eVWj1B/0bGuftWA9eUltdg9YUN/CoWu526rMV3NHdfeYwENT1a9gIQX4JouOJIgzovSupSvCYr3i2OxkAh/PoNESC+WCgG5w+S9pNjOZNd3jKb5DtEFC1FF1Ivawo5rqoG8uKh4CWTRjweQCXsaKgT1gtK3WDCdyTJ3jPBsUZdciE6EXCQLy5c4NSiLG7juySb321cJ3cw0Ap+w8E5UqHiy7QSi52Re1xyIPEL9JU4XPi7JFvRYWlB4Z7LK/eYNhnkrg1E0DA1MIOteIGMuHmsaRESCOC85VqbuAhYTdWkF1pkMl3sXCF+MeIJHVHojKDSR/QjRMFXSNacfFVEvSUuLF0S1yQtjQYkn0+3OVTIYbCQyKGYKpNOMFVKmkkW5HydCLmlLqxcMI+fCoqID2eZ+45wF6hYGWyig+ooV6qdgQQhPFHXNnX56hPorZGnyWVCjfWEFlci6k9tWyGS0EMniAWqvIiTTnBGhcaKyqPgLCeK8wOna/UfVivp1CaiT/eO2eRtsYJBNKxUhPAk1RJloLIp/q4h6wbG49IlTs3lZQcF+Amo3rZHRhotGGqa/UmSiWQNCJtI1F/r9RMgFaXHtk2xHlpVAhWZ0Ny1aSTAhowmjLw6E8DTUABpuxvHCI9R/1hanH7DY0WNVDeSmoHLP2EqAFSuHjYxING9EpHsx6LUgzs9kdcd7UQ3XVSm20JzOTrkTlawy7LDibXQET0QCaPOMJV2O+4n6kdPV5/eGJeU1BZCbhKqZ9mUEc5ohQZFZG2qwN5M3BwdA56lLKo7zCf3oWF5/K6jpc00nptOsx01RrLfTQM1OtxAsLDdME1c0yVkeCZ+k5al7p9rqayqYcxqSG0Z2CyjbaRbOL3ROwytqHhJE+qStL77h1LhfUsO4eer96oYSKNopFvIXytNQWc8k941onwgiGG6Q8ka2lpek0E7znverLiPYSRbaF2rzOFlO8Z0I/cApcJDhCJFXLNZkRYzJE/n7lQwFEC9FvpDMQ+dqGvkLJLwXEM2Sg6h/EdV8XFDAHBPR/YrLILvRgn7jiaispVNUEOm9hEiWaEDOF8Ne/TZupn67wiq6oWDAf6UwEZWVMIUror1XEYepAqm/BZ3QrSdhaOb2YBymLSXcLTpkFatS/EToewPhTB0Q/a3OcH6XPlW6XWyIns05FXEaKxBOtNFDwjusQCHTjAk/nM44vkt7VLSKvJTzK6W5iMif6cPa8NM3+0GbBZHeCYhmizok/8hTqF9OhdS/mLSUdMvWXRHtnYRIxhKkExHLHGU5DZKmCv9q8m05EfpORRzGAkSZKOqc8hfhl9D/DNpt8ZDwxkA4YySQSDQm0fgHESDZTPtC/MdCgkivWIFC1iukUNBZ67Mo60tfJxqiv5aKaK8Copk7IYPqNOpu0mkkYY5bFv6uToS+SohszkE0KFQEcn6RMlVaQfpvgYeEFxURzdGACCYXyPgi7T9FJIj0YiC8vQIBuwOifi1lWfUv6PxjqIj2GyuS7MdpKpFAyloSRKdqd+G8deGP4UQo/xIQbQKeJhAViHwRN5PehfAPyUOOXxIiT0B9kkFEHqJxKScmTOStREx5fB4x2rLzjSFB5F8qIs6QJ4lERANSlxIwaaJoJWDa4yNEoy94Qyqi/zIQfoYwh/CPDFG3Eo9pE5WvckD8vRPAeGQnQpmIWJE05RyZfnrMuRLCKM8jS+hmEoTuXQOoe2IBchBRQPQ56hTuFxqQsZSBidN4teIw+vwyIj4xgmQiSogyxzlDpd9PiIaVNEydppih5cnNOxH1kTVEJ6KKOOfwM4QXDlNWkjDKk7AsIlhpiHbzAkL4iSWEMtFAhDlo2Bv0ukOEF3KA0iRR7QzM8fgIofGJBchBrEiatNiLb5wQjQtxIOE5hqGGSVYUme9eQ/QnRpBMAdFnieaE33CYthAaGE1TRDVUMdWIg6S7lxAanlhDdEqIMoszl+ndClG3kAISnoDFUsKIkQg57l6AtCeWEMoVcc5C3Zp7K2LSQiJI6wRZLZ0Y9TYKJNw9EoQeDyxAjoEI02Rjld5mzFgIo/QwF9RUACUTTqF0+wpk8PMiSFYkT3MYC+9RhWhYB1WUOGM8bDFomEgQuX8HRMsDawjooHltDfowYspCIko722pqiwSj0QALpN0/EojG55UmqRM1U/ETEojwOhimnS0VtdZAg3FFofkBZIz4GXLiOxcmSROdloQ/KhCN66AC0852ippLIE2woNj4ABxGxdsrqpL4vtEkYSJvKdPHB6YtJOC0s5Wi9gJKPYgHyD8AahgVb4y7/lrcbWtz8EQkhtxnJBB166CB0+5NcNEJSFCDMU2xQk8ggFS8qSD6uviblqYYNHOxU+nCgkkLiQZUDgOu6xQVpZ0RRcH1EVADqQRDSd9v4ZaFKepU0U64wmPGQmgYUM2MOkXniDDt/jJuij6fQUCpJiuh68c93jCaIk3lzAy6dEA0LCSa0BEhoandT1hgqudFURTungE1mDZvwRW9dMT71WYIU9GwEq/JmLIQGiZUW7wsNLX8CRUD2sMFcSh+0EMIONXiUK7o5ZL4ZqUZ3FzZiPA1HiPNfDndZdGI6jjdBe7savujYEF15PAOH0XU4vkUqBhQLR5xVIVKcrcqTCA092Ek08UDMmc/+RpqVlS158O94Y/c1fxHNEz87C2nlHIbatU9BhYLqiOHS/goovjibhRN0CZjI+6qtBxVSXyJN/TraD9F5/wsmjFf6DHQYeNnyzH4VyGk0tVqCfep2UuTUTPR6Gq3INXhr6BsbO7PSBblHgRVMzPLfUr2jtmSieMy6itSiVfw+GJpTZWeBMv6wn0K9txs3sKg688lqfgLyH8xHktyj4LC8hLdJzInNL0YOAFuTTquoPS9KK6o0LOgc3GN7lSz1uarOGEA9TVpvILq96K2HuGnQWVpnW9Vspbmi7hCyLiocQn37+XXE+lxUF+YeLpVwVqcz+EchBel/gry8rUorabSA+G+LPF0r8ian48GqhG2LipeQv57UV+L8BMh7qs66G41Y7TAgjpAcVHpGorfy8lSPD0S4r6mSLcr2WorOECDwPxVKH4tCiuJ9FCI+4oi3a9gK6+AQSeK6lehuAaZgeI6Cj0W4r4cCXTDyFZcAXWIMCx+F4qygOGnoLiKQg+GqCxGPN2yZsovIUEKwXlNx3XkZbrONAfFNRR6NnQupTPds2SKlhggDkd1SR5Avk9WmGahuIJCT4eCrKMw3bRgqa2BEI0MxhUJQblOlYjmoTjfSc+HuC5CIoHvDFnKi2iAwwLJggqG6JxHAk1FXuaSg54Q0SEraI5uXDN0LuLcN8hkWdCBIt8naUyTEbeZuqOHRFymk0j4W5MMhUWkfacNt55BBtMMctLLiYhOmSYR/EEQ+TZXZrp3wRCtkq8StkFpOdECuWauMi2BuMzRPT0qotDmKY5M3hqy05eRxkWRrPbFFDIamqkW6N25iFyxNyJZfBhEoU4hxZHRe9PMlGWQl0sKmeW+lEJ2QzPTI70/G5HLYmpEsvk4iFwa1vrJZPbeJDPnOuiQCwoZ5rqQQqZ9EQs10KfzEVGsZspBVhMy3jQiCmXYGdmT5XsTzISFkO+fSCTbpyxiHGSdYwWN09GiOZYBGyUy3fUAtUREPjUDUk9Hxl1A8tcjM7TWON6RwmSdz7GAHmlKPnK/qp2e1u5ibnKRtBw9/RmGs7TLRkvR0dNsRvpiiHyq7WeOTFO6mNvMKTqamMOZW3unt3wG+pIcQkqptt9LSikEpj9IDiGlVNvvNaV0BE/PNBmpy9lFg5G0KZGRsCs1G7wrJRODduVgom5LZCLtS81C2JeSBd6XgoFBG7OBtjM1XNqZEu7YmQLO7UwEE9qaG6rtTQmV9qaAOvYmQrnNqYFoc06YtjsFTN6dCBO3pw7x21OG0PYcEX1/coi8P1EHHBvUeZ3QBs3X5R2KymVui3JyUaY9+rxGeJOiekmgXZr7BZH2aS4fRdqqj/FW87Rbxyq/jBLof///f///f///f///f///7////f+////3/z/dWFqNvCA+W8vhvxd8tpbD30nRn52X40V/pv9aeNGf6fnp77BTfy/WylCvB4b+Hh4O9KeC/tr+RIb+Hv5I2gu1VqGOfV5f5v9WeH2Z706qcf+ddFXhVfsW4fctparpDyfXjX5Z4VW7OxU7e3aTsD6HPAX9fcuAWr9ESL+GZ8HY2k7+c1DV4qaAPkd9MVbDr86HlfTX9IBUJfGC+NV501TilwkvztVQ/k3435Vq9+uh/JvwXVNN34UOUVVJtBzKP4anf1kqfj1UfgxP903jdyEKITAtiDgET9/zj077gsiF4On+GoP0Gs72SvjLzPmKL/sXlt5s8krTgm5y6LMuDf2/JZG7iSHpPw8oiSbpB+Vaay2vy43H6C3/nHxeY1xneSZXNf19VU0/pdRaa34oVfWZVNW/iopoOP+SfF5j9LP8s9Ch4dhRGzNzqzFmZoPNDbULVLlbCrHugE5EdcCcZ35DTK8dEYX0a3gRVB1E1CbM1Y9dxy0wF+ePil/bUlLlz5ofSOeEuS73i/5+TWXmoQ3W64Y2oEs/trW+YM6rbsrXgjk5f1SoY0s+7yEI5cqfNX0LncYwMqst1liN5PMeC5AxuEQqq9WoUAcRtQlz9eOBcjAznzXty62PCWAMPvbk1scEMAYfr6OlcSS1G867JR92hvKAv6cA9A1pwD/rY1FfFyKipL+mz8qEfx07yoRf+Cfla8FevW5igb8wirGRQ8eCex07EguC69iQLviFtwyolVKH6qt9wV5X/g5a2jIq1BEbUH11wr3Yx1A5Vib869hz3AJ7nnlLHnALp1AecAunl13aHWBBUDi9qgmiq7yiCMLnQ0VfF4I0QbjHGPFZfk4ZiK5jQxoIyzFb6gj3WFnYeKdIWQjP8kARxOpCdNSvuDS8L10Iz/KCJgj3DW0h2nOMEZYjwAjL8a6mDVee2CjHiy5slPIGwcb+SJZXhSCCnXekY2v7MU2wcaRIEezMc82JjXekCbbO4muCnW3bsRBj7Ly+gTV5XZrYKOUxwc47km5slDPSsbO5Ona2V9UNRbC3vWev5BfsbQ+kiZeVMJu7r2Pz+CmMvav4imBvmWpz9zXsluxp2Dx2DcQ69s70vq6N101slfLU5u5LE3u7r2Pv4ejYe7yJY0VgD+ZrWGgvG8zXdGC8ZXbmIQ6UfTfMzibWzXwvBw7PhYfXcMJeN/O9DEjypIWHZ1o3870cODxFHLMz92lhOorsMmNeo8OenfleBubrkmjX2y5snu9YN/O9HDg8acKeF/MQA93TsFmS0bBZ0ou6xlaa0IUTfaYmGopWa63GWfWYcKLPfFlor7gzqW1ZY9sFszMZmJXUOi1JVoVTrkpEqd0/54A5K6m5axieG/Y6CxHlNgzkWms3qp5js5JapyXJMWH2TGq+DbA1YY+Wiaic610M886k1qHhssbQy8syzNUyEZVuoL1gVlLrtCQ5bphXJrUtDc2xDOFMRJlFw2UsQzgTUWbRcL0niXZYF/RZyE5Tm9qnUcnvmIXsKsZ8QyM7TQNlU4PZmQx0cnYDzVoOJrus35LE6OSsoqBZFaY0sg+BfbJBfk8nZzfQrAZdDnJ2Q4wT5qxkn8/Nm5mVArOR89QQbDXog152GjORXoz7uU7ObqBZDbpUcnZNklGhSyE9iSZahS6F9CSavOeGnowMXRK5u4L2FknkLQbycyd50zR4T4HZmQx0cnfjNg6YUsib5k9h6J3cRZRlDWNm8nqZr5O7G7e1jELuW0NTkhgjkbc91DM5h9HI3bRmKXfokt92G4Vs1vBYJ3c3bmtpUsh9KmCDjUZ21VAUNhrZVUN5S4feyexGoeBUxlsa+dlojw3yZ2NsyWJ0JgMr+dLSYNxWJX9a7xk7JZBEmxSsCppWoUsmv59uJV9aGowMncmfRLuVBn0m8rdHGnkL9IuCp6IONZwL9kFvG9ogZ37JSr60NBgN+knBrkiIvEurAfIurb4itQldsiVap2hVkN+xKJgMfqwGqGuyI03o4snCSUE2spJgdorW9zxpNOglQl25tW6cFE2znRRkI2vNSAHioWq3USl6P9DJfWmSIrSUjNoplb4FHhr6UycF2cja1AZFk3ygRYrnGmoJFM811PKADHPC2cg8oOcQLeV8xxWhofWnhKKHhh03dPFkIkeyUZXDyiG6f8etTQpXBUkRTVKIxmQ5ko2qsdbpUeiDwln2Zd/SLgqfyjDXE72vG4cnui1HslGVDL2FqCs9cnmC1uV50tjayb60RfGu3O84QqyNp0Yo77ugiycTQmHxsTEonn+HaBwj7fjI0C+Kx7mEwhLoWnukGC1GvG2Su0CvsaooG1s9f8FprPoyobD4mpFirCytGnLuqoac38XkHNqscW29o4baSzhE2xp0KWRjxIZvGG0DjV9RoJ81rvFHNcoGkqlGbASGVh6pBm3M2y5fM84aPrVgDAC/LxvAlV81YsN3GTV+KkgKiQaMvIdEA0b+nlHJi8ffUUL1tyzoUmgpZQf/isPY3320s30BesPYQbKLfWzsT/bQX0eXBQyuv2IY+6t2WsC8jrThtIB5HekL5lXI/xvot9mNfgNM2tnewjuXjx8brrEl3YNry9h1+O4vI7vWei0N/DrqDgDSW/oF8y10OT7vliN0OT7vlt/WKfpc/mdo9PvqW2jneNf8oH8eflP1jceKFbVrKK8jdn3e7fvw+GlQExeA2ZKPmrgAzJaeGkRE2UB92/kfqPZX4B+Hfp06S3Rr431URgCY9deJRbkHgNV8lHsAWO0NxMZ8G/8zoPyI+QT/LUuZW9rK7hf1LfIbvKkkCsr7iEpfPuD6cXAQ5Wv5gDu5iPK1fMCdXpCWhnNP5+3130HKbxhG3TF+De9XhoItsjLW8hvmjow3Ld5Ppqhr5zcQUeHpQv+upQ3e3lxElM/bhZl8RJTP24WZnqNmSNpy0uN/2OgapCyBDd6Q8CuaQQ937dhw6MqadjwzFeQN5ztYG/T2y06tfwkR5XM5cH3V0C56cWrTgREiotSmA+MFNDR039T6v0yaGsSt4DDWBv4Z1SgPndrYUJZWtP5M13jDehV+RdVGADE8QESli4H0Tbc230REmZeBuoGIMi8D9QXFQHXdmvzLUFoaOi8gGeCY/IxkXA8VDUfI6dJoKRLKrOePpiGHGt5RjfYjeNMROR4iStM4vok15HcRUTd4DxF1g19Al7FcTcMZSVVP/wRURNPO89FtSI6c+Bk0NUmRXHWNlrZSpCzuUnBGOnQlGXdovoSMFSpV9dbuABk90gNt6B7KBn9TMXqo6lkpQy8eEm18lKEXD4k23pBEA3uSISXA0IuRjfY3UTW083zNwAwU+SGnhjuQFtRhsIYeCLq4okn2VeiD1FtDC5x4S9fAgQI9G8vQ2Vgaiq8gcEIvHvoFtDQcgQa9KRV6cw1Xhd5c40V0GpId1DXM5GrQJ9nG/UdRM7TMR8tAT56y8EOSaOi+Dr0Z2UB3HWLp+AoaCmbyFDGqdhhorhOvqQaaK03D20rTOIxurORJK1KM4Uk/oRlSXEU0SQqJtpJnuUi0lTzrTTQ13J4kGlZ1nDBbDPWPosvQMl+zsJqRGd4F0GngTla6oUsyqBsY1chF376uGTN/RdUgzToF+iBzGujZqAPvoW6AHWVCb2SqTuhCZjWwqlUXIjQ1dEf/CTQ1yOmoAp1J7xpmsk7ot9I1zGSd0O93VAPVQc0ARstElM8Fc5BzGFjj8++hbmiZjm4LkM714AH/CmgYkKt+1EtgNrKTGMC6ztquiQ+vKwYwxxijvYy6BqzOtXJfMCVbxQLm1ep5LfgfS2JgXYWI0tFhe1h1cl+wT4uGAfQjEaWjw2scBkZV8oBZv6sYwDoLEeU2YEoysoHVlNxhspINrKbkDpPfQbexPNStuGTPael/UJqGpunSdPhl/ZAkxsabvMURFBgtS+W3pWnEGzmbIygvoWJtZIJt7uTMYm016DaAefE1YQt9FzVr40E2G8DqfA04s0JsAKvzNeDML8migT3Ut1XyJvnrKC1D42yU5hYp44dQkV0zuajtEY9r30Vpbmrk5j3zeAu1bZ3mmMlDxxYJpWlF+duItzXy3lb0JvO2oje9hNiQ7KG+RyK9f3w9KmKgfRule8NI9FPI92tmomCVDd0TjspcRNeWRsF4ReNghoJcU2iOnsjfNkgJEfdrOk1H8aJG7jT3SLK4XyNsJi0Nt4uabBiePg3j21G10L6NqK2AnEQ/hrheUROF8wxlJguUJqO6QqNQOIxP5CQyRK5fkWmKdVC4SmRmihG3KzovgMLaII2i1w4p5M1XiCczdBioLso9IonpwqOM70bNkvJ1RMct1roS/R6io38yDtrapqsFIhvkziYzEdW+HKsX2slpvFUc2SKK45PmaYLVK+1Ml3hWI9pBFPtHnWkFlFgiPVO8jpAU8of2kXi6NrPaAlRoc2q3vJAamZbKusNqZrV5qLF5flRWq/GFpTEzH4X059LvWxqr+QMin/urUQJdXs57ABj3Weir5sqfNdN+n1pXlVZPR9diiI4yXvXsCF1545Fpe2p9LGAOLvTJuo/IxfqOJHq3slqN17e+rHFm2pvb7ZGeKOxifUcK0ypd+OnooT83qQ8/6amHn56+Nsf6o+eDFpvqZ6Fnj/4xe0u0+Sg/eolMf8RLK4vZZRP0tDOVoZdYM8LWBL3Hhia0NYuGEjmgl72pG1J9VQy/N2UDuJKVLpiNNme2IL3VWmvrAtvvTjSsnYm25zT3FdqgU9+VaY8+1o510DbdRmQ1+h/VufWpyeBC/+0XAFZQOCCCEgAAML8AnQEqvANzAT6dSqNLpDWkIiV1abCwE4llbuFuXjv+MfgB+gH8n+KofeqHg/9AP499/kgP4n+AH6FfzL1B/Y/5h+AH6AfxTr29PMo0D8ALi2m7jd5ase/Of5P21+WPZp+KfiLzarcfmf+J/Tuj16gHnv9Vn9O9AH2q+5x/r/U3+1P4zfIB/OvRf9X70Bf5P/x/Ts9k3IzvBP8A/AD9QPz97/CEQp/KhXr/lylKpmpiujx0FJzt29ijgK4o8dBSc7dvYo4CuKPHQUnOsYKPk29BvgmCj5OhedOhT+VC4UOFjBR8nQvOnQp/KhcKHCxfvqAB4ht9p0KfyoXChwsYKPk6F506FP5ULhQ4WMFHybbKaQ2KvgbpOhedOhT+VC4UOFjBR8nQvOnQp/KhcKHCxgow4JhZLXikRtEcAm1r8nW2idVkeEoha0ElFY6xWsiP2gPRruGGLZcX7cUAq4mW+LV1VAacWqthCVmQpSlKUpSlKUpSlKUpSlKUpSlKUpSlKUpSlF/QTgVc1Tf8UCmJr+z0xKmdgZZoVZb5aa/XnQV50FedBXnQV50FedBXnQV50FedBXnQV50Fb88Gl2VAlSawq0roZoCq2efJDexa8CzpgvZGaZ4XnRZ0q1cOmMSFPyYhQyVu+cZAgpplhZdoiywsUAr+JBJ6sOkRg4Y1iZFIDHXAT7WhKI5EpUE0aIk5A0+N/iPBs633atl/rQ5chLd6/HU2oareagY4TZNlxVGul8UJrFGku0WzbLq66Nsx7JxFcM6OTmrcJ46Q1druwZfuA3zRHv0797CqmUvonVYuEMoa3o+6eFVIN6KKPZqGjCZXEK+JvsNsCCY87cq+P8/slg/0GY3daoU/NRmAiXvA6p32kmGmZqPNNPHNHR3ElCZKSQNEC1eisIOAturwJ2N+K2ndZYqcJMGEJHQPFHqZsx50VfIM003LEYa1+UE3znm3EEQmURkCySlKGIBf0gIVJRCnCpHKZtkzDeqLT2xKzQmzXzg5xNJxmGGhrg5RNmekAlqd/7PIp5WLH2H/PJz8/lHNnbkxLVyx0XiLh+8mKm1aGn07T5vw0zoRQGU6TXXs4Rrr5uGmpv5hSAewan8MsB9r70p7vtfMJeDOK3M8NmPq8OW+RN4wunAYIENlLYfpdqZO0q9eW31bPYBxOGeZeCbOpNlM0Xs0aXwRNVpByjWaMZYM1oLaZx8GaRKeUwNsYQyiY/PBxLQJ/fQao6j2mmY4cq7+ICoF+lfUvKcA768BQstC/FulqFzA7TkWKvgJna6mkrlpL6XwKcuJuzlBIAhUWIlizg1XzvLN/GKXkeLuHjnWfPV4o6ShpqcAauUscLF++n/7FlGJOMtQvznScTAe1M1cGWWqqoQkgoBonazGjizxSt7pXqPCTurhQ4OLVKe6Uxv/15r9edBXnf8FedBXnQV50FedBXnQV50FedBXnQV50FedBXnQV50FcLP9lk6F3Y6EWaL1WW+Wmv150FedBXnQV50FedBXnQV50FedBXnQV50FedBXnQV50Fec4YhwsYKPk6F506FP5ULhQ4WMFHydC86dCn8qFwocLFOPF0jP+hPmhnta0jSv75hhty++ZUULT/RRJiVuLr7zXOND21G4cuFDg7O7VJCw/5wlnaJgo+Tnr2kyAEe16vn4O3ZEGdetXYGS2gbF65PoABgLGXPWmSvJl5woBI4gkxNoEulVtded4forQazqI2k425oWUPQ4WsLty+JrXqmLMcINwKnQ1xWFljKaXSrOT3Z03E0mzrkiA3QbBPHlbpzb5CcwoisMxSK1TL2KGTjLQlC3iL5RYG6/ONSPRRN5T9KbxXjfzTe3lscFbu46CwOE89gqTQ6t1/CmEdgCqMtuSmBPKZhEjgqXc+pq2dTWlTKyymorces2r3BN/2jlCwp7j2zOS0ZMEIw0hmniqrsP/WxuEgDqHlA5od02lsbhQJkV4jM58cihs9NK7EAparAAQ5jGJ+VZphv37ezDha/NQYeNVgENUlrHxKFQwr/9a1+UEH6CljkVn9gE2sYLP4AA+60AArJ+o4lz1Kk6e9zUyBmSP7zcli0VA0zOYsxg2/WGVap0Gx3aidPW0ETUh0SbMB8zYpA4x6hKSwGnUJSWA06hKSwGnUJSWA06hKSwGnUJSWA06hKSwGnUJSWA06hKSwGnUJSWA06hKSwGm8gCCIGMQUukFcs/cM63mtLveRND4w9iKCO7t5l7jTY+TAAAAAAAAAAAAAAAAAAAAAUm5MLI2ZjdbqDKRjqQqoMeMW9Ul8MsEdOgAAAAAAAAAAAAACz8JLGY1vNfnlCNdf7SQtup/jieRZVbGAZ17IyDcTsxsYTaGoMdNfTLPqLQPjPYACRhj/oFADizUrqjVfjAwyV2JwVFsNkK4cS81xx1pgn6xm36AAAAAAAAAAABO1x6ddUogFZCYovz+bcruqi/hD0eI5//Uzjuvhx3tXRIDBvvwpBBFpGcu7entWaOi0y+xm/5TuiNSiQmy7YY+AQJ2VWf0Isyp5oDxu3yPqjrOc38sGgG5T+et+WGmk2+/M+7mdD+GzRjQUdxbotvDRUR1XwZ+PFQx2bhEY1X5H86NNUkYEgB1VXj1Jw0zko2+/M+7mdD+GzRjQUdxbotvDRUR1XwZ+PFQx2bhEY1X5H86NNUkYEgB1tSZXEb23GXRPJLozv5kPaNMYhf9Ssmlu7Y530Eql3UhbzIQ2vUQzarfy5AWRoyQKpBIDVSxs247kbLqiUX1AEBQzPzRp1RE99Jo5vHUPBEgBbg+tMrVisrv+DIpv1RgYQ1NhCrfXAQe5ehk/ePIAFZonQhqbCGGXb4ERL4QFj4PC2aDFMFeOAlDtGw4z7Q9LNKkSCLRBYmPE8wtm500lvhf61tjkC4KA14p/o4lSrpq5vlwZLk5Bb8SFig6niVRiS3Qh5cPtLG9iyiu87dssiVWCj/BgOTgISzdRI/ZaO0nquiNFpvWG8l6/qet6EdO1fFzwXUnm5LPhtYi/9s4H3gMncOanSe1VQ9D6+Vjdg/FE2zhTsDPIiKLYg2N/J55IIIvz3NtrtbZ9+v2351VydexOqgNHs/7+NEcAZmj+2H12sYU9ZI7PniXRbHHo18hlOAr1Gcib6wS/xtql1qiaMtU4kBe2/bF5bZVuazZNpS6uVB+NXsDMcu88C89flD5fwvhNDTJnTkvSCG4++E0DBX9jKvM3XmTZpMc8Uu5HkUQCBuShp1pE1GzYniGV337uoXlD2XN881i3A2xdzL/qXussqtEIV2hdFhCtI5VnyEGSOdP/KJv18ghq9RFpacVr9gAFVh2Qzzn8nt64AskroqbsP8nWIpEQgfwvk/RROQ6vGND0kpUDANybO998fpLWKlFK4K4cssJ2gyyAtL1bUnoMddqP32OimAZPLS/ST7sfL+huL9uB3INTZPkX3GzyfkELgaB/6ZdWeFCv6er/XbxbtDcZZrgRPIicgVRJaJIE+83a9ZRRqHI2EJuE7tocWqo3Tz3ZqSlwcR/uInGES4O9U1SrB7oagbQyCMW3B9iwOLrnFDP0UuIxYqfW4tGo1l8eNHO3YK0QT0Tai63iRGlfBhY3o90VxaSFxhzgavanZ4Onz7QufVJ3YG26qV6E8HRBI3b0Cf2PJ6cZ4OvpG2punCd4cedULokBhRdVCWl2nD1v7AP4430Jsjv6T18c0/zG8N8dfAPKfsbgOyO7hBuIVAvf3ZMORWPErEWN1Ye6JgicsLx0/GPNPPmKxfHHVd0RqUSEQ7NY+1rzWVerKm6+z5OENOy/Bu5uMy39lfd1WEUeSVEH1pzcyIwTfPeII3QuTvlUMBuQFrA1cgoFqTE5ed4OxgRXGxtgB7p11r/K91X71ismdfMVdOhvLglWK3HLELPCVU+Hm7eq2SP+a+TKA2NOn8iQvG0O4RjBlbCUQ+YuN05dlB0smUAMot2KtewcVtZLAgZxWCf4uKds55wHjY+bdRivyIvPynJf/t9QX9LmXz5buECbdeMVpC4DN57opZrKp4/nLWd753qgYBMxdLFJZfE9J+U/qQXaMyj8bC1aQmcXvVQOQpqNGsgP6rtGjAYE8kUqR8efKQSrjxkNRBD2LG6qJWLjZjlZcOTyYnfNYkhiHpQ4GAM2Q766G1MCj61bQcbx6nb7ejQn7wCh1YA5Gx/vnXPKdV4gi2A8bhO/JQAh7PhTWNWoRVB2twjZwz7QAZycslLrnjEPZd4TSWWuWVoqxJetzjt2Mc4midBMczaccimGCN/3AJlF23+xY/WMfJehokP8G2JizsRtLAAhejuqKVW0ZQKGXtsZ+ew/KODMQuc+wYtYO8g3IXpmHrl26dMYD/1wHJj2DPoFwZpmUR2w+FnAj2Gt2k/Q5Nq2jDXgRfCKzLKEDTRO4k6Dsij2stWNhgeBLg7WGh8v4MACDmYrZ1uw/AcHs83LAany2nn3X/w+5KAy+XVr7CQxYgDa6TvfCpHFwDrHAkME7+jZoQ4HvG7+gn1t0V/HsO7SIdi2sYUJTEW0OYxwUTswAXun1jSgtoHVNBXIuOHqTh0UpmkQfaAMqR5+6h1BIS9OdE0s0PgAbfhiOG0eIj1jOUrAxLhwbii/YYOIKAGURF7myfNA8ynjWjn1KAzKgdYv4O1dDHST3+I9rnwEG5wZZADXBIqztN7/ZMNAJWH9soqVwFG9jthPf+KLZfNTCYgjqm5O+/tWH0NNb2hfqZ256eHH530pPIj67JY94qOvEj3MeflPQuY68zS0jE8aogIfkCF+jckUSU/g5UH2d7AfraqUSfLXY/CEdGiLObd2yOLl7pW8B6jG3c9L7vYFo6QpQXJKqClu5MayyEfNZ9QnWXA/VWidT/5rmOO4GaFBXX1sKmU6JjdEgtD3WYs4g6MCrOtWaUuQk1HbW5Slely0UG8jP1Z1r/56gH8Fgbd7teo8qxHjJN9MkODwAAAABd57AAA9+V/Ln2FZ15rQKKTMjv7gK8OTwXZL06Gg538yPy0cb//8cTOHoW1PkKGN45jqD1mwDAfqhHoBQGDOOw3ESjeljNnE/PRjpzXhUJ2j8N8T8pgwYxKw4T/d5lneZZ3mWd5lncas7zD4PcgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlIf5pJtpkYrYzB9nCh79hUhBvN5pHD5OHkrSvWOeKr94BjmFP5hThigGjsvL036EFvJ1r6VevaVezfCR1eScVX7jSzD3E8MGK6nIUHOJsFPO12fVpf5P1UBSETl4ABz3GIU0fFjgtlrfWSES0AHvHVNiVIOV6qZl3JZBjtcJUlqMWJ0aBFVAbfWwyWdsXy7RTmX68TDizpl2qHzEMc1VmnarX+YpvHIl+oE58J0JhaT9jjAd15f+x8jcPYTuAjvNuJwyUP//J7yaJdokA4coR0j167NfQfZKFfYuTl0MAAfT1P2shtnxErL5OIg827Hk6Nm6X0rIXMiVvGw55rpyGD1R7fdosO7zy09+HAKZW6x+MoJCZmdlOOhk3iIHlAXiTMXgQHb14r3YllYytbiU1gwG50MZdMOlX2HyDIUFSChxABeYnTuYuZ0p6Su70rDkrbNLhbjRWwjFDBxjHrFp0Mys93TnAZsOPeh31TbfUEkUqU+I0ChZtapV5fxklmZoLJGpaEPZBmrviXCjmADnjIFiMWL9K3/iU8jglI3AKBD3CJq2B3ms+V0ud+ALE0sDNT2F2HpY41K/FBTlqIP/+Vdk3Nz8dyKCNl7DRHaTLsrQvJACWdiNONHpLdTh5fpppE2G6mnUSPjBscZHCqeVtrBiqBhQJDiE8ocHbiJE0Xr4jYjqgub0b12skco51fn5Cy0yFHdsIpRAgDBAWdmMi+STlQe3xjfOfeNuvf3SRFWS8Is2hbO15dehbNwxC2K0OF9QcgsJyCXaV1BDakk1G7J/nfVxVrQ5tY8zYPEG4PHaGYf96830uCkkjahxc/31FStm/kRlAekQmTT0OaoVFl7EuN2/yZWd3j2kKH6KKkg8h3ya2Sgi9+ikGjNM+UEeoiPRpkpwJ9ufexAdG7KmJcLbTi83g/taGiN6ipWZQ22M7MQAgs6WnlnzWV/mOMd5hWhehEiEOdx1z5wrPWR7N2NT+GA+t+couqUupiTB6Mxkgk4+LsOMVYGDz/EnaY6JyNL0vOUT2hUiFp9W8KcSAeA+L6b8k7SDv+ZhVWyF9Btbftng9hD/07J4e3RB1Del70YOsN/hcfz+94Jdxg1vwqQ5u2CwjjA6QBZ4AAubnJhY25zk9JwQ6uSPlBj1/oXdaqlFAAAAAAAAAAAAAAAAA=="});print('printer from Native: $result');
      return result;
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return false;
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
                barcodeScanRes = await callScanAPI();
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'Checkout',
              callback: (args) async {
                transAmount = args[0].toString();
                await callSaleAPI();
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'printInvoice',
              callback: (args) async {
                transResult = args[0].toString();
                print("transResult $transResult");
                if (transResult.isNotEmpty) {
                  final bool cut = await callPrinterAPI();
                  // if (cut == true) {
                  //   Future.delayed(const Duration(seconds: 3), () async{
                  //     await platform.invokeMethod('cut', {});
                  //   });
                  // }
                }
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
