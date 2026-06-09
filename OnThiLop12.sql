CREATE DATABASE OnThiLop12;
GO
USE OnThiLop12;
GO

-- Xóa bảng theo thứ tự ngược để tránh lỗi khóa ngoại (Foreign Key)
IF OBJECT_ID('ThongBao', 'U') IS NOT NULL DROP TABLE ThongBao;
IF OBJECT_ID('LichSuLamBai', 'U') IS NOT NULL DROP TABLE LichSuLamBai;
IF OBJECT_ID('CauHoi', 'U') IS NOT NULL DROP TABLE CauHoi;
IF OBJECT_ID('Chuong', 'U') IS NOT NULL DROP TABLE Chuong; 
IF OBJECT_ID('MonHoc', 'U') IS NOT NULL DROP TABLE MonHoc;
IF OBJECT_ID('NguoiDung', 'U') IS NOT NULL DROP TABLE NguoiDung;
IF OBJECT_ID('VaiTro', 'U') IS NOT NULL DROP TABLE VaiTro;

-- ==========================================================
-- KHỞI TẠO CẤU TRÚC BẢNG TRÊN SQL SERVER
-- ==========================================================

CREATE TABLE VaiTro (
    MaVaiTro INT PRIMARY KEY IDENTITY(1,1),
    TenVaiTro NVARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE NguoiDung (
    MaNguoiDung INT PRIMARY KEY IDENTITY(1,1),
    TenDangNhap NVARCHAR(255) NOT NULL UNIQUE,
    MatKhau NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(255),
    Email NVARCHAR(255),
    MaVaiTro INT NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaVaiTro) REFERENCES VaiTro(MaVaiTro)
);

CREATE TABLE MonHoc (
    MaMon INT PRIMARY KEY IDENTITY(1,1),
    TenMon NVARCHAR(255) UNIQUE NOT NULL,
    MoTa NVARCHAR(MAX)
);

CREATE TABLE Chuong (
    MaChuong INT PRIMARY KEY IDENTITY(1,1),
    MaMon INT NOT NULL,
    TenChuong NVARCHAR(MAX) NOT NULL,
    SoThuTu INT DEFAULT 1,
    FOREIGN KEY (MaMon) REFERENCES MonHoc(MaMon)
);

CREATE TABLE CauHoi (
    MaCauHoi INT PRIMARY KEY IDENTITY(1,1),
    MaChuong INT NOT NULL,
    NoiDung NVARCHAR(MAX) NOT NULL,
    CauA NVARCHAR(MAX) NOT NULL,
    CauB NVARCHAR(MAX) NOT NULL,
    CauC NVARCHAR(MAX) NOT NULL,
    CauD NVARCHAR(MAX) NOT NULL,
    DapAnDung NVARCHAR(1) NOT NULL CHECK (DapAnDung IN ('A','B','C','D')),
    LoiGiai NVARCHAR(MAX),
    NgayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaChuong) REFERENCES Chuong(MaChuong)
);

CREATE TABLE LichSuLamBai (
    MaLichSu INT PRIMARY KEY IDENTITY(1,1),
    MaNguoiDung INT NOT NULL,
    MaChuong INT NOT NULL,
    Diem FLOAT NOT NULL,
    SoCauDung INT NOT NULL,
    TongSoCau INT NOT NULL,
    DanhSachDapAnChon NVARCHAR(MAX) NOT NULL,
    NgayLam DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung) ON DELETE CASCADE,
    FOREIGN KEY (MaChuong) REFERENCES Chuong(MaChuong) ON DELETE CASCADE
);

CREATE TABLE ThongBao (
    MaThongBao INT PRIMARY KEY IDENTITY(1,1),
    TieuDe NVARCHAR(255),
    NoiDung NVARCHAR(MAX),
    NgayTao DATETIME DEFAULT GETDATE()
);

USE OnThiLop12;
GO

-- 1. Xem danh sách câu hỏi đã cào
SELECT TOP 50 * FROM CauHoi;

-- 2. Xem danh sách đề thi/chương liên quan
SELECT * FROM LichSuLamBai;

-- 3. Xem danh sách môn học
SELECT * FROM NguoiDung;