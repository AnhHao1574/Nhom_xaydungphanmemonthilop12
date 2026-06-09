using System.Text.Json.Serialization;

namespace TaoApi.Models
{
    public class CauHoi
    {
        public int MaCauHoi { get; set; }
        public int MaChuong { get; set; }
        public string NoiDung { get; set; } = string.Empty;
        public string CauA { get; set; } = string.Empty;
        public string CauB { get; set; } = string.Empty;
        public string CauC { get; set; } = string.Empty;
        public string CauD { get; set; } = string.Empty;
        public string DapAnDung { get; set; } = string.Empty;
        public string? LoiGiai { get; set; }
        public DateTime? NgayTao { get; set; } = DateTime.UtcNow;

        [JsonIgnore]
        public Chuong? Chuong { get; set; }
    }
}
