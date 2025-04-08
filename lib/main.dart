import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_insta_clone/bloc/post/post_bloc.dart';
import 'package:flutter_insta_clone/screen/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (context) => PostBloc()),
      ],
      child: MaterialApp(
        title: 'Simple Instagram Clone',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            primary: Colors.purple,
            surface: Colors.purple[50],
          ),
        ),
        home: const OnBoardingScreen(),
      ),
    );
  }
}
