import 'dart:async';

/// Debouncer utility for delaying function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

typedef VoidCallback = void Function();

/// Extension for debouncing search queries
extension DebounceExtension on String {
  void debounceSearch({
    required Function(String) onSearch,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    final debouncer = Debouncer(delay: delay);
    debouncer.run(() => onSearch(this));
  }
}
