import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/drawing_room_viewmodel.dart';
import '../../../../core/route/app_route_name.dart';

class DrawingRoomListScreen extends StatefulWidget {
  const DrawingRoomListScreen({super.key});

  @override
  State<DrawingRoomListScreen> createState() => _DrawingRoomListScreenState();
}

class _DrawingRoomListScreenState extends State<DrawingRoomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrawingRoomViewModel>().loadUserRooms();
    });
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
            onPressed: () {
              Navigator.pushNamed(context, AppRouteName.userProfile);
            },
          ),
        ],
      ),
      body: Consumer<DrawingRoomViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.clearError();
                      viewModel.loadUserRooms();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadUserRooms(),
            child:
                viewModel.userRooms.isEmpty
                    ? _buildEmptyState(context, viewModel)
                    : _buildRoomsList(context, viewModel),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "join",
            onPressed: () => _showJoinRoomDialog(context),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.login, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "create",
            onPressed: () => _showCreateRoomDialog(context),
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    DrawingRoomViewModel viewModel,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.room_outlined, size: 120, color: Colors.grey[300]),
        const SizedBox(height: 24),
        const Text(
          'No Drawing Rooms',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Create a new room or join an existing one to start drawing with others.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showCreateRoomDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showJoinRoomDialog(context),
                icon: const Icon(Icons.login),
                label: const Text('Join Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomsList(BuildContext context, DrawingRoomViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.userRooms.length,
      itemBuilder: (context, index) {
        final room = viewModel.userRooms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                room.roomName.isNotEmpty ? room.roomName[0].toUpperCase() : 'R',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              room.roomName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Room ID: ${room.roomId}'),
                const SizedBox(height: 2),
                Text(
                  '${room.participants.length}/${room.maxParticipants} participants',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (room.isPasswordProtected)
                  Row(
                    children: [
                      Icon(Icons.lock, size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Password Protected',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _enterRoom(context, room.roomId),
            onLongPress: () => _showRoomOptions(context, room.roomId),
          ),
        );
      },
    );
  }

  void _enterRoom(BuildContext context, String roomId) {
    // Navigate to the drawing canvas screen
    Navigator.pushNamed(context, AppRouteName.drawingRoom, arguments: roomId);
  }

  void _showRoomOptions(BuildContext context, String roomId) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Room Details'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRoomDetails(context, roomId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text('Leave Room'),
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _leaveRoom(context, roomId);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showRoomDetails(BuildContext context, String roomId) {
    // Show room details dialog
    // You can implement this similar to your existing DrawingRoomSettingsDialog
  }

  void _leaveRoom(BuildContext context, String roomId) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave Room'),
            content: const Text('Are you sure you want to leave this room?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Leave'),
              ),
            ],
          ),
    );

    if (shouldLeave == true && mounted) {
      final viewModel = context.read<DrawingRoomViewModel>();
      final success = await viewModel.leaveRoom(roomId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left the room')),
        );
      } else if (mounted && viewModel.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to leave room'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isPasswordProtected = false;
    int maxParticipants = 10;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Create Room'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Room Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Password Protected'),
                        value: isPasswordProtected,
                        onChanged: (value) {
                          setState(() {
                            isPasswordProtected = value ?? false;
                          });
                        },
                      ),
                      if (isPasswordProtected) ...[
                        const SizedBox(height: 8),
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
                          const Text('Max Participants: '),
                          Expanded(
                            child: Slider(
                              value: maxParticipants.toDouble(),
                              min: 2,
                              max: 20,
                              divisions: 18,
                              label: maxParticipants.toString(),
                              onChanged: (value) {
                                setState(() {
                                  maxParticipants = value.round();
                                });
                              },
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
                      onPressed:
                          () => _createRoom(
                            context,
                            nameController.text.trim(),
                            isPasswordProtected
                                ? passwordController.text.trim()
                                : null,
                            maxParticipants,
                          ),
                      child: const Text('Create'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showJoinRoomDialog(BuildContext context) {
    final roomIdController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Join Room'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roomIdController,
                  decoration: const InputDecoration(
                    labelText: 'Room ID',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password (if required)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () => _joinRoom(
                      context,
                      roomIdController.text.trim(),
                      passwordController.text.trim().isEmpty
                          ? null
                          : passwordController.text.trim(),
                    ),
                child: const Text('Join'),
              ),
            ],
          ),
    );
  }

  void _createRoom(
    BuildContext context,
    String roomName,
    String? password,
    int maxParticipants,
  ) async {
    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context); // Close dialog

    final viewModel = context.read<DrawingRoomViewModel>();
    final room = await viewModel.createRoom(
      roomName: roomName,
      password: password,
      maxParticipants: maxParticipants,
    );

    if (room != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room "${room.roomName}" created successfully!'),
        ),
      );
    } else if (mounted && viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to create room'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _joinRoom(BuildContext context, String roomId, String? password) async {
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context); // Close dialog

    final viewModel = context.read<DrawingRoomViewModel>();
    final success = await viewModel.joinRoom(roomId, password: password);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the room!')),
      );
    } else if (mounted && viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to join room'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
