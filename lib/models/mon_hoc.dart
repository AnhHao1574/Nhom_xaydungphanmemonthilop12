class MonHoc {
  final int? id;
  final String maMon;
  final String tenMon;
  final String? moTa;

  MonHoc({this.id, required this.maMon, required this.tenMon, this.moTa});

  factory MonHoc.fromMap(Map<String, dynamic> map) {
    return MonHoc(
      id: map['id']?.toInt(),
      maMon: map['maMon'] ?? '',
      tenMon: map['tenMon'] ?? '',
      moTa: map['moTa'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maMon': maMon,
      'tenMon': tenMon,
      'moTa': moTa,
    };
  }
}