import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/crypto_coin.dart';
import '../services/crypto_service.dart';
import '../services/ai_service.dart';

class CoinDetailScreen extends StatefulWidget {
  final CryptoCoin coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  final CryptoService _cryptoService = CryptoService();
  final AiService _aiService = AiService();

  late Future<List<double>> _historicalDataFuture;
  late Future<String> _aiSummaryFuture;

  @override
  void initState() {
    super.initState();
    _historicalDataFuture = _cryptoService.fetchHistoricalPrices(widget.coin.id);
    _aiSummaryFuture = _aiService.getMarketSummary(widget.coin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.coin.name} Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.network(widget.coin.image, width: 50, height: 50),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.coin.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(widget.coin.symbol.toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '\$${widget.coin.currentPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.coin.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Divider(),

              Text('24h Change: ${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%', style: TextStyle(color: widget.coin.priceChangePercentage24h >= 0 ? Colors.green : Colors.red)),
              Text('Market Cap: \$${widget.coin.marketCap.toStringAsFixed(0)}'),
              Text('24h High: \$${widget.coin.high24h.toStringAsFixed(2)}'),
              Text('24h Low: \$${widget.coin.low24h.toStringAsFixed(2)}'),
              Text('Volume: \$${widget.coin.totalVolume.toStringAsFixed(0)}'),

              const SizedBox(height: 30),

              const Text('🤖 AI Market Analysis:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FutureBuilder<String>(
                future: _aiSummaryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: LinearProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error fetching AI analysis: ${snapshot.error}');
                  } else {
                    return Card(
                      elevation: 2,
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(snapshot.data ?? 'No summary available.', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 30),

              const Text('Price Trend (Last 7 Days):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FutureBuilder<List<double>>(
                future: _historicalDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    List<FlSpot> spots = [];
                    for (int i = 0; i < snapshot.data!.length; i++) {
                      spots.add(FlSpot(i.toDouble(), snapshot.data![i]));
                    }

                    double firstPrice = snapshot.data!.first;
                    double lastPrice = snapshot.data!.last;
                    bool isUp = lastPrice >= firstPrice;
                    Color lineColor = isUp ? Colors.green : Colors.red;

                    return SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: lineColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: lineColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Historical data is unavailable for this coin.'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}