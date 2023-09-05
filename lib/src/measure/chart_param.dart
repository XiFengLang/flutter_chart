import 'package:flutter/widgets.dart';

import '../coordinate/chart_circular_coordinate_render.dart';
import '../coordinate/chart_coordinate_render.dart';
import '../coordinate/chart_dimensions_coordinate_render.dart';
import '../measure/chart_layout_param.dart';
import '../utils/transform_utils.dart';
import 'chart_circular_param.dart';
import 'chart_dimension_param.dart';

typedef AnnotationTooltipWidgetBuilder = PreferredSizeWidget? Function(BuildContext context);

abstract class ChartParam extends ChangeNotifier {
  ///点击的位置
  Offset? localPosition;

  ///缩放级别
  final double zoom;

  ///滚动偏移
  Offset offset;

  ///根据位置缓存配置信息
  List<ChartLayoutParam> childrenState = [];

  ///获取所在位置的布局信息
  ChartLayoutParam paramAt(index) => childrenState[index];

  ChartParam({
    this.localPosition,
    this.zoom = 1,
    this.offset = Offset.zero,
    required this.childrenState,
  });

  factory ChartParam.coordinate({
    Offset? localPosition,
    double zoom = 1,
    Offset offset = Offset.zero,
    required List<ChartLayoutParam> childrenState,
    required ChartCoordinateRender coordinate,
  }) {
    if (coordinate is ChartDimensionsCoordinateRender) {
      return ChartDimensionParam.coordinate(localPosition: localPosition, zoom: zoom, offset: offset, childrenState: childrenState, coordinate: coordinate);
    }
    return ChartCircularParam.coordinate(
      localPosition: localPosition,
      zoom: zoom,
      offset: offset,
      childrenState: childrenState,
      coordinate: coordinate as ChartCircularCoordinateRender,
    );
  }

  ///坐标转换工具
  late TransformUtils transformUtils;

  late Size size;
  late EdgeInsets margin;
  late EdgeInsets padding;

  ///图形内容的外边距信息
  late EdgeInsets contentMargin;

  ///未处理的坐标  原点在左上角
  Rect get contentRect => Rect.fromLTRB(contentMargin.left, contentMargin.top, size.width - contentMargin.left, size.height - contentMargin.bottom);

  void init({required Size size, required EdgeInsets margin, required EdgeInsets padding}) {
    this.size = size;
    this.margin = margin;
    this.padding = padding;
    contentMargin = EdgeInsets.fromLTRB(margin.left + padding.left, margin.top + padding.top, margin.right + padding.right, margin.bottom + padding.bottom);
  }

  void scroll(Offset offset);

  @override
  bool operator ==(Object other) {
    if (other is ChartParam) {
      return super == other && zoom == other.zoom;
    }
    return super == other;
  }
}
