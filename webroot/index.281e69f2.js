function e(e){return e&&e.__esModule?e.default:e}var t=globalThis,n={},i={},o=t.parcelRequirefbde;null==o&&((o=function(e){if(e in n)return n[e].exports;if(e in i){var t=i[e];delete i[e];var o={id:e,exports:{}};return n[e]=o,t.call(o.exports,o,o.exports),o.exports}var a=Error("Cannot find module '"+e+"'");throw a.code="MODULE_NOT_FOUND",a}).register=function(e,t){i[e]=t},t.parcelRequirefbde=o),(0,o.register)("27Lyk",function(e,t){Object.defineProperty(e.exports,"register",{get:()=>n,set:e=>n=e,enumerable:!0,configurable:!0});var n,i=new Map;n=function(e,t){for(var n=0;n<t.length-1;n+=2)i.set(t[n],{baseUrl:e,path:t[n+1]})}}),o("27Lyk").register(new URL("",import.meta.url).toString(),JSON.parse('["gvBVN","index.281e69f2.js","jkrgM","ghost1.de1ed5f2.webp","48MX7","ghost2.72daf16c.webp"]'));let a=0;function c(e,t){
    return void 0===t&&(t={}),new Promise((n,i)=>{
        let o=`exec_callback_${Date.now()}_${a++}`;
        
        function c(e){
            delete window[e]
        }
        
        // Test for test environment specifically
        const isTestEnvironment = window.location.pathname.includes('test.html');
        if (isTestEnvironment) {
            console.log("[TEST ENV] Command:", e);
            logOutput("[TEST] Simulating command: " + e);
            
            // Simulate commands in test environment
            if (e.includes("get_gmslist") || e.includes("get_gamelist")) {
                logOutput("[TEST] Simulating get_gmslist");
                setTimeout(() => {
                    n({
                        errno: 0, 
                        stdout: "com.google.android.gms\ncom.google.android.gms.ads.identifier.service.AdvertisingIdService\ncom.google.android.gms.nearby.mediums.nearfieldcommunication.NfcAdvertisingService", 
                        stderr: ""
                    });
                }, 500); // Add slight delay to simulate real command
            } else if (e.includes("get_module_version")) {
                n({errno: 0, stdout: "2.1-test", stderr: ""});
            } else if (e.includes("get_kill_logd") || e.includes("get_misc_opt")) {
                n({errno: 0, stdout: "0", stderr: ""});
            } else if (e.includes("save_gmslist") || e.includes("save_gamelist")) {
                logOutput("[TEST] Simulating save_gmslist");
                setTimeout(() => {
                    n({errno: 0, stdout: "Saved", stderr: ""});
                }, 1000); // Add longer delay for save operation
            } else {
                // Default simulation for other commands
                logOutput(`[TEST] Command simulation: ${e}`);
                n({errno: 0, stdout: "Command simulated in testing mode", stderr: ""});
            }
            return;
        }
        
        // Check if ksu.exec is available (real device)
        if (typeof ksu !== 'undefined' && ksu.exec) {
            window[o]=(e,t,i)=>{
                n({errno:e,stdout:t,stderr:i}),c(o)
            };
            
            try{
                ksu.exec(e,JSON.stringify(t),o)
            } catch(e){
                // Log the error and try alternative methods
                console.error("Error using ksu.exec:", e);
                logOutput(`Error executing command: ${e}`, true);
                i(e);
                c(o);
            }
        } else {
            // We're in a browser environment without ksu, use test fallbacks
            console.log("[BROWSER] KSU not available. Command was:", e);
            logOutput("System command not available in this environment. Using test data.", true);
            
            // Fallbacks similar to test environment
            if (e.includes("get_gmslist") || e.includes("get_gamelist")) {
                n({errno: 0, stdout: "com.google.android.gms\ncom.google.android.gms.ads.identifier.service.AdvertisingIdService", stderr: ""});
            } else if (e.includes("get_module_version")) {
                n({errno: 0, stdout: "2.1-browser", stderr: ""});
            } else if (e.includes("get_kill_logd") || e.includes("get_misc_opt")) {
                n({errno: 0, stdout: "0", stderr: ""});
            } else if (e.includes("save_gmslist") || e.includes("save_gamelist")) {
                logOutput("Simulating save_gmslist in browser");
                n({errno: 0, stdout: "Saved", stderr: ""});
            } else {
                // Default simulation
                n({errno: 0, stdout: "Command simulated in browser", stderr: ""});
            }
        }
    })
}function s(){this.listeners={}}function r(){this.listeners={},this.stdin=new s,this.stdout=new s,this.stderr=new s}function l(e){
    // Check if ksu is available
    if (typeof ksu !== 'undefined' && ksu.toast) {
        ksu.toast(e);
    } else {
        // Fallback for browsers/testing environments
        console.log("Toast message:", e);
        
        try {
            // Add a temporary visual toast using DOM
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
            toast.textContent = e;
            
            // Make sure document.body exists before appending
            if (document.body) {
                document.body.appendChild(toast);
                
                // Remove after 3 seconds
                setTimeout(() => {
                    try {
                        document.body.removeChild(toast);
                    } catch (err) {
                        console.error("Error removing toast:", err);
                    }
                }, 3000);
            }
            
            // Also log to the output console
            logOutput(`Toast: ${e}`);
        } catch (err) {
            console.error("Error showing toast:", err);
        }
    }
}

