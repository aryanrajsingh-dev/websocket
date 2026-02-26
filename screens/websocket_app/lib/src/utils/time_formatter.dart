class TimeFormatter {
  static String formatUpTime(Duration upTime) {
    final hours = upTime.inHours.toString().padLeft(2, '0');
    final minutes = (upTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (upTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }

  static String getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
