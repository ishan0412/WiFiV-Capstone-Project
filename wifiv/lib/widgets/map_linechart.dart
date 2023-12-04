import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

const TextStyle axisLabelStyle =
    TextStyle(fontFamily: 'Satoshi', fontSize: 7, color: Colors.white);

class MapLineChart extends StatelessWidget {
  final List<FlSpot> data;

  const MapLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double minValue = 200;
    double maxValue = 0;
    for (FlSpot point in data) {
      if (point.y < minValue) {
        minValue = point.y;
      }
      if (point.y > maxValue) {
        maxValue = point.y;
      }
    }
    double minYlim = 5 * (minValue / 5).floorToDouble();
    double maxYlim = 5 * (maxValue / 5).ceilToDouble();
    return LineChart(LineChartData(
        minX: 0,
        maxX: 120,
        minY: minYlim,
        maxY: maxYlim,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
            border: const Border(
                bottom: BorderSide(color: Colors.white, width: 0.64),
                right: BorderSide(color: Colors.white, width: 0.64))),
        titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: ((value % 60) == 0)
                            ? Text(DateFormat.Hm().format(DateTime.now().subtract(Duration(seconds: 120 - value.toInt()))),
                                style: axisLabelStyle)
                            : const Text('')))),
            rightTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: ((value % ((maxYlim - minYlim) / 2)) == 0)
                            ? Text('${value.round()}', style: axisLabelStyle)
                            : const Text(''))))),
        lineBarsData: [
          LineChartBarData(
              color: Colors.white,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [1, 1],
              spots: data)
        ]));
  }
}
