import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SafeHer start screen loads', (tester) async {
    await tester.pumpWidget(SafeHerApp());

    expect(find.text('SafeHer'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Signup'), findsOneWidget);
  });

  testWidgets('Chatbot clarifies vague fear without triggering an alert', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ChatBotPage()));

    await tester.enterText(find.byType(TextField), 'I feel unsafe');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(find.text('I feel unsafe'), findsWidgets);
    expect(find.textContaining('Are you in immediate danger right now?'), findsOneWidget);
    expect(find.textContaining('Move to a safer public place'), findsNothing);
    expect(find.textContaining('Nearest police station: local'), findsNothing);
  });

  testWidgets('Chatbot gives urgent guidance for an explicit immediate threat', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ChatBotPage()));

    await tester.enterText(find.byType(TextField), 'Someone is following me right now');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(find.textContaining('call 112 in India'), findsOneWidget);
  });

  testWidgets('Login screen suggests the previously used email', (tester) async {
    SharedPreferences.setMockInitialValues({'last_login_email': 'demo@example.com'});
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    expect(find.text('demo@example.com'), findsOneWidget);
  });

  testWidgets('Map screen shows destination input and safe route button', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MapPage()));

    expect(find.text('Departure'), findsNothing);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Suggest Safe Route'), findsOneWidget);
  });
}
