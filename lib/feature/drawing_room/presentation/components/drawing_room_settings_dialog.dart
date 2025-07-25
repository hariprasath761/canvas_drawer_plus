import 'package:canvas_drawer_plus/feature/auth/model/user_model.dart';
import 'package:canvas_drawer_plus/feature/drawing_room/data/repository/drawing_room_repository.dart';
import 'package:canvas_drawer_plus/feature/drawing_room/presentation/viewmodel/drawing_room_viewmodel.dart';
import 'package:canvas_drawer_plus/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../model/drawing_room.dart';

class DrawingRoomSettingsDialog extends StatefulWidget {
  final String roomId;

  const DrawingRoomSettingsDialog({super.key, required this.roomId});

  @override
  State<DrawingRoomSettingsDialog> createState() =>
      _DrawingRoomSettingsDialogState();
}

class _DrawingRoomSettingsDialogState extends State<DrawingRoomSettingsDialog> {
  late DrawingRoomRepository _roomService;
  DrawingRoom? _room;
  bool _isLoading = true;
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];
  List<UserModel> participants = [];
  UserModel? createdBy;

  Future<List<Map<String, dynamic>>> getUserName(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    for (var user in userIds) {
      final userInfo = await _firestore.collection('users').doc(user).get();
      logger.i(userInfo.data());
      if (userInfo.exists && userInfo.data() != null) {
        users.add(userInfo.data()!);
      }
    }
    if (mounted) {
      setState(() {});
    }

    return users;
  }

  @override
  void initState() {
    super.initState();

    _roomService = context.read<DrawingRoomViewModel>().repository;
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    try {
      final room = await _roomService.getRoom(widget.roomId);
      participants = await _roomService.getParticipantData(
        room?.participants ?? [],
      );
      try {
        createdBy = participants.firstWhere(
          (user) => user.uid == room?.createdBy,
        );
      } catch (e) {
        logger.e('Error fetching participants: $e');
      }

      setState(() {
        _room = room;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading room details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room ID copied to clipboard')),
    );
  }

  void _shareRoom() {
    // In a real app, you'd use a share plugin
    _copyRoomId();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room ID copied! Share it with others to invite them.'),
      ),
    );
  }

  Future<void> _leaveRoom() async {
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

    if (shouldLeave == true) {
      try {
        await _roomService.leaveRoom(widget.roomId);
        if (mounted) {
          Navigator.pop(context, true); // Return to room list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error leaving room: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Room Settings'),
      content:
          _isLoading
              ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
              : _room == null
              ? const Text('Room not found')
              : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Room Name', _room!.roomName),
                  _buildInfoRow('Room ID', _room!.roomId),
                  _buildInfoRow('Creator', createdBy?.displayName ?? 'Unknown'),
                  _buildInfoRow(
                    'Participants',
                    '${_room!.participants.length}/${_room!.maxParticipants}',
                  ),
                  _buildInfoRow('Created', _formatDate(_room!.createdAt)),
                  if (_room!.isPasswordProtected)
                    _buildInfoRow('Security', 'Password Protected'),

                  const SizedBox(height: 16),

                  // Participants list
                  const Text(
                    'Participants:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            participants.map((participant) {
                              final isCreator =
                                  participant.uid == _room!.createdBy;
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 16,
                                  child: Text(
                                    participant.displayName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  participant.displayName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing:
                                    isCreator
                                        ? const Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 16,
                                        )
                                        : null,
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(onPressed: _shareRoom, child: const Text('Share')),
        TextButton(
          onPressed: _leaveRoom,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Leave Room'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
