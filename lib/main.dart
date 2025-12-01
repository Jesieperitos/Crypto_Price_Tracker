import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/crypto_coin.dart';
import 'services/crypto_service.dart';
import 'screens/crypto_list_screen.dart';
import 'screens/favorites_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !(_isDarkMode ?? true);
      prefs.setBool('isDarkMode', _isDarkMode!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDarkMode == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return MaterialApp(
      title: 'Advanced Crypto Tracker',
      theme: _isDarkMode! ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: HomeScreen(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode!),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({super.key, required this.onThemeToggle, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<List<CryptoCoin>> _cryptoListFuture;
  final CryptoService _cryptoService = CryptoService();
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _cryptoListFuture = _cryptoService.fetchCryptoPrices();
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  void _toggleFavorite(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
      prefs.setStringList('favorites', _favorites);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      CryptoListScreen(
        cryptoListFuture: _cryptoListFuture,
        onRefresh: () => setState(() => _cryptoListFuture = _cryptoService.fetchCryptoPrices()),
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      FavoritesScreen(
        cryptoListFuture: _cryptoListFuture,
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Tracker 📈'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Coins'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}