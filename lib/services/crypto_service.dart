// lib/services/crypto_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_coin.dart';

class CryptoService {
  final String _apiUrl =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false";

  Future<List<CryptoCoin>> fetchCryptoPrices() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List jsonList = jsonDecode(response.body);
        return jsonList.map((json) => CryptoCoin.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load crypto prices. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching data: $e');
    }
  }

  Future<List<double>> fetchHistoricalPrices(String coinId) async {
    final String historyUrl =
        "https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=usd&days=7";

    try {
      final response = await http.get(Uri.parse(historyUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> prices = jsonResponse['prices'] ?? [];
        return prices.map((item) => (item[1] as num).toDouble()).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Historical Data Error: $e');
      return [];
    }
  }
}