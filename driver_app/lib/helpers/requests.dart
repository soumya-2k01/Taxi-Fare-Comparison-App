// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:http/http.dart' as http;

class Requests
{
  static Future<dynamic> getRequest(String url) async
  {
    http.Response response = await http.get(Uri.parse(url));

    try {
      if(response.statusCode == 200)
      {
        String data = response.body;
        var decodedData = jsonDecode(data);
      
        return decodedData;
      }
      else
      {
        return 'failed';
      }
    } 
    catch (e) {
      return 'failed';
    }
  }
}