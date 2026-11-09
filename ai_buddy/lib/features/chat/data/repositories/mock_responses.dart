/// Canned markdown replies for the Phase 5 mock repository.
///
/// They exercise everything the chat UI renders: headings, lists, tables,
/// block quotes, inline code and fenced code blocks.
abstract final class MockResponses {
  static String replyFor(String prompt) {
    final p = prompt.toLowerCase();
    if (p.contains('jwt') || p.contains('auth')) return _jwt;
    if (p.contains('debounce') || p.contains('dart') || p.contains('code')) {
      return _dartCode;
    }
    if (p.contains('trip') || p.contains('goa') || p.contains('travel')) {
      return _trip;
    }
    if (p.contains('mvvm')) return _mvvm;
    return _fallback(prompt);
  }

  static const String _jwt = '''
## How JWT authentication works

A **JSON Web Token** is a signed string the server gives you after you sign in. The app sends it with every request so the server knows who you are.

1. You sign in with email and password.
2. The server checks them and returns a token signed with a secret.
3. The app stores the token securely and sends `Authorization: Bearer <token>`.
4. The server verifies the signature on each request. No session lookup is needed.

| Part | Contains |
| --- | --- |
| Header | Algorithm, e.g. `HS256` |
| Payload | User id (`sub`), expiry (`exp`) |
| Signature | Proof the token wasn't changed |

> Tokens can't be revoked once issued, so keep their lifetime reasonable.
''';

  static const String _dartCode = '''
Here's a small, reusable **debouncer** in Dart. It waits until calls stop for a moment before running the action:

```dart
import 'dart:async';

class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
```

Use it for search boxes:

```dart
final debounce = Debouncer(const Duration(milliseconds: 300));
onChanged: (text) => debounce(() => search(text)),
```

Remember to call `dispose()` when the widget is removed.
''';

  static const String _trip = '''
## 2 days in Goa on a budget

### Day 1: North Goa
- **Morning:** Fort Aguada and the lighthouse
- **Afternoon:** Calangute and Baga beaches
- **Evening:** Sunset at Chapora Fort, dinner at a beach shack

### Day 2: Old Goa and Panaji
- **Morning:** Basilica of Bom Jesus
- **Afternoon:** Walk the Latin Quarter in Fontainhas
- **Evening:** River cruise on the Mandovi

**Tips:** rent a scooter (about ₹400/day), carry cash for shacks, and visit between November and February.
''';

  static const String _mvvm = '''
## Why MVVM works well in Flutter

- **Separation of concerns:** widgets only render state; ViewModels hold logic.
- **Testability:** ViewModels are plain Dart, so they're unit-tested without widgets.
- **Reuse:** the same ViewModel can drive phone and tablet layouts.
- **Predictable state:** with Riverpod, every screen state is an explicit value.

> In this app: View → ViewModel → Repository → API, and each layer only talks to the next one.
''';

  static String _fallback(String prompt) {
    final quoted = prompt.length > 80 ? '${prompt.substring(0, 80)}…' : prompt;
    return '''
This is a **mock reply** to:

> $quoted

Real AI answers arrive in Phase 6. For now you can try:

- a prompt with *dart* or *code* for a code block,
- *JWT* for a table,
- any message containing the word `fail` to see the error and **Retry** flow.
''';
  }
}
