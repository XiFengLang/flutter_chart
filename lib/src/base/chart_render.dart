import 'chart_coordinate_render.dart';

/// @author jd

abstract class ChartRender<T> {
  ChartRender();
  //坐标系
  late ChartCoordinateRender<T> coordinateChart;

  //初始化
  void init(ChartCoordinateRender<T> coordinateChart) {
    this.coordinateChart = coordinateChart;
  }

  double withXOffset(double offset, [bool scrollable = true]) {
    return coordinateChart.withXOffset(offset, scrollable);
  }

  double withXZoom(double offset) {
    return coordinateChart.withXZoom(offset);
  }

  double withYOffset(double offset, [bool scrollable = true]) {
    return coordinateChart.withYOffset(offset, scrollable);
  }

  void draw();
}
