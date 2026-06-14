import 'package:flutter/material.dart';
import '../models/de_thi.dart';
import '../models/mon_hoc.dart';
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
  List<MonHoc> _monHocs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeThi();
  }

  void _loadDeThi() async {
    setState(() => _isLoading = true);
    final list = await _adminService.getDanhSachDeThi();
    final monHocs = await _adminService.getDanhSachMonHoc();
    setState(() {
      _allDeThis = list;
      _monHocs = monHocs;
      _isLoading = false;
    });
  }

  // Helper to map icon based on subject name
  IconData _getCategoryIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('toán')) return Icons.calculate;
    if (name.contains('hóa')) return Icons.science;
    if (name.contains('lý') || name.contains('vật lý')) return Icons.bolt;
    if (name.contains('sử') || name.contains('lịch sử')) return Icons.history_edu;
    if (name.contains('sinh') || name.contains('sinh học')) return Icons.biotech;
    if (name.contains('văn') || name.contains('ngữ văn')) return Icons.menu_book;
    if (name.contains('anh') || name.contains('tiếng anh')) return Icons.language;
    if (name.contains('địa')) return Icons.public;
    return Icons.school;
  }

  // Helper to map gradient based on subject name
  List<Color> _getCategoryGradient(String name, int id) {
    name = name.toLowerCase();
    if (name.contains('hóa')) return [const Color(0xFF43A047), const Color(0xFF66BB6A)];
    if (name.contains('toán')) return [const Color(0xFF1E88E5), const Color(0xFF42A5F5)];
    if (name.contains('lý') || name.contains('vật lý')) return [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)];
    if (name.contains('sử') || name.contains('lịch sử')) return [const Color(0xFFE65100), const Color(0xFFFB8C00)];
    if (name.contains('sinh') || name.contains('sinh học')) return [const Color(0xFF00796B), const Color(0xFF009688)];
    if (name.contains('anh') || name.contains('tiếng anh')) return [const Color(0xFF0288D1), const Color(0xFF29B6F6)];
    if (name.contains('văn') || name.contains('ngữ văn')) return [const Color(0xFFC2185B), const Color(0xFFEC407A)];
    if (name.contains('địa')) return [const Color(0xFF388E3C), const Color(0xFF81C784)];
    
    final List<List<Color>> defaults = [
      [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
      [const Color(0xFF37474F), const Color(0xFF455A64)],
      [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
      [const Color(0xFFD84315), const Color(0xFFFF5722)],
    ];
    return defaults[id % defaults.length];
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
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDeThi();
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: _isLoading
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
                      child: _monHocs.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 100),
                                Center(
                                  child: Text(
                                    'Không có môn học nào.\nHãy vào phần quản trị để thêm!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black54, fontSize: 15),
                                  ),
                                ),
                              ],
                            )
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.15,
                              ),
                              itemCount: _monHocs.length,
                              itemBuilder: (context, index) {
                                final mh = _monHocs[index];
                                return _buildCategoryCard(mh);
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryCard(MonHoc mh) {
    int count = _allDeThis
        .where((de) => (de.monHocId) == mh.id)
        .length;

    final gradientColors = _getCategoryGradient(mh.tenMon, mh.id ?? 0);
    final icon = _getCategoryIcon(mh.tenMon);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          List<DeThi> filteredList = _allDeThis
              .where((de) => (de.monHocId) == mh.id)
              .toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DanhSachDeByMonScreen(
                subjectName: mh.tenMon,
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
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                mh.tenMon,
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
                                builder: (_) => DeThiScreen(
                                  deThi: dt,
                                  gradientColors: gradientColors,
                                ),
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
