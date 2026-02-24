class DataDto {
  final Map<String, dynamic> payload;

  DataDto({required this.payload});

  factory DataDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = Map.from(json);
    payload.remove('type');
    return DataDto(payload: payload);
  }
}
    