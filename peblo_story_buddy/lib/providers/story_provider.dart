import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/story_model.dart';

final storyListProvider = FutureProvider<List<StoryModel>>((ref) async {
  final data = await rootBundle.loadString('assets/json/stories.json');
  final json = jsonDecode(data) as Map<String, dynamic>;
  final stories = (json['stories'] as List)
      .map((s) => StoryModel.fromJson(s as Map<String, dynamic>))
      .toList();
  return stories;
});
