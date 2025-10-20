// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:news_app/main.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/views/home_view.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  testWidgets('MyApp configures GetMaterialApp correctly', (tester) async {
    await tester.pumpWidget(const MyApp());

    final getMaterialApp =
        tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));

    expect(getMaterialApp.initialRoute, AppPages.initial);
    expect(getMaterialApp.getPages, isNotNull);
    expect(getMaterialApp.getPages, isNotEmpty);
    expect(getMaterialApp.initialBinding, isNotNull);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.byType(HomeView), findsOneWidget);
  });
}
