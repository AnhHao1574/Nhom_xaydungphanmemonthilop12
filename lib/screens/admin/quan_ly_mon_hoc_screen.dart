import 'dart:ui';
import 'package:flutter/material.dart';

import '../../models/mon_hoc.dart';
import '../../services/admin_service.dart';

class QuanLyMonHocScreen extends StatefulWidget {
  const QuanLyMonHocScreen({super.key});

  @override
  State<QuanLyMonHocScreen> createState() => _QuanLyMonHocScreenState();
}

class _QuanLyMonHocScreenState extends State<QuanLyMonHocScreen> {
  final _adminService = AdminService.instance;
  List<MonHoc> _monHocs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _adminService.getDanhSachMonHoc();
    if (mounted) setState(() => _monHocs = data);
  }

  void _showFormDialog({MonHoc? monHoc}) {
    final tenCtrl = TextEditingController(text: monHoc?.tenMon ?? '');
    final moTaCtrl = TextEditingController(text: monHoc?.moTa ?? '');
    final isEdit = monHoc != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Sửa Môn Học' : 'Thêm Môn Học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên môn học *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: moTaCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tenCtrl.text.trim().isEmpty) return;
              if (isEdit) {
                await _adminService.capNhatMonHoc(
                  MonHoc(
                    id: monHoc.id,
                    maMon: monHoc.maMon,
                    tenMon: tenCtrl.text.trim(),
                    moTa: moTaCtrl.text.trim().isEmpty
                        ? null
                        : moTaCtrl.text.trim(),
                  ),
                );
              } else {
                await _adminService.themMonHoc(
                  MonHoc(
                    maMon: 'NEW',
                    tenMon: tenCtrl.text.trim(),
                    moTa: moTaCtrl.text.trim().isEmpty
                        ? null
                        : moTaCtrl.text.trim(),
                  ),
                );
              }
              if (context.mounted) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                _loadData();
              }
            },
            child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MonHoc monHoc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Xóa môn "${monHoc.tenMon}"?\nTất cả đề thi và câu hỏi liên quan cũng sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _adminService.xoaMonHoc(monHoc.id!);
              if (context.mounted) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quản Lý Môn Học', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/hinhnen.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),
          SafeArea(
            child: _monHocs.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có môn học. Nhấn + để thêm.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _monHocs.length,
                    itemBuilder: (context, index) {
                      final mh = _monHocs[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: Colors.white.withOpacity(0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.2,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.3),
                                child: Text(
                                  '${mh.id}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                mh.tenMon,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              subtitle: Text(
                                mh.moTa ?? 'Không có mô tả',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () => _showFormDialog(monHoc: mh),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(mh),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade600,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
