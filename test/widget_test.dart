// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:irondex/widgets/common/cards/machine_card.dart';

void main() {
  testWidgets('MachineCard renders core information', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MachineCard(
            name: '레그프레스',
            imageUrl: 'https://example.com/image.png',
            brandName: '테스트 브랜드',
            brandLogoUrl: 'https://example.com/logo.png',
            score: 4.5,
            reviewCnt: 12,
            isFavorite: true,
          ),
        ),
      ),
    );

    expect(find.text('레그프레스'), findsOneWidget);
    expect(find.text('테스트 브랜드'), findsOneWidget);
    expect(find.text('(12)'), findsOneWidget);
  });
}
