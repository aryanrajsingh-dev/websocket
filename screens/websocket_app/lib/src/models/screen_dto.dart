class ScreenDto {
  final String screenId;
  final String title;

  ScreenDto({required this.screenId, required this.title});

  factory ScreenDto.fromJson(Map<String, dynamic> json) => ScreenDto(
        screenId: json.containsKey('screenId') ? json['screenId'].toString() : '1',
        title: json['title'].toString(),
      );
}
