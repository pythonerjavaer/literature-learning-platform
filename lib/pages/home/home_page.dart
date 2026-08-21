import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../reader/book_reader_page.dart';
import '../search/search_result_page.dart';
import '../profile/profile_page.dart';
import '../discussion/discussion_page.dart';
import '../analysis/latest_analysis_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<String> _carouselItems = [
    'Pride and Prejudice - Jane Austen',
    'A Tale of Two Cities - Charles Dickens',
    'Wuthering Heights - Emily Brontë',
    'The Great Gatsby - F. Scott Fitzgerald',
    'Animal Farm - George Orwell',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Fiction', 'icon': Icons.book},
    {'name': 'Poetry', 'icon': Icons.music_note},
    {'name': 'Drama', 'icon': Icons.theater_comedy},
    {'name': 'Prose', 'icon': Icons.article},
    {'name': 'Biography', 'icon': Icons.person},
    {'name': 'History', 'icon': Icons.history},
  ];

  final List<Map<String, dynamic>> _latestAnalyses = [
    {
      'title': 'Pride and Prejudice: Character Relationships',
      'author': 'Prof. Wang',
      'date': '2023-10-25',
      'preview': 'An in-depth analysis of character dynamics, focusing on Elizabeth and Darcy...'
    },
    {
      'title': 'A Tale of Two Cities: Historical Context',
      'author': 'Mr. Li',
      'date': '2023-10-23',
      'preview': 'How the French Revolution influenced Dickens; a historical reading of the novel...'
    },
    {
      'title': 'Wuthering Heights: Narrative Structure',
      'author': 'Prof. Zhang',
      'date': '2023-10-20',
      'preview': 'How layered narration enhances mystery and complexity; a detailed breakdown...'
    },
  ];

  final List<Map<String, dynamic>> _hotDiscussions = [
    {
      'title': 'Is Mr. Darcy truly arrogant?',
      'author': 'Literature Enthusiast',
      'replies': 42,
      'lastActive': '2 hours ago'
    },
    {
      'title': 'Animal Farm in Modern Times',
      'author': 'Thinker',
      'replies': 38,
      'lastActive': '5 hours ago'
    },
    {
      'title': 'Gatsby and the American Dream',
      'author': 'Dreamer',
      'replies': 27,
      'lastActive': 'Yesterday'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('English Classics Reader'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchResultPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 显示通知
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 轮播图
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CarouselSlider(
                  items: _carouselItems.map((title) {
                    return Builder(
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 160,
                    viewportFraction: 0.9,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 指示器
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_carouselItems.length, (idx) {
                  final isActive = _currentIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[400],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),
              // Latest analyses title and view more
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest Analyses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LatestAnalysisPage(),
                        ),
                      );
                    },
                    child: const Text('View More'),
                  ),
                ],
              ),

              // 最新解析卡片（展示一条）
              if (_latestAnalyses.isNotEmpty)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LatestAnalysisPage(),
                        ),
                      );
                    },
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _latestAnalyses.first['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Author: ${_latestAnalyses.first['author']}'),
                            const SizedBox(width: 12),
                            Text('Published: ${_latestAnalyses.first['date']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _latestAnalyses.first['preview'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),

              const SizedBox(height: 16),
              // Hot discussions title and view more
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hot Discussions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiscussionPage(),
                        ),
                      );
                    },
                    child: const Text('See More'),
                  ),
                ],
              ),

              // 热门讨论卡片（展示一条）
              if (_hotDiscussions.isNotEmpty)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hotDiscussions.first['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Author: ${_hotDiscussions.first['author']}'),
                            const SizedBox(width: 12),
                            Text('Replies: ${_hotDiscussions.first['replies']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last Active: ${_hotDiscussions.first['lastActive']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },
      ),
    );
  }
}