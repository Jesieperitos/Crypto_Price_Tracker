import 'package:flutter/material.dart';
import '../models/crypto_coin.dart';
import 'coin_detail_screen.dart';

class CryptoListScreen extends StatefulWidget {
  final Future<List<CryptoCoin>> cryptoListFuture;
  final VoidCallback onRefresh;
  final List<String> favorites;
  final Function(String) onToggleFavorite;

  const CryptoListScreen({
    super.key,
    required this.cryptoListFuture,
    required this.onRefresh,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  String _searchQuery = '';
  String _sortBy = 'market_cap';

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price':
        return 'Price';
      case 'change':
        return '24h Change';
      default:
        return 'Market Cap';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search coins...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),

                const SizedBox(width: 8),

                PopupMenuButton<String>(
                  initialValue: _sortBy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sort, size: 20),
                        const SizedBox(width: 4),
                        Text(_getSortLabel(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  onSelected: (String value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'market_cap',
                      child: Text('Sort by Market Cap (Default)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'price',
                      child: Text('Sort by Price'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'change',
                      child: Text('Sort by 24h Change'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<CryptoCoin>>(
              future: widget.cryptoListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available.'));
                } else {
                  List<CryptoCoin> coins = snapshot.data!
                      .where((coin) => coin.name.toLowerCase().contains(_searchQuery) || coin.symbol.toLowerCase().contains(_searchQuery))
                      .toList();

                  coins.sort((a, b) {
                    switch (_sortBy) {
                      case 'price':
                        return b.currentPrice.compareTo(a.currentPrice);
                      case 'change':
                        return b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h);
                      default:
                        return b.marketCap.compareTo(a.marketCap);
                    }
                  });

                  return ListView.builder(
                    itemCount: coins.length,
                    itemBuilder: (context, index) {
                      final coin = coins[index];
                      bool isFavorite = widget.favorites.contains(coin.id);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 4,
                        child: ListTile(
                          leading: Image.network(coin.image, width: 40, height: 40),
                          title: Text('${coin.name} (${coin.symbol.toUpperCase()})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('24h Change: ${coin.priceChangePercentage24h.toStringAsFixed(2)}%', style: TextStyle(color: coin.priceChangePercentage24h >= 0 ? Colors.green : Colors.red)),
                              Text('Market Cap: \$${coin.marketCap.toStringAsFixed(0)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${coin.currentPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: coin.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                              IconButton(
                                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null),
                                onPressed: () => widget.onToggleFavorite(coin.id),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CoinDetailScreen(coin: coin)),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}