-- SQL Server Database Schema Creation Script
-- Create Database (Optional, uncomment if needed)
-- CREATE DATABASE OnThiLop12;
-- GO
-- USE OnThiLop12;
-- GO

-- 1. Create table VaiTro
IF OBJECT_ID('NguoiDung', 'U') IS NOT NULL DROP TABLE NguoiDung;
IF OBJECT_ID('VaiTro', 'U') IS NOT NULL DROP TABLE VaiTro;
CREATE TABLE VaiTro (
    MaVaiTro INT PRIMARY KEY,
    TenVaiTro NVARCHAR(50) NOT NULL
);

-- 2. Create table NguoiDung
CREATE TABLE NguoiDung (
    MaNguoiDung INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap NVARCHAR(100) NOT NULL UNIQUE,
    MatKhau NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(255) NULL,
    Email NVARCHAR(255) NULL,
    MaVaiTro INT NOT NULL,
    NgayTao DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_NguoiDung_VaiTro FOREIGN KEY (MaVaiTro) REFERENCES VaiTro(MaVaiTro)
);

-- 3. Create table MonHoc
IF OBJECT_ID('LichSuLamBai', 'U') IS NOT NULL DROP TABLE LichSuLamBai;
IF OBJECT_ID('CauHoi', 'U') IS NOT NULL DROP TABLE CauHoi;
IF OBJECT_ID('Chuong', 'U') IS NOT NULL DROP TABLE Chuong;
IF OBJECT_ID('MonHoc', 'U') IS NOT NULL DROP TABLE MonHoc;

CREATE TABLE MonHoc (
    MaMon INT IDENTITY(1,1) PRIMARY KEY,
    TenMon NVARCHAR(255) NOT NULL,
    MoTa NVARCHAR(MAX) NULL
);

-- 4. Create table Chuong (DeThi)
CREATE TABLE Chuong (
    MaChuong INT IDENTITY(1,1) PRIMARY KEY,
    MaMon INT NOT NULL,
    TenChuong NVARCHAR(255) NOT NULL,
    SoThuTu INT NULL,
    CONSTRAINT FK_Chuong_MonHoc FOREIGN KEY (MaMon) REFERENCES MonHoc(MaMon) ON DELETE CASCADE
);

-- 5. Create table CauHoi
CREATE TABLE CauHoi (
    MaCauHoi INT IDENTITY(1,1) PRIMARY KEY,
    MaChuong INT NOT NULL,
    NoiDung NVARCHAR(MAX) NOT NULL,
    CauA NVARCHAR(MAX) NOT NULL,
    CauB NVARCHAR(MAX) NOT NULL,
    CauC NVARCHAR(MAX) NOT NULL,
    CauD NVARCHAR(MAX) NOT NULL,
    DapAnDung NVARCHAR(10) NOT NULL,
    LoiGiai NVARCHAR(MAX) NULL,
    NgayTao DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_CauHoi_Chuong FOREIGN KEY (MaChuong) REFERENCES Chuong(MaChuong) ON DELETE CASCADE
);

-- 6. Create table LichSuLamBai (KetQua)
CREATE TABLE LichSuLamBai (
    MaLichSu INT IDENTITY(1,1) PRIMARY KEY,
    MaNguoiDung INT NOT NULL,
    MaChuong INT NOT NULL,
    Diem FLOAT NOT NULL,
    SoCauDung INT NOT NULL,
    TongSoCau INT NOT NULL,
    DanhSachDapAnChon NVARCHAR(MAX) NOT NULL,
    NgayLam DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_LichSuLamBai_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung) ON DELETE CASCADE,
    CONSTRAINT FK_LichSuLamBai_Chuong FOREIGN KEY (MaChuong) REFERENCES Chuong(MaChuong)
);
