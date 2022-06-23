import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_cover_sdk/my_cover_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Mycover SDK Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var allProducts;

  initialiseSdk(context, {productId}) async {
    var userId = "olakunle@mycovergenius.com";

    final mycover =
        MyCoverAI(context: context, userId: userId, productId: productId ?? '');
   var response = await mycover.initialise();

    if (response != null) {
      showLoading('$response');
    } else {
      print("No Response!");
    }
  }

  @override
  initState() {
    super.initState();

    // initialiseSdk(context);

    getAllProducts();
  }



  Future<void> showLoading(String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 50,
            child: Text(message),
          ),
        );
      },
    );
  }


  static makePostRequest({apiUrl, data, apiKey}) async {
    final uri = Uri.parse(apiUrl);
    final jsonString = json.encode(data);

    var headers;
    if (apiKey == null) {
      headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
      };
    } else {
      headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
        'x-api-id': '$apiKey',
      };
    }
    return await http.post(uri, body: jsonString, headers: headers);
  }

  static const String productUrl =
      'https://staging.api.mycover.ai/v1/sdk/initialize';

  getAllProducts() async {
    var data = {
      "client_id": 'olakunle@mycovergenius.com',
    };

    try {
      var res = await makePostRequest(apiUrl: productUrl, data: data);
      print(res.statusCode);
      print(res.body);
      if (res.statusCode! >= 200 && res.statusCode < 300) {
        var body = jsonDecode(res.body);
        setState(() => allProducts = body['data']['productDetails']);
      } else {
        print('Errororororoor CHUCKS oooooooooooo');
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('All products')),
        body: allProducts == null
            ? const Center(
                child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.green))
            : ListView.separated(
                itemBuilder: (c, i) {
                  var item = allProducts[i];
                  return ListTile(
                      title: Text(item['name']),
                      onTap: () =>
                          initialiseSdk(context, productId: item['id']));
                },
                separatorBuilder: (c, i) => const SizedBox(height: 5),
                itemCount: allProducts.length));
  }
}
