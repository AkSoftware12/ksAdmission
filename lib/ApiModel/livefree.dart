class ContentPdf {
  final int id;
  final String title;
  final String url;
  final String? filePath;
  final String? fileType;

  ContentPdf({
    required this.id,
    required this.title,
    required this.url,
    this.filePath,
    this.fileType,
  });

  factory ContentPdf.fromJson(Map<String, dynamic> j) {
    return ContentPdf(
      id: j['id'] ?? 0,
      title: (j['title'] ?? '').toString(),
      url: (j['url'] ?? '').toString(),
      filePath: j['file_path']?.toString(),
      fileType: j['file_type']?.toString(),
    );
  }
}

class ContentItem {
  final int id;
  final String title;
  final String thumbnail;

  // demo fields
  final int? demoId;
  final String? videoUrl;

  // live class fields
  final int? teacherId;
  final String? className;
  final String? meetingUrl;
  final String? classDate;
  final String? startTime;
  final String? endTime;
  final int? isPublished;
  final String? apiStatus;

  final List<ContentPdf> pdfs;

  ContentItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.demoId,
    this.videoUrl,
    this.teacherId,
    this.className,
    this.meetingUrl,
    this.classDate,
    this.startTime,
    this.endTime,
    this.isPublished,
    this.apiStatus,
    required this.pdfs,
  });

  /// ✅ DEMO API parse (data: [ ... ])
  factory ContentItem.fromDemoJson(Map<String, dynamic> j) {
    final pdfList = (j['pdfs'] as List?) ?? []; // demo me "pdfs"
    return ContentItem(
      id: j['id'] ?? 0,
      demoId: j['demo_id'],
      title: (j['title'] ?? '').toString(),
      thumbnail: (j['thumbnail'] ?? '').toString(),
      videoUrl: j['video_url']?.toString(),
      pdfs: pdfList
          .map((e) => ContentPdf.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ✅ LIVE API parse (data: { upcoming/live/completed })
  factory ContentItem.fromLiveJson(Map<String, dynamic> j) {
    // live api me "pdf" aata hai (not "pdfs")
    final pdfList = (j['pdf'] as List?) ?? [];
    return ContentItem(
      id: j['id'] ?? 0,
      title: (j['title'] ?? '').toString(),
      thumbnail: (j['thumbnail'] ?? '').toString(),
      teacherId: j['teacher_id'],
      className: (j['class'] ?? '').toString(),
      meetingUrl: j['meeting_url']?.toString(),
      classDate: j['class_date']?.toString(),
      startTime: j['start_time']?.toString(),
      endTime: j['end_time']?.toString(),
      isPublished: j['is_published'],
      apiStatus: j['api_status']?.toString(),
      videoUrl: j['video_url']?.toString(), // completed me aata
      pdfs: pdfList
          .map((e) => ContentPdf.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ✅ Play priority: recording > meeting
  String get playableUrl {
    if (videoUrl != null && videoUrl!.isNotEmpty) return videoUrl!;
    if (meetingUrl != null && meetingUrl!.isNotEmpty) return meetingUrl!;
    return "";
  }

  /// ✅ Safe startDateTime
  DateTime? get startDateTime {
    if (classDate == null || classDate!.isEmpty) return null;
    if (startTime == null || startTime!.isEmpty) return null;

    final st = startTime!.length >= 5 ? startTime!.substring(0, 5) : "00:00";
    return DateTime.tryParse('$classDate $st:00');
  }

  /// ✅ ADD THIS: Safe endDateTime
  DateTime? get endDateTime {
    if (classDate == null || classDate!.isEmpty) return null;
    if (endTime == null || endTime!.isEmpty) return null;

    final et = endTime!.length >= 5 ? endTime!.substring(0, 5) : "00:00";
    return DateTime.tryParse('$classDate $et:00');
  }
}
