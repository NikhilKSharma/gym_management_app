import 'package:gymanager/src/pages/add_member_page.dart';
import 'package:gymanager/src/pages/add_trainer_page.dart';
import 'package:gymanager/src/pages/analytics_page.dart';
import 'package:gymanager/src/pages/home_page.dart';
import 'package:gymanager/src/pages/login_page.dart';
import 'package:gymanager/src/pages/profile_page.dart';
import 'package:gymanager/src/pages/signup_page.dart';
import 'package:gymanager/src/pages/trainer_details_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter createRouter({required String initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/add-trainer',
          builder: (context, state) => const AddTrainerPage(),
        ),
        GoRoute(
          path: '/add-member',
          builder: (context, state) => const AddMemberPage(),
        ),
        GoRoute(
          path: '/trainer/:trainerId',
          builder: (context, state) {
            final trainerId = state.pathParameters['trainerId']!;
            final trainerName = state.extra as String;
            return TrainerDetailsPage(
                trainerId: trainerId, trainerName: trainerName);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsPage(),
        ),
        // The route for '/active-members' has been removed.
      ],
    );
  }
}