// Console output function
function logOutput(message, isError = false) {
    // First log to console for debugging
    console.log(`${isError ? "[ERROR]" : "[INFO]"} ${message}`);
    
    // Try to append to the UI console if it exists
    const outputConsole = document.getElementById("outputConsole");
    if (outputConsole) {
        const logEntry = document.createElement("div");
        logEntry.className = isError ? "text-red-400" : "text-green-300";
        logEntry.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
        outputConsole.appendChild(logEntry);
        outputConsole.scrollTop = outputConsole.scrollHeight;
    }
}

s.prototype.on=function(e,t){this.listeners[e]||(this.listeners[e]=[]),this.listeners[e].push(t)},s.prototype.emit=function(e,...t){this.listeners[e]&&this.listeners[e].forEach(e=>e(...t))},r.prototype.on=function(e,t){this.listeners[e]||(this.listeners[e]=[]),this.listeners[e].push(t)},r.prototype.emit=function(e,...t){this.listeners[e]&&this.listeners[e].forEach(e=>e(...t))};var u={};u=new URL("ghost1.de1ed5f2.webp",import.meta.url).toString();var d={};async function m(){
    let{errno:e,stdout:t} = await c("ghost-utils get_module_version");
    if(0 === e) {
        const moduleVer = document.getElementById("moduleVer");
        if (moduleVer) {
            moduleVer.textContent = t.trim();
        }
        logOutput(`Module version: ${t.trim()}`);
    }
}async function g(){
    // Always show as working since we don't rely on the service anymore
    const statusEl = document.getElementById("serviceStatus");
    const imgEl = document.getElementById("imgGhost");
    
    if (statusEl) {
        statusEl.textContent = "Working ✨";
    }
    
    if (imgEl) {
        imgEl.src = /*@__PURE__*/e(u);
    }
    
    logOutput("GMS Control Panel service status: Working");
}async function f(){
    // Set static message instead of service PID
    const servicePID = document.getElementById("servicePID");
    if (servicePID) {
        servicePID.textContent = "GMS Control Panel Active";
    }
    logOutput("GMS Control Panel is active and ready");
}async function v(){
    let{errno:e,stdout:t} = await c("ghost-utils get_kill_logd");
    if(0 === e) {
        const switchEl = document.getElementById("killLogdSwitch");
        if (switchEl) {
            switchEl.checked = "1" === t.trim();
        }
    }
}async function A(){
    let{errno:e,stdout:t} = await c("ghost-utils get_misc_opt");
    if(0 === e) {
        const switchEl = document.getElementById("miscOptSwitch");
        if (switchEl) {
            switchEl.checked = "1" === t.trim();
        }
    }
}async function p(e){logOutput(`${e ? "Enabling" : "Disabling"} GMS services optimization...`);let{errno, stdout, stderr}=await c(e?"ghost-utils set_kill_logd 1":"ghost-utils set_kill_logd 0");if(errno===0){logOutput(e ? "GMS services optimization enabled" : "GMS services restored");l(e ? "GMS services optimization setting saved" : "GMS services restoration setting saved")}else{logOutput(`Error: ${stderr || "Failed to set GMS optimization"}`,true);l("Error changing GMS optimization settings")}}async function S(e){logOutput(`${e ? "Enabling" : "Disabling"} miscellaneous optimizations...`);let{errno, stdout, stderr}=await c(e?"ghost-utils set_misc_opt 1":"ghost-utils set_misc_opt 0");if(errno===0){logOutput(e ? "Miscellaneous optimizations enabled" : "Miscellaneous optimizations disabled");l(e ? "Miscellaneous optimizations setting saved" : "Miscellaneous optimizations setting saved")}else{logOutput(`Error: ${stderr || "Failed to set miscellaneous optimizations"}`,true);l("Error changing miscellaneous optimization settings")}}async function w(){
    logOutput("Applying all settings...");
    
    // Get UI state with error checking
    const killLogdSwitch = document.getElementById("killLogdSwitch");
    const miscOptSwitch = document.getElementById("miscOptSwitch");
    
    if (!killLogdSwitch || !miscOptSwitch) {
        logOutput("Error: Can't find required switch elements", true);
        l("UI Error: Missing switch controls");
        return;
    }
    
    // Apply settings based on UI state
    const gmsEnabled = killLogdSwitch.checked;
    const miscEnabled = miscOptSwitch.checked;
    
    // Apply GMS optimization settings with improved error handling
    logOutput(`Applying GMS optimization: ${gmsEnabled ? "enabled" : "disabled"}`);
    try {
        // First check if gmslist.txt exists to provide better error messages
        const checkResult = await c("ls -la /data/ghost/gmslist.txt 2>/dev/null || echo 'File not found'");
        if (checkResult.stdout.includes("File not found")) {
            logOutput("Warning: gmslist.txt not found in /data/ghost, will attempt to create", true);
        }
        
        let gmsResult = await c(gmsEnabled ? "ghost-utils set_kill_logd 1" : "ghost-utils set_kill_logd 0");
        if(gmsResult.errno === 0) {
            logOutput(gmsEnabled ? "GMS services optimization applied successfully" : "GMS services optimization disabled successfully");
        } else {
            logOutput(`Error applying GMS optimization: ${gmsResult.stderr || "Unknown error"}`, true);
            // Try to provide more context about the error
            if (gmsResult.stderr && gmsResult.stderr.includes("not found")) {
                logOutput("The gmslist.txt file or 'pm' command may not be accessible. This could be due to insufficient permissions.", true);
            }
        }
    } catch (err) {
        logOutput(`Exception during GMS optimization: ${err.message}`, true);
    }
    
    // Apply miscellaneous optimizations settings with similar improvements
    logOutput(`Applying miscellaneous optimizations: ${miscEnabled ? "enabled" : "disabled"}`);
    try {
        let miscResult = await c(miscEnabled ? "ghost-utils set_misc_opt 1" : "ghost-utils set_misc_opt 0");
        if(miscResult.errno === 0) {
            logOutput(miscEnabled ? "Miscellaneous optimizations applied successfully" : "Miscellaneous optimizations disabled successfully");
        } else {
            logOutput(`Error applying miscellaneous optimizations: ${miscResult.stderr || "Unknown error"}`, true);
        }
    } catch (err) {
        logOutput(`Exception during miscellaneous optimizations: ${err.message}`, true);
    }
    
    logOutput("Settings application complete!");
    l("All optimization settings applied");
}async function y(e){logOutput(`Setting default CPU governor to ${e}...`);let{errno, stderr}=await c("ghost-utils set_default_cpugov "+e);if(errno!==0){logOutput(`Error setting CPU governor: ${stderr || "Unknown error"}`,true)}}async function E(e){logOutput(`Setting powersave CPU governor to ${e}...`);let{errno, stderr}=await c("ghost-utils set_powersave_cpugov "+e);if(errno!==0){logOutput(`Error setting powersave CPU governor: ${stderr || "Unknown error"}`,true)}}async function _(){let{errno:e,stdout:t}=await c("ghost-utils get_available_cpugov");if(0===e){let e=t.trim().split(/\s+/),n=document.getElementById("cpuGovernor"),i=document.getElementById("cpuGovernorPowersave");n.innerHTML="",i.innerHTML="",e.forEach(e=>{let t=document.createElement("option");t.value=e,t.textContent=e,n.appendChild(t);let o=document.createElement("option");o.value=e,o.textContent=e,i.appendChild(o)});let{errno:o,stdout:a}=await c("ghost-utils get_default_cpugov");if(0===o){let e=a.trim();n.value=e}let{errno:s,stdout:r}=await c("ghost-utils get_powersave_cpugov");if(0===s){let e=r.trim();i.value=e}}logOutput("CPU governor settings loaded")}async function h(){
    logOutput("Saving logs...");
    
    try {
        const result = await c("ghost-utils save_logs");
        
        if(result.errno === 0){
            logOutput("Logs have been saved successfully");
            logOutput("Check your device for saved logs at /sdcard/gmscontrol_log");
            l("Logs have been saved on /sdcard/gmscontrol_log");
        } else {
            // Detailed error reporting
            logOutput(`Error saving logs: ${result.stderr || "Unknown error"}`, true);
            
            // Try to display useful information about the failure
            if (result.stderr && result.stderr.includes("Permission denied")) {
                logOutput("This appears to be a permissions issue. The app may need storage permissions.", true);
            } else if (result.stderr && result.stderr.includes("No such file or directory")) {
                logOutput("Required directories may not exist or be accessible on your device.", true);
            }
            
            l("Failed to save logs");
        }
    } catch (err) {
        logOutput(`Exception occurred while saving logs: ${err.message}`, true);
        l("Error occurred while saving logs");
    }
}async function B(){
    logOutput("Opening GMS Services editor...");
    
    // Add DOM element check with detailed logging
    try {
        // More detailed diagnostics
        const allModals = document.querySelectorAll('[id*="modal"]');
        if (allModals.length === 0) {
            logOutput("Error: No modal elements found in the document", true);
        } else {
            logOutput(`Found ${allModals.length} modal-like elements`, false);
        }
        
        // Get DOM elements with error checking
        const modal = document.getElementById("gmslistModal");
        const textarea = document.getElementById("gmslistInput");
        
        if (!modal) {
            logOutput("Error: GMS Services modal element not found (ID: gmslistModal)", true);
            l("UI error: Could not find the edit window");
            return;
        }
        
        if (!textarea) {
            logOutput("Error: GMS Services textarea element not found (ID: gmslistInput)", true);
            l("UI error: Could not find the edit window content area");
            return;
        }
        
        // Call get_gmslist with error handling
        try {
            logOutput("Fetching GMS services list...");
            const {errno, stdout, stderr} = await c("ghost-utils get_gmslist");
            
            if (errno === 0) {
                // Success - update the textarea and show the modal
                // Check if content has pipes or newlines to determine format
                let formattedContent;
                if (stdout.includes('|')) {
                    // Content has pipes, convert to newlines for display
                    formattedContent = stdout.trim().replace(/\|/g, "\n");
                    logOutput("Converted pipe-separated list to newlines for display");
                } else {
                    // Content already has newlines
                    formattedContent = stdout.trim();
                    logOutput("Using newline format from gmslist.txt");
                }
                
                textarea.value = formattedContent;
                
                // Show the modal by handling Tailwind classes properly
                logOutput("Showing GMS Services modal...");
                modal.classList.remove("hidden");
                // Add flex display to make it visible (needed for Tailwind classes)
                modal.classList.add("flex");
                
                logOutput("GMS Services list loaded successfully");
            } else {
                // Command error
                logOutput(`Error loading GMS Services list: ${stderr || "Unknown error"}`, true);
                l("Failed to load GMS Services list");
            }
        } catch (err) {
            // Exception during command execution
            logOutput(`Exception loading GMS Services list: ${err.message}`, true);
            l("Error accessing GMS Services list");
        }
    } catch (err) {
        // General exception
        logOutput(`Unexpected error opening edit window: ${err.message}`, true);
        l("Error opening edit window");
    }
}async function L(){
    try {
        const textarea = document.getElementById("gmslistInput");
        const modal = document.getElementById("gmslistModal");
        
        if (!textarea) {
            logOutput("Error: GMS Services textarea element not found when saving", true);
            l("Error: Could not find GMS Services edit area");
            return;
        }
        
        // Get text and ensure format is correct for shell script
        // The script expects forward slashes, which are converted to pipes
        const textContent = textarea.value.trim();
        
        // Clean up the content - remove empty lines and ensure consistent format
        const cleanedContent = textContent
            .split("\n")
            .filter(line => line.trim() !== "")  // Remove empty lines
            .join("/");
            
        logOutput("Saving GMS Services list...");
        logOutput(`Prepared ${cleanedContent.split("/").length} services for saving`);
        
        try {
            // Call the script to save
            const {errno, stdout, stderr} = await c(`ghost-utils save_gmslist "${cleanedContent}"`);
            
            if (errno === 0) {
                // Success
                logOutput("GMS Services list saved successfully");
                l("GMS Services list saved successfully");
                
                // Hide the modal if it exists
                if (modal) {
                    // Properly handling Tailwind classes
                    modal.classList.add("hidden");
                    modal.classList.remove("flex");
                }
            } else {
                // Command error
                logOutput(`Error saving GMS Services list: ${stderr || "Unknown error"}`, true);
                l("Failed to save GMS Services list");
            }
        } catch (err) {
            // Exception during command execution
            logOutput(`Exception saving GMS Services list: ${err.message}`, true);
            l("Error saving GMS Services list");
        }
    } catch (err) {
        // General exception
        logOutput(`Unexpected error saving GMS list: ${err.message}`, true);
        l("Error saving settings");
    }
}async function clearOutput() {
    const outputConsole = document.getElementById("outputConsole");
    if (outputConsole) {
        outputConsole.innerHTML = '<div class="text-gray-400">Output cleared.</div>';
        console.log("Output console cleared");
    } else {
        console.log("No output console found to clear");
    }
}async function D(){
    logOutput("Disabling all optimizations...");
    
    let {errno, stdout, stderr} = await c("ghost-utils disable_all_optimizations");
    
    if(errno === 0) {
        // Update the UI state if elements exist
        const killLogdSwitch = document.getElementById("killLogdSwitch");
        const miscOptSwitch = document.getElementById("miscOptSwitch");
        
        if (killLogdSwitch) {
            killLogdSwitch.checked = false;
        }
        
        if (miscOptSwitch) {
            miscOptSwitch.checked = false;
        }
        
        logOutput("All optimizations have been disabled");
        logOutput("Google services have been restored");
        logOutput("A reboot is recommended for full effect");
        l("All optimizations have been disabled");
    } else {
        logOutput(`Error disabling optimizations: ${stderr || "Unknown error"}`, true);
        l("Error occurred while disabling optimizations");
    }
}async function I(){logOutput("Opening website...");await c("ghost-utils open_website")}d=new URL("ghost2.72daf16c.webp",import.meta.url).toString(),document.addEventListener("DOMContentLoaded",async e=>{
    // Initialize console
    logOutput("Initializing GMS Control Panel...");
    
    // Load app state
    await m();
    await g();
    await f();
    await v();
    await A();
    
    try {
        await _();
    } catch (err) {
        logOutput("CPU governors not available in this version");
    }
    
    // Event Listeners
    document.getElementById("saveLogsButton").addEventListener("click",async function(){
        await h();
    });
    
    document.getElementById("applyButton").addEventListener("click",async function(){
        await w();
    });
    
    document.getElementById("killLogdSwitch").addEventListener("change",async function(){
        logOutput(`GMS optimization ${this.checked ? "enabled" : "disabled"} (not applied yet)`);
    });
    
    document.getElementById("miscOptSwitch").addEventListener("change",async function(){
        logOutput(`Miscellaneous optimizations ${this.checked ? "enabled" : "disabled"} (not applied yet)`);
    });
    
    document.getElementById("disableAnythingButton").addEventListener("click",async function(){
        await D();
    });
    
    document.getElementById("clearOutputButton").addEventListener("click",async function(){
        await clearOutput();
    });
    
    // Add event listener for restart service button
    try {
        const restartBtn = document.getElementById("restartServiceButton");
        if (restartBtn) {
            restartBtn.addEventListener("click", async function(){
                logOutput("Reapplying optimization settings...");
                try {
                    // First check if the shell command exists
                    const checkCmd = await c("ghost-utils | grep -q 'reapply_settings' && echo 'exists' || echo 'missing'");
                    if (checkCmd.stdout && checkCmd.stdout.includes("missing")) {
                        logOutput("Warning: reapply_settings function not found in ghost-utils", true);
                        // Fall back to manual reapplication
                        logOutput("Falling back to manual reapplication...");
                        await w();
                        return;
                    }
                    
                    // Execute the reapply command
                    let result = await c("ghost-utils reapply_settings");
                    if (result.errno === 0) {
                        logOutput("Settings have been reapplied successfully");
                        l("Settings reapplied");
                    } else {
                        logOutput(`Error reapplying settings: ${result.stderr || "Unknown error"}`, true);
                        if (result.stderr && (result.stderr.includes("not found") || result.stderr.includes("No such file"))) {
                            logOutput("Command not found. Falling back to manual reapplication...");
                            await w();
                        } else {
                            l("Failed to reapply settings");
                        }
                    }
                } catch (err) {
                    logOutput(`Exception during reapply: ${err.message}`, true);
                    logOutput("Attempting manual reapplication as fallback...");
                    await w();
                }
            });
            logOutput("Reapply button initialized");
        }
    } catch(err) {
        logOutput("Error setting up reapply button: " + err.message, true);
    }
    
    // Try to find CPU governor elements, but don't fail if they don't exist
    try {
        const cpuGovPowersave = document.getElementById("cpuGovernorPowersave");
        const cpuGov = document.getElementById("cpuGovernor");
        
        if(cpuGovPowersave) {
            cpuGovPowersave.addEventListener("change",async function(){
                await E(this.value);
            });
        }
        
        if(cpuGov) {
            cpuGov.addEventListener("change",async function(){
                await y(this.value);
            });
        }
    } catch(err) {
        logOutput("CPU governor controls not available", true);
    }
    
    // Add try-catch blocks around all other elements for safety
    try {
        const editGmslistBtn = document.getElementById("editGmslistButton");
        if (editGmslistBtn) {
            editGmslistBtn.addEventListener("click", function(){
                B();
            });
            logOutput("GMS Services edit button initialized");
        } else {
            logOutput("GMS Services edit button not found", true);
        }
    } catch(err) {
        logOutput("Error setting up GMS Services edit button: " + err.message, true);
    }
    
    try {
        const cancelBtn = document.getElementById("cancelButton");
        if (cancelBtn) {
            cancelBtn.addEventListener("click", function(){
                const modal = document.getElementById("gmslistModal");
                if (modal) {
                    modal.classList.add("hidden");
                    modal.classList.remove("flex");
                    logOutput("GMS Services edit canceled");
                }
            });
        }
    } catch(err) {
        logOutput("Error setting up cancel button: " + err.message, true);
    }
    
    try {
        const saveGmslistBtn = document.getElementById("saveGmslistButton");
        if (saveGmslistBtn) {
            saveGmslistBtn.addEventListener("click", async function(){
                await L();
            });
        }
    } catch(err) {
        logOutput("Error setting up save gmslist button: " + err.message, true);
    }
    
    try {
        const imgGhost = document.getElementById("imgGhost");
        if (imgGhost) {
            imgGhost.addEventListener("click", async function(){
                await I();
            });
        }
    } catch(err) {
        logOutput("Error setting up image click handler: " + err.message, true);
    }
    
    logOutput("GMS Control Panel initialization complete");
});
//# sourceMappingURL=index.281e69f2.js.map
