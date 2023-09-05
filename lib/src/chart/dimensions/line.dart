import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/src/measure/chart_dimension_param.dart';

import '../../measure/chart_param.dart';
import '../../utils/chart_utils.dart';
import '../../base/chart_body_render.dart';
import '../../measure/chart_layout_param.dart';

typedef LinePosition<T> = List<num> Function(T);

/// @author JD
class Line<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///每个点对应的值 不要使用过于耗时的方法
  final LinePosition values;

  ///线颜色
  final List<Color> colors;

  ///优先级高于colors
  final List<Shader>? shaders;

  ///点的颜色
  final List<Color>? dotColors;

  ///点半径
  final double dotRadius;

  ///是否有空心圆
  final bool isHollow;

  ///线宽
  final double strokeWidth;

  ///填充颜色
  final bool? filled;

  ///曲线
  final bool isCurve;

  ///线 画笔
  final Paint paint;

  ///路径之间的处理规则
  final PathOperation? operation;

  Line({
    required super.data,
    required this.position,
    required this.values,
    super.yAxisPosition = 0,
    this.colors = colors10,
    this.shaders,
    this.dotColors,
    this.dotRadius = 2,
    this.strokeWidth = 1,
    this.isHollow = false,
    this.filled = false,
    this.isCurve = false,
    this.operation,
  }) : paint = Paint()
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

  final Paint _dotPaint = Paint();
  Paint? _fullPaint;
  @override
  void init(ChartParam param) {
    super.init(param);
    if (filled == true) {
      _fullPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill;
    }
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    param as ChartDimensionParam;
    List<ChartLayoutParam> shapeList = [];

    int index = 0;
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = param.contentMargin.left;
    left = param.transformUtils.withXOffset(left);

    double right = param.size.width - param.contentMargin.right;
    double top = param.contentMargin.top;
    double bottom = param.size.height - param.contentMargin.bottom;
    Map<int, LineInfo> pathMap = {};
    ChartLayoutParam? lastShape;
    num? lastXvs;
    //遍历数据 处理数据信息
    for (T value in data) {
      num xvs = position.call(value);
      if (lastXvs != null) {
        assert(lastXvs < xvs, '虽然支持逆序，但是为了防止数据顺序混乱，还是强制要求必须是正序的数组');
      }
      List<num> yvs = values.call(value);
      List<ChartLayoutParam> shapes = [];
      assert(colors.length >= yvs.length, '颜色配置跟数据源不匹配');
      assert(shaders == null || shaders!.length >= yvs.length, '颜色配置跟数据源不匹配');
      double xPo = xvs * param.xAxis.density + left;

      //先判断是否选中，此场景是第一次渲染之后点击才有，所以用老数据即可
      List<ChartLayoutParam> childrenLayoutParams = layoutParam.children;
      if (param.localPosition != null && index < childrenLayoutParams.length && (childrenLayoutParams[index].hitTest(param.localPosition!) == true)) {
        layoutParam.selectedIndex = index;
      }
      //一条数据下可能多条线
      for (int valueIndex = 0; valueIndex < yvs.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        LineInfo? lineInfo = pathMap[valueIndex];
        if (lineInfo == null) {
          lineInfo = LineInfo();
          pathMap[valueIndex] = lineInfo;
        }
        //计算点的位置
        num value = yvs[valueIndex];
        double yPo = bottom - param.yAxis[yAxisPosition].relativeHeight(value);
        yPo = param.transformUtils.withYOffset(yPo);
        if (index == 0) {
          lineInfo.path.moveTo(xPo, yPo);
        } else {
          if (isCurve) {
            ChartLayoutParam lastChild = lastShape!.children[valueIndex];
            double preX = lastChild.rect!.center.dx;
            double preY = lastChild.rect!.center.dy;
            double xDiff = xPo - preX;
            double centerX1 = preX + xDiff / 2;
            double centerY1 = preY;

            double centerX2 = xPo - xDiff / 2;
            double centerY2 = yPo;

            // chart.canvas.drawCircle(
            //     Offset(centerX1, centerY1), 2, Paint()..color = Colors.red);
            //
            // chart.canvas.drawCircle(
            //     Offset(centerX2, centerY2), 2, Paint()..color = Colors.blue);

            //绘制贝塞尔路径
            lineInfo.path.cubicTo(
              centerX1,
              centerY1, // control point 1
              centerX2,
              centerY2, //  control point 2
              xPo,
              yPo,
            );
          } else {
            lineInfo.path.lineTo(xPo, yPo);
          }
        }
        lineInfo.pointList.add(Offset(xPo, yPo));
        //存放点的位置
        ChartLayoutParam shape = ChartLayoutParam.rect(rect: Rect.fromCenter(center: Offset(xPo, yPo), width: dotRadius, height: dotRadius));
        shapes.add(shape);
      }

      Rect currentRect = Rect.fromLTRB(xPo, top, xPo + dotRadius * 2, bottom);
      ChartLayoutParam shape = ChartLayoutParam.rect(rect: currentRect);
      shape.left = left;
      shape.right = right;
      shape.children.addAll(shapes);
      //这里用链表解决查找附近节点的问题
      shape.preShapeState = lastShape;
      lastShape?.nextShapeState = shape;
      shapeList.add(shape);

      lastShape = shape;
      //放到最后
      index++;
      lastXvs = xvs;
    }

    //开启后可查看热区是否正确
    // int i = 0;
    // for (var element in shapeList) {
    //   Rect newRect = Rect.fromLTRB(element.getHotRect()!.left + 1, element.getHotRect()!.top + 1, element.getHotRect()!.right - 1, element.getHotRect()!.bottom);
    //   Paint newPaint = Paint()
    //     ..color = colors10[i % colors10.length]
    //     ..strokeWidth = strokeWidth
    //     ..style = PaintingStyle.stroke;
    //   canvas.drawRect(newRect, newPaint);
    //   i++;
    // }
    //开始绘制了
    drawLine(param, canvas, pathMap);
    layoutParam.children = shapeList;
  }

  void drawLine(ChartParam param, Canvas canvas, Map<int, LineInfo> pathMap) {
    //点
    _dotPaint.strokeWidth = strokeWidth;
    List<Color> dotColorList = dotColors ?? colors;
    Path? lastPath;
    pathMap.forEach((index, lineInfo) {
      //先画线
      if (shaders != null && filled == false) {
        canvas.drawPath(lineInfo.path, paint..shader = shaders![index]);
      } else {
        canvas.drawPath(lineInfo.path, paint..color = colors[index]);
      }
      //然后填充颜色
      if (filled == true) {
        Offset last = lineInfo.pointList.last;
        Offset first = lineInfo.pointList.first;
        lineInfo.path
          ..lineTo(last.dx, param.contentRect.bottom)
          ..lineTo(first.dx, param.contentRect.bottom);

        if (shaders != null) {
          _fullPaint?.shader = shaders![index];
        } else {
          _fullPaint?.color = colors[index];
        }
        Path newPath = lineInfo.path;
        if (operation != null) {
          if (lastPath != null) {
            newPath = Path.combine(operation!, newPath, lastPath!);
          }
          lastPath = lineInfo.path;
        }
        canvas.drawPath(newPath, _fullPaint!);
      }
      //最后画点
      if (dotRadius > 0) {
        for (Offset point in lineInfo.pointList) {
          //先用白色覆盖
          _dotPaint.style = PaintingStyle.fill;
          canvas.drawCircle(Offset(point.dx, point.dy), dotRadius, _dotPaint..color = Colors.white);
          //再画空心
          if (isHollow) {
            _dotPaint.style = PaintingStyle.stroke;
          } else {
            _dotPaint.style = PaintingStyle.fill;
          }
          canvas.drawCircle(Offset(point.dx, point.dy), dotRadius, _dotPaint..color = dotColorList[index]);
        }
      }
    });
  }
}

class LineInfo {
  final Path path = Path();
  final List<Offset> pointList = [];
  LineInfo();
}
