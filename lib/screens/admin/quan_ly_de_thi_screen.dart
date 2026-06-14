import 'dart:ui';
import 'package:flutter/material.dart';

import '../../models/de_thi.dart';
import '../../models/mon_hoc.dart';
import '../../services/admin_service.dart';
import '../../services/crawler_service.dart';

class QuanLyDeThiScreen extends StatefulWidget {
  const QuanLyDeThiScreen({super.key});

  @override
  State<QuanLyDeThiScreen> createState() => _QuanLyDeThiScreenState();
}

class _QuanLyDeThiScreenState extends State<QuanLyDeThiScreen> {
  final _adminService = AdminService.instance;
  List<DeThi> _deThis = [];
  List<MonHoc> _monHocs = [];
  int? _selectedFilterMonHocId;

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
    final crawlLinkCtrl = TextEditingController();
    int selectedMon = deThi?.monHocId ?? (_monHocs.isNotEmpty ? _monHocs.first.id! : 1);
    final isEdit = deThi != null;
    bool isCrawling = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (builderCtx, setDialogState) {
          if (isCrawling) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Đang cào dữ liệu câu hỏi từ web...\nVui lòng đợi.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return WillPopScope(
            onWillPop: () async => true,
            child: AlertDialog(
              title: Text(isEdit ? 'Sửa Đề Thi' : 'Thêm Đề Thi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: selectedMon,
                      decoration: const InputDecoration(
                        labelText: 'Môn học *',
                        border: OutlineInputBorder(),
                      ),
                      items: _monHocs
                          .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.tenMon, overflow: TextOverflow.ellipsis),
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
                    if (!isEdit) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: crawlLinkCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Link cào câu hỏi (Vietjack / detracnghiem) (Tùy chọn)',
                          helperText: 'Hệ thống sẽ cào câu hỏi trực tiếp cho đề thi này',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(builderCtx),
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
                      if (builderCtx.mounted) {
                        Navigator.pop(builderCtx);
                        _loadData();
                      }
                    } else {
                      // Tạo mới đề thi và lấy ID
                      final newDeThiId = await _adminService.themDeThi(DeThi(
                        monHocId: selectedMon,
                        maDe: 'NEW',
                        tenDe: tenCtrl.text.trim(),
                        thoiGian: 45,
                        namThi: DateTime.now().year,
                        soThuTu: stt,
                      ));

                      final link = crawlLinkCtrl.text.trim();
                      if (link.isNotEmpty && newDeThiId > 0) {
                        setDialogState(() {
                          isCrawling = true;
                        });

                        try {
                          final success = await CrawlerService().crawlAndImport(newDeThiId, link);

                          if (builderCtx.mounted) {
                            Navigator.pop(builderCtx);
                          }

                          if (success) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã thêm đề thi "${tenCtrl.text.trim()}" và cào câu hỏi thành công!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tạo đề thi thành công nhưng cào câu hỏi thất bại hoặc link không đúng cấu trúc.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (builderCtx.mounted) {
                            Navigator.pop(builderCtx);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi trong quá trình cào câu hỏi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } else {
                        if (builderCtx.mounted) {
                          Navigator.pop(builderCtx);
                        }
                      }
                      _loadData();
                    }
                  },
                  child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(DeThi deThi) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Xóa đề "${deThi.tenDe}"?\nTất cả câu hỏi và lịch sử liên quan cũng sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _adminService.xoaDeThi(deThi.id!);
              if (dialogCtx.mounted) {
                Navigator.pop(dialogCtx);
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
    final filteredDeThis = _selectedFilterMonHocId == null
        ? _deThis
        : _deThis.where((dt) => dt.monHocId == _selectedFilterMonHocId).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quản Lý Đề Thi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                // Dropdown Filter for Subjects
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            dropdownColor: const Color(0xFF212121),
                            isExpanded: true,
                            value: _selectedFilterMonHocId,
                            hint: const Text(
                              'Lọc theo môn học (Tất cả)',
                              style: TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Tất cả môn học', style: TextStyle(color: Colors.white)),
                              ),
                              ..._monHocs.map((m) => DropdownMenuItem<int?>(
                                value: m.id,
                                child: Text(m.tenMon, style: const TextStyle(color: Colors.white)),
                              )),
                            ],
                            onChanged: (v) {
                              setState(() {
                                _selectedFilterMonHocId = v;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredDeThis.isEmpty
                      ? Center(
                          child: Text(
                            _selectedFilterMonHocId == null
                                ? 'Chưa có đề thi. Nhấn + để thêm.'
                                : 'Môn học này chưa có đề thi nào.',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filteredDeThis.length,
                          itemBuilder: (context, index) {
                            final dt = filteredDeThis[index];
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
                                      dt.tenDe, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      'Môn: ${_tenMonHoc(dt.monHocId)} | Mã: ${dt.maDe}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                          onPressed: () => _showFormDialog(deThi: dt),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => _confirmDelete(dt),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade600,
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
