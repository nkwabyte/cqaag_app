import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Holds the strokes drawn on a [SignaturePad].
class SignatureController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  Size _canvasSize = Size.zero;

  List<List<Offset>> get strokes => _strokes;

  /// Whether anything worth calling a signature has been drawn.
  bool get hasInk => _strokes.any((s) => s.length > 1);

  void _start(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void _extend(Offset point) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(point);
    notifyListeners();
  }

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  /// Renders the signature as a PNG, black ink on white, scaled to fit
  /// [width] x [height]. Kept small so the signed PDF stays well under the
  /// agreements database's size limit.
  Future<Uint8List?> toPng({int width = 600, int height = 200}) async {
    if (!hasInk || _canvasSize.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), Paint()..color = Colors.white);

    final scale = (width / _canvasSize.width).clamp(0.0, height / _canvasSize.height);
    canvas.scale(scale);
    _paintStrokes(canvas, _strokes, strokeWidth: 3);

    final image = await recorder.endRecording().toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }
}

void _paintStrokes(Canvas canvas, List<List<Offset>> strokes, {required double strokeWidth}) {
  final paint = Paint()
    ..color = Colors.black
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  for (final stroke in strokes) {
    if (stroke.length == 1) {
      canvas.drawCircle(stroke.first, strokeWidth / 2, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
      continue;
    }
    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (final point in stroke.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }
}

/// A box the applicant signs in with a finger.
class SignaturePad extends StatelessWidget {
  const SignaturePad({super.key, required this.controller, this.height});

  final SignatureController controller;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height ?? 160.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            controller._canvasSize = constraints.biggest;
            return GestureDetector(
              // Claim vertical drags too, so signing does not scroll the page.
              onVerticalDragStart: (d) => controller._start(d.localPosition),
              onVerticalDragUpdate: (d) => controller._extend(d.localPosition),
              onHorizontalDragStart: (d) => controller._start(d.localPosition),
              onHorizontalDragUpdate: (d) => controller._extend(d.localPosition),
              onTapDown: (d) => controller._start(d.localPosition),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => CustomPaint(
                  size: constraints.biggest,
                  painter: _SignaturePainter(controller.strokes),
                  child: controller.hasInk
                      ? null
                      : Center(
                          child: Text(
                            'Sign here',
                            style: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.6), fontSize: 14.sp),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) => _paintStrokes(canvas, strokes, strokeWidth: 2.5);

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
