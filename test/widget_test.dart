import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:iprakriti/main.dart';

void main() {
  testWidgets('boots the app shell', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://smqiowljeufxablwyads.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtcWlvd2xqZXVmeGFibHd5YWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3MjAzNzgsImV4cCI6MjA5MjI5NjM3OH0.hHCHkDuHFLcXt0iwDgLEwGDGC8G2PbczNQUJvNiJ25M',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: IPrakritiApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(IPrakritiApp), findsOneWidget);
  });
}
