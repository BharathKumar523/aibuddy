import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fired by the network layer when the server rejects the stored token
/// (a 401 on an authenticated request).
///
/// This is a separate object, not a direct call into the session, because
/// the session depends on the network layer (through AuthRepository).
/// Calling back into it from Dio would be a circular provider dependency.
/// Dio only knows this signal; the session listens to it.
class UnauthorizedSignal {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}

final unauthorizedSignalProvider = Provider<UnauthorizedSignal>((ref) {
  final signal = UnauthorizedSignal();
  ref.onDispose(signal.dispose);
  return signal;
}, name: 'unauthorizedSignalProvider');
