import 'dart:convert';
import 'package:flutter/material.dart';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  Stroke({required this.points, required this.color, required this.width});

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        'color': color.toARGB32(),
        'width': width,
      };

  factory Stroke.fromJson(Map<String, dynamic> json) => Stroke(
        points: (json['points'] as List)
            .map((p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()))
            .toList(),
        color: Color(json['color'] as int),
        width: (json['width'] as num).toDouble(),
      );
}

String strokesToJson(List<Stroke> strokes) {
  if (strokes.isEmpty) return '';
  return jsonEncode(strokes.map((s) => s.toJson()).toList());
}

List<Stroke> strokesFromJson(String json) {
  if (json.isEmpty) return [];
  final list = jsonDecode(json) as List;
  return list.map((s) => Stroke.fromJson(s as Map<String, dynamic>)).toList();
}

class DrawingOverlay extends StatefulWidget {
  final List<Stroke> strokes;
  final bool isActive;
  final Color penColor;
  final double penWidth;
  final bool isEraser;
  final ValueChanged<List<Stroke>> onStrokesChanged;

  const DrawingOverlay({
    super.key,
    required this.strokes,
    required this.isActive,
    required this.penColor,
    required this.penWidth,
    required this.isEraser,
    required this.onStrokesChanged,
  });

  @override
  State<DrawingOverlay> createState() => DrawingOverlayState();
}

class DrawingOverlayState extends State<DrawingOverlay> {
  Stroke? _currentStroke;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: widget.isActive
          ? (details) {
              setState(() {
                _currentStroke = Stroke(
                  points: [details.localPosition],
                  color: widget.isEraser ? const Color(0x00000000) : widget.penColor,
                  width: widget.isEraser ? widget.penWidth * 3 : widget.penWidth,
                );
              });
            }
          : null,
      onPanUpdate: widget.isActive
          ? (details) {
              if (_currentStroke == null) return;
              setState(() {
                _currentStroke!.points.add(details.localPosition);
              });
            }
          : null,
      onPanEnd: widget.isActive
          ? (_) {
              if (_currentStroke == null) return;
              final newStrokes = [...widget.strokes, _currentStroke!];
              setState(() => _currentStroke = null);
              widget.onStrokesChanged(newStrokes);
            }
          : null,
      child: CustomPaint(
        painter: _OverlayPainter(
          strokes: widget.strokes,
          currentStroke: _currentStroke,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  _OverlayPainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, ?currentStroke]) {
      if (stroke.points.length < 2) continue;

      final isEraserStroke = stroke.color == const Color(0x00000000);

      final paint = Paint()
        ..color = isEraserStroke ? Colors.white : stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => true;
}
