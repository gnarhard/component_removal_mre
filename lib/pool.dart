import 'package:flutter/material.dart';

abstract class ObjectPool<T> {
  T get();
  void release(T object);
}

/// Adheres to FILO (First In Last Out) principle.
class Pool<T> implements ObjectPool<T> {
  final List<T> _pool = [];
  final String name;

  Pool(this.name);

  Pool build(int size, T Function(Pool<T>, int) factory) {
    _pool.addAll(List.generate(size, (i) => factory(this, i)));
    return this;
  }

  @override
  T get() {
    if (_pool.isEmpty) {
      debugPrint('$name pool is empty. Consider increasing the size.');
    }

    final component = _pool.first;
    _pool.removeAt(0);

    // debugPrint('Getting $name from pool. Remaining: ${_pool.length}');
    return component;
  }

  @override
  void release(T object) {
    _pool.add(object);
    // debugPrint('Released $name back to pool. Remaining: ${_pool.length}');
  }

  bool get isPopulated => _pool.isNotEmpty;
}
