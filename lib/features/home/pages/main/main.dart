import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/app/routes.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/core/preferences/icons.dart';
import 'package:kasirsuper/features/home/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:kasirsuper/features/home/pages/home/page.dart';

// Define AmiiboListPage widget here or import if already defined in another file
class AmiiboListPage extends StatefulWidget {
  const AmiiboListPage({super.key});

  @override
  State<AmiiboListPage> createState() => _AmiiboListPageState();
}

class _AmiiboListPageState extends State<AmiiboListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amiibo List'),
      ),
      body: Center(
        child: Text('Amiibo List Page Content'),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  final List<String> favorites;
  final List<String> products;

  const FavoritePage({Key? key, required this.favorites, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Page'),
      ),
      body: Center(
        child: Text('Favorite Page Content'),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static const String routeName = '/main';

  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[
      AmiiboListPage(),  // Ensure this is defined or imported properly
      FavoritePage(favorites: [], products: []),  // Pass the required parameters here
    ];

    return BlocBuilder<BottomNavBloc, int>(
      builder: (context, index) {
        return Scaffold(
          body: pages[index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) {
              context.read<BottomNavBloc>().add(TapBottomNavEvent(value));
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(AppIcons.storefront),
                label: "Beranda",
              ),
              BottomNavigationBarItem(
                icon: Icon(AppIcons.receipt),
                label: "Favorite",
              ),
            ],
          ),
        );
      },
    );
  }
}
