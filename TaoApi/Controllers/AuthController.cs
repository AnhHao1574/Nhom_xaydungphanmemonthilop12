using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaoApi.Data;
using TaoApi.Models;

namespace TaoApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.TenDangNhap) || string.IsNullOrWhiteSpace(request.MatKhau))
            {
                return BadRequest("Tên đăng nhập và mật khẩu không được trống.");
            }

            var user = await _context.NguoiDungs
                .FirstOrDefaultAsync(u => u.TenDangNhap == request.TenDangNhap.Trim() && u.MatKhau == request.MatKhau);

            if (user == null)
            {
                return Unauthorized("Tài khoản hoặc mật khẩu không chính xác.");
            }

            return Ok(user);
        }

        [HttpGet("check-username")]
        public async Task<IActionResult> CheckUsername([FromQuery] string tenDangNhap)
        {
            if (string.IsNullOrWhiteSpace(tenDangNhap))
            {
                return BadRequest("Tên đăng nhập không được trống.");
            }

            var exists = await _context.NguoiDungs
                .AnyAsync(u => EF.Functions.Like(u.TenDangNhap, tenDangNhap.Trim()));

            return Ok(exists);
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] NguoiDung user)
        {
            if (user == null || string.IsNullOrWhiteSpace(user.TenDangNhap) || string.IsNullOrWhiteSpace(user.MatKhau))
            {
                return BadRequest("Thông tin đăng ký không hợp lệ.");
            }

            var exists = await _context.NguoiDungs.AnyAsync(u => u.TenDangNhap == user.TenDangNhap.Trim());
            if (exists)
            {
                return Conflict("Tên đăng nhập đã tồn tại.");
            }

            user.TenDangNhap = user.TenDangNhap.Trim();
            user.NgayTao = DateTime.UtcNow;
            user.MaVaiTro = user.MaVaiTro == 0 ? 3 : user.MaVaiTro; // Mặc định là Học sinh (3)

            _context.NguoiDungs.Add(user);
            await _context.SaveChangesAsync();

            return Ok(user);
        }
    }

    public class LoginRequest
    {
        public string TenDangNhap { get; set; } = string.Empty;
        public string MatKhau { get; set; } = string.Empty;
    }
}
