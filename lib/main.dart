import 'dart:convert';

import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:flutter/material.dart';



void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FatSecret',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: RaisedButton(
            onPressed: (){
              FatSecretApi fatSecretApi = new FatSecretApi();
              fatSecretApi.fetchAllFoodsFromApi();
            },
            child: Text('Work my FatSecret'),
          ),
        ),
      ),
    );
  }
}
class FatSecretApi{
  /// I used these tuts for reference
// вы

// http://platform.fatsecret.com/api/Default.aspx?screen=rapiauth
// https://github.com/EugeneHoran/Android-FatSecret-REST-API

// https://stackoverflow.com/questions/49797558/how-to-make-http-post-request-with-url-encoded-body-in-flutter

// https://groups.google.com/a/dartlang.org/forum/#!topic/cloud/Ci1gFhYBSDQ


// https://stackoverflow.com/questions/28910178/calculating-an-oauth-signature
  static const API_KEY = 'df3b63f9dc6f4c499171b0186c30fd2b';

  static const API_SECRET = '581ca8909b3f48bebfb4cb88ca6702e2';

  static const API_METHOD = 'GET';

  static const REQUEST_URL = 'http://platform.fatsecret.com/rest/server.api';

  static const SIGNATURE_METHOD = 'HMAC-SHA1';

  static const OAUTH_VERSION = '1.0';

  var _sigHasher;

  FatSecretApi() {
    var bytes = utf8.encode('$API_SECRET&');
    _sigHasher = new Hmac(sha1, bytes);
  }

  /// Fetches all foods from Fatsecret Api
  fetchAllFoodsFromApi() async {
    Map<String, String> params = {
      'oauth_consumer_key': API_KEY,
      'oauth_signature_method': SIGNATURE_METHOD,
      'oauth_timestamp': (DateTime.now().millisecondsSinceEpoch).toString(),
      'oauth_nonce': nonce(),
      'oauth_version': (1.0).toString(),
      'format': 'json',
    };

    var signatureUri = _generateSignature(API_METHOD, REQUEST_URL, params);
    params['oauth_signature'] = signatureUri;

    var sortedParams = SortedMap.from(params);

    var client = http.Client();

    final response = await client.post(
      REQUEST_URL,
      headers: sortedParams,

    );

    print('Response status code: ${response.statusCode}');
    print(response.body);

    print('$signatureUri');
    print('$sortedParams');
    print('$params');
  }

  String nonce() {
    return randomString(8);
  }

  String _generateSignature(
      String method, String baseUrl, Map<String, String> params) {
    var encodedMethod = Uri.encodeComponent(method);
    var encodedUrl = Uri.encodeComponent(baseUrl);

    var sortedParams = SortedMap.from(params);
    var concatedParams = _toQueryString(sortedParams);

    var encodedParams = Uri.encodeComponent(concatedParams);

    var finalUrl = '$encodedMethod&${_encode(encodedUrl.toString())}'
        + '&${_encode(encodedParams)}';

    var base64converted = base64.encode(_hash(finalUrl));

    print('encoded method = $encodedMethod');
    print('encoded url = $encodedUrl');
    print('encoded params = $encodedParams');
    print('final url = $finalUrl');
    print('base64converted = $base64converted');

    return base64converted;
  }

  String _toQueryString(Map<String, String> data) {
    var items = data.keys.map((k) => "$k=${_encode(data[k])}").toList();

    items.sort();

    return items.join('&');
  }

  String _encode(String data) {
    return percent.encode(data.codeUnits);
  }

  List<int> _hash(String data) => _sigHasher.convert(data.codeUnits).bytes;

}



