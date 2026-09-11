# ⚡ Arsenal Aim Lock + ESP Script

**Lightweight Roblox Script dengan UI Modern**

## 🎯 Fitur Utama

✨ **Aim Lock**
- Target selection (Head, Body, Hand)
- Smooth camera movement
- Distance-based targeting

👁️ **ESP**
- Box visualization
- Player name display
- Distance-based rendering
- Toggle on/off

🎨 **User Interface**
- Modern SkyZen design
- Draggable UI
- Compact size (350x280)
- Minimal resource usage

⌨️ **Keyboard Shortcuts**
- **E** = Toggle Aim Lock
- **R** = Toggle ESP
- **F** = Toggle UI

## 📥 Cara Menggunakan

### Copy & Paste ke Executor:
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/akunmedan722-pixel/arsenal-esp-aimlock/main/script.lua'))()
```

### Atau Manual:
1. Copy isi file `script.lua`
2. Buka Roblox Executor (Synapse X, Krnl, JJSploit, dll)
3. Paste script
4. Klik Execute

## ⚙️ Pengaturan

Edit bagian ini di dalam script untuk customize:

```lua
local Config = {
    AimLockEnabled = false,      -- Status awal Aim Lock
    ESPEnabled = true,           -- Status awal ESP
    TargetPart = "Head",         -- Target default (Head, Torso, RightHand)
    MaxDistance = 500,           -- Jarak maksimal deteksi
    Smoothness = 0.1,            -- Kelancaran aim lock (0-1)
}
```

## 🎮 Kontrol

| Tombol | Fungsi |
|--------|--------|
| E | Aktif/Matikan Aim Lock |
| R | Aktif/Matikan ESP |
| F | Buka/Tutup UI |
| Drag Header | Pindah UI |

## 📊 Performa

- File Size: ~16KB
- ESP Update: Setiap 0.5 detik (optimized)
- Lightweight & Super cepat
- Minimal resource usage

## 🎨 Design

- **Color Scheme**: Cyberpunk SkyZen Style
- **UI Size**: 350x280px (Mobile Optimized)
- **Font**: Gotham Bold
- **Theme**: Dark background dengan accent biru

## ⚠️ Disclaimer

Script ini hanya untuk educational purpose. Gunakan dengan bijak dan sesuai dengan Terms of Service Roblox.

## 📝 Lisensi

Free to use dan modify.

---

**Created by:** akunmedan722-pixel  
**Repository:** [arsenal-esp-aimlock](https://github.com/akunmedan722-pixel/arsenal-esp-aimlock)