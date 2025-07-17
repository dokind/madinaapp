import 'package:flutter/material.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/home/view/client_chat_detail_page.dart';

class ClientMessagesPage extends StatefulWidget {
  const ClientMessagesPage({super.key});

  @override
  State<ClientMessagesPage> createState() => _ClientMessagesPageState();
}

class _ClientMessagesPageState extends State<ClientMessagesPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy chat data in Russian
  final List<ChatContact> _contacts = [
    ChatContact(
      id: '1',
      name: 'Хейли Джеймс',
      lastMessage: 'Отставать то, во что вы верите',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 9,
      isOnline: true,
    ),
    ChatContact(
      id: '2',
      name: 'Натан Скотт',
      lastMessage:
          'Однажды тебе семнадцать и планируешь когда -нибудь. А затем тихо и без ...',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 2,
      isOnline: false,
    ),
    ChatContact(
      id: '3',
      name: 'Брук Дэвис',
      lastMessage: 'Я тот, кто я. Нет оправданий .',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    ChatContact(
      id: '4',
      name: 'Джейми Скотт',
      lastMessage: 'Некоторые люди немного разные. Я думаю, что это круто .',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatContact(
      id: '5',
      name: 'Мариан Макфадден',
      lastMessage:
          'Прошлой ночью в НБА Шарлотта Бобкатс тихо сделал шаг, который большинство спортивных фанатов ...',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatContact(
      id: '6',
      name: 'Анвон Тейлор',
      lastMessage: 'Встретиться со мной в Rivercourt',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
      isOnline: true,
    ),
    ChatContact(
      id: '7',
      name: 'Джейк Ягельски',
      lastMessage:
          'В своей жизни вы пойдете в некоторые замечательные места и сделаете несколько замечательных вещей .',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatContact(
      id: '8',
      name: 'Пейтон Сойер',
      lastMessage:
          'Каждая песня заканчивается, это не повод не наслаждаться музыкой',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  List<ChatContact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = _contacts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts
            .where((contact) =>
                contact.name.toLowerCase().contains(query.toLowerCase()) ||
                contact.lastMessage.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                // Navigate to edit contacts
              },
              child: const Text(
                'Редактировать',
                style: TextStyle(
                  color: Color(0xFF006FFD),
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Чаты',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                // Start new chat
              },
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF006FFD),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Поиск',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Chat List
          Expanded(
            child: _filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Чаты не найдены',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return ChatContactTile(
                        contact: contact,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  ClientChatDetailPage(contact: contact),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ChatContactTile extends StatelessWidget {
  const ChatContactTile({
    super.key,
    required this.contact,
    required this.onTap,
  });

  final ChatContact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF006FFD),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.split(' ').map((name) => name[0]).take(2).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (contact.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        contact.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        contact.lastMessage,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (contact.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF006FFD),
                shape: BoxShape.circle,
              ),
              child: Text(
                contact.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
