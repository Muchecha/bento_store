import 'package:bento_store/core/config/env_config.dart';
import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/features/admin/service/cubit/admin_sale_cubit.dart';
import 'package:bento_store/features/auth/service/cubit/auth_cubit.dart';
import 'package:bento_store/features/product/service/cubit/product_cubit.dart';
import 'package:bento_store/features/sale/service/cubit/sale_cubit.dart';
import 'package:bento_store/features/seller/service/cubit/seller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart' as di;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('mouse_tracker.dart') ||
        details.library?.contains('mouse_tracker.dart') == true) {
      return;
    }
    FlutterError.presentError(details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.getIt<AuthCubit>()),
        BlocProvider(create: (context) => di.getIt<SellerCubit>()),
        BlocProvider(create: (context) => di.getIt<ProductCubit>()),
        BlocProvider(create: (context) => di.getIt<SaleCubit>()),
        BlocProvider(create: (context) => di.getIt<AdminSaleCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: EnvConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: AppRouter.login,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
