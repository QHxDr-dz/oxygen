import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxygenclub/presentation/dashboard_screen/widgets/heart_rate_chart_widget.dart';

Widget _buildChart(List<double> data) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          height: 400,
          child: HeartRateChartWidget(heartRateData: data),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders an empty state instead of throwing for no data', (
    tester,
  ) async {
    await tester.pumpWidget(_buildChart(const []));
    await tester.pumpAndSettle();

    expect(find.text('No heart-rate data yet'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders peak and average when data is available', (
    tester,
  ) async {
    await tester.pumpWidget(_buildChart(const [80, 120, 160]));
    await tester.pumpAndSettle();

    expect(find.text('160 BPM'), findsOneWidget);
    expect(find.text('120 BPM'), findsOneWidget);
    expect(find.text('No heart-rate data yet'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
