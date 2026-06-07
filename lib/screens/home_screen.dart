import 'package:flutter/material.dart';
import '../models/de_thi.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../widgets/logout_button.dart';
import 'lich_su_screen.dart';
import 'de_thi_screen.dart'; // Đảm bảo import này đúng

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _adminService = AdminService.instance;
  List<DeThi> _allDeThis = [];
  bool _isLoading = true;

  // Lưu số lượng câu hỏi hoặc số chương tự động đếm từ DB của từng môn
  // ignore: unused_field
  Map<int, int> _itemsCountByMon = {1: 0, 2: 0, 3: 0, 4: 0};

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Hóa Học', 'icon': Icons.science, 'color': Colors.green},
    {
      'id': 2,
      'name': 'Toán Học',
      'icon': Icons.calculate,
      'color': Colors.blue,
    },
    {'id': 3, 'name': 'Vật Lý 12', 'icon': Icons.bolt, 'color': Colors.purple},
    {
      'id': 4,
      'name': 'Lịch Sử 12',
      'icon': Icons.history_edu,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDeThi();
  }

  void _loadDeThi() async {
    setState(() => _isLoading = true);
    final list = await _adminService.getDanhSachDeThi();
    setState(() {
      _allDeThis = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ôn Thi Lớp 12'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LichSuScreen()),
            ),
          ),
          const LogoutButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null)
                    Text(
                      'Chào mừng, ${user.hoTen ?? user.tenDangNhap}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Danh mục môn học:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  // Hiển thị Grid các môn học
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return _buildCategoryCard(cat);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    // Đếm số lượng đề thi cho mỗi môn để hiển thị số lượng "tự động"
    int count = _allDeThis
        .where((de) => (de.monHocId) == (cat['id'] as int))
        .length;

    return InkWell(
      onTap: () {
        // Lọc danh sách đề theo môn
        List<DeThi> filteredList = _allDeThis
            .where((de) => (de.monHocId) == (cat['id'] as int))
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DanhSachDeByMonScreen(
              subjectName: cat['name'],
              exams: filteredList,
              color: cat['color'],
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [cat['color'], cat['color'].withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat['icon'], size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                cat['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$count đề thi',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Màn hình hiển thị danh sách đề sau khi chọn môn
class DanhSachDeByMonScreen extends StatelessWidget {
  final String subjectName;
  final List<DeThi> exams;
  final Color color;

  const DanhSachDeByMonScreen({
    super.key,
    required this.subjectName,
    required this.exams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đề thi $subjectName'),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: exams.isEmpty
          ? const Center(child: Text('Hiện chưa có đề thi cho môn học này.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final dt = exams[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      dt.tenDe,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Thời gian: ${dt.thoiGian} phút | Mã đề: ${dt.maDe}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeThiScreen(deThi: dt),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
