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

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 1,
      'name': 'Hóa Học',
      'icon': Icons.science,
      'gradient': [Color(0xFF43A047), Color(0xFF66BB6A)],
    },
    {
      'id': 2,
      'name': 'Toán Học',
      'icon': Icons.calculate,
      'gradient': [Color(0xFF1E88E5), Color(0xFF42A5F5)],
    },
    {
      'id': 3,
      'name': 'Vật Lý 12',
      'icon': Icons.bolt,
      'gradient': [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
    },
    {
      'id': 4,
      'name': 'Lịch Sử 12',
      'icon': Icons.history_edu,
      'gradient': [Color(0xFFE65100), Color(0xFFFB8C00)],
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Ôn Thi Lớp 12',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử làm bài',
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
          : Column(
              children: [
                // Header greeting section with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user != null)
                        Text(
                          'Xin chào, ${user.hoTen ?? user.tenDangNhap}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Chọn môn học để bắt đầu ôn thi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return _buildCategoryCard(cat);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    int count = _allDeThis
        .where((de) => (de.monHocId) == (cat['id'] as int))
        .length;

    final gradientColors = cat['gradient'] as List<Color>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          List<DeThi> filteredList = _allDeThis
              .where((de) => (de.monHocId) == (cat['id'] as int))
              .toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DanhSachDeByMonScreen(
                subjectName: cat['name'],
                exams: filteredList,
                gradientColors: gradientColors,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat['icon'], size: 32, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                cat['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count đề thi',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
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
  final List<Color> gradientColors;

  const DanhSachDeByMonScreen({
    super.key,
    required this.subjectName,
    required this.exams,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: gradientColors[0],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Text(
              '${exams.length} đề thi có sẵn',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),

          // Exam list
          Expanded(
            child: exams.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Hiện chưa có đề thi cho môn học này.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final dt = exams[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: gradientColors[0],
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            dt.tenDe,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '${dt.thoiGian} phút  •  Mã: ${dt.maDe}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: gradientColors[0].withOpacity(0.6),
                          ),
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
          ),
        ],
      ),
    );
  }
}
