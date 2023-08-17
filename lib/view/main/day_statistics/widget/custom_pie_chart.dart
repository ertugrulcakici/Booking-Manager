import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../day_statistics_view.dart';

class CustomPieChart extends StatelessWidget {
  final String title;
  final Map<String, num> data;
  late final List<ChartSampleData> chartData;
  late final double total;
  late final int theMostIndex;
  late final List<PieSeries<ChartSampleData, String>> pieSeries;
  CustomPieChart({super.key, required this.title, required this.data}) {
    chartData = data.entries
        .map((e) => ChartSampleData(
              x: e.key,
              y: e.value,
            ))
        .toList()
        .cast<ChartSampleData>();
    total = chartData.fold(
        0, (previousValue, element) => previousValue + element.y.toDouble());
    theMostIndex = chartData.indexWhere((element) =>
        element.y.toDouble() ==
        chartData
            .map((e) => e.y.toDouble())
            .reduce((value, element) => value > element ? value : element));

    pieSeries = <PieSeries<ChartSampleData, String>>[
      PieSeries<ChartSampleData, String>(
          explode: true,
          explodeIndex: theMostIndex,
          dataSource: chartData,
          xValueMapper: (ChartSampleData data, _) =>
              "${data.x}\n%${(data.y.toDouble() / total * 100).toStringAsFixed(2)}",
          yValueMapper: (ChartSampleData data, _) => data.y,
          dataLabelMapper: (ChartSampleData data, _) =>
              "${data.x}: ${data.y.toStringAsFixed(2)}",
          startAngle: 90,
          endAngle: 90,
          enableTooltip: true,
          strokeColor: Colors.black,
          strokeWidth: 0.5,
          explodeGesture: ActivationMode.singleTap,
          explodeOffset: '10%',
          dataLabelSettings: const DataLabelSettings(
              labelIntersectAction: LabelIntersectAction.shift,
              margin: EdgeInsets.zero,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.curve, length: '20%'),
              isVisible: true,
              overflowMode: OverflowMode.shift))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(text: title),
      series: pieSeries,
      legend: const Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
        textStyle: TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}
