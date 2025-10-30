import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/core/di/injection.dart' as di;
import 'package:todoapp/presentation/pages/home_page.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Bắt đầu khởi tạo Dependency Injection...');
  await di.init();
  print('Dependency Injection hoàn tất!');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp.build() đã chạy!');
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (_) => di.sl<TaskBloc>()..add(LoadTaskEvent()),
        ),
      ],
      child: MaterialApp(
        title: "Todo List App",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
