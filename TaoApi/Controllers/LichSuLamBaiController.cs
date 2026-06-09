using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoApi.Data;
using TaoApi.Models;

namespace TaoApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LichSuLamBaiController : ControllerBase
    {
        private readonly AppDbContext _context;

        public LichSuLamBaiController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _context.LichSuLamBais
                .Join(_context.Chuongs, 
                      ls => ls.MaChuong, 
                      c => c.MaChuong, 
                      (ls, c) => new HistoryWithChapterName
                      {
                          MaLichSu = ls.MaLichSu,
                          MaNguoiDung = ls.MaNguoiDung,
                          MaChuong = ls.MaChuong,
                          TenChuong = c.TenChuong, // maps to TenDeThi in Flutter
                          Diem = ls.Diem,
                          SoCauDung = ls.SoCauDung,
                          TongSoCau = ls.TongSoCau,
                          DanhSachDapAnChon = ls.DanhSachDapAnChon,
                          NgayLam = ls.NgayLam
                      })
                .OrderByDescending(h => h.NgayLam)
                .ToListAsync();

            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var item = await _context.LichSuLamBais
                .Where(ls => ls.MaLichSu == id)
                .Join(_context.Chuongs, 
                      ls => ls.MaChuong, 
                      c => c.MaChuong, 
                      (ls, c) => new HistoryWithChapterName
                      {
                          MaLichSu = ls.MaLichSu,
                          MaNguoiDung = ls.MaNguoiDung,
                          MaChuong = ls.MaChuong,
                          TenChuong = c.TenChuong,
                          Diem = ls.Diem,
                          SoCauDung = ls.SoCauDung,
                          TongSoCau = ls.TongSoCau,
                          DanhSachDapAnChon = ls.DanhSachDapAnChon,
                          NgayLam = ls.NgayLam
                      })
                .FirstOrDefaultAsync();

            if (item == null) return NotFound("Lịch sử làm bài không tồn tại.");
            return Ok(item);
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetByUser(int userId)
        {
            var list = await _context.LichSuLamBais
                .Where(ls => ls.MaNguoiDung == userId)
                .Join(_context.Chuongs, 
                      ls => ls.MaChuong, 
                      c => c.MaChuong, 
                      (ls, c) => new HistoryWithChapterName
                      {
                          MaLichSu = ls.MaLichSu,
                          MaNguoiDung = ls.MaNguoiDung,
                          MaChuong = ls.MaChuong,
                          TenChuong = c.TenChuong,
                          Diem = ls.Diem,
                          SoCauDung = ls.SoCauDung,
                          TongSoCau = ls.TongSoCau,
                          DanhSachDapAnChon = ls.DanhSachDapAnChon,
                          NgayLam = ls.NgayLam
                      })
                .OrderByDescending(h => h.NgayLam)
                .ToListAsync();

            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] LichSuLamBai item)
        {
            if (item == null)
            {
                return BadRequest("Dữ liệu không hợp lệ.");
            }

            item.NgayLam = DateTime.UtcNow;
            _context.LichSuLamBais.Add(item);
            await _context.SaveChangesAsync();
            return Ok(item.MaLichSu);
        }
    }

    public class HistoryWithChapterName
    {
        public int MaLichSu { get; set; }
        public int MaNguoiDung { get; set; }
        public int MaChuong { get; set; }
        public string? TenChuong { get; set; }
        public double Diem { get; set; }
        public int SoCauDung { get; set; }
        public int TongSoCau { get; set; }
        public string? DanhSachDapAnChon { get; set; }
        public DateTime? NgayLam { get; set; }
    }
}
