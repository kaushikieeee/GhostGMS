# GhostGMS Module  

## 📌 Overview  
Ghost GMS is a **Magisk module** designed to **optimize device performance** by allowing users to **disable or enable specific Google services (GMS)** while also applying **kernel, animation, and logging tweaks** to improve efficiency.  

The module now includes a **WebUI** for an **easy-to-use interface** where users can **toggle settings** and **apply optimizations seamlessly**.  

> **Note:**  
> Ghost GMS is compatible with most **stock ROMs**. However, on **Nothing OS** and **NothingMuch ROM**, users may see an **error stating that GMS was unable to disable**—but in reality, it has been **successfully disabled**.

> UI forked from Encore Optimizations.

---

## 🚀 Features  

### ✅ **Custom GMS Service Control**  
- Users can **manually type** the GMS services they want to **enable/disable**.  
- Alternatively, users can **use the predefined list** included in the module.  
- Changes take effect after pressing the **Apply button** in the WebUI.  

### 🌐 **WebUI for Easy Configuration**  
- **Simple toggles** for enabling/disabling different optimizations.  
- **Apply changes instantly** with the **Apply button**.  
- **Logs system status** and displays whether **GMS services** are currently **active**.  

### ⚡ **Performance Optimizations**  
- **GMS Optimizations**:  
  - Reduce background processes and restrict unnecessary services.  
- **Kernel & System Tweaks**:  
  - Optimize **animation speeds**.  
  - Disable **unnecessary logging** to reduce resource usage.  
  - Improve **power efficiency** and reduce **CPU wakeups**.  

### 📊 **Logging and Debugging Panel**  
- **View system logs** directly from the **WebUI**.  
- **Check GMS status** and overall **system optimizations** in real time.  

---

## 🛠️ How to Use  

1. **Install the module** via **Magisk/Zygisk**.  
2. **Reboot your device** after installation.  
3. **Open the WebUI** *(instructions provided in the module output after installation)*.  
4. **Customize GMS optimizations**:  
   - Enter specific **GMS services** to disable/enable **OR** use the built-in selection.  
   - Toggle other **performance tweaks** (kernel, animation, logging optimizations).  
5. **Press the Apply button** to finalize changes.  
6. **Reboot again** to fully apply optimizations.  

---

## 🔄 Compatibility  
✅ **Works on most stock ROMs**.  

⚠️ **Nothing OS & NothingMuch ROM Users**:  
- You may see an **error stating that GMS could not be disabled**.  
- However, **GMS is actually disabled despite the error message**.  

---

## 📜 Notes  
- If you experience **issues**, check the **logs in the WebUI** for details.  
- Logs are stored in:  
  ```bash
  /sdcard/gmscontrol_log
