import 'dart:convert';

import 'package:ai_pocket_tools/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  List<types.TextMessage> _messages = [];
  final _user = const types.User(
    id: 'user',
    firstName: 'John',
    role: types.Role.user,
  );
  final _admin = const types.User(
    id: 'admin',
    firstName: 'Admin',
    role: types.Role.admin,
  );

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addTextMessage(types.TextMessage message) {
    setState(() {
      _messages.insert(0, message);
    });

    final chatService = ref.read(selectedChatServiceProvider);
    chatService
        .sendMessage(_messages, _user)
        .run() //
        .then((either) {
      final response = either.fold(
        (failure) => types.TextMessage(
          author: _admin,
          id: const Uuid().v4(),
          text: failure,
        ),
        (messages) => messages.first,
      );

      setState(() {
        _messages.insert(0, response);
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addTextMessage(textMessage);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.TextMessage.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        textMessageBuilder: (
          message, {
          required messageWidth,
          required showName,
        }) =>
            Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: messageWidth.toDouble(),
            child: MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        avatarBuilder: (user) => Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            child: Icon(
              switch (user.role) {
                null => Icons.warning,
                types.Role.admin => Icons.admin_panel_settings,
                types.Role.agent => Icons.support_agent,
                types.Role.moderator => Icons.add_moderator,
                types.Role.user => Icons.person,
              },
            ),
          ),
        ),
        user: _user,
        theme: DefaultChatTheme(
          sentMessageBodyTextStyle: const TextStyle(
            color: Colors.white,
          ),
          receivedMessageBodyTextStyle: const TextStyle(
            color: Colors.black,
          ),
          primaryColor: Colors.blue.shade100,
          secondaryColor: Colors.grey.shade100,
          seenIcon: const Text(
            'read',
            style: TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
