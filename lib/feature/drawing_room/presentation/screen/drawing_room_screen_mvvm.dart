import 'package:canvas_drawer_plus/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/route/app_route_name.dart';
import '../../model/drawing_point.dart';
import '../components/drawing_room_settings_dialog.dart';
import '../components/network_status_indicator.dart';
import '../viewmodel/drawing_canvas_viewmodel.dart';
import '../viewmodel/drawing_room_viewmodel.dart';

class DrawingRoomScreenMVVM extends StatefulWidget {
  final String? roomId;
  const DrawingRoomScreenMVVM({super.key, this.roomId});

  @override
  State<DrawingRoomScreenMVVM> createState() => _DrawingRoomScreenMVVMState();
}

class _DrawingRoomScreenMVVMState extends State<DrawingRoomScreenMVVM> {
  late DrawingCanvasViewModel _canvasViewModel;

  @override
  void initState() {
    logger.i(
      "DrawingRoomScreenMVVM initState called, roomId: ${widget.roomId}",
    );
    super.initState();
    if (widget.roomId != null) {
      _initializeCanvas();
    }
  }

  void _initializeCanvas() {
    final roomViewModel = context.read<DrawingRoomViewModel>();
    _canvasViewModel = DrawingCanvasViewModel(
      repository: roomViewModel.repository,
      roomId: widget.roomId!,
    );
  }

  @override
  void dispose() {
    _canvasViewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.roomId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Drawing Room'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('No room ID provided')),
      );
    }

    return ChangeNotifierProvider<DrawingCanvasViewModel>.value(
      value: _canvasViewModel,
      child: Consumer<DrawingCanvasViewModel>(
        builder: (context, canvasViewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text('Room: ${widget.roomId}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              DrawingRoomSettingsDialog(roomId: widget.roomId!),
                    );
                  },
                ),
                IconButton(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        AppRouteName.userProfile,
                      ),
                  icon: const Icon(Icons.person, color: Colors.black87),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Show error overlay if there's an error
                if (canvasViewModel.hasError)
                  Container(
                    color: Colors.red.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            canvasViewModel.errorMessage ?? 'An error occurred',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: canvasViewModel.clearError,
                            child: const Text('Dismiss'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Drawing Canvas
                _buildDrawingCanvas(canvasViewModel),

                // Color Palette
                _buildColorPalette(canvasViewModel),

                // Tool Selection
                _buildToolSelection(canvasViewModel),

                // Width Slider
                _buildWidthSlider(canvasViewModel),

                if (canvasViewModel.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            floatingActionButton: _buildFloatingActionButtons(canvasViewModel),
          );
        },
      ),
    );
  }

  Widget _buildDrawingCanvas(DrawingCanvasViewModel viewModel) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        viewModel.startDrawing(details.localPosition);
      },
      onPanUpdate: (details) {
        viewModel.updateDrawing(details.localPosition);
      },
      onPanEnd: (_) {
        viewModel.endDrawing();
      },
      child: CustomPaint(
        painter: DrawingPainter(drawingPoints: viewModel.drawingPoints),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  Widget _buildColorPalette(DrawingCanvasViewModel viewModel) {
    return Positioned(
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.availableColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final color = viewModel.availableColors[index];
                  final isSelected = viewModel.selectedColor == color;

                  return GestureDetector(
                    onTap: () => viewModel.selectColor(color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      foregroundDecoration: BoxDecoration(
                        border:
                            isSelected
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
          const SizedBox(width: 8),
          const NetworkStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildToolSelection(DrawingCanvasViewModel viewModel) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 40,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildToolButton(viewModel, DrawingTool.pen, Icons.edit, "Pen"),
            const SizedBox(width: 8),
            _buildToolButton(
              viewModel,
              DrawingTool.eraser,
              Icons.cleaning_services,
              "Eraser",
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              viewModel,
              DrawingTool.circle,
              Icons.circle_outlined,
              "Circle",
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              viewModel,
              DrawingTool.rectangle,
              Icons.rectangle_outlined,
              "Rectangle",
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              viewModel,
              DrawingTool.square,
              Icons.crop_square,
              "Square",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    DrawingCanvasViewModel viewModel,
    DrawingTool tool,
    IconData icon,
    String label,
  ) {
    final isSelected = viewModel.selectedTool == tool;

    return GestureDetector(
      onTap: () => viewModel.selectTool(tool),
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

  Widget _buildWidthSlider(DrawingCanvasViewModel viewModel) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 320,
      left: 0,
      bottom: 150,
      child: RotatedBox(
        quarterTurns: 3, // 270 degrees
        child: Slider(
          value: viewModel.selectedWidth,
          min: 1,
          max: 20,
          onChanged: viewModel.updateWidth,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(DrawingCanvasViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "Undo",
          onPressed: viewModel.canUndo ? viewModel.undoLastDrawing : null,
          backgroundColor: viewModel.canUndo ? null : Colors.grey,
          child: const Icon(Icons.undo),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: "Redo",
          onPressed: viewModel.canRedo ? viewModel.redoLastDrawing : null,
          backgroundColor: viewModel.canRedo ? null : Colors.grey,
          child: const Icon(Icons.redo),
        ),
      ],
    );
  }
}

// Keep the same DrawingPainter class as it's already well-structured
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
