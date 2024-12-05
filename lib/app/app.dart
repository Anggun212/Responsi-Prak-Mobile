import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/app/routes.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/core/preferences/colors.dart';
import 'package:kasirsuper/core/preferences/theme/light_theme.dart';
import 'package:kasirsuper/features/home/blocs/blocs.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  get routes => null;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavBloc()),
      ],
      child: MaterialApp(
        title: 'Nitendo Amiibo List',
        debugShowCheckedModeBanner: false,
        theme: LightTheme(AppColors.green).theme,
        onGenerateRoute: routes,
      ),
    );
  }
}
