import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_client.dart';

import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  // 通知设置
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  // 缓存大小
  String _cacheSize = '23.5 MB';

  // 应用版本
  final String _appVersion = '1.0.0';

  // 开发者选项：后端地址
  final TextEditingController _apiBaseController = TextEditingController();
  String _apiStatus = '';

  @override
  void initState() {
    super.initState();
    _loadSavedApiBaseUrl();
  }

  Future<void> _loadSavedApiBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('apiBaseUrl') ?? '';
      if (saved.isNotEmpty) {
        _apiBaseController.text = saved;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // 账号安全
          _buildSectionHeader('Account & Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          const Divider(),

          // 通知设置
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive updates for analyses and replies'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
              Fluttertoast.showToast(
                msg: value ? 'Push notifications enabled' : 'Push notifications disabled',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.email),
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive weekly summaries and important updates'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
              Fluttertoast.showToast(
                msg: value ? 'Email notifications enabled' : 'Email notifications disabled',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          const Divider(),

          // 界面设置
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('App Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (ThemeMode? newThemeMode) {
                if (newThemeMode != null) {
                  themeProvider.toggleTheme();
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Reading Font Size'),
            trailing: DropdownButton<String>(
              value: 'Medium',
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'Small', child: Text('Small')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Large', child: Text('Large')),
                DropdownMenuItem(value: 'Extra Large', child: Text('Extra Large')),
              ],
              onChanged: (String? newSize) {
                if (newSize != null) {
                  Fluttertoast.showToast(
                    msg: 'Font size set to $newSize',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              },
            ),
          ),
          const Divider(),

          // 存储管理
          _buildSectionHeader('Storage'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Cache Management'),
            subtitle: Text('Current cache size: $_cacheSize'),
            trailing: TextButton(
              child: const Text('Clear'),
              onPressed: () {
                _showClearCacheDialog();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Offline Reading'),
            subtitle: const Text('Manage downloaded classics content'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Fluttertoast.showToast(
                msg: 'Offline reading settings under development...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          const Divider(),

          // 关于
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Check for Updates'),
            subtitle: Text('Current version: $_appVersion'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _checkForUpdates();
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Fluttertoast.showToast(
                msg: 'Privacy policy is under development...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('User Agreement'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Fluttertoast.showToast(
                msg: 'User agreement is under development...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          ),
          const SizedBox(height: 24),

          // 开发者选项：后端地址配置
          _buildSectionHeader('Developer Options'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Backend URL (e.g., http://192.168.x.x:8090)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiBaseController,
                  decoration: const InputDecoration(
                    hintText: 'Enter backend URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final url = _apiBaseController.text.trim();
                        if (url.isEmpty) {
                          Fluttertoast.showToast(msg: 'Please enter backend URL');
                          return;
                        }
                        try {
                          await ApiClient().configureBaseUrl(url);
                          Fluttertoast.showToast(msg: 'Backend URL saved');
                        } catch (e) {
                          Fluttertoast.showToast(msg: 'Save failed: $e');
                        }
                      },
                      child: const Text('Save Backend URL'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () async {
                        setState(() => _apiStatus = 'Testing...');
                        try {
                          final resp = await ApiClient().dio.get('/health');
                          setState(() => _apiStatus = 'Connected: ${resp.data['status']}');
                          Fluttertoast.showToast(msg: 'Connection successful');
                        } catch (e) {
                          setState(() => _apiStatus = 'Connection failed: $e');
                          Fluttertoast.showToast(msg: 'Connection failed: $e');
                        }
                      },
                      child: const Text('Test Connection'),
                    ),
                  ],
                ),
                if (_apiStatus.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _apiStatus,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 构建分区标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // 修改密码对话框
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  helperText: 'At least 8 characters including letters and numbers',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // 验证密码
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (currentPassword.isEmpty ||
                  newPassword.isEmpty ||
                  confirmPassword.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please fill in all password fields',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }

              if (newPassword != confirmPassword) {
                Fluttertoast.showToast(
                  msg: 'New passwords do not match',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }

              if (newPassword.length < 8) {
                Fluttertoast.showToast(
                  msg: 'New password must be at least 8 characters',
                  toastLength: Toast.LENGTH_SHORT,
                );
                return;
              }

              // 模拟密码修改成功
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Password changed successfully',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // 清除缓存对话框
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Clear all cached data? This removes temporary files without affecting your personal data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // 模拟清除缓存
              Navigator.pop(context);
              setState(() {
                _cacheSize = '0 B';
              });
              Fluttertoast.showToast(
                msg: 'Cache cleared',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // 关于对话框
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'English Classics Reader',
        applicationVersion: _appVersion,
        applicationIcon: const FlutterLogo(size: 32),
        children: const [
          SizedBox(height: 16),
          Text(
            'English Classics Reader is a learning platform for students and teachers, offering classics reading, notes, analyses, and discussions.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          Text('© 2023 English Classics Reader Team', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // 检查更新
  void _checkForUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check for Updates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Checking for updates...'),
          ],
        ),
      ),
    );

    // 模拟检查更新
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Check for Updates'),
          content: const Text('You are already on the latest version.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
