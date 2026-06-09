import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/services/ai_service.dart';
import '../../core/localization/app_translation.dart';

class AISettingsDialog extends StatefulWidget {
  const AISettingsDialog({super.key});

  @override
  State<AISettingsDialog> createState() => _AISettingsDialogState();
}

class _AISettingsDialogState extends State<AISettingsDialog> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = true;
  bool _hasKey = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentKey();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentKey() async {
    final key = await AIService().getApiKey();
    if (mounted) {
      setState(() {
        _keyController.text = key ?? '';
        _hasKey = key != null;
        _isLoading = false;
      });
    }
  }

  void _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('api_key_empty'.tr)),
      );
      return;
    }

    await AIService().saveApiKey(key);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('api_key_saved'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _deleteKey() async {
    await AIService().deleteApiKey();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('api_key_deleted'.tr),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final inkMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      title: Row(
        children: [
          const Icon(CupertinoIcons.sparkles, color: Color(0xFF0066CC), size: 22),
          const SizedBox(width: 8),
          Text(
            'gemini_settings_title'.tr,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'gemini_settings_desc'.tr,
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 13,
                      color: inkMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keyController,
                    obscureText: _obscureText,
                    autofocus: true,
                    style: TextStyle(fontFamily: 'SF Pro Text', color: inkColor),
                    decoration: InputDecoration(
                      hintText: 'enter_api_key'.tr,
                      hintStyle: TextStyle(color: inkMuted.withOpacity(0.6), fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: inkMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Link to obtain free key
                  GestureDetector(
                    onTap: () {
                      // We don't necessarily need url_launcher, user can open web browser manually,
                      // but displaying it clearly helps!
                      print('🔗 Hướng dẫn: Truy cập https://aistudio.google.com/ để lấy API Key miễn phí.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('get_key_free_toast'.tr),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    child: Text(
                      'get_api_key_free'.tr,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 12,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        if (_hasKey)
          TextButton(
            onPressed: _deleteKey,
            child: Text(
              'delete_key'.tr,
              style: const TextStyle(color: Colors.redAccent, fontFamily: 'SF Pro Text'),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'cancel'.tr,
            style: const TextStyle(color: Colors.grey, fontFamily: 'SF Pro Text'),
          ),
        ),
        ElevatedButton(
          onPressed: _saveKey,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066CC),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'save'.tr,
            style: const TextStyle(fontFamily: 'SF Pro Text', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
