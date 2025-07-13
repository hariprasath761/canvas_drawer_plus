import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class NetworkStatusIndicator extends StatefulWidget {
  const NetworkStatusIndicator({super.key});

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  bool _isConnected = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startNetworkCheck();
  }

  void _startNetworkCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkNetworkStatus();
    });
    _checkNetworkStatus(); // Initial check
  }

  Future<void> _checkNetworkStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && isConnected != _isConnected) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    } on SocketException catch (_) {
      if (mounted && _isConnected) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
