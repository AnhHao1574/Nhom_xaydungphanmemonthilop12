import 'dart:ui';
import 'package:flutter/material.dart';

import '../../models/cau_hoi.dart';
import '../../models/de_thi.dart';
import '../../services/admin_service.dart';

class QuanLyCauHoiScreen extends StatefulWidget {
  const QuanLyCauHoiScreen({super.key});

  @override
  State<QuanLyCauHoiScreen> createState() => _QuanLyCauHoiScreenState();
}

class _QuanLyCauHoiScreenState extends State<QuanLyCauHoiScreen> {
  final _adminService = AdminService.instance;
  List<DeThi> _deThis = [];
  List<CauHoi> _cauHois = [];
  int? _selectedDeThiId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeThi();
  }

  Future<void> _loadDeThi() async {
    final data = await _adminService.getDanhSachDeThi();
    if (mounted) {
      setState(() {
        _deThis = data;
        _selectedDeThiId = data.isNotEmpty ? data.first.id : null;
        _isLoading = false;
      });
      if (_selectedDeThiId != null) _loadCauHoi();
    }
  }

  Future<void> _loadCauHoi() async {
    if (_selectedDeThiId == null) return;
    setState(() => _isLoading = true);
    final data = await _adminService.getCauHoiTheoDeThi(_selectedDeThiId!);
    if (mounted) {
      setState(() {
        _cauHois = data;
        _isLoading = false;
      });
    }
  }

  void _showFormDialog({CauHoi? cauHoi}) {
    final noiDungCtrl = TextEditingController(text: cauHoi?.noiDung ?? '');
    final aCtrl = TextEditingController(text: cauHoi?.dapAnA ?? '');
    final bCtrl = TextEditingController(text: cauHoi?.dapAnB ?? '');
    final cCtrl = TextEditingController(text: cauHoi?.dapAnC ?? '');
    final dCtrl = TextEditingController(text: cauHoi?.dapAnD ?? '');
    final giaiThichCtrl = TextEditingController(text: cauHoi?.giaiThich ?? '');
    String dapAnDung = cauHoi?.dapAnDung ?? 'A';
    final isEdit = cauHoi != null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa Câu Hỏi' : 'Thêm Câu Hỏi'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noiDungCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung câu hỏi *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: aCtrl,
                    decoration: const InputDecoration(labelText: 'Đáp án A *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bCtrl,
                    decoration: const InputDecoration(labelText: 'Đáp án B *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: cCtrl,
                    decoration: const InputDecoration(labelText: 'Đáp án C *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dCtrl,
                    decoration: const InputDecoration(labelText: 'Đáp án D *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: dapAnDung,
                    decoration: const InputDecoration(
                      labelText: 'Đáp án đúng *',
                      border: OutlineInputBorder(),
                    ),
                    items: ['A', 'B', 'C', 'D']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => dapAnDung = v!),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: giaiThichCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Lời giải',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (noiDungCtrl.text.trim().isEmpty ||
                    aCtrl.text.trim().isEmpty ||
                    bCtrl.text.trim().isEmpty ||
                    cCtrl.text.trim().isEmpty ||
                    dCtrl.text.trim().isEmpty) {
                  return;
                }
                final data = CauHoi(
                  id: cauHoi?.id,
                  deThiId: cauHoi?.deThiId ?? _selectedDeThiId!,
                  noiDung: noiDungCtrl.text.trim(),
                  dapAnA: aCtrl.text.trim(),
                  dapAnB: bCtrl.text.trim(),
                  dapAnC: cCtrl.text.trim(),
                  dapAnD: dCtrl.text.trim(),
                  dapAnDung: dapAnDung,
                  giaiThich: giaiThichCtrl.text.trim().isEmpty
                      ? null
                      : giaiThichCtrl.text.trim(),
                );
                if (isEdit) {
                  await _adminService.capNhatCauHoi(data);
                } else {
                  await _adminService.themCauHoi(data);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadCauHoi();
                }
              },
              child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CauHoi cauHoi) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa câu hỏi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _adminService.xoaCauHoi(cauHoi.id!);
              if (context.mounted) {
                Navigator.pop(context);
                _loadCauHoi();
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
        title: const Text('Quản Lý Câu Hỏi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _deThis.isEmpty
                      ? const Text('Chưa có đề thi. Hãy tạo đề thi trước.', style: TextStyle(color: Colors.white70))
                      : DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: _selectedDeThiId,
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: Colors.blueGrey.shade900,
                          decoration: InputDecoration(
                            labelText: 'Chọn đề thi',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.12),
                          ),
                          items: _deThis
                              .map((d) => DropdownMenuItem(
                                    value: d.id,
                                    child: Text(
                                      d.tenDe,
                                      style: const TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedDeThiId = v);
                            _loadCauHoi();
                          },
                        ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : _cauHois.isEmpty
                          ? const Center(
                              child: Text(
                                'Chưa có câu hỏi cho đề thi này.',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _cauHois.length,
                              itemBuilder: (context, index) {
                                final ch = _cauHois[index];
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
                                        title: Text(
                                          'Câu ${index + 1}: ${ch.noiDung}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          'Đáp án đúng: ${ch.dapAnDung}',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                              onPressed: () => _showFormDialog(cauHoi: ch),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                                              onPressed: () => _confirmDelete(ch),
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
          ),
        ],
      ),
      floatingActionButton: _selectedDeThiId == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.purple.shade600,
              onPressed: () => _showFormDialog(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
