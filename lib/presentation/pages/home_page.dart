import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/application/bloc/task_state.dart';
import 'package:todoapp/application/bloc/list_bloc.dart';
import 'package:todoapp/application/bloc/list_event.dart';
import 'package:todoapp/application/bloc/list_state.dart';
import 'package:todoapp/application/bloc/theme_bloc.dart';
import 'package:todoapp/application/bloc/theme_event.dart';
import 'package:todoapp/application/bloc/theme_state.dart';
import 'package:todoapp/domain/entities/todo_entity.dart';
import 'package:todoapp/domain/entities/todo_list_entity.dart';
import 'package:todoapp/presentation/pages/add_todo_page.dart';
import 'package:todoapp/presentation/pages/edit_todo_page.dart';
import 'package:todoapp/presentation/pages/todo_detail_page.dart';
import 'package:todoapp/presentation/pages/trash_page.dart';
import 'package:todoapp/presentation/pages/analytics_page.dart';
import '../../presentation/widgets/todo_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quickAddController = TextEditingController();

  bool get _isSpeechSupported =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quickAddController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isSpeechSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhận diện giọng nói không hỗ trợ trên nền tảng này.'),
        ),
      );
      return;
    }
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          if (!mounted) return;
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              if (!mounted) return;
              setState(() {
                _searchController.text = val.recognizedWords;
                context.read<TaskBloc>().add(
                  SearchTasksEvent(val.recognizedWords),
                );
              });
            },
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dịch vụ giọng nói không khả dụng hoặc bị từ chối quyền micro.',
              ),
            ),
          );
        }
      } catch (e) {
        print('❌ Lỗi khởi tạo SpeechToText: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Yêu cầu chạy lại ứng dụng (cold boot) để tích hợp plugin native, hoặc thiết bị thiếu Google Speech Services.',
            ),
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'book':
        return Icons.book_outlined;
      case 'fitness':
        return Icons.fitness_center_outlined;
      case 'list':
      default:
        return Icons.format_list_bulleted;
    }
  }

  void _showAddListDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = 0xFF0066CC;
    String selectedIcon = 'list';

    final colors = [
      0xFF0066CC, // Action Blue
      0xFFFF3B30, // Red
      0xFFFF9500, // Orange
      0xFFFFCC00, // Yellow
      0xFF34C759, // Green
      0xFF5AC8FA, // Teal
      0xFFAF52DE, // Purple
      0xFFFF2D55, // Pink
    ];

    final icons = ['list', 'work', 'personal', 'shopping', 'book', 'fitness'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              title: const Text(
                'Danh sách mới',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Tên danh sách',
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Màu sắc',
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Biểu tượng',
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: icons.map((icon) {
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(selectedColor).withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Color(selectedColor)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              _getIconData(icon),
                              color: isSelected
                                  ? Color(selectedColor)
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final newList = TodoListEntity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        iconName: selectedIcon,
                        colorHex: selectedColor,
                      );
                      context.read<ListBloc>().add(AddListEvent(newList));
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(selectedColor),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color activeBlue = const Color(0xFF0066CC);
    final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final Color inkMuted = isDark
        ? const Color(0xFFCCCCCC)
        : const Color(0xFF7A7A7A);
    final Color canvasColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoaded) {
          final filter = state.currentFilter;
          final isDashboard = filter == 'Dashboard';

          return Scaffold(
            body: SafeArea(
              top: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar / Top sticky bar
                  _buildTopBar(context, isDark, inkColor, isDashboard, filter),

                  // Main Content
                  Expanded(
                    child: isDashboard
                        ? _buildDashboard(
                            context,
                            state,
                            isDark,
                            inkColor,
                            inkMuted,
                            canvasColor,
                          )
                        : _buildFilteredListView(
                            context,
                            state,
                            isDark,
                            inkColor,
                            inkMuted,
                            canvasColor,
                          ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: !isDashboard && state.filteredTodos.isNotEmpty
                ? _buildBottomProgressSticky(
                    context,
                    state,
                    isDark,
                    inkColor,
                    inkMuted,
                    activeBlue,
                  )
                : null,
            floatingActionButton: !isDashboard
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTodoPage(
                            initialListId:
                                filter != 'All' &&
                                    filter != 'Today' &&
                                    filter != 'Scheduled' &&
                                    filter != 'Flagged' &&
                                    filter != 'Completed' &&
                                    filter != 'Trash'
                                ? filter
                                : null,
                          ),
                        ),
                      );
                    },
                    label: const Text(
                      'Thêm công việc',
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    backgroundColor: activeBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  )
                : null,
          );
        }

        if (state is TaskLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TaskError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Lỗi: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TaskBloc>().add(LoadTaskEvent()),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Đang khởi tạo dữ liệu')),
        );
      },
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isDark,
    Color inkColor,
    bool isDashboard,
    String filter,
  ) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F7))
            .withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isDashboard)
                  GestureDetector(
                    onTap: () {
                      context.read<TaskBloc>().add(
                        const ChangeFilterEvent('Dashboard'),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: const Color(0xFF0066CC),
                        ),
                        const Text(
                          "Danh sách",
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 16,
                            color: Color(0xFF0066CC),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    "Việc cần làm",
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.374,
                      color: inkColor,
                    ),
                  ),
                Row(
                  children: [
                    // Theme toggler
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, themeState) {
                        final isDarkTheme =
                            themeState.themeMode == ThemeMode.dark;
                        return IconButton(
                          icon: Icon(
                            isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                            color: isDarkTheme
                                ? Colors.yellow
                                : const Color(0xFF1D1D1F),
                            size: 20,
                          ),
                          onPressed: () {
                            context.read<ThemeBloc>().add(ToggleThemeEvent());
                          },
                        );
                      },
                    ),
                    // Backup & Restore PopupMenu
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: inkColor, size: 20),
                      onSelected: (val) {
                        if (val == 'backup') {
                          context.read<TaskBloc>().add(BackupDataEvent());
                        } else if (val == 'restore') {
                          context.read<TaskBloc>().add(RestoreDataEvent());
                        } else if (val == 'trash') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TrashPage(),
                            ),
                          );
                        } else if (val == 'analytics') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AnalyticsPage(),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'analytics',
                          child: Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 18,
                                color: Colors.purple,
                              ),
                              SizedBox(width: 8),
                              Text("Thống kê hiệu suất"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'trash',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text("Thùng rác"),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'backup',
                          child: Row(
                            children: [
                              Icon(
                                Icons.backup_outlined,
                                size: 18,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text("Sao lưu (JSON)"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'restore',
                          child: Row(
                            children: [
                              Icon(
                                Icons.restore_outlined,
                                size: 18,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text("Khôi phục (JSON)"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    TaskLoaded state,
    bool isDark,
    Color inkColor,
    Color inkMuted,
    Color canvasColor,
  ) {
    // Calculate counters
    final todayCount = state.allTodos.where((t) {
      if (t.isTrash || t.isDone) return false;
      if (t.dueDate == null) return false;
      final now = DateTime.now();
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).length;

    final scheduledCount = state.allTodos
        .where((t) => !t.isTrash && !t.isDone && t.dueDate != null)
        .length;
    final allCount = state.allTodos
        .where((t) => !t.isTrash && !t.isDone)
        .length;
    final flaggedCount = state.allTodos
        .where(
          (t) => !t.isTrash && !t.isDone && t.priority.toLowerCase() == 'high',
        )
        .length;
    final completedCount = state.allTodos
        .where((t) => !t.isTrash && t.isDone)
        .length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Search & Voice Input Box
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  context.read<TaskBloc>().add(SearchTasksEvent(val.trim()));
                  // If query is not empty and we are on dashboard, change view to All tasks to display search result
                  if (val.trim().isNotEmpty) {
                    context.read<TaskBloc>().add(
                      const ChangeFilterEvent('All'),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: "Tìm kiếm...",
                  prefixIcon: const Icon(Icons.search, size: 18),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_isSpeechSupported) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _listen,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? Colors.redAccent.withOpacity(0.2)
                        : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isListening
                          ? Colors.redAccent
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.redAccent : inkColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Grid Smart Filters
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _buildSmartFilterCard(
              context,
              'Today',
              'Hôm nay',
              todayCount,
              Icons.today,
              const Color(0xFFFF3B30),
              isDark,
            ),
            _buildSmartFilterCard(
              context,
              'Scheduled',
              'Đã lên lịch',
              scheduledCount,
              Icons.calendar_month,
              const Color(0xFF007AFF),
              isDark,
            ),
            _buildSmartFilterCard(
              context,
              'All',
              'Tất cả',
              allCount,
              Icons.all_inbox,
              const Color(0xFF8E8E93),
              isDark,
            ),
            _buildSmartFilterCard(
              context,
              'Flagged',
              'Quan trọng',
              flaggedCount,
              Icons.flag,
              const Color(0xFFFF9500),
              isDark,
            ),
            _buildSmartFilterCard(
              context,
              'Completed',
              'Đã xong',
              completedCount,
              Icons.check_circle,
              const Color(0xFF34C759),
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Custom Folders / Lists header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Thư mục của tôi",
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: inkColor,
                letterSpacing: -0.5,
              ),
            ),
            IconButton(
              onPressed: () => _showAddListDialog(context),
              icon: const Icon(Icons.add, color: Color(0xFF0066CC)),
              tooltip: "Thêm thư mục",
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Custom Folders List
        BlocBuilder<ListBloc, ListState>(
          builder: (context, listState) {
            if (listState is ListLoaded) {
              if (listState.lists.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withOpacity(0.5)
                        : const Color(0xFFF1F5F9).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Chưa có thư mục tùy chọn",
                      style: TextStyle(
                        color: inkMuted,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: listState.lists.map((folder) {
                  final taskCount = state.allTodos
                      .where(
                        (t) => !t.isTrash && !t.isDone && t.listId == folder.id,
                      )
                      .length;
                  return Dismissible(
                    key: Key("list-folder-${folder.id}"),
                    background: Container(
                      color: Colors.redAccent.withOpacity(0.1),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (dir) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Xóa thư mục"),
                          content: Text(
                            "Bạn có chắc chắn muốn xóa thư mục \"${folder.name}\"? Tất cả công việc bên trong cũng sẽ bị xóa vĩnh viễn.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Hủy"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "Xóa",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      context.read<ListBloc>().add(DeleteListEvent(folder.id));
                      // Refresh tasks list in case it cascades deleted
                      context.read<TaskBloc>().add(LoadTaskEvent());
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(folder.colorHex).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(folder.iconName),
                            color: Color(folder.colorHex),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          folder.name,
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.w600,
                            color: inkColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              taskCount.toString(),
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 16,
                                color: inkMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: inkMuted,
                            ),
                          ],
                        ),
                        onTap: () {
                          context.read<TaskBloc>().add(
                            ChangeFilterEvent(folder.id),
                          );
                        },
                      ),
                    ),
                  ),
                );
                }).toList(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildSmartFilterCard(
    BuildContext context,
    String filterKey,
    String title,
    int count,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<TaskBloc>().add(ChangeFilterEvent(filterKey));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TodoEntity _parseSmartQuickAdd(String text, String? currentListId) {
    String title = text;
    List<String> tags = [];
    String priority = 'medium';
    DateTime? dueDate;

    // 1. Parse Tags (e.g. #work, #personal)
    final tagRegex = RegExp(r'#(\S+)');
    final tagMatches = tagRegex.allMatches(text);
    for (final match in tagMatches) {
      if (match.group(1) != null) {
        tags.add(match.group(1)!);
      }
    }
    title = title.replaceAll(tagRegex, '');

    // 2. Parse Priority (e.g. !cao, !trung, !thap)
    final priorityRegex = RegExp(r'!(\S+)');
    final priorityMatches = priorityRegex.allMatches(text);
    for (final match in priorityMatches) {
      final val = match.group(1)?.toLowerCase() ?? '';
      if (val == 'cao') {
        priority = 'high';
      } else if (val == 'trung' || val == 'trungbinh') {
        priority = 'medium';
      } else if (val == 'thap') {
        priority = 'low';
      }
    }
    title = title.replaceAll(priorityRegex, '');

    // 3. Parse Due Dates (simple parsing: hôm nay, ngày mai, lúc HH:mm)
    final now = DateTime.now();
    if (title.contains('hôm nay') || title.contains('hom nay')) {
      dueDate = DateTime(now.year, now.month, now.day, 23, 59);
      title = title.replaceAll(RegExp(r'(hôm nay|hom nay)'), '');
    } else if (title.contains('ngày mai') || title.contains('ngay mai')) {
      final tomorrow = now.add(const Duration(days: 1));
      dueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);
      title = title.replaceAll(RegExp(r'(ngày mai|ngay mai)'), '');
    }

    // Parse specific time, e.g. lúc 15:00
    final timeRegex = RegExp(r'(lúc|luc)\s+(\d{1,2}):(\d{2})', caseSensitive: false);
    final timeMatch = timeRegex.firstMatch(text);
    if (timeMatch != null) {
      final hour = int.tryParse(timeMatch.group(2) ?? '') ?? 12;
      final minute = int.tryParse(timeMatch.group(3) ?? '') ?? 0;
      
      if (dueDate != null) {
        dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day, hour, minute);
      } else {
        dueDate = DateTime(now.year, now.month, now.day, hour, minute);
      }
      title = title.replaceAll(timeRegex, '');
    }

    title = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (title.isEmpty) {
      title = "Công việc mới";
    }

    return TodoEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      isDone: false,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      tags: tags,
      subtasks: const [],
      listId: currentListId,
    );
  }

  Widget _buildFilteredListView(
    BuildContext context,
    TaskLoaded state,
    bool isDark,
    Color inkColor,
    Color inkMuted,
    Color canvasColor,
  ) {
    final todos = state.filteredTodos;
    final filter = state.currentFilter;

    String filterTitle = 'Công việc';
    Color accentColor = const Color(0xFF0066CC);

    if (filter == 'Today') {
      filterTitle = 'Hôm nay';
      accentColor = const Color(0xFFFF3B30);
    } else if (filter == 'Scheduled') {
      filterTitle = 'Đã lên lịch';
      accentColor = const Color(0xFF007AFF);
    } else if (filter == 'All') {
      filterTitle = 'Tất cả';
      accentColor = const Color(0xFF8E8E93);
    } else if (filter == 'Flagged') {
      filterTitle = 'Quan trọng';
      accentColor = const Color(0xFFFF9500);
    } else if (filter == 'Completed') {
      filterTitle = 'Đã hoàn thành';
      accentColor = const Color(0xFF34C759);
    } else {
      // Find list name in ListBloc
      final listState = context.read<ListBloc>().state;
      if (listState is ListLoaded) {
        final currentList = listState.lists.where((l) => l.id == filter);
        if (currentList.isNotEmpty) {
          filterTitle = currentList.first.name;
          accentColor = Color(currentList.first.colorHex);
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Title Filter Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              filterTitle,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: accentColor,
              ),
            ),
            // Sort popup
            PopupMenuButton<String>(
              icon: Icon(Icons.sort, color: inkColor),
              onSelected: (val) {
                context.read<TaskBloc>().add(SortTasksEvent(val));
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'createdAt',
                  child: Text(
                    "Thời gian tạo",
                    style: TextStyle(
                      color: state.sortBy == 'createdAt' ? accentColor : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'dueDate',
                  child: Text(
                    "Hạn chót",
                    style: TextStyle(
                      color: state.sortBy == 'dueDate' ? accentColor : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'priority',
                  child: Text(
                    "Độ ưu tiên",
                    style: TextStyle(
                      color: state.sortBy == 'priority' ? accentColor : null,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'alphabetical',
                  child: Text(
                    "Tên A-Z",
                    style: TextStyle(
                      color: state.sortBy == 'alphabetical'
                          ? accentColor
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search within filter
        TextField(
          onChanged: (val) {
            context.read<TaskBloc>().add(SearchTasksEvent(val.trim()));
          },
          decoration: InputDecoration(
            hintText: "Tìm kiếm trong mục này...",
            prefixIcon: const Icon(Icons.search, size: 18),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Smart Quick-Add Input field
        if (filter != 'Completed' && filter != 'Trash') ...[
          TextField(
            controller: _quickAddController,
            textInputAction: TextInputAction.send,
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                final listId = filter != 'All' &&
                        filter != 'Today' &&
                        filter != 'Scheduled' &&
                        filter != 'Flagged'
                    ? filter
                    : null;
                final newTodo = _parseSmartQuickAdd(val.trim(), listId);
                context.read<TaskBloc>().add(AddTaskEvent(newTodo));
                _quickAddController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm nhanh: "${newTodo.title}"'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Xem',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TodoDetailPage(id: newTodo.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
            decoration: InputDecoration(
              hintText: "Thêm việc... (VD: Mua sữa #giadinh !cao ngày mai lúc 15:00)",
              hintStyle: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 13,
                color: inkMuted.withOpacity(0.8),
              ),
              prefixIcon: const Icon(CupertinoIcons.plus_circle, size: 18, color: Color(0xFF0066CC)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, size: 16, color: Color(0xFF0066CC)),
                onPressed: () {
                  final val = _quickAddController.text;
                  if (val.trim().isNotEmpty) {
                    final listId = filter != 'All' &&
                            filter != 'Today' &&
                            filter != 'Scheduled' &&
                            filter != 'Flagged'
                        ? filter
                        : null;
                    final newTodo = _parseSmartQuickAdd(val.trim(), listId);
                    context.read<TaskBloc>().add(AddTaskEvent(newTodo));
                    _quickAddController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm nhanh: "${newTodo.title}"'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.6)
                  : const Color(0xFFF1F5F9).withOpacity(0.6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0066CC),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        todos.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 64.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: inkMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Không có công việc nào!",
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16,
                          color: inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: todos.map((item) {
                  return Dismissible(
                    key: Key("todo-item-${item.id}"),
                    background: Container(
                      color: Colors.redAccent.withOpacity(0.1),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24.0),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (dir) async {
                      // Move to trash confirm
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Xóa công việc"),
                          content: Text(
                            "Bỏ công việc \"${item.title}\" vào Thùng rác?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Hủy"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "Xóa",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      context.read<TaskBloc>().add(MoveToTrashEvent(item.id));
                    },
                    child: TodoTitle(
                      todo: item,
                      onChanged: (newValue) {
                        context.read<TaskBloc>().add(
                          UpdateTaskStatusEvent(item.id, newValue!),
                        );
                      },
                      onDelete: () {
                        context.read<TaskBloc>().add(MoveToTrashEvent(item.id));
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditTodoPage(id: item.id, oldTodo: item),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TodoDetailPage(id: item.id),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildBottomProgressSticky(
    BuildContext context,
    TaskLoaded state,
    bool isDark,
    Color inkColor,
    Color inkMuted,
    Color activeBlue,
  ) {
    final todos = state.filteredTodos;
    final total = todos.length;
    final done = todos.where((t) => t.isDone).length;
    final completionRate = total > 0 ? (done / total) : 0.0;
    final pending = total - done;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F7))
            .withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${(completionRate * 100).toInt()}% Hoàn thành mục này",
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: inkColor,
                      ),
                    ),
                    Text(
                      "Đang làm: $pending | Đã xong: $done",
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 11,
                        color: inkMuted,
                      ),
                    ),
                  ],
                ),
                // Visual mini-bar
                Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: completionRate,
                    child: Container(
                      decoration: BoxDecoration(
                        color: activeBlue,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
