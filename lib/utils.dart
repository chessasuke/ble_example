class Utils {

}

extension StringX on String {

  String get guidNum => '0x${toUpperCase().substring(4, 8)}';
  

}
