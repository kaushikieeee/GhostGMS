# 👻 GhostGMS Module  

## 📌 Overview  
**GhostGMS** is a feature-packed **Magisk module** designed to help you **disable battery-draining Google services (GMS)** while applying **safe, stability-focused system tweaks**—like reducing logging, optimizing kernel flags, and smoothing out animations.  

Now with a slick **WebUI**, you can manage it all with a few clicks—**no terminal commands**, no guesswork.

> 💡 **WebUI originally forked from Encore Optimizations**  
> 💻 Maintained by [Kaushik (Veloxineology Labs)](https://github.com/veloxineology)

---

## 🚀 Features  

### ✅ GMS Service Control  
- Type your own GMS services or use a **predefined safe list**.  
- Apply toggles and changes in the **WebUI** (yup, it's all point & click).  

### 🌐 WebUI (Click, Toggle, Done ✅)  
- Accessible via browser on the same Wi-Fi  
- Real-time system state display  
- Changes persist thanks to `localStorage`  
- Super clean interface to toggle GMS, kernel, logging, and animation tweaks  

### ⚡ Performance & Battery Optimizations  
- ☠️ Disable verbose logging (SurfaceFlinger, HWC, gamed, Wi-Fi debug, etc.)  
- 🧠 Kernel-level tuning for smoother behavior  
- 💤 Less background GMS chatter = more battery and less lag  
- 🎞️ Animation tweaks for instant responsiveness  

### 🛡️ Built for Stability  
- Only **safe tweaks retained**  
- Aggressive/bootloop-prone settings were 🔥 yeeted into the void  
- Works out of the box on **ANY ROM** (including **Nothing OS**, **PixelOS**, **Lineage**, etc.)

---

## 📦 How to Flash (3-step speedrun)

> ⚠️ Magisk + Zygisk required

1. **Download & flash** the module via **Magisk Manager**  
2. **Reboot your phone**  
3. Access the WebUI:

   - 🧙‍♂️ **KernelSU Users**: Automatically opens after install.  
   - 🧪 **Magisk Users**: Use this standalone WebUI tool:  
     👉 [`KsuWebUIStandalone`](https://github.com/5ec1cff/KsuWebUIStandalone)

4. Toggle your desired settings  
5. Hit **"Apply"** and then **Reboot** again

> 📍 You’ll find the **WebUI link printed in your Magisk log** after installation!

---

## 🔄 Compatibility  

| ROM / OS              | Compatibility ✅ |
|------------------------|------------------|
| Stock ROMs            | ✅ Works like a charm  
| Nothing OS            | ✅ No bugs, full support  
| NothingMuch ROM       | ✅ Fully supported  
| Pixel Experience      | ✅ 100%  
| LineageOS / Custom    | ✅ Absolutely  

---

## 📂 Logs and Support  

- Log Location:  
  ```bash
  /sdcard/gmscontrol_log
