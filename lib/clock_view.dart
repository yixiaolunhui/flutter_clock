import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

///时钟
class ClockView extends StatefulWidget {
  const ClockView({
    Key key,
    this.radius = 150,
    this.borderColor = Colors.black,
    this.scaleColor = Colors.black,
    this.numberColor = Colors.black,
    this.moveBallColor = Colors.red,
    this.hourHandColor = Colors.black,
    this.minuteHandColor = Colors.black,
    this.secondHandColor = Colors.red,
    this.middleCircleColor = Colors.red,
  }) : super(key: key);

  //钟表的半径
  final double radius;

  //边框的颜色
  final Color borderColor;

  //刻度的颜色
  final Color scaleColor;

  //数字的颜色
  final Color numberColor;

  //走秒小球颜色
  final Color moveBallColor;

  //时针的颜色
  final Color hourHandColor;

  //分针的颜色
  final Color minuteHandColor;

  //秒针的颜色
  final Color secondHandColor;

  //中间圆颜色
  final Color middleCircleColor;

  @override
  State<StatefulWidget> createState() {
    return ClockViewState();
  }
}

class ClockViewState extends State<ClockView> {
  //当前时间
  DateTime dateTime;

  //定时器
  Timer timer;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        dateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    //取消定时器
    if (timer.isActive) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClockPainter(
        dateTime,
        radius: widget.radius,
        borderColor: this.widget.borderColor,
        scaleColor: this.widget.scaleColor,
        numberColor: this.widget.numberColor,
        moveBallColor: this.widget.moveBallColor,
        hourHandColor: this.widget.hourHandColor,
        minuteHandColor: this.widget.minuteHandColor,
        secondHandColor: this.widget.secondHandColor,
        middleCircleColor: this.widget.middleCircleColor,
      ),
      size: Size(widget.radius * 2, widget.radius * 2),
    );
  }
}

class ClockPainter extends CustomPainter {
  //边框的颜色
  final Color borderColor;

  //刻度的颜色
  final Color scaleColor;

  //数字的颜色
  final Color numberColor;

  //中间圆颜色
  final Color middleCircleColor;

  //走秒小球颜色
  final Color moveBallColor;

  //时针的颜色
  final Color hourHandColor;

  //分针的颜色
  final Color minuteHandColor;

  //秒针的颜色
  final Color secondHandColor;

  //边框画笔的宽度
  double borderWidth;

  //刻度画笔的宽度
  double scaleWidth;

  //数字画笔的宽度
  double numberWidth;

  //时针画笔的宽度
  double hourHandWidth;

  //分针画笔的宽度
  double minuteHandWidth;

  //秒针画笔的宽度
  double secondHandWidth;

  //中间圆的宽度
  double middleCircleWidth;

  //小刻度的位置集合
  List<Offset> scaleOffset = [];

  //大刻度的位置集合 每5个小刻度是一个大刻度
  List<Offset> bigScaleOffset = [];

  //钟表的半径
  final double radius;

  //当前时间
  final DateTime dateTime;

  //边框画笔
  Paint borderPaint;

  //刻度画笔
  Paint scalePaint;

  //大刻度画笔
  Paint biggerScalePaint;

  //数字画笔
  TextPainter textPainter;

  //时针画笔
  Paint hourPaint;

  //分针画笔
  Paint minutePaint;

  //秒针画笔
  Paint secondPaint;

  //中间圆画笔
  Paint centerPaint;

  //移动小球画笔
  Paint moveBallPaint;

