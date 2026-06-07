import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/logout_button.dart';
import 'quan_ly_cau_hoi_screen.dart';
import 'quan_ly_de_thi_screen.dart';
import 'quan_ly_mon_hoc_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Điều Khiển Admin'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: const [LogoutButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null)
            Card(
              color: Colors.blueGrey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${user.hoTen ?? user.tenDangNhap}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Mã người dùng: ${user.id}'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildMenu(
            context,
            icon: Icons.subject,
            title: 'Quản lý Môn Học',
            subtitle: 'Thêm, sửa, xóa môn học',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuanLyMonHocScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenu(
            context,
            icon: Icons.article,
            title: 'Quản lý Đề Thi',
            subtitle: 'Thêm, sửa, xóa đề thi (chương)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuanLyDeThiScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenu(
            context,
            icon: Icons.quiz,
            title: 'Quản lý Câu Hỏi',
            subtitle: 'Thêm, sửa, xóa câu hỏi theo đề thi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuanLyCauHoiScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blueGrey),
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
