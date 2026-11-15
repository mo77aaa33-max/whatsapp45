import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

const Color kGreen = Color(0xFF075E54);
const Color kLightGreen = Color(0xFF25D366);
const Color kBubbleMe = Color(0xFFDCF8C6);
const Color kChatBg = Color(0xFFECE5DD);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: kGreen,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
        appBarTheme: const AppBarTheme(
          backgroundColor: kGreen,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kLightGreen,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------------------------------------------------------- Data

class Message {
  final String text;
  final bool isMe;
  final String time;
  Message(this.text, this.isMe, this.time);
}

class Chat {
  final String name;
  final Color color;
  final List<Message> messages;
  int unread;
  Chat(this.name, this.color, this.messages, {this.unread = 0});

  String get lastMessage => messages.isEmpty ? '' : messages.last.text;
  String get lastTime => messages.isEmpty ? '' : messages.last.time;
}

final List<Chat> chats = [
  Chat('Ahmed', Colors.blue, [
    Message('ازيك يا معلم؟', false, '10:01'),
    Message('الحمد لله تمام، وانت؟', true, '10:02'),
    Message('هنتقابل النهارده؟', false, '10:05'),
  ], unread: 2),
  Chat('Mona', Colors.pink, [
    Message('بعتلك الملف', false, '09:30'),
    Message('تمام شكرا جدا', true, '09:31'),
  ]),
  Chat('Family Group', Colors.orange, [
    Message('العشا جاهز 🍲', false, 'Yesterday'),
  ], unread: 5),
  Chat('Omar', Colors.purple, [
    Message('الماتش الساعة كام؟', false, 'Yesterday'),
    Message('الساعة 9', true, 'Yesterday'),
  ]),
  Chat('Sara', Colors.teal, [
    Message('Good morning ☀️', false, 'Mon'),
  ]),
  Chat('Work Team', Colors.indigo, [
    Message('Meeting at 3 PM', false, 'Sun'),
    Message('Ok 👍', true, 'Sun'),
  ]),
];

String nowTime() {
  final t = TimeOfDay.now();
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

Widget avatar(String name, Color color, {double radius = 24}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: color,
    child: Text(
      name.characters.first.toUpperCase(),
      style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold),
    ),
  );
}

// ---------------------------------------------------------------- Home

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  IconData get _fabIcon {
    switch (_tabs.index) {
      case 1:
        return Icons.camera_alt;
      case 2:
        return Icons.add_call;
      default:
        return Icons.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp'),
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'group', child: Text('New group')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'UPDATES'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          ChatsTab(onChanged: () => setState(() {})),
          const UpdatesTab(),
          const CallsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(_fabIcon),
      ),
    );
  }
}

// ---------------------------------------------------------------- Chats tab

class ChatsTab extends StatefulWidget {
  final VoidCallback onChanged;
  const ChatsTab({super.key, required this.onChanged});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (_, __) => const Divider(height: 0, indent: 80),
      itemBuilder: (context, i) {
        final chat = chats[i];
        return ListTile(
          leading: avatar(chat.name, chat.color),
          title: Text(chat.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chat.lastMessage,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(chat.lastTime,
                  style: TextStyle(
                      fontSize: 12,
                      color: chat.unread > 0 ? kLightGreen : Colors.grey)),
              const SizedBox(height: 4),
              if (chat.unread > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: kLightGreen,
                  child: Text('${chat.unread}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white)),
                ),
            ],
          ),
          onTap: () async {
            setState(() => chat.unread = 0);
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
            );
            setState(() {});
            widget.onChanged();
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Chat screen

class ChatScreen extends StatefulWidget {
  final Chat chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => widget.chat.messages.add(Message(text, true, nowTime())));
    _controller.clear();
    _scrollDown();

    // Fake auto reply
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() =>
          widget.chat.messages.add(Message('تمام 👍', false, nowTime())));
      _scrollDown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    return Scaffold(
      backgroundColor: kChatBg,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            avatar(chat.name, chat.color, radius: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.name, style: const TextStyle(fontSize: 17)),
                const Text('online', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(8),
              itemCount: chat.messages.length,
              itemBuilder: (_, i) => Bubble(message: chat.messages[i]),
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_emotions_outlined,
                        color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.attach_file, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Icon(Icons.camera_alt, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 24,
              backgroundColor: kGreen,
              child: IconButton(
                icon: Icon(
                    _controller.text.trim().isEmpty ? Icons.mic : Icons.send,
                    color: Colors.white),
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final Message message;
  const Bubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final me = message.isMe;
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: me ? kBubbleMe : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(me ? 10 : 0),
            bottomRight: Radius.circular(me ? 0 : 10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                if (me) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.done_all, size: 16, color: Colors.blue),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Updates tab

class UpdatesTab extends StatelessWidget {
  const UpdatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: Stack(
            children: [
              avatar('Me', Colors.grey),
              const Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: kLightGreen,
                  child: Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          title: const Text('My status',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Tap to add status update'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('Recent updates', style: TextStyle(color: Colors.grey)),
        ),
        for (final c in chats.take(4))
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kLightGreen, width: 2.5),
              ),
              child: avatar(c.name, c.color, radius: 22),
            ),
            title: Text(c.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Today, 08:15'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StatusView(chat: c)),
            ),
          ),
      ],
    );
  }
}

class StatusView extends StatefulWidget {
  final Chat chat;
  const StatusView({super.key, required this.chat});

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
      vsync: this, duration: const Duration(seconds: 5))
    ..forward().whenComplete(() {
      if (mounted) Navigator.pop(context);
    });

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.chat.color,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => LinearProgressIndicator(
                  value: _anim.value,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              ListTile(
                leading: avatar(widget.chat.name, Colors.black26),
                title: Text(widget.chat.name,
                    style: const TextStyle(color: Colors.white)),
                subtitle: const Text('Today, 08:15',
                    style: TextStyle(color: Colors.white70)),
              ),
              const Expanded(
                child: Center(
                  child: Text('صباح الخير ☀️',
                      style: TextStyle(fontSize: 32, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Calls tab

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = [
      ('Ahmed', Colors.blue, true, 'Today, 11:20', false),
      ('Mona', Colors.pink, false, 'Today, 09:02', true),
      ('Omar', Colors.purple, true, 'Yesterday, 22:10', false),
      ('Sara', Colors.teal, false, 'Yesterday, 18:45', false),
      ('Work Team', Colors.indigo, true, 'Sun, 15:00', true),
    ];
    return ListView(
      children: [
        for (final c in calls)
          ListTile(
            leading: avatar(c.$1, c.$2),
            title: Text(c.$1,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                Icon(c.$3 ? Icons.call_made : Icons.call_received,
                    size: 16, color: c.$3 ? kLightGreen : Colors.red),
                const SizedBox(width: 4),
                Text(c.$4),
              ],
            ),
            trailing: Icon(c.$5 ? Icons.videocam : Icons.call, color: kGreen),
          ),
      ],
    );
  }
}
