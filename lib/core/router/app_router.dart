import 'package:go_router/go_router.dart';
import '../../entities/movie.dart';
import '../../screens/details_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/movie_form_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) {
        final movie = state.extra as Movie;
        return DetailsScreen(initialMovie: movie);
      },
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const MovieFormScreen(),
    ),
  ],
);
