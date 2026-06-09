import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppleDropdownItem<T> {
  final T value;
  final String label;
  final Widget? icon;

  const AppleDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

class AppleDropdown<T> extends StatelessWidget {
  final T value;
  final List<AppleDropdownItem<T>> items;
  final ValueChanged<T>? onChanged;
  final String? hint;

  const AppleDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.hint,
  });

  bool get isEnabled => onChanged != null;

  void _showBottomSheet(BuildContext context) {
    if (!isEnabled) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Apple-styled color palette
    final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color separatorColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Drag Indicator
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (hint != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    hint!,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: inkColor,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: separatorColor),
              ],
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: separatorColor,
                    indent: items[index].icon != null ? 56 : 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.value == value;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: item.icon != null
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(child: item.icon),
                            )
                          : null,
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFF0066CC) : inkColor,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Color(0xFF0066CC),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        onChanged?.call(item.value);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final Color inkMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF7A7A7A);
    final Color fieldColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    // Find the item representing the current selected value
    AppleDropdownItem<T>? selectedItem;
    try {
      selectedItem = items.firstWhere((item) => item.value == value);
    } catch (_) {
      if (items.isNotEmpty) {
        selectedItem = items.first;
      }
    }

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol, width: 0.8),
        ),
        child: InkWell(
          onTap: isEnabled ? () => _showBottomSheet(context) : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                if (selectedItem?.icon != null) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(child: selectedItem!.icon),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    selectedItem?.label ?? hint ?? '',
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 15,
                      color: selectedItem != null ? inkColor : inkMuted,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_up_chevron_down,
                  color: inkMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
