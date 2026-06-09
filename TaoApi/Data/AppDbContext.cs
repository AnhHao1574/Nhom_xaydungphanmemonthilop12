using Microsoft.EntityFrameworkCore;
using TaoApi.Models;

namespace TaoApi.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<VaiTro> VaiTros { get; set; }
        public DbSet<NguoiDung> NguoiDungs { get; set; }
        public DbSet<MonHoc> MonHocs { get; set; }
        public DbSet<Chuong> Chuongs { get; set; }
        public DbSet<CauHoi> CauHois { get; set; }
        public DbSet<LichSuLamBai> LichSuLamBais { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<VaiTro>(entity =>
            {
                entity.ToTable("VaiTro");
                entity.HasKey(e => e.MaVaiTro);
                entity.Property(e => e.MaVaiTro).ValueGeneratedNever();
            });

            modelBuilder.Entity<NguoiDung>(entity =>
            {
                entity.ToTable("NguoiDung");
                entity.HasKey(e => e.MaNguoiDung);
                entity.HasIndex(e => e.TenDangNhap).IsUnique();
                entity.HasOne(d => d.VaiTro)
                    .WithMany()
                    .HasForeignKey(d => d.MaVaiTro)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<MonHoc>(entity =>
            {
                entity.ToTable("MonHoc");
                entity.HasKey(e => e.MaMon);
            });

            modelBuilder.Entity<Chuong>(entity =>
            {
                entity.ToTable("Chuong");
                entity.HasKey(e => e.MaChuong);
                entity.HasOne(d => d.MonHoc)
                    .WithMany(p => p.Chuongs)
                    .HasForeignKey(d => d.MaMon)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<CauHoi>(entity =>
            {
                entity.ToTable("CauHoi");
                entity.HasKey(e => e.MaCauHoi);
                entity.HasOne(d => d.Chuong)
                    .WithMany(p => p.CauHois)
                    .HasForeignKey(d => d.MaChuong)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<LichSuLamBai>(entity =>
            {
                entity.ToTable("LichSuLamBai");
                entity.HasKey(e => e.MaLichSu);
                entity.HasOne(d => d.NguoiDung)
                    .WithMany()
                    .HasForeignKey(d => d.MaNguoiDung)
                    .OnDelete(DeleteBehavior.Cascade);
                entity.HasOne(d => d.Chuong)
                    .WithMany()
                    .HasForeignKey(d => d.MaChuong)
                    .OnDelete(DeleteBehavior.Restrict);
            });
        }
    }
}
