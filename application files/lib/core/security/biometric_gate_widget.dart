import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'biometric_service.dart';

class BiometricGate extends ConsumerStatefulWidget {
  final Widget child;
  final String title;

  const BiometricGate({
    super.key,
    required this.child,
    this.title = 'Authenticate to Access MyPocket',
  });

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate> with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _triggerBiometricAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock screen on app resume
    if (state == AppLifecycleState.paused) {
      setState(() {
        _isAuthenticated = false;
      });
    } else if (state == AppLifecycleState.resumed && !_isAuthenticated) {
      _triggerBiometricAuth();
    }
  }

  Future<void> _triggerBiometricAuth() async {
    setState(() {
      _isChecking = true;
    });

    final bioService = ref.read(biometricServiceProvider);
    final success = await bioService.authenticate(localizedReason: widget.title);

    if (mounted) {
      setState(() {
        _isAuthenticated = success;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 72,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 24),
                Text(
                  'App Access Locked',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Biometric authentication or device PIN is required to unlock your MyPocket digital wallet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _triggerBiometricAuth,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock Now'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
