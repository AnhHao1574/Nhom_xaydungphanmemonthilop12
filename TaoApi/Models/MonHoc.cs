using System.Text.Json.Serialization;

namespace TaoApi.Models
{
    public class MonHoc
    {
        public int MaMon { get; set; }
        public string TenMon { get; set; } = string.Empty;
        public string? MoTa { get; set; }

        [JsonIgnore]
        public ICollection<Chuong> Chuongs { get; set; } = new List<Chuong>();
    }
}
