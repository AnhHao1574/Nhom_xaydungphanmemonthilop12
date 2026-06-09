using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoApi.Data;
using TaoApi.Models;

namespace TaoApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MonHocController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MonHocController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _context.MonHocs.OrderBy(m => m.MaMon).ToListAsync();
            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var item = await _context.MonHocs.FindAsync(id);
            if (item == null) return NotFound("Môn học không tồn tại.");
            return Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] MonHoc item)
        {
            if (item == null || string.IsNullOrWhiteSpace(item.TenMon))
            {
                return BadRequest("Tên môn học không được để trống.");
            }

            _context.MonHocs.Add(item);
            await _context.SaveChangesAsync();
            return Ok(item.MaMon); // Trả về ID của môn học mới tạo giống SQLite register/insert
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] MonHoc item)
        {
            if (item == null || string.IsNullOrWhiteSpace(item.TenMon))
            {
                return BadRequest("Thông tin không hợp lệ.");
            }

            var dbItem = await _context.MonHocs.FindAsync(id);
            if (dbItem == null) return NotFound("Môn học không tồn tại.");

            dbItem.TenMon = item.TenMon;
            dbItem.MoTa = item.MoTa;

            await _context.SaveChangesAsync();
            return Ok(1); // Số dòng thay đổi (thành công trả về >= 1)
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var dbItem = await _context.MonHocs.FindAsync(id);
            if (dbItem == null) return NotFound("Môn học không tồn tại.");

            _context.MonHocs.Remove(dbItem);
            await _context.SaveChangesAsync();
            return Ok(1); // Trả về số lượng dòng bị xóa thành công
        }
    }
}
