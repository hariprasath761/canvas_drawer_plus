import 'package:canvas_drawer_plus/core/theme/app_color.dart';
import 'package:canvas_drawer_plus/feature/drawing_room/model/drawing_point.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DrawingRoomScreen extends StatefulWidget {
  const DrawingRoomScreen({super.key});

  @override
  State<DrawingRoomScreen> createState() => _DrawingRoomScreenState();
}

class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
  var avaiableColor = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;
  var selectedTool = DrawingTool.pen;

  DrawingPoint? currentDrawingPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Canvas
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                currentDrawingPoint = DrawingPoint.create(
                  offsets: [details.localPosition],
                  color: selectedColor,
                  width: selectedWidth,
                  tool: selectedTool,
                );

                if (currentDrawingPoint == null) return;
                drawingPoints.add(currentDrawingPoint!);
                historyDrawingPoints = List.of(drawingPoints);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                if (currentDrawingPoint == null) return;

                if (currentDrawingPoint!.isShape) {
                  // For shapes, we only need start and end points
                  currentDrawingPoint = currentDrawingPoint?.copyWith(
                    offsets: [
                      currentDrawingPoint!.offsets.first,
                      details.localPosition,
                    ],
                  );
                } else {
                  // For pen and eraser, add all points
                  currentDrawingPoint = currentDrawingPoint?.copyWith(
                    offsets:
                        currentDrawingPoint!.offsets
                          ..add(details.localPosition),
                  );
                }
                drawingPoints.last = currentDrawingPoint!;
                historyDrawingPoints = List.of(drawingPoints);
              });
            },
            onPanEnd: (_) {
              currentDrawingPoint = null;
            },
            child: CustomPaint(
              painter: DrawingPainter(drawingPoints: drawingPoints),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),

          /// color pallet
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: avaiableColor.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = avaiableColor[index];
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: avaiableColor[index],
                        shape: BoxShape.circle,
                      ),
                      foregroundDecoration: BoxDecoration(
                        border:
                            selectedColor == avaiableColor[index]
                                ? Border.all(
                                  color: AppColor.primaryColor,
                                  width: 4,
                                )
                                : null,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// Tool selection
          Positioned(
            top: MediaQuery.of(context).padding.top + 90,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildToolButton(DrawingTool.pen, Icons.edit, "Pen"),
                  const SizedBox(width: 8),
                  _buildToolButton(
                    DrawingTool.eraser,
                    Icons.cleaning_services,
                    "Eraser",
                  ),
                  const SizedBox(width: 8),
                  _buildToolButton(
                    DrawingTool.circle,
                    Icons.circle_outlined,
                    "Circle",
                  ),
                  const SizedBox(width: 8),
                  _buildToolButton(
                    DrawingTool.rectangle,
                    Icons.rectangle_outlined,
                    "Rectangle",
                  ),
                  const SizedBox(width: 8),
                  _buildToolButton(
                    DrawingTool.square,
                    Icons.crop_square,
                    "Square",
                  ),
                ],
              ),
            ),
          ),

          /// pencil size
          Positioned(
            top: MediaQuery.of(context).padding.top + 320,
            left: 0,
            bottom: 150,
            child: RotatedBox(
              quarterTurns: 3, // 270 degree
              child: Slider(
                value: selectedWidth,
                min: 1,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    selectedWidth = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Undo",
            onPressed: () {
              if (drawingPoints.isNotEmpty && historyDrawingPoints.isNotEmpty) {
                setState(() {
                  drawingPoints.removeLast();
                });
              }
            },
            child: const Icon(Icons.undo),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "Redo",
            onPressed: () {
              setState(() {
                if (drawingPoints.length < historyDrawingPoints.length) {
                  // 6 length 7
                  final index = drawingPoints.length;
                  drawingPoints.add(historyDrawingPoints[index]);
                }
              });
            },
            child: const Icon(Icons.redo),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon, String label) {
    bool isSelected = selectedTool == tool;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTool = tool;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColor.primaryColor.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColor.primaryColor : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColor.primaryColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    // Save the canvas state
    canvas.save();

    // Draw white background first
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Create a layer for proper blend mode support
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (var drawingPoint in drawingPoints) {
      final paint =
          Paint()
            ..color = drawingPoint.color
            ..isAntiAlias = true
            ..strokeWidth = drawingPoint.width
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

      // For eraser, use blend mode clear
      if (drawingPoint.tool == DrawingTool.eraser) {
        paint.blendMode = BlendMode.clear;
        // Make sure the color is opaque for clear blend mode to work
        paint.color = Colors.black.withOpacity(1.0);
      }

      switch (drawingPoint.tool) {
        case DrawingTool.pen:
        case DrawingTool.eraser:
          _drawFreehand(canvas, drawingPoint, paint);
          break;
        case DrawingTool.circle:
          _drawCircle(canvas, drawingPoint, paint);
          break;
        case DrawingTool.rectangle:
          _drawRectangle(canvas, drawingPoint, paint);
          break;
        case DrawingTool.square:
          _drawSquare(canvas, drawingPoint, paint);
          break;
      }
    }

    // Restore the layer
    canvas.restore();
    canvas.restore();
  }

  void _drawFreehand(Canvas canvas, DrawingPoint drawingPoint, Paint paint) {
    if (drawingPoint.offsets.isEmpty) return;
    if (drawingPoint.tool == DrawingTool.eraser) {
      for (var offset in drawingPoint.offsets) {
        canvas.drawCircle(
          offset,
          drawingPoint.width / 2,
          paint..style = PaintingStyle.fill,
        );
      }
      paint.style = PaintingStyle.stroke;
    }
    for (var i = 0; i < drawingPoint.offsets.length - 1; i++) {
      final current = drawingPoint.offsets[i];
      final next = drawingPoint.offsets[i + 1];
      canvas.drawLine(current, next, paint);
    }
  }

  void _drawCircle(Canvas canvas, DrawingPoint drawingPoint, Paint paint) {
    if (drawingPoint.offsets.length < 2) return;

    final start = drawingPoint.offsets.first;
    final end = drawingPoint.offsets.last;
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final radius = (end - start).distance / 2;

    canvas.drawCircle(center, radius, paint);
  }

  void _drawRectangle(Canvas canvas, DrawingPoint drawingPoint, Paint paint) {
    if (drawingPoint.offsets.length < 2) return;

    final rect = drawingPoint.boundingRect;
    canvas.drawRect(rect, paint);
  }

  void _drawSquare(Canvas canvas, DrawingPoint drawingPoint, Paint paint) {
    if (drawingPoint.offsets.length < 2) return;

    final start = drawingPoint.offsets.first;
    final end = drawingPoint.offsets.last;
    final side = (end.dx - start.dx).abs().clamp(
      0.0,
      (end.dy - start.dy).abs(),
    );

    final rect = Rect.fromLTWH(
      start.dx,
      start.dy,
      end.dx > start.dx ? side : -side,
      end.dy > start.dy ? side : -side,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