  ClockPainter(
    this.dateTime, {
    this.radius,
    this.borderColor,
    this.scaleColor,
    this.numberColor,
    this.moveBallColor,
    this.hourHandColor,
    this.minuteHandColor,
    this.secondHandColor,
    this.middleCircleColor,
  }) {
    //根据自己的审美设置这些画笔的宽度
    borderWidth = 8 * (radius / 100);
    scaleWidth = 2 * (radius / 100);
    numberWidth = 20 * (radius / 100);
    hourHandWidth = 5 * (radius / 100);
    minuteHandWidth = 3 * (radius / 100);
    secondHandWidth = 1 * (radius / 100);
    middleCircleWidth = 4 * (radius / 100);

    //边框画笔
    borderPaint =
        createPaint(borderColor, borderWidth, style: PaintingStyle.stroke);
    //刻度画笔
    scalePaint = createPaint(numberColor, scaleWidth);
    //大刻度
    biggerScalePaint = createPaint(numberColor, scaleWidth * 2);
    //时针画笔
    hourPaint = createPaint(hourHandColor, hourHandWidth);
    //分针画笔
    minutePaint = createPaint(minuteHandColor, minuteHandWidth);
    //秒针画笔
    secondPaint = createPaint(secondHandColor, secondHandWidth);
    //中间圆
    centerPaint = createPaint(middleCircleColor, middleCircleWidth);
    //移动小球画笔
    moveBallPaint = createPaint(moveBallColor, scaleWidth * 2);
    //数字
    textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    //计算出 小刻度和大刻度
    final l = radius - borderWidth * 2;
    for (var i = 0; i < 60; i++) {
      Offset offset = pointOffset(radius, l, 360 / 60 * i);
      //小刻度
      scaleOffset.add(offset);
      //大刻度
      if (i % 5 == 0) {
        bigScaleOffset.add(offset);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    //绘制边框
    drawBorder(canvas);
    //绘制刻度
    drawScale(canvas);
    //绘制数字
    drawNumber(canvas);
    //绘制时针
    drawHour(canvas);
    //绘制分针
    drawMinute(canvas);
    //绘制秒针
    drawSecond(canvas);
    //绘制中间圆圈
    drawMiddleCircle(canvas);
    //绘制移动小球
    drawMoveBall(canvas);
  }

  //判断是否需要重绘
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  ///绘制边框
  void drawBorder(Canvas canvas) {
    canvas.drawCircle(
        Offset(radius, radius), radius - borderWidth / 2, borderPaint);
  }

  ///绘制刻度
  void drawScale(Canvas canvas) {
    //小刻度
    canvas.drawPoints(PointMode.points, scaleOffset, scalePaint);
    //大刻度
    canvas.drawPoints(PointMode.points, bigScaleOffset, biggerScalePaint);
  }

  ///绘制数字
  void drawNumber(Canvas canvas) {
    double l = radius - borderWidth * 4;
    for (var i = 0; i < bigScaleOffset.length; i++) {
      textPainter.text = TextSpan(
        text: "${i == 0 ? 12 : i}",
        style: TextStyle(color: numberColor, fontSize: numberWidth),
      );
      Offset offset = pointOffset(radius, l, i * 360 / 12);
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
            offset.dx - (textPainter.width / 2),
            offset.dy - (textPainter.height / 2),
          ));
    }
  }

  ///绘制时针
  void drawHour(Canvas canvas) {
    final hour = dateTime.hour;
    double angle = 360 / 12 * hour + dateTime.minute / 60 * 30;
    Offset hourHand1 = pointOffset(radius, radius * 0.1, angle + 180);
    Offset hourHand2 = pointOffset(radius, radius * 0.45, angle);
    canvas.drawLine(hourHand1, hourHand2, hourPaint);
  }

  ///绘制分针
  void drawMinute(Canvas canvas) {
    final minute = dateTime.minute;
    double angle = 360 / 60 * minute + dateTime.second / 60 * 6;
    Offset minuteHand1 = pointOffset(radius, radius * 0.1, angle + 180);
    Offset minuteHand2 = pointOffset(radius, radius * 0.7, angle);
    canvas.drawLine(minuteHand1, minuteHand2, minutePaint);
  }

  ///绘制秒针
  void drawSecond(Canvas canvas) {
    final second = dateTime.second;
    double angle = 360 / 60 * second;
    Offset secondHand1 = pointOffset(radius, radius * 0.1, angle + 180);
    Offset secondHand2 = pointOffset(radius, radius * 0.7, angle);
    canvas.drawLine(secondHand1, secondHand2, secondPaint);
  }

  ///绘制中间圆圈
  void drawMiddleCircle(Canvas canvas) {
    canvas.drawCircle(Offset(radius, radius), middleCircleWidth, centerPaint);
  }

  ///绘制移动小球
  void drawMoveBall(Canvas canvas) {
    final second = dateTime.second;
    canvas.drawCircle(scaleOffset[second], middleCircleWidth, moveBallPaint);
  }
}

///创建Paint
Paint createPaint(Color color, double strokeWidth,
    {PaintingStyle style = PaintingStyle.fill}) {
  return Paint()
    ..color = color
    ..isAntiAlias = true
    ..style = style
    ..strokeCap = StrokeCap.round
    ..strokeWidth = strokeWidth;
}

///圆中万能求点公式
Offset pointOffset(double radius, double l, double angle) {
  return Offset(
    radius + l * sin(degToRad(angle)),
    radius - l * cos(degToRad(angle)),
  );
}

///角度转换为弧度
num degToRad(num deg) => deg * (pi / 180.0);
