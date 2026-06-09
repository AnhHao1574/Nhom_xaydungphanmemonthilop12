using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoApi.Data;
using TaoApi.Models;

namespace TaoApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CauHoiController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CauHoiController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _context.CauHois.OrderByDescending(q => q.MaCauHoi).ToListAsync();
            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var item = await _context.CauHois.FindAsync(id);
            if (item == null) return NotFound("Câu hỏi không tồn tại.");
            return Ok(item);
        }

        [HttpGet("dethi/{deThiId}")]
        public async Task<IActionResult> GetByDeThi(int deThiId)
        {
            var list = await _context.CauHois
                .Where(q => q.MaChuong == deThiId)
                .OrderBy(q => q.MaCauHoi)
                .ToListAsync();
            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CauHoi item)
        {
            if (item == null || string.IsNullOrWhiteSpace(item.NoiDung))
            {
                return BadRequest("Nội dung câu hỏi không được trống.");
            }

            item.NgayTao = DateTime.UtcNow;
            _context.CauHois.Add(item);
            await _context.SaveChangesAsync();
            return Ok(item.MaCauHoi);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CauHoi item)
        {
            if (item == null || string.IsNullOrWhiteSpace(item.NoiDung))
            {
                return BadRequest("Thông tin câu hỏi không hợp lệ.");
            }

            var dbItem = await _context.CauHois.FindAsync(id);
            if (dbItem == null) return NotFound("Câu hỏi không tồn tại.");

            dbItem.MaChuong = item.MaChuong;
            dbItem.NoiDung = item.NoiDung;
            dbItem.CauA = item.CauA;
            dbItem.CauB = item.CauB;
            dbItem.CauC = item.CauC;
            dbItem.CauD = item.CauD;
            dbItem.DapAnDung = item.DapAnDung;
            dbItem.LoiGiai = item.LoiGiai;

            await _context.SaveChangesAsync();
            return Ok(1);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var dbItem = await _context.CauHois.FindAsync(id);
            if (dbItem == null) return NotFound("Câu hỏi không tồn tại.");

            _context.CauHois.Remove(dbItem);
            await _context.SaveChangesAsync();
            return Ok(1);
        }
    }
}
