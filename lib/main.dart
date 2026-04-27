import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/layout/admin_shell.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const GymAdminApp());
}

class GymAdminApp extends StatelessWidget {
  const GymAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create singletons at root so they persist across routes
    final authCubit  = sl<AuthCubit>()..checkAuth();
    final themeCubit = sl<ThemeCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider.value(value: themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'FalconGym Admin',
            debugShowCheckedModeBanner: false,
            theme:      AppTheme.lightTheme,
            darkTheme:  AppTheme.darkTheme,
            themeMode:  themeMode,
            routerConfig: createRouter(authCubit),
            builder: (context, child) {
              // Enforce minimum width for web layout
              return LayoutBuilder(
                builder: (context, constraints) {
                  return child ?? const SizedBox.shrink();
                },
              );
            },
          );
        },
      ),
    );
  }
}
