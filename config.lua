Config              = {}
Config.ESX = 'esx:getMiSharedCheoObject'
Config.DrawDistance = 100.0
Config.CopsRequired = 0   -- SỐ CẢNH SÁT ĐỂ CÓ THỂ HỘ TỐNG
Config.BlipUpdateTime = 3000   -- THỜI GIAN CẬP NHẬT VỊ TRÍ XE HỘ TỐNG
Config.CooldownMinutes = 10   -- THỜI GIAN CHỜ
Config.Locale = 'vn'   -- NGÔN NGỮ
Config.job = 'police'  -- JOB CÓ THỂ LẤY XE HỘ TỐNG

-- BẬT KHI BẠN MUỐN GIỚI HẠN JOB CÓ THỂ HÌN THẤY ĐOÀN XE HỘ TỐNG TRÊN GPS

Config.private = false

-- CÁC JOB CÓ THỂ NHÌN THẤY ĐOÀN XE HỘ TỐNG KHI #  Config.private = true  #

Config.job1 = 'gang1'
Config.job2 = 'gang2'
Config.job3 = 'gang3'
Config.job4 = 'gang4'
Config.job5 = 'gang5'

-- ĐIỂM LẤY XE HỘ TỐNG

Config.layxe = {			
	diemxe = {
		Pos   = {x = 503.94	, y = -3122.67, z = 5.07},
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Color = {r = 0, g = 128, b = 255},
		Type  = 27,
		Colour    = 3, --BLIP
		Id        = 426, --BLIP
	},
}

-- ĐIỂM XE HỘ TỐNG XUẤT HIỆN

Config.XeXuatHien = {
      Pos   = {x = 489.1, y = -3144.42, z = 6.07, alpha = 356.12}, --alpha is the orientation of the car
      Size  = {x = 3.0, y = 3.0, z = 1.0},
      Type  = -1,
}

-- ĐIỂM GIAO XE HỘ TỐNG

Config.GiaoXe = {
	xe = {
		Pos      = {x = 2130.68, y = 4781.32, z = 40.6},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 0, g = 128, b = 255},
		Type  = 27,
		Payment  = 1800000,
		Cars = {'rhino','apc','rhino','apc','rhino'}   -- LOẠI XE DÙNG ĐỂ HỘ TỐNG
	},
}

-- SỬ DỤNG HÒM THÍNH CHỨA SÚNG / ITEM
-- CHỈ ĐƯỢC BẬT 1 TRONG 2

Config.homsung = false    -- Thính súng
Config.homitem = true	  -- Thính item

-- ĐỒ CHỨA TRONG THÍNH VÀ SỐ LƯỢNG CÓ ĐƯỢC

Config.homthinh1 = 'iron'   --Tên đồ trong hòm
Config.soluong1 = 20		--Số lượng

Config.homthinh2 = 'iron'   --Tên đồ trong hòm
Config.soluong2 = 30		--Số lượng

Config.homthinh3 = 'iron'   --Tên đồ trong hòm
Config.soluong3 = 40		--Số lượng

Config.homthinh4 = 'iron'   --Tên đồ trong hòm
Config.soluong4 = 50		--Số lượng