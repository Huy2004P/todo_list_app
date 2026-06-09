import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/application/bloc/task_state.dart';
import 'package:todoapp/domain/entities/todo_entity.dart';
import 'package:todoapp/core/services/notification_service.dart';
import 'package:todoapp/core/localization/app_translation.dart';
import 'package:todoapp/application/bloc/language_bloc.dart';
import 'package:todoapp/application/bloc/language_state.dart';
import 'package:todoapp/presentation/widgets/apple_dropdown.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with TickerProviderStateMixin {
  TodoEntity? _selectedTodo;
  int _selectedDurationMinutes = 25; // Default Pomodoro
  int _secondsRemaining = 25 * 60;
  int _totalSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  // Custom durations options (in minutes)
  final List<int> _durations = [5, 10, 15, 25];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_selectedTodo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_select_task'.tr),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _onFocusCompleted();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _selectedDurationMinutes * 60;
      _totalSeconds = _selectedDurationMinutes * 60;
    });
  }

  void _onDurationSelected(int minutes) {
    if (_isRunning) return;
    setState(() {
      _selectedDurationMinutes = minutes;
      _secondsRemaining = minutes * 60;
      _totalSeconds = minutes * 60;
    });
  }

  // Debug fast-forward to 3 seconds for quick verification
  void _enableDebugMode() {
    if (!_isRunning) return;
    setState(() {
      _secondsRemaining = 3;
    });
  }

  void _onFocusCompleted() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    final focusSeconds = _totalSeconds - _secondsRemaining;
    if (_selectedTodo != null && focusSeconds > 0) {
      context.read<TaskBloc>().add(
        UpdateTaskFocusDurationEvent(
          taskId: _selectedTodo!.id,
          addedSeconds: focusSeconds,
        ),
      );

      // Play system sound feedback
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.heavyImpact();

      final String bodyMessage = 'focus_completed_body'.tr
          .replaceAll('{min}', '$_selectedDurationMinutes')
          .replaceAll('{task}', _selectedTodo!.title);

      // Show notification
      NotificationService().showInstantNotification(
        id: 999,
        title: 'focus_completed_title'.tr,
        body: bodyMessage,
      );

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          title: Text(
            'focus_completed_title'.tr,
            style: const TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'focus_completed_desc'.tr
                .replaceAll('{min}', '$_selectedDurationMinutes')
                .replaceAll('{task}', _selectedTodo!.title),
            style: const TextStyle(fontFamily: 'SF Pro Text'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resetTimer();
              },
              child: Text('confirm_dialog_btn'.tr, style: const TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final inkMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, langState) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'focus_mode'.tr,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              if (_isRunning)
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.amber),
                  tooltip: 'debug_fast_forward'.tr,
                  onPressed: _enableDebugMode,
                ),
            ],
          ),
          body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoaded) {
            final activeTodos = state.allTodos
                .where((t) => !t.isDone && !t.isTrash)
                .toList();

            if (activeTodos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.timer, size: 72, color: inkMuted),
                      const SizedBox(height: 16),
                      Text(
                        'no_active_tasks'.tr,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: inkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'create_task_to_focus'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 14,
                          color: inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Keep selected todo valid if it's still in the list
            if (_selectedTodo != null) {
              final stillExists = activeTodos.any((t) => t.id == _selectedTodo!.id);
              if (!stillExists) {
                _selectedTodo = activeTodos.first;
              } else {
                // Keep references updated
                _selectedTodo = activeTodos.firstWhere((t) => t.id == _selectedTodo!.id);
              }
            } else {
              _selectedTodo = activeTodos.first;
            }

            final progress = _totalSeconds > 0
                ? (_secondsRemaining / _totalSeconds)
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Task Selector Dropdown
                  AppleDropdown<TodoEntity?>(
                    value: _selectedTodo,
                    hint: 'select_task_focus'.tr,
                    items: activeTodos.map((todo) {
                      return AppleDropdownItem<TodoEntity?>(
                        value: todo,
                        label: todo.title,
                        icon: const Icon(CupertinoIcons.checkmark_seal, color: Color(0xFF0066CC), size: 18),
                      );
                    }).toList(),
                    onChanged: _isRunning
                        ? null
                        : (TodoEntity? newValue) {
                            setState(() {
                              _selectedTodo = newValue;
                            });
                          },
                  ),
                  const SizedBox(height: 36),

                  // 2. Circular Timer Ring
                  Center(
                    child: SizedBox(
                      width: 240,
                      height: 240,
                      child: CustomPaint(
                        painter: TimerRingPainter(
                          progress: progress,
                          ringColor: const Color(0xFF0066CC),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          strokeWidth: 16,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(_secondsRemaining),
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: inkColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isRunning ? 'focusing'.tr : 'pause'.tr.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _isRunning ? const Color(0xFF34C759) : inkMuted,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 3. Duration Selector (Capsule Buttons)
                  if (!_isRunning)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _durations.map((minutes) {
                        final isSelected = _selectedDurationMinutes == minutes;
                        final String unit = 'minutes_unit'.tr;
                        return ChoiceChip(
                          label: Text(
                            '$minutes $unit',
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : inkColor,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0066CC),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          elevation: 0,
                          pressElevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF0066CC)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          onSelected: (_) => _onDurationSelected(minutes),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 48),

                  // 4. Control Buttons (Capsule Pill style)
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (_isRunning) ...[
                        // Pause Button
                        ElevatedButton.icon(
                          onPressed: _pauseTimer,
                          icon: const Icon(CupertinoIcons.pause_fill, size: 18),
                          label: Text('pause'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9500),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            textStyle: const TextStyle(fontFamily: 'SF Pro Text', fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Reset/Cancel Button
                        OutlinedButton.icon(
                          onPressed: _resetTimer,
                          icon: const Icon(CupertinoIcons.clear, size: 18),
                          label: Text('cancel'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            textStyle: const TextStyle(fontFamily: 'SF Pro Text', fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else ...[
                        // Start Button
                        ElevatedButton.icon(
                          onPressed: _startTimer,
                          icon: const Icon(CupertinoIcons.play_arrow_solid, size: 18),
                          label: Text('start_focus'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            textStyle: const TextStyle(fontFamily: 'SF Pro Text', fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_secondsRemaining != _selectedDurationMinutes * 60)
                          // Resume and Reset options
                          OutlinedButton.icon(
                            onPressed: _resetTimer,
                            icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 18),
                            label: Text('reset'.tr),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: inkColor,
                              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              textStyle: const TextStyle(fontFamily: 'SF Pro Text', fontWeight: FontWeight.bold),
                            ),
                          ),
                      ]
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
      },
    );
  }
}

class TimerRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color backgroundColor;
  final double strokeWidth;

  TimerRingPainter({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final double angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
