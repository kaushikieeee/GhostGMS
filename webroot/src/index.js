/**
 * GhostGMS Web Interface
 * Main JavaScript file for the web interface
 */

// Utility function to execute commands with KSU
async function executeCommand(command, params = {}) {
    return new Promise((resolve, reject) => {
        const callbackName = `exec_callback_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
        
        // Test environment simulation
        if (window.location.pathname.includes('test.html')) {
            console.log("[TEST] Simulating command:", command);
            // Simulate command execution with test data
            setTimeout(() => {
                resolve({
                    errno: 0,
                    stdout: "Test output",
                    stderr: ""
                });
            }, 500);
            return;
        }

        // Real device execution with KSU
        if (typeof ksu !== 'undefined' && ksu.exec) {
            window[callbackName] = (errno, stdout, stderr) => {
                resolve({ errno, stdout, stderr });
                delete window[callbackName];
            };

            try {
                ksu.exec(command, JSON.stringify(params), callbackName);
            } catch (error) {
                console.error("Error executing command:", error);
                reject(error);
            }
        } else {
            // Browser fallback
            console.log("[BROWSER] KSU not available");
            resolve({
                errno: 0,
                stdout: "Browser simulation",
                stderr: ""
            });
        }
    });
}

// Show toast notifications
function showToast(message) {
    if (typeof ksu !== 'undefined' && ksu.toast) {
        ksu.toast(message);
    } else {
        // Browser fallback
        const toast = document.createElement('div');
        toast.style.position = 'fixed';
        toast.style.bottom = '20px';
        toast.style.left = '50%';
        toast.style.transform = 'translateX(-50%)';
        toast.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
        toast.style.color = 'white';
        toast.style.padding = '10px 20px';
        toast.style.borderRadius = '4px';
        toast.style.zIndex = '9999';
        toast.textContent = message;
        
        document.body.appendChild(toast);
        setTimeout(() => document.body.removeChild(toast), 3000);
    }
}

// Log output to console and UI
function logOutput(message, isError = false) {
    console.log(`${isError ? "[ERROR]" : "[INFO]"} ${message}`);
    
    const outputConsole = document.getElementById("outputConsole");
    if (outputConsole) {
        const logEntry = document.createElement("div");
        logEntry.className = isError ? "text-red-400" : "text-green-300";
        logEntry.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
        outputConsole.appendChild(logEntry);
        outputConsole.scrollTop = outputConsole.scrollHeight;
    }
}

// Initialize module version display
async function initModuleVersion() {
    const result = await executeCommand("ghost-utils get_module_version");
    if (result.errno === 0) {
        const moduleVer = document.getElementById("moduleVer");
        if (moduleVer) {
            moduleVer.textContent = result.stdout.trim();
        }
        logOutput(`Module version: ${result.stdout.trim()}`);
    }
}

// Initialize service status
async function initServiceStatus() {
    const statusEl = document.getElementById("serviceStatus");
    const imgEl = document.getElementById("imgGhost");
    
    if (statusEl) {
        statusEl.textContent = "Working ✨";
    }
    
    if (imgEl) {
        imgEl.src = "ghost1.de1ed5f2.webp";
    }
    
    logOutput("GMS Control Panel service status: Working");
}

// Initialize toggle states
async function initToggleStates() {
    // GMS Optimization toggle
    const gmsResult = await executeCommand("ghost-utils get_kill_logd");
    if (gmsResult.errno === 0) {
        const switchEl = document.getElementById("killLogdSwitch");
        if (switchEl) {
            const currentState = gmsResult.stdout.trim() === "1";
            switchEl.checked = currentState;
            localStorage.setItem('killLogdState', currentState);
        }
    }

    // Misc Optimizations toggle
    const miscResult = await executeCommand("ghost-utils get_misc_opt");
    if (miscResult.errno === 0) {
        const switchEl = document.getElementById("miscOptSwitch");
        if (switchEl) {
            const currentState = miscResult.stdout.trim() === "1";
            switchEl.checked = currentState;
            localStorage.setItem('miscOptState', currentState);
        }
    }
}

// Restore saved toggle states
function restoreToggleStates() {
    const killLogdSwitch = document.getElementById("killLogdSwitch");
    const miscOptSwitch = document.getElementById("miscOptSwitch");
    
    if (killLogdSwitch) {
        const savedState = localStorage.getItem('killLogdState');
        if (savedState !== null) {
            killLogdSwitch.checked = savedState === 'true';
        }
    }
    
    if (miscOptSwitch) {
        const savedState = localStorage.getItem('miscOptState');
        if (savedState !== null) {
            miscOptSwitch.checked = savedState === 'true';
        }
    }
}

// Apply GMS optimization
async function applyGMSOptimization(enabled) {
    logOutput(`${enabled ? "Enabling" : "Disabling"} GMS services optimization...`);
    const result = await executeCommand(
        enabled ? "ghost-utils set_kill_logd 1" : "ghost-utils set_kill_logd 0"
    );
    
    if (result.errno === 0) {
        logOutput(enabled ? "GMS services optimization enabled" : "GMS services restored");
        showToast(enabled ? "GMS services optimization setting saved" : "GMS services restoration setting saved");
    } else {
        if (result.stderr && (result.stderr.includes("No GMS services could be disabled") || 
            result.stderr.includes("No GMS services could be enabled"))) {
            logOutput("Note: Some GMS services were already in the desired state", false);
            showToast("GMS services are already in the desired state");
        } else {
            logOutput(`Error: ${result.stderr || "Failed to set GMS optimization"}`, true);
            showToast("Error changing GMS optimization settings");
        }
    }
}

// Apply miscellaneous optimizations
async function applyMiscOptimizations(enabled) {
    logOutput(`${enabled ? "Enabling" : "Disabling"} miscellaneous optimizations...`);
    const result = await executeCommand(
        enabled ? "ghost-utils set_misc_opt 1" : "ghost-utils set_misc_opt 0"
    );
    
    if (result.errno === 0) {
        logOutput(enabled ? "Miscellaneous optimizations enabled" : "Miscellaneous optimizations disabled");
        showToast(enabled ? "Miscellaneous optimizations setting saved" : "Miscellaneous optimizations setting saved");
    } else {
        logOutput(`Error: ${result.stderr || "Failed to set miscellaneous optimizations"}`, true);
        showToast("Error changing miscellaneous optimization settings");
    }
}

// Apply all settings
async function applyAllSettings() {
    logOutput("Applying all settings...");
    
    const killLogdSwitch = document.getElementById("killLogdSwitch");
    const miscOptSwitch = document.getElementById("miscOptSwitch");
    
    if (!killLogdSwitch || !miscOptSwitch) {
        logOutput("Error: Can't find required switch elements", true);
        showToast("UI Error: Missing switch controls");
        return;
    }
    
    const gmsEnabled = killLogdSwitch.checked;
    const miscEnabled = miscOptSwitch.checked;
    
    // Apply GMS optimization
    logOutput(`Applying GMS optimization: ${gmsEnabled ? "enabled" : "disabled"}`);
    try {
        const checkResult = await executeCommand("ls -la /data/ghost/gmslist.txt 2>/dev/null || echo 'File not found'");
        if (checkResult.stdout.includes("File not found")) {
            logOutput("Warning: gmslist.txt not found in /data/ghost, will attempt to create", true);
        }
        
        const gmsResult = await executeCommand(gmsEnabled ? "ghost-utils set_kill_logd 1" : "ghost-utils set_kill_logd 0");
        if (gmsResult.errno === 0) {
            logOutput(gmsEnabled ? "GMS services optimization applied successfully" : "GMS services optimization disabled successfully");
        } else {
            if (gmsResult.stderr && gmsResult.stderr.includes("not found")) {
                logOutput("The gmslist.txt file or 'pm' command may not be accessible. This could be due to insufficient permissions.", true);
            } else if (gmsResult.stderr) {
                logOutput(`GMS optimization status: ${gmsResult.stderr}`, true);
            } else {
                logOutput("GMS optimization status: Operation completed", true);
            }
        }
    } catch (err) {
        logOutput(`GMS optimization status: ${err.message}`, true);
    }
    
    // Apply miscellaneous optimizations
    logOutput(`Applying miscellaneous optimizations: ${miscEnabled ? "enabled" : "disabled"}`);
    try {
        const miscResult = await executeCommand(miscEnabled ? "ghost-utils set_misc_opt 1" : "ghost-utils set_misc_opt 0");
        if (miscResult.errno === 0) {
            logOutput(miscEnabled ? "Miscellaneous optimizations applied successfully" : "Miscellaneous optimizations disabled successfully");
        } else {
            logOutput(`Error applying miscellaneous optimizations: ${miscResult.stderr || "Unknown error"}`, true);
        }
    } catch (err) {
        logOutput(`Exception during miscellaneous optimizations: ${err.message}`, true);
    }
    
    logOutput("Settings application complete!");
    showToast("All optimization settings applied");
}

// Initialize the application
document.addEventListener("DOMContentLoaded", async () => {
    // Restore saved states
    restoreToggleStates();
    
    // Initialize components
    await initModuleVersion();
    await initServiceStatus();
    await initToggleStates();
    
    // Set up event listeners
    document.getElementById("killLogdSwitch")?.addEventListener("change", (e) => {
        applyGMSOptimization(e.target.checked);
    });
    
    document.getElementById("miscOptSwitch")?.addEventListener("change", (e) => {
        applyMiscOptimizations(e.target.checked);
    });
    
    document.getElementById("applySettings")?.addEventListener("click", () => {
        applyAllSettings();
    });
    
    // Initialize console
    logOutput("Initializing GMS Control Panel...");
}); 