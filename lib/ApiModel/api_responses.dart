import 'livefree.dart';

class LiveClassesResponse {
  final List<ContentItem> upcoming;
  final List<ContentItem> live;
  final List<ContentItem> completed;

  LiveClassesResponse({
    required this.upcoming,
    required this.live,
    required this.completed,
  });

  factory LiveClassesResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;

    List<ContentItem> parseList(dynamic x) {
      final list = (x as List?) ?? [];
      return list
          .map((e) => ContentItem.fromLiveJson(e as Map<String, dynamic>))
          .toList();
    }

    return LiveClassesResponse(
      upcoming: parseList(data['upcoming']),
      live: parseList(data['live']),
      completed: parseList(data['completed']),
    );
  }
}

class FreeContentResponse {
  final bool status;
  final String message;
  final List<ContentItem> data;

  FreeContentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FreeContentResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? [];
    return FreeContentResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: list
          .map((e) => ContentItem.fromDemoJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


class TeacherLiveClassesResponse {
  final List<ContentItem> upcoming;
  final List<ContentItem> live;
  final List<ContentItem> completed;

  TeacherLiveClassesResponse({
    required this.upcoming,
    required this.live,
    required this.completed,
  });

  factory TeacherLiveClassesResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;

    List<ContentItem> parseList(dynamic x) {
      final list = (x as List?) ?? [];
      return list
          .map((e) => ContentItem.fromLiveJson(e as Map<String, dynamic>))
          .toList();
    }

    return TeacherLiveClassesResponse(
      upcoming: parseList(data['upcoming']),
      live: parseList(data['live']),
      completed: parseList(data['completed']),
    );
  }
}
