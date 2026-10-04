import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funpedia_admin/main.dart';

void main() {
  testWidgets('editor opens with sample article and block controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FunpediaAdminApp());
    await tester.pumpAndSettle();

    expect(find.text('Mesopotamia'), findsWidgets);
    expect(find.text('Subject'), findsOneWidget);
    expect(find.text('Topic'), findsOneWidget);
    expect(find.text('Add a block'), findsWidgets);
    expect(find.text('Image'), findsOneWidget);
  });
}
