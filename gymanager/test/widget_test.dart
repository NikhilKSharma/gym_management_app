import 'package:flutter_test/flutter_test.dart';
import 'package:gymanager/main.dart';
import 'package:gymanager/src/config/app_router.dart';

void main() {
  testWidgets('App starts and shows Login page', (WidgetTester tester) async {
    // 1. Create a router instance for the test.
    final router = AppRouter.createRouter(initialLocation: '/login');

    // 2. Build our app, providing the required router.
    await tester.pumpWidget(MyApp(router: router));

    // 3. Verify that the login page is visible.
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
