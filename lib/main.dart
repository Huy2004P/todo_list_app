import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/application/bloc/list_bloc.dart';
import 'package:todoapp/application/bloc/list_event.dart';
import 'package:todoapp/application/bloc/theme_bloc.dart';
import 'package:todoapp/application/bloc/theme_event.dart';
import 'package:todoapp/application/bloc/theme_state.dart';
import 'package:todoapp/core/di/injection.dart' as di;
import 'package:todoapp/core/services/notification_service.dart';
import 'package:todoapp/presentation/pages/splash_page.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Bắt đầu khởi tạo Dependency Injection...');
  await di.init();
  print('Dependency Injection hoàn tất!');

  print('Khởi tạo dịch vụ thông báo...');
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  print('Dịch vụ thông báo hoàn tất!');

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
        BlocProvider<ThemeBloc>(
          create: (_) => di.sl<ThemeBloc>()..add(LoadThemeEvent()),
        ),
        BlocProvider<ListBloc>(
          create: (_) => di.sl<ListBloc>()..add(LoadListsEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: "Todo List App",
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}

