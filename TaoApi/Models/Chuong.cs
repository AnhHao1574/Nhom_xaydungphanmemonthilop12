using System.Text.Json.Serialization;

namespace TaoApi.Models
{
    public class Chuong
    {
        public int MaChuong { get; set; }
        public int MaMon { get; set; }
        public string TenChuong { get; set; } = string.Empty;
        public int? SoThuTu { get; set; }
        
        [JsonIgnore]
        public MonHoc? MonHoc { get; set; }
        
        [JsonIgnore]
        public ICollection<CauHoi> CauHois { get; set; } = new List<CauHoi>();
    }
}
