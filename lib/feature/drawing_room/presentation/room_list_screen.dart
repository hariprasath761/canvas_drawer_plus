import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/drawing_room.dart';
import '../service/drawing_room_service.dart';
import '../../../core/route/app_route_name.dart';
import '../../../main.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late DrawingRoomService _roomService;
  List<DrawingRoom> _rooms = [];
  bool _isLoading = true;
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roomService = DrawingRoomService(isar);
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await _roomService.getUserRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rooms: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateRoomDialog() {
    final TextEditingController roomNameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordProtected = false;
    int maxParticipants = 10;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Create New Room'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: roomNameController,
                        decoration: const InputDecoration(
                          labelText: 'Room Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: isPasswordProtected,
                            onChanged:
                                (value) => setState(
                                  () => isPasswordProtected = value ?? false,
                                ),
                          ),
                          const Text('Password Protected'),
                        ],
                      ),
                      if (isPasswordProtected) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Max Participants:'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Slider(
                              value: maxParticipants.toDouble(),
                              min: 2,
                              max: 20,
                              divisions: 18,
                              label: maxParticipants.toString(),
                              onChanged:
                                  (value) => setState(
                                    () => maxParticipants = value.toInt(),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (roomNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a room name'),
                            ),
                          );
                          return;
                        }

                        try {
                          final room = await _roomService.createRoom(
                            roomName: roomNameController.text,
                            password:
                                isPasswordProtected
                                    ? passwordController.text
                                    : null,
                            maxParticipants: maxParticipants,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              AppRouteName.drawingRoom,
                              arguments: room.roomId,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error creating room: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showJoinRoomDialog() {
    _roomIdController.clear();
    _passwordController.clear();
    bool needsPassword = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Join Room'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _roomIdController,
                        decoration: const InputDecoration(
                          labelText: 'Room ID',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      if (needsPassword) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_roomIdController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a room ID'),
                            ),
                          );
                          return;
                        }

                        try {
                          final room = await _roomService.joinRoom(
                            _roomIdController.text,
                            password:
                                _passwordController.text.isNotEmpty
                                    ? _passwordController.text
                                    : null,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              AppRouteName.drawingRoom,
                              arguments: room.roomId,
                            );
                          }
                        } catch (e) {
                          if (e.toString().contains('password')) {
                            setState(() => needsPassword = true);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error joining room: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Join'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _copyRoomId(String roomId) {
    Clipboard.setData(ClipboardData(text: roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room ID copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Rooms'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed:
                () => Navigator.pushNamed(context, AppRouteName.userProfile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRooms,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rooms.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.room_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No rooms found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create a new room or join an existing one',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          room.roomName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Room ID: ${room.roomId}'),
                            Text(
                              'Participants: ${room.participants.length}/${room.maxParticipants}',
                            ),
                            Text(
                              'Last modified: ${_formatDate(room.lastModified)}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (room.isPasswordProtected)
                              const Icon(Icons.lock, color: Colors.orange),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyRoomId(room.roomId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    AppRouteName.drawingRoom,
                                    arguments: room.roomId,
                                  ),
                            ),
                          ],
                        ),
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRouteName.drawingRoom,
                              arguments: room.roomId,
                            ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "join",
            onPressed: _showJoinRoomDialog,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.login),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "create",
            onPressed: _showCreateRoomDialog,
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
