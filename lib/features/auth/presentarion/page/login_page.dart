import 'package:bento_store/core/config/env_config.dart';
import 'package:bento_store/core/routes/app_router.dart';
import 'package:bento_store/core/theme/app_theme.dart';
import 'package:bento_store/features/auth/service/cubit/auth_cubit.dart';
import 'package:bento_store/features/auth/service/cubit/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    _usernameController.text = 'mor_2314';
    _passwordController.text = '83r5^_';
    context.read<AuthCubit>().checkAuthStatus();
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final useWideLayout = screenWidth > screenHeight || screenWidth > 800;

    return BlocListener<AuthCubit, AuthState>(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child:
                useWideLayout
                    ? ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: kIsWeb ? 900 : screenWidth * 0.9, minHeight: screenHeight * 0.7),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: _buildHeader(context, screenWidth)),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(flex: 4, child: _buildLoginForm(context, screenWidth)),
                    ],
                  ),
                )
                    : ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : screenWidth * 0.9, minHeight: screenHeight * 0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(context, screenWidth),
                      SizedBox(height: screenHeight * 0.04),
                      _buildLoginForm(context, screenWidth),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);

          if (state is AuthSuccess) {
            Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (route) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: kIsWeb ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
                margin: kIsWeb ? EdgeInsets.all(8) : null,
              ),
            );
          } else if (state is AuthSessionExpired) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Sua sessão expirou. Por favor, faça login novamente.'),
                backgroundColor: Colors.red,
                behavior: kIsWeb ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
                margin: kIsWeb ? EdgeInsets.all(8) : null,
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
          }
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context, double width) {
    final titleSize = _calculateResponsiveFontSize(width, 0.05, 30, 36);
    final subtitleSize = _calculateResponsiveFontSize(width, 0.02, 14, 18);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Image.asset(
              'assets/logo.png',
              width: width * 0.2,
              height: width * 0.2,
              errorBuilder:
                  (context, error, stackTrace) =>
              const SizedBox.shrink(),
            ),
          ),
        Text(
          EnvConfig.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Sistema de Vendas',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: subtitleSize, color: AppTheme.secondaryColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, double width) {
    final isSmallScreen = width < 600;
    final inputTextSize = _calculateResponsiveFontSize(width, isSmallScreen ? 0.03 : 0.015, 14, 18);
    final buttonTextSize = _calculateResponsiveFontSize(
      width,
      isSmallScreen ? 0.035 : 0.018,
      12,
      18,
    );

    return Container(
      padding: kIsWeb ? EdgeInsets.all(24) : EdgeInsets.zero,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Acesse sua conta',
                  style: TextStyle(fontSize: buttonTextSize, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            TextFormField(
              controller: _usernameController,
              enabled: !_isLoading,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              style: TextStyle(fontSize: inputTextSize),
              decoration: InputDecoration(
                hintText: 'Digite seu usuário',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: inputTextSize),
                prefixIcon: Icon(
                  Icons.person_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: inputTextSize * 1.5,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 12,
                  vertical: isSmallScreen ? 12 : 8,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu usuário';
                }
                return null;
              },
            ),
            SizedBox(height: isSmallScreen ? 16 : 12),
            TextFormField(
              controller: _passwordController,
              enabled: !_isLoading,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthCubit>().login(
                    _usernameController.text,
                    _passwordController.text,
                  );
                }
              },
              style: TextStyle(fontSize: inputTextSize),
              decoration: InputDecoration(
                hintText: 'Digite sua senha',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: inputTextSize),
                prefixIcon: Icon(
                  Icons.lock_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: inputTextSize * 1.5,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 12,
                  vertical: isSmallScreen ? 12 : 8,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite sua senha';
                }
                return null;
              },
            ),
            SizedBox(height: isSmallScreen ? 24 : 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed:
                _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthCubit>().login(
                      _usernameController.text,
                      _passwordController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 8),
                  ),
                ),
                child:
                _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text('Entrar', style: TextStyle(fontSize: buttonTextSize)),
              ),
            ),
            // if (kIsWeb)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 16),
            //     child: TextButton(
            //       onPressed: () {
            //         //TODO Implementar recuperação de senha
            //       },
            //       child: Text(
            //         'Esqueci minha senha',
            //         style: TextStyle(fontSize: inputTextSize * 0.9, color: AppTheme.primaryColor),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  double _calculateResponsiveFontSize(
      double screenWidth,
      double percentage,
      double minSize,
      double maxSize,
      ) {
    final size = screenWidth * percentage;
    return size.clamp(minSize, maxSize);
  }
}
