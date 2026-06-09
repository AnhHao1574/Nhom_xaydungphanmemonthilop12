using System.Text.Json.Serialization;

namespace TaoApi.Models
{
    public class LichSuLamBai
    {
        public int MaLichSu { get; set; }
        public int MaNguoiDung { get; set; }
        public int MaChuong { get; set; }
        public double Diem { get; set; }
        public int SoCauDung { get; set; }
        public int TongSoCau { get; set; }
        public string DanhSachDapAnChon { get; set; } = string.Empty;
        public DateTime? NgayLam { get; set; } = DateTime.UtcNow;

        [JsonIgnore]
        public NguoiDung? NguoiDung { get; set; }
        
        [JsonIgnore]
        public Chuong? Chuong { get; set; }
    }
}
