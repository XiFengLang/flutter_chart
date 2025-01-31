
part of flutter_chart_plus;


class _ChartDimensionParam extends ChartParam {
  ///y坐标轴
  final List<YAxis> yAxis;

  ///x坐标轴
  final XAxis xAxis;

  _ChartDimensionParam.coordinate({
    super.outDraw,
    super.controlValue,
    required super.childrenState,
    required ChartDimensionsCoordinateRender coordinate,
  })  : yAxis = coordinate.yAxis,
        xAxis = coordinate.xAxis;

  @override
  void init({required Size size, required EdgeInsets margin, required EdgeInsets padding}) {
    super.init(size: size, margin: margin, padding: padding);
    //初始化配置
    double width = size.width;
    double height = size.height;
    int count = xAxis.count;
    //每格的宽度，用于控制一屏最多显示个数
    double density = (width - contentMargin.horizontal) / count / xAxis.interval;
    xAxis.fixedDensity = density;
    //x轴密度 即1 value 等于多少尺寸
    if (xAxis.zoom) {
      xAxis.density = density * zoom;
    } else {
      xAxis.density = density;
    }

    for (YAxis yA in yAxis) {
      num max = yA.max;
      num min = yA.min;
      int yCount = yA.count;
      //y轴密度  即1 value 等于多少尺寸
      double itemHeight = (height - margin.vertical) / yCount;
      double itemValue = (max - min) / yCount;
      double density = itemHeight / itemValue;
      yA.fixedDensity = density;
      if (yA.zoom) {
        yA.density = density * zoom;
      } else {
        yA.density = density;
      }
    }

    //转换工具
    transform = TransformUtils(
      anchor: Offset(margin.left, size.height - margin.bottom),
      offset: offset,
      size: size,
      padding: padding,
      reverseX: false,
      reverseY: true,
    );
  }

  @override
  void scroll(Offset offset) {
    //校准偏移，不然缩小后可能起点都在中间了，或者无限滚动
    double x = offset.dx;
    // double y = newOffset.dy;
    if (x < 0) {
      x = 0;
    }
    //放大的场景  offset会受到zoom的影响，所以这里的宽度要先剔除zoom的影响再比较
    double chartContentWidth = xAxis.density * xAxis.max;
    double chartViewPortWidth = size.width - contentMargin.horizontal;
    //处理成跟缩放无关的偏移
    double maxOffset = (chartContentWidth - chartViewPortWidth);
    if (maxOffset < 0) {
      //内容小于0
      x = 0;
    } else if (x > maxOffset) {
      x = maxOffset;
    }
    this.offset = Offset(x, 0);
  }
}
