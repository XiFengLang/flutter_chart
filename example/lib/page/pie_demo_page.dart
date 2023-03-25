import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/flutter_chart.dart';

/// @author JD
class PieChartDemoPage extends StatelessWidget {
  PieChartDemoPage({Key? key}) : super(key: key);

  final DateTime startTime = DateTime(2023, 1, 1);

  @override
  Widget build(BuildContext context) {
    final List<Map> dataList = [
      {
        'time': startTime.add(const Duration(days: 1)),
        'value1': 100,
        'value2': 200,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 3)),
        'value1': 200,
        'value2': 400,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 5)),
        'value1': 400,
        'value2': 200,
        'value3': 100,
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 100,
        'value2': 300,
        'value3': 200,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Pie'),
            SizedBox(
              height: 200,
              child: ChartWidget(
                builder: (controller) => PieChartCoordinateRender(
                  data: dataList,
                  margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 10),
                  position: (item) => (double.parse(item['value1'].toString())),
                  legendWidth: 20,
                  chartRender: Pie(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    legendFormatter: (item) {
                      return (item['time'] as DateTime).toStringWithFormat(format: 'MM-dd');
                    },
                    valueFormatter: (item) => item['value1'].toString(),
                  ),
                ),
              ),
            ),
            const Text('Hole Pie'),
            SizedBox(
              height: 200,
              child: ChartWidget(
                builder: (controller) => PieChartCoordinateRender(
                  data: dataList,
                  margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 10),
                  position: (item) => (double.parse(item['value1'].toString())),
                  chartRender: Pie(
                    holeRadius: 40,
                    valueTextOffset: 20,
                    centerTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    valueFormatter: (item) => item['value1'].toString(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
