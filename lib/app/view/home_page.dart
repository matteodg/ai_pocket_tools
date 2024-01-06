import 'package:ai_pocket_tools/chat/view/chat_page.dart';
import 'package:ai_pocket_tools/rag/view/rag_page.dart';
import 'package:ai_pocket_tools/settings/view/settings_page.dart';
import 'package:ai_pocket_tools/shared_items/view/shared_items_page.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (selectedIndex) => setState(
          () => _selectedIndex = selectedIndex,
        ),
        iconSize: 20,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Shared Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'RAG',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: LazyLoadIndexedStack(
        index: _selectedIndex,
        children: const [
          SharedItemsPage(),
          ChatPage(),
          RagPage(),
          SettingsPage(),
        ],
      ),
    );
  }
}
