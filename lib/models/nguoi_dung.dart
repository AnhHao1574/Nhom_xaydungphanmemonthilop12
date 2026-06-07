class NguoiDung {
  final int? id;
  final String tenDangNhap;
  final String matKhau;
  final String? hoTen;
  final String? email;
  final int maVaiTro;

  NguoiDung({
    this.id,
    required this.tenDangNhap,
    required this.matKhau,
    this.hoTen,
    this.email,
    required this.maVaiTro,
  });

  bool get isAdminRoute => id == 1 || id == 2;
  bool get isStudentRoute => id != null && !isAdminRoute;

  factory NguoiDung.fromMap(Map<String, dynamic> map) {
    return NguoiDung(
      id: map['MaNguoiDung'] as int? ?? map['id'] as int?,
      tenDangNhap: map['TenDangNhap'] as String? ?? map['tenDangNhap'] as String? ?? '',
      matKhau: map['MatKhau'] as String? ?? map['matKhau'] as String? ?? '',
      hoTen: map['HoTen'] as String? ?? map['hoTen'] as String?,
      email: map['Email'] as String? ?? map['email'] as String?,
      maVaiTro: map['MaVaiTro'] as int? ?? map['maVaiTro'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'MaNguoiDung': id,
        'TenDangNhap': tenDangNhap,
        'MatKhau': matKhau,
        'HoTen': hoTen,
        'Email': email,
        'MaVaiTro': maVaiTro,
        'NgayTao': DateTime.now().toIso8601String(),
      };
}
