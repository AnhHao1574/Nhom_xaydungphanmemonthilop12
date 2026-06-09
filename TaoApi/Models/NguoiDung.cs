using System.Text.Json.Serialization;

namespace TaoApi.Models
{
    public class NguoiDung
    {
        public int MaNguoiDung { get; set; }
        public string TenDangNhap { get; set; } = string.Empty;
        public string MatKhau { get; set; } = string.Empty;
        public string? HoTen { get; set; }
        public string? Email { get; set; }
        public int MaVaiTro { get; set; }
        public DateTime? NgayTao { get; set; } = DateTime.UtcNow;

        [JsonIgnore]
        public VaiTro? VaiTro { get; set; }
    }
}
