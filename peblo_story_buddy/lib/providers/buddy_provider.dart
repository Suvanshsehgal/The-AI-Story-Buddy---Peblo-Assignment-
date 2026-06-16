import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ai_buddy_section.dart';

class BuddyNotifier extends Notifier<BuddyState> {
  @override
  BuddyState build() => BuddyState.idle;
}

final buddyProvider = NotifierProvider<BuddyNotifier, BuddyState>(BuddyNotifier.new);
