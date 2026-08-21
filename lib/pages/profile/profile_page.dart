import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_register_page.dart';
import '../notes/notes_page.dart';
import 'favorites_page.dart';
import 'my_discussions_page.dart';
import '../../services/api_client.dart';

import '../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 模拟用户数据
  String _username = 'literary enthusiast';
  final String _userType = 'student';
  String _email = 'student@example.com';
  final String _avatarUrl = '';
  int _notesCount = 0;
  int _discussionsCount = 0;
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavoritesCount();
    _loadCounts();
  }

  // 加载用户数据
  void _loadUserData() {
    // 实际应用中应该从Provider或本地存储获取用户数据
    // 这里使用模拟数据
  }

  Future<void> _loadFavoritesCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('favorites_items');
      int count = 0;
      if (raw != null && raw.isNotEmpty) {
        try {
          final list = (jsonDecode(raw) as List);
          count = list.length;
        } catch (_) {}
      }
      setState(() {
        _favoritesCount = count;
      });
    } catch (_) {}
  }

  Future<void> _loadCounts() async {
    try {
      // 统计笔记数量（后端全部笔记条数）
      final notes = await ApiClient().listNotes();
      int notesCount = notes.length;

      // 统计讨论数量（我的话题 + 我参与的回复条数）
      final topics = await ApiClient().listDiscussions();
      int myTopicCount = 0;
      int myReplyCount = 0;
      final String me = _username;
      for (final m in topics) {
        final author = (m['author'] ?? '').toString();
        if (author == me) myTopicCount++;
        final backendId = (m['id'] ?? '').toString();
        if (backendId.isEmpty) continue;
        try {
          final replies = await ApiClient().listDiscussionReplies(backendId);
          myReplyCount += replies
              .where((r) => (r['author'] ?? '') == me)
              .length;
        } catch (_) {}
      }
      setState(() {
        _notesCount = notesCount;
        _discussionsCount = myTopicCount + myReplyCount;
      });
    } catch (_) {}
  }

  // 编辑个人资料
  void _editProfile() {
    final nameController = TextEditingController(text: _username);
    final emailController = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头像选择
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _avatarUrl.isNotEmpty
                          ? NetworkImage(_avatarUrl)
                          : null,
                      child: _avatarUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Username
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
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
              // 更新用户信息
              setState(() {
                _username = nameController.text;
                _email = emailController.text;
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Profile updated',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // 退出登录
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              () async {
                // 清除登录状态与本地token
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                userProvider.logout();
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('authToken');
                  await prefs.setBool('isLoggedIn', false);
                } catch (_) {}

                if (!mounted) return;
                Navigator.pop(context);
                Fluttertoast.showToast(msg: 'Logged out');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginRegisterPage()),
                  (route) => false,
                );
              }();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息区域
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                children: [
                  // 头像和基本信息
                  Row(
                    children: [
                      // 头像
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: _avatarUrl.isNotEmpty
                            ? NetworkImage(_avatarUrl)
                            : null,
                        child: _avatarUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // 用户信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userType,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 编辑资料按钮
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _editProfile,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),

            // 统计信息
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Notes', _notesCount),
                  _buildStatItem('Discussions', _discussionsCount),
                  _buildStatItem('Favorites', _favoritesCount),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 功能列表
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'My Content',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListItem(
              icon: Icons.note,
              title: 'My Notes',
              subtitle: 'View and manage all your notes',
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const NotesPage()))
                    .then((_) => _loadCounts());
              },
            ),
            _buildListItem(
              icon: Icons.forum,
              title: 'My Discussions',
              subtitle: 'View all discussions you participate in',
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const MyDiscussionsPage(),
                      ),
                    )
                    .then((_) => _loadCounts());
              },
            ),
            _buildListItem(
              icon: Icons.favorite,
              title: 'My Favorites',
              subtitle: 'View your saved classics and analyses',
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(builder: (_) => const FavoritesPage()),
                    )
                    .then((_) => _loadFavoritesCount());
              },
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Account Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListItem(
              icon: Icons.lock,
              title: 'Account Security',
              subtitle: 'Change password and security settings',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Account security features coming soon...',
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
            _buildListItem(
              icon: Icons.notifications,
              title: 'Notification Settings',
              subtitle: 'Manage messages and alerts',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Notification settings coming soon...',
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
            _buildListItem(
              icon: Icons.help,
              title: 'Help & Feedback',
              subtitle: 'FAQ and feedback',
              onTap: () {
                Navigator.pushNamed(context, '/support');
              },
            ),
            _buildListItem(
              icon: Icons.exit_to_app,
              title: 'Log Out',
              subtitle: 'Exit current account',
              onTap: _logout,
              textColor: Colors.red,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 构建统计项
  Widget _buildStatItem(String label, int count) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // 构建列表项
  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
