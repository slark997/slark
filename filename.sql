CREATE DATABASE QuanLyBanHang
GO

USE QuanLyBanHang
GO

-- Tạo bảng KHACHHANG
CREATE TABLE KHACHHANG
(
	MAKH CHAR(4),
	HOTEN VARCHAR(40),
	DCHI VARCHAR(50),
	SODT VARCHAR(20),
	NGSINH SMALLDATETIME,
	NGDK SMALLDATETIME,
	DOANHSO MONEY,
	CONSTRAINT PK_KHACHHANG PRIMARY KEY (MAKH)
)

-- Tạo bảng NHANVIEN
CREATE TABLE NHANVIEN
(
	MANV CHAR(4),
	HOTEN VARCHAR(40),
	SODT VARCHAR(20),
	NGVL SMALLDATETIME
	CONSTRAINT PK_NHANVIEN PRIMARY KEY (MANV)
)

-- Tạo bảng SANPHAM
CREATE TABLE SANPHAM
(
	MASP CHAR(4),
	TENSP VARCHAR(40),
	DVT VARCHAR(20),
	NUOCSX VARCHAR(40),
	GIA MONEY
	CONSTRAINT PK_SANPHAM PRIMARY KEY (MASP)
)

-- Tạo bảng HOADON
CREATE TABLE HOADON
(
	SOHD INT,
	NGHD SMALLDATETIME,
	MAKH CHAR(4),
	MANV CHAR(4),
	TRIGIA MONEY
	CONSTRAINT PK_HOADON PRIMARY KEY (SOHD)
)

-- Tạo bảng CTHD (Chi tiết hóa đơn)
CREATE TABLE CTHD
(
	SOHD INT,
	MASP CHAR(4),
	SL INT,
	CONSTRAINT PK_CTHD PRIMARY KEY (SOHD, MASP),
)

SET DATEFORMAT DMY
CREATE TRIGGER trg_ins_udt_NgHD ON HoaDon
FOR Insert, Update
AS
BEGIN
	IF (EXISTS (SELECT * FROM KhachHang, inserted 
				WHERE KhachHang.MaKH = inserted.MaKH 
				AND KhachHang.NgDK > inserted.NgHD))
	BEGIN
		PRINT 'Error: NgHD phai >= NgDK'
		ROLLBACK TRANSACTION
	END
END

-- Trigger: sửa NgDK của KhachHang
CREATE TRIGGER trg_upd_NgDK ON KhachHang
FOR Update
AS
BEGIN
	IF (EXISTS (SELECT * FROM HoaDon, inserted
				WHERE HoaDon.MaKH = inserted.MAKH
				AND HoaDon.NgHD < inserted.NgDK))
	BEGIN
		PRINT 'Error: NgHD phai >= NgDK'
		ROLLBACK TRANSACTION
	END
END

-- I.12 Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.

-- Trigger: thêm và sửa NgHD của HoaDon
CREATE TRIGGER trg_ins_udt_NgBH ON HoaDon
FOR Insert, Update
AS
BEGIN
	IF (EXISTS (SELECT * FROM NhanVien, inserted 
				WHERE NhanVien.MaNV = inserted.MaKH 
				AND NhanVien.NgVL > inserted.NgHD))
	BEGIN
		PRINT 'Error: NgHD phai >= NgVL'
		ROLLBACK TRANSACTION
	END
END

-- Trigger: sửa NGVL của NhanVien
CREATE TRIGGER trg_upd_NgVL ON NhanVien
FOR Update
AS
BEGIN
	IF (EXISTS (SELECT * FROM HoaDon, inserted
				WHERE HoaDon.MaNV = inserted.MANV
				AND HoaDon.NgHD < inserted.NgVL))
	BEGIN
		PRINT 'Error: NgHD phai >= NgDK'
		ROLLBACK TRANSACTION
	END
END

-- I.13 Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn

-- Trigger: Xóa một CTHD
CREATE TRIGGER trg_del_CTHD ON CTHD
FOR Delete
AS
BEGIN
	IF ((SELECT COUNT(*) FROM deleted WHERE SoHD = deleted.SoHD)
		= (SELECT COUNT(*) FROM HoaDon, deleted WHERE deleted.SoHD = HoaDon.SoHD))
	BEGIN
		PRINT 'Error: Moi hoa don phai co it nhat 1 CTHD'
		ROLLBACK TRANSACTION
	END
END

-- I.15 Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.

-- Trigger: Update DoanhSo của KhachHang
CREATE TRIGGER trg_upd_DoanhSo ON KhachHang
FOR Update
AS
BEGIN
	DECLARE @TongTriGia MONEY, @DoanhSo MONEY

	SELECT @TongTriGia = SUM(TriGia)
	FROM HoaDon, inserted
	WHERE HoaDon.MaKH = inserted.MaKH

	SELECT @DoanhSo = DoanhSo FROM inserted

	IF (@DoanhSo <> @TongTriGia)
	BEGIN
		PRINT('Doanh so cua mot khach hang la tong tri gia cac hoa don khach hang thanh vien do da mua')
		ROLLBACK TRANSACTION
	END
END
