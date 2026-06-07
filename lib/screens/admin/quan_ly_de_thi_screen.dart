import 'package:flutter/material.dart';

import '../../models/de_thi.dart';
import '../../models/mon_hoc.dart';
import '../../services/admin_service.dart';

class QuanLyDeThiScreen extends StatefulWidget {
  const QuanLyDeThiScreen({super.key});

  @override
  State<QuanLyDeThiScreen> createState() => _QuanLyDeThiScreenState();
}

class _QuanLyDeThiScreenState extends State<QuanLyDeThiScreen> {
  final _adminService = AdminService.instance;
  List<DeThi> _deThis = [];
  List<MonHoc> _monHocs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final deThis = await _adminService.getDanhSachDeThi();
    final monHocs = await _adminService.getDanhSachMonHoc();
    if (mounted) {
      setState(() {
        _deThis = deThis;
        _monHocs = monHocs;
      });
    }
  }

  String _tenMonHoc(int monHocId) {
    for (final m in _monHocs) {
      if (m.id == monHocId) return m.tenMon;
    }
    return 'Môn #$monHocId';
  }

  void _showFormDialog({DeThi? deThi}) {
    final tenCtrl = TextEditingController(text: deThi?.tenDe ?? '');
    final sttCtrl = TextEditingController(text: '${deThi?.soThuTu ?? ''}');
    int selectedMon = deThi?.monHocId ?? (_monHocs.isNotEmpty ? _monHocs.first.id! : 1);
    final isEdit = deThi != null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa Đề Thi' : 'Thêm Đề Thi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedMon,
                  decoration: const InputDecoration(
                    labelText: 'Môn học *',
                    border: OutlineInputBorder(),
                  ),
                  items: _monHocs
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.tenMon),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedMon = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tenCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên đề thi *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sttCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số thứ tự (để trống = tự động)',
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
                final stt = int.tryParse(sttCtrl.text.trim());
                if (isEdit) {
                  await _adminService.capNhatDeThi(DeThi(
                    id: deThi.id,
                    monHocId: selectedMon,
                    maDe: deThi.maDe,
                    tenDe: tenCtrl.text.trim(),
                    thoiGian: deThi.thoiGian,
                    namThi: deThi.namThi,
                    soThuTu: stt ?? deThi.soThuTu,
                  ));
                } else {
                  await _adminService.themDeThi(DeThi(
                    monHocId: selectedMon,
                    maDe: 'NEW',
                    tenDe: tenCtrl.text.trim(),
                    thoiGian: 45,
                    namThi: DateTime.now().year,
                    soThuTu: stt,
                  ));
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(DeThi deThi) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Xóa đề "${deThi.tenDe}"?\nTất cả câu hỏi và lịch sử liên quan cũng sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _adminService.xoaDeThi(deThi.id!);
              if (context.mounted) {
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
      appBar: AppBar(
        title: const Text('Quản Lý Đề Thi'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: _deThis.isEmpty
          ? const Center(child: Text('Chưa có đề thi. Nhấn + để thêm.'))
          : ListView.builder(
              itemCount: _deThis.length,
              itemBuilder: (context, index) {
                final dt = _deThis[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(dt.tenDe, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Môn: ${_tenMonHoc(dt.monHocId)} | Mã: ${dt.maDe}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(deThi: dt),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(dt),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: _monHocs.isEmpty
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hãy thêm môn học trước!')),
                )
            : () => _showFormDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
