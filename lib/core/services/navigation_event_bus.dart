import 'dart:async';
import 'package:sanchora/core/widgets/sanchora_bottom_nav.dart';

class NavigationEventBus {
  // Singleton instance
  static final NavigationEventBus _instance = NavigationEventBus._internal();
  static NavigationEventBus get instance => _instance;

  NavigationEventBus._internal();

  // Stream controller for scroll-to-top events
  final StreamController<BottomNavTab> _scrollToTopController = StreamController<BottomNavTab>.broadcast();

  /// Stream to listen for scroll-to-top events.
  Stream<BottomNavTab> get scrollToTopStream => _scrollToTopController.stream;

  /// Fire an event indicating the active tab was tapped again.
  void fireScrollToTop(BottomNavTab tab) {
    _scrollToTopController.add(tab);
  }

  void dispose() {
    _scrollToTopController.close();
  }
}
