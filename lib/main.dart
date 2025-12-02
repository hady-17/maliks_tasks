import 'package:flutter/material.dart';
import 'package:maliks_tasks/view/screens/home.dart';
import 'package:maliks_tasks/view/screens/welcome_screen.dart';
import 'package:maliks_tasks/view/auth/sign_in.dart';
import 'package:maliks_tasks/view/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['project_url']!,
    anonKey: dotenv.env['anon_api_key']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maliks Tasks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const RootPage(),
        '/home': (context) => const HomePage(),
        '/sign_in': (context) => const SignInPage(),
        '/login': (context) => const LoginPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // No signed-in user; show welcome screen
      if (mounted) setState(() => _loading = false);
      return;
    }

    // Check remember-me flag in local storage. If not remembered, sign out and show welcome.
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      final rememberUserId = prefs.getString('remember_user_id');

      if (!remember) {
        await Supabase.instance.client.auth.signOut();
        if (mounted) setState(() => _loading = false);
        return;
      }

      if (rememberUserId != null && rememberUserId != user.id) {
        // Different user previously remembered — sign out
        await Supabase.instance.client.auth.signOut();
        if (mounted) setState(() => _loading = false);
        return;
      }
    } catch (_) {
      // If prefs fail, continue and attempt to use session as-is
    }

    // Fetch profile from `profiles` table. If not available, fall back to minimal info.
    try {
      final resp = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      Map<String, dynamic> profile;
      if (resp != null) {
        profile = Map<String, dynamic>.from(resp);
      } else {
        profile = {'id': user.id, 'email': user.email};
      }

      if (!mounted) return;

      // Navigate to /home with profile as arguments
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home', arguments: profile);
      });
    } catch (e) {
      if (!mounted) return;
      final profile = {'id': user.id, 'email': user.email};
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home', arguments: profile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const WelcomeScreen();
  }
}
