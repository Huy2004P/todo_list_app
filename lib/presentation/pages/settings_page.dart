import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:todoapp/application/bloc/theme_bloc.dart';
import 'package:todoapp/application/bloc/theme_event.dart';
import 'package:todoapp/application/bloc/theme_state.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/application/bloc/language_bloc.dart';
import 'package:todoapp/application/bloc/language_event.dart';
import 'package:todoapp/application/bloc/language_state.dart';
import 'package:todoapp/core/localization/app_translation.dart';
import 'package:todoapp/presentation/widgets/ai_settings_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _launchDonation(BuildContext context) async {
    final Uri url = Uri.parse('https://ko-fi.com/huyp04'); // Link donation
    try {
      final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở liên kết donation!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLanguageDialog(BuildContext context, AppLanguage currentLang) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'language_selector'.tr,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: inkColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguage.values.map((lang) {
              final isSelected = lang == currentLang;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(
                  lang.name,
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0066CC) : inkColor,
                  ),
                ),
                trailing: isSelected 
                  ? const Icon(CupertinoIcons.checkmark_alt, color: Color(0xFF0066CC)) 
                  : null,
                onTap: () {
                  context.read<LanguageBloc>().add(ChangeLanguageEvent(lang));
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getFontSizeLabel(double factor) {
    if ((factor - 0.85).abs() < 0.01) return 'font_size_small'.tr;
    if ((factor - 1.0).abs() < 0.01) return 'font_size_normal'.tr;
    if ((factor - 1.15).abs() < 0.01) return 'font_size_large'.tr;
    if ((factor - 1.3).abs() < 0.01) return 'font_size_huge'.tr;
    return '${factor}x';
  }

  void _showFontSizeDialog(BuildContext context, double currentFactor) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
        
        final sizes = [
          {'factor': 0.85, 'label': 'font_size_small'.tr},
          {'factor': 1.0, 'label': 'font_size_normal'.tr},
          {'factor': 1.15, 'label': 'font_size_large'.tr},
          {'factor': 1.3, 'label': 'font_size_huge'.tr},
        ];

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'font_size'.tr,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: inkColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: sizes.map((size) {
              final double factor = size['factor'] as double;
              final String label = size['label'] as String;
              final isSelected = (factor - currentFactor).abs() < 0.01;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(
                  '$label (${factor}x)',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0066CC) : inkColor,
                  ),
                ),
                trailing: isSelected 
                  ? const Icon(CupertinoIcons.checkmark_alt, color: Color(0xFF0066CC)) 
                  : null,
                onTap: () {
                  context.read<ThemeBloc>().add(ChangeTextScaleEvent(factor));
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, langState) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        // Curated color palette matching existing AppTheme
        final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
        final Color inkMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF7A7A7A);
        final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F7);
        final Color hairlineColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('settings'.tr),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: inkColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo & App Name Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066CC), Color(0xFF0071E3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066CC).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Todo App',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: inkColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'version'.tr} 1.0.0',
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 13,
                        color: inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // SECTION 1: CÁ NHÂN HÓA
              _buildSectionTitle('personalization'.tr, inkMuted),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: hairlineColor, width: 0.8),
                ),
                child: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final isDarkTheme = themeState.themeMode == ThemeMode.dark;
                    return Column(
                      children: [
                        _buildSettingRow(
                          context: context,
                          icon: isDarkTheme ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                          iconBgColor: isDarkTheme ? Colors.indigo : Colors.orange,
                          title: 'dark_mode'.tr,
                          subtitle: isDarkTheme ? 'dark_mode_on'.tr : 'dark_mode_off'.tr,
                          trailing: CupertinoSwitch(
                            value: isDarkTheme,
                            activeColor: const Color(0xFF0066CC),
                            onChanged: (val) {
                              context.read<ThemeBloc>().add(ToggleThemeEvent());
                            },
                          ),
                        ),
                        Divider(height: 1, color: hairlineColor, indent: 56),
                        _buildSettingRow(
                          context: context,
                          icon: CupertinoIcons.textformat_size,
                          iconBgColor: Colors.blueAccent,
                          title: 'font_size'.tr,
                          subtitle: _getFontSizeLabel(themeState.textScaleFactor),
                          onTap: () {
                            _showFontSizeDialog(context, themeState.textScaleFactor);
                          },
                          trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: inkMuted),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 2: NGÔN NGỮ
              _buildSectionTitle('language'.tr, inkMuted),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: hairlineColor, width: 0.8),
                ),
                child: _buildSettingRow(
                  context: context,
                  icon: CupertinoIcons.globe,
                  iconBgColor: Colors.teal,
                  title: 'language'.tr,
                  subtitle: langState.language.name,
                  onTap: () {
                    _showLanguageDialog(context, langState.language);
                  },
                  trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: inkMuted),
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 3: HỖ TRỢ AI & TIỆN ÍCH
              _buildSectionTitle('utilities_ai'.tr, inkMuted),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: hairlineColor, width: 0.8),
                ),
                child: Column(
                  children: [
                    _buildSettingRow(
                      context: context,
                      icon: CupertinoIcons.sparkles,
                      iconBgColor: Colors.purple,
                      title: 'gemini_config'.tr,
                      subtitle: 'gemini_config_desc'.tr,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AISettingsDialog(),
                        );
                      },
                      trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 4: QUẢN LÝ DỮ LIỆU
              _buildSectionTitle('data_management'.tr, inkMuted),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: hairlineColor, width: 0.8),
                ),
                child: Column(
                  children: [
                    _buildSettingRow(
                      context: context,
                      icon: CupertinoIcons.cloud_upload_fill,
                      iconBgColor: Colors.blue,
                      title: 'backup_data'.tr,
                      subtitle: 'backup_data_desc'.tr,
                      onTap: () {
                        context.read<TaskBloc>().add(BackupDataEvent());
                      },
                      trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: inkMuted),
                    ),
                    Divider(height: 1, color: hairlineColor, indent: 56),
                    _buildSettingRow(
                      context: context,
                      icon: CupertinoIcons.cloud_download_fill,
                      iconBgColor: Colors.green,
                      title: 'restore_data'.tr,
                      subtitle: 'restore_data_desc'.tr,
                      onTap: () {
                        context.read<TaskBloc>().add(RestoreDataEvent());
                      },
                      trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 5: ỦNG HỘ PHÁT TRIỂN (DONATION)
              _buildSectionTitle('support_author'.tr, inkMuted),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF2E1A0C), const Color(0xFF1E1005)] 
                      : [const Color(0xFFFFF6ED), const Color(0xFFFFF0E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF5C3A21) : const Color(0xFFFFE0C2), 
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.heart_fill,
                            color: Color(0xFFFF8C00),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'donation_message'.tr,
                                style: TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFFFD4B2) : const Color(0xFF8A5A36),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'donation_desc'.tr,
                                style: TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFFD4C2B3) : const Color(0xFFAC876A),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => _launchDonation(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.coffee_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'donation_btn'.tr,
                            style: const TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final Color inkMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF7A7A7A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: inkColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 12,
                      color: inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
