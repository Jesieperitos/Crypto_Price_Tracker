import 'package:flutter/material.dart';
import '../models/crypto_coin.dart';

class FavoritesScreen extends StatelessWidget {
  final Future<List<CryptoCoin>> cryptoListFuture;
  final List<String> favorites;
  final Function(String) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.cryptoListFuture,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CryptoCoin>>(
      future: cryptoListFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CryptoCoin> favoriteCoins = snapshot.data!.where((coin) => favorites.contains(coin.id)).toList();
          return ListView.builder(
            itemCount: favoriteCoins.length,
            itemBuilder: (context, index) {
              final coin = favoriteCoins[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(coin.image, width: 40),
                  title: Text('${coin.name} (${coin.symbol.toUpperCase()})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => onToggleFavorite(coin.id),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}