import 'dart:math' as math;

class SmoothingBuffer {
  final List<double> _values;
  final int maxSize;

  SmoothingBuffer(this.maxSize) : _values = [];

  void add(double v) {
    _values.add(v);
    if (_values.length > maxSize) _values.removeAt(0);
  }

  double get average =>
      _values.isEmpty ? 0.0 : _values.reduce((a, b) => a + b) / _values.length;

  double get max => _values.isEmpty ? 0.0 : _values.reduce(math.max);

  double get min => _values.isEmpty ? 0.0 : _values.reduce(math.min);

  void clear() => _values.clear();
}

class HysteresisCounter {
  int _count = 0;
  final int threshold;
  final int decay;

  HysteresisCounter({this.threshold = 3, this.decay = 5});

  bool update(bool activated) {
    if (activated) {
      _count = math.min(_count + 1, threshold + 1);
    } else if (_count > 0) {
      _count -= decay;
      if (_count < 0) _count = 0;
    }
    return _count >= threshold;
  }

  double get normalized => (_count / threshold).clamp(0.0, 1.0);

  void reset() => _count = 0;
}

class TrajectoryTracker {
  final List<double> _dx = [];
  final List<double> _dy = [];
  final int window;

  double _prevX = 0;
  double _prevY = 0;
  bool _hasPrev = false;

  TrajectoryTracker({this.window = 5});

  void add(double x, double y) {
    if (_hasPrev) {
      _dx.add(x - _prevX);
      _dy.add(y - _prevY);
      if (_dx.length > window) _dx.removeAt(0);
      if (_dy.length > window) _dy.removeAt(0);
    }
    _prevX = x;
    _prevY = y;
    _hasPrev = true;
  }

  bool get isMovingToward {
    if (_dx.length < 3) return false;
    final recentX = _dx.sublist(math.max(0, _dx.length - 3));
    final recentY = _dy.sublist(math.max(0, _dy.length - 3));
    final avgDx = recentX.reduce((a, b) => a + b) / recentX.length;
    final avgDy = recentY.reduce((a, b) => a + b) / recentY.length;
    final speed = math.sqrt(avgDx * avgDx + avgDy * avgDy);
    return speed > 0.002;
  }

  void reset() {
    _dx.clear();
    _dy.clear();
    _hasPrev = false;
  }
}
