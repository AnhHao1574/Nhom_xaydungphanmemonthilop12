using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoApi.Data;
using TaoApi.Models;

namespace TaoApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChuongController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ChuongController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _context.Chuongs.OrderByDescending(c => c.MaChuong).ToListAsync();
            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var item = await _context.Chuongs.FindAsync(id);
            if (item == null) return NotFound("Đề thi/Chương không tồn tại.");
            return Ok(item);
        }

        [HttpGet("monhoc/{monHocId}")]
        public async Task<IActionResult> GetByMonHoc(int monHocId)
        {
            var list = await _context.Chuongs
                .Where(c => c.MaMon == monHocId)
                .OrderBy(c => c.SoThuTu)
                .ToListAsync();
            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Chuong item)
        {
            if (item == null || string.IsNullOrWhiteSpace(item.TenChuong))
            {
                return BadRequest("Tên đề thi/Chương không được để trống.");
            }

            int soThuTu = item.SoThuTu ?? 0;
            if (soThuTu <= 0)
            {
                var maxStt = await _context.Chuongs
                    .Where(c => c.MaMon == item.MaMon)
                    .MaxAsync(c => (int?)c.SoThuTu) ?? 0;
                soThuTu = maxStt + 1;
            }
            item.SoThuTu = soThuTu;

            _context.Chuongs.Add(item);
            await _context.SaveChangesAsync();
            return Ok(item.MaChuong); // Trả về ID của chương mới
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Chuong item)
        {
            if (item == null || string.IsNullOrWhiteSpace(item.TenChuong))
            {
                return BadRequest("Thông tin không hợp lệ.");
            }

            var dbItem = await _context.Chuongs.FindAsync(id);
            if (dbItem == null) return NotFound("Đề thi/Chương không tồn tại.");

            dbItem.MaMon = item.MaMon;
            dbItem.TenChuong = item.TenChuong;
            if (item.SoThuTu != null)
            {
                dbItem.SoThuTu = item.SoThuTu;
            }

            await _context.SaveChangesAsync();
            return Ok(1);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var dbItem = await _context.Chuongs.FindAsync(id);
            if (dbItem == null) return NotFound("Đề thi/Chương không tồn tại.");

            // EF Core will handle Cascade deletes if configured, or we delete children manually:
            var questions = await _context.CauHois.Where(q => q.MaChuong == id).ToListAsync();
            _context.CauHois.RemoveRange(questions);

            var histories = await _context.LichSuLamBais.Where(h => h.MaChuong == id).ToListAsync();
            _context.LichSuLamBais.RemoveRange(histories);

            _context.Chuongs.Remove(dbItem);
            await _context.SaveChangesAsync();
            return Ok(1);
        }
    }
}
