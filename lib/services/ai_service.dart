import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/crypto_coin.dart';

class AiService {
  final String _apiKey = "AIzaSyAdGBwEsnlzoeVZltfvny5pQeI-S5JuP60";
  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> getMarketSummary(CryptoCoin coin) async {
    final prompt = """
      Analyze the following cryptocurrency data and provide a concise, one-sentence market summary. 
      Indicate if the 24-hour trend is strongly bullish, moderately bearish, or neutral. 
      Base the analysis primarily on the 24h Change and Volume.
      
      Coin: ${coin.name} (${coin.symbol.toUpperCase()})
      24h Change: ${coin.priceChangePercentage24h.toStringAsFixed(2)}%
      Volume: \$${coin.totalVolume.toStringAsFixed(0)}
      
      Summary:
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'AI analysis unavailable.';
    } catch (e) {
      print('AI Error: $e');
      return 'AI analysis failed. Please verify the Gemini API key, network connection, or quota limit.';
    }
  }
}