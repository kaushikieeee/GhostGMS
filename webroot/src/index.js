/**
 * GhostGMS Web Interface
 * Main JavaScript file for the web interface
 */

// Security configuration
let securityToken = null;
let sessionTimeout = null;
const SESSION_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes
const MAX_RETRIES = 3;
let retryCount = 0;
const SECURE_COOKIE_NAME = 'ghostgms_session';
const CSRF_TOKEN_NAME = 'ghostgms_csrf';
let csrfToken = null;
let pendingRequests = new Set();
const COMMAND_TIMEOUT_MS = 10000; // 10 seconds timeout for commands
const LOG_DIR = "/data/media/0/ghostgms/logs"; // Using internal storage path
const LOG_PERMISSIONS = "777"; // Full permissions for log directory

// Log categories
const LOG_CATEGORIES = {
    UI: "UI",
    SECURITY: "SECURITY",
    COMMAND: "COMMAND",
    SYSTEM: "SYSTEM",
    ERROR: "ERROR",
    DEBUG: "DEBUG"
};

// Initialize logging system
async function initLogging() {
    try {
        // Create log directory if it doesn't exist
        await executeCommand(`mkdir -p ${LOG_DIR}`);
        
        // Set proper permissions
        await executeCommand(`chmod ${LOG_PERMISSIONS} ${LOG_DIR}`);
        
        // Create today's log file
        const today = new Date().toISOString().split('T')[0];
        const logFile = `${LOG_DIR}/ghostgms_${today}.log`;
        
        // Initialize log file with header
        const header = `=== GhostGMS Log - ${new Date().toISOString()} ===\n`;
        await executeCommand(`echo "${header}" > ${logFile}`);
        
        // Set permissions for the log file
        await executeCommand(`chmod ${LOG_PERMISSIONS} ${logFile}`);
        
        logOutput("Logging system initialized successfully", false, LOG_CATEGORIES.SYSTEM, {
            logDir: LOG_DIR,
            permissions: LOG_PERMISSIONS
        });
        return true;
    } catch (error) {
        console.error("Failed to initialize logging system:", error);
        showError("Failed to initialize logging system");
        return false;
    }
}

// Write log entry to file
async function writeLogEntry(level, message, category, context = {}) {
    try {
        const today = new Date().toISOString().split('T')[0];
        const logFile = `${LOG_DIR}/ghostgms_${today}.log`;
        const timestamp = new Date().toISOString();
        const logEntry = `[${timestamp}] [${level}] [${category}] ${message} ${JSON.stringify(context)}\n`;
        
        // Write to log file
        await executeCommand(`echo "${logEntry}" >> ${logFile}`);
        
        // Ensure permissions are maintained
        await executeCommand(`chmod ${LOG_PERMISSIONS} ${logFile}`);
        
        // Verify log file exists and is writable
        const verifyResult = await executeCommand(`ls -l ${logFile}`);
        logOutput(`Log file status: ${verifyResult.stdout}`, false, LOG_CATEGORIES.SYSTEM, {
            logFile: logFile,
            permissions: LOG_PERMISSIONS
        });
    } catch (error) {
        console.error("Failed to write log entry:", error);
        // Try to create the log file again if it doesn't exist
        try {
            const today = new Date().toISOString().split('T')[0];
            const logFile = `${LOG_DIR}/ghostgms_${today}.log`;
            await executeCommand(`touch ${logFile}`);
            await executeCommand(`chmod ${LOG_PERMISSIONS} ${logFile}`);
            // Retry writing the log entry
            await writeLogEntry(level, message, category, context);
        } catch (retryError) {
            console.error("Failed to recover log file:", retryError);
        }
    }
}

// Enhanced log output function
function logOutput(message, isError = false, category = LOG_CATEGORIES.SYSTEM, context = {}) {
    const level = isError ? "ERROR" : "INFO";
    console.log(`[${level}] [${category}] ${message}`);
    
    // Write to log file
    writeLogEntry(level, message, category, context);
    
    // Update UI console
    const outputConsole = document.getElementById("outputConsole");
    if (outputConsole) {
        const logEntry = document.createElement("div");
        logEntry.className = isError ? "text-red-400" : "text-green-300";
        logEntry.textContent = `[${new Date().toLocaleTimeString()}] [${level}] [${category}] ${message}`;
        outputConsole.appendChild(logEntry);
        outputConsole.scrollTop = outputConsole.scrollHeight;
    }
}

// Initialize security
async function initSecurity() {
    try {
        // Check if we're running on localhost
        if (!window.location.hostname.match(/^(localhost|127\.0\.0\.1)$/)) {
            throw new Error("Access denied: Web interface can only be accessed from localhost");
        }

        // Check if we're using HTTPS
        if (window.location.protocol !== 'https:' && !window.location.hostname.match(/^(localhost|127\.0\.0\.1)$/)) {
            throw new Error("Access denied: Web interface must be accessed via HTTPS");
        }

        // Check for required APIs
        if (!window.crypto || !window.crypto.getRandomValues) {
            throw new Error("Required security APIs not available");
        }

        // Generate CSRF token
        csrfToken = generateCSRFToken();
        document.cookie = `${CSRF_TOKEN_NAME}=${csrfToken}; secure; samesite=Strict; path=/; max-age=${SESSION_TIMEOUT_MS/1000}`;

        // Get security token from KSU
        const result = await executeCommand("ghost-utils get_security_token");
        if (result.errno === 0) {
            securityToken = result.stdout.trim();
            // Store token in secure cookie
            document.cookie = `${SECURE_COOKIE_NAME}=${securityToken}; secure; samesite=Strict; path=/; max-age=${SESSION_TIMEOUT_MS/1000}`;
            // Set session timeout
            resetSessionTimeout();
            // Reset retry count on successful authentication
            retryCount = 0;
        } else {
            throw new Error("Failed to get security token");
        }
    } catch (error) {
        console.error("Security initialization failed:", error);
        showError("Security initialization failed. Please restart the module.");
        return false;
    }
    return true;
}

// Generate CSRF token
function generateCSRFToken() {
    try {
        const array = new Uint32Array(8);
        window.crypto.getRandomValues(array);
        return Array.from(array, dec => ('0' + dec.toString(16)).substr(-2)).join('');
    } catch (error) {
        console.error("Failed to generate CSRF token:", error);
        throw new Error("Security error: Failed to generate CSRF token");
    }
}

// Verify CSRF token
function verifyCSRFToken(token) {
    if (!token || typeof token !== 'string' || token.length !== 64) {
        return false;
    }
    return token === csrfToken;
}

// Reset session timeout
function resetSessionTimeout() {
    if (sessionTimeout) {
        clearTimeout(sessionTimeout);
    }
    sessionTimeout = setTimeout(() => {
        securityToken = null;
        csrfToken = null;
        document.cookie = `${SECURE_COOKIE_NAME}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; secure; samesite=Strict`;
        document.cookie = `${CSRF_TOKEN_NAME}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; secure; samesite=Strict`;
        showError("Session expired. Please refresh the page.");
    }, SESSION_TIMEOUT_MS);
}

// Sanitize command input
function sanitizeCommand(command) {
    if (!command || typeof command !== 'string') {
        throw new Error("Invalid command input");
    }
    // Remove any potential command injection attempts
    return command.replace(/[;&|`$(){}<>]/g, '');
}

// Validate command response
function validateCommandResponse(response) {
    if (!response || typeof response !== 'object') {
        throw new Error("Invalid command response");
    }
    if (typeof response.errno !== 'number') {
        throw new Error("Invalid error code in response");
    }
    if (typeof response.stdout !== 'string' || typeof response.stderr !== 'string') {
        throw new Error("Invalid output in response");
    }
    return true;
}

// Utility function to execute commands with KSU
async function executeCommand(command, params = {}) {
    return new Promise((resolve, reject) => {
        // Check if we have a valid security token
        if (!securityToken) {
            reject(new Error("Not authenticated"));
            return;
        }

        // Reset session timeout on activity
        resetSessionTimeout();

        // Sanitize command
        command = sanitizeCommand(command);

        const callbackName = `exec_callback_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
        
        // Set command timeout
        const timeoutId = setTimeout(() => {
            if (pendingRequests.has(callbackName)) {
                pendingRequests.delete(callbackName);
                delete window[callbackName];
                reject(new Error("Command execution timed out"));
            }
        }, COMMAND_TIMEOUT_MS);
        
        // Test environment simulation
        if (window.location.pathname.includes('test.html')) {
            console.log("[TEST] Simulating command:", command);
            clearTimeout(timeoutId);
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
            // Add to pending requests
            pendingRequests.add(callbackName);

            window[callbackName] = (errno, stdout, stderr) => {
                // Clean up timeout
                clearTimeout(timeoutId);
                
                // Clean up callback
                delete window[callbackName];
                pendingRequests.delete(callbackName);
                
                try {
                    // Validate response
                    const response = { errno, stdout, stderr };
                    validateCommandResponse(response);
                    
                    // Handle authentication errors
                    if (errno === 1 && stderr.includes("Invalid token")) {
                        retryCount++;
                        if (retryCount >= MAX_RETRIES) {
                            securityToken = null;
                            csrfToken = null;
                            document.cookie = `${SECURE_COOKIE_NAME}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; secure; samesite=Strict`;
                            document.cookie = `${CSRF_TOKEN_NAME}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; secure; samesite=Strict`;
                            reject(new Error("Authentication failed. Please refresh the page."));
                            return;
                        }
                        // Retry with new token
                        initSecurity().then(() => {
                            executeCommand(command, params).then(resolve).catch(reject);
                        }).catch(reject);
                        return;
                    }
                    
                    resolve(response);
                } catch (error) {
                    console.error("Error validating command response:", error);
                    reject(error);
                }
            };

            try {
                // Add security token and client IP to command
                const clientIP = window.location.hostname;
                const secureCommand = `ghost-utils verify_token ${securityToken} ${clientIP} && ${command}`;
                ksu.exec(secureCommand, JSON.stringify(params), callbackName);
            } catch (error) {
                console.error("Error executing command:", error);
                clearTimeout(timeoutId);
                pendingRequests.delete(callbackName);
                reject(error);
            }
        } else {
            // Browser fallback
            clearTimeout(timeoutId);
            console.log("[BROWSER] KSU not available");
            resolve({
                errno: 0,
                stdout: "Browser simulation",
                stderr: ""
            });
        }
    });
}

// Clean up pending requests
function cleanupPendingRequests() {
    for (const callbackName of pendingRequests) {
        delete window[callbackName];
    }
    pendingRequests.clear();
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

// Show error message
function showError(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'fixed top-0 left-0 right-0 bg-red-500 text-white p-4 text-center z-50';
    errorDiv.textContent = message;
    document.body.appendChild(errorDiv);
    setTimeout(() => errorDiv.remove(), 5000);
}

// Initialize module version display
async function initModuleVersion() {
    const result = await executeCommand("ghost-utils get_module_version");
    if (result.errno === 0) {
        const moduleVer = document.getElementById("moduleVer");
        if (moduleVer) {
            moduleVer.textContent = result.stdout.trim();
        }
        logOutput(`Module version: ${result.stdout.trim()}`, false, LOG_CATEGORIES.SYSTEM);
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
    
    logOutput("GMS Control Panel service status: Working", false, LOG_CATEGORIES.SYSTEM);
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
    logOutput(`${enabled ? "Enabling" : "Disabling"} GMS services optimization...`, false, LOG_CATEGORIES.UI, {
        action: "toggle_gms_optimization",
        newState: enabled
    });
    
    const result = await executeCommand(
        enabled ? "ghost-utils set_kill_logd 1" : "ghost-utils set_kill_logd 0"
    );
    
    if (result.errno === 0) {
        logOutput(enabled ? "GMS services optimization enabled" : "GMS services restored", false, LOG_CATEGORIES.COMMAND, {
            action: "gms_optimization",
            state: enabled,
            result: "success"
        });
        showToast(enabled ? "GMS services optimization setting saved" : "GMS services restoration setting saved");
    } else {
        if (result.stderr && (result.stderr.includes("No GMS services could be disabled") || 
            result.stderr.includes("No GMS services could be enabled"))) {
            logOutput("Note: Some GMS services were already in the desired state", false, LOG_CATEGORIES.COMMAND, {
                action: "gms_optimization",
                state: enabled,
                result: "no_change_needed"
            });
            showToast("GMS services are already in the desired state");
        } else {
            logOutput(`Error: ${result.stderr || "Failed to set GMS optimization"}`, true, LOG_CATEGORIES.ERROR, {
                action: "gms_optimization",
                state: enabled,
                error: result.stderr
            });
            showToast("Error changing GMS optimization settings");
        }
    }
}

// Apply miscellaneous optimizations
async function applyMiscOptimizations(enabled) {
    logOutput(`${enabled ? "Enabling" : "Disabling"} miscellaneous optimizations...`, false, LOG_CATEGORIES.UI, {
        action: "toggle_misc_optimizations",
        newState: enabled
    });
    
    const result = await executeCommand(
        enabled ? "ghost-utils set_misc_opt 1" : "ghost-utils set_misc_opt 0"
    );
    
    if (result.errno === 0) {
        logOutput(enabled ? "Miscellaneous optimizations enabled" : "Miscellaneous optimizations disabled", false, LOG_CATEGORIES.COMMAND, {
            action: "misc_optimizations",
            state: enabled,
            result: "success"
        });
        showToast(enabled ? "Miscellaneous optimizations setting saved" : "Miscellaneous optimizations setting saved");
    } else {
        logOutput(`Error: ${result.stderr || "Failed to set miscellaneous optimizations"}`, true, LOG_CATEGORIES.ERROR, {
            action: "misc_optimizations",
            state: enabled,
            error: result.stderr
        });
        showToast("Error changing miscellaneous optimization settings");
    }
}

// Apply all settings
async function applyAllSettings() {
    logOutput("Applying all settings...", false, LOG_CATEGORIES.UI, {
        action: "apply_all_settings",
        timestamp: new Date().toISOString()
    });
    
    const killLogdSwitch = document.getElementById("killLogdSwitch");
    const miscOptSwitch = document.getElementById("miscOptSwitch");
    
    if (!killLogdSwitch || !miscOptSwitch) {
        logOutput("Error: Can't find required switch elements", true, LOG_CATEGORIES.ERROR, {
            action: "apply_all_settings",
            error: "missing_ui_elements"
        });
        showToast("UI Error: Missing switch controls");
        return;
    }
    
    const gmsEnabled = killLogdSwitch.checked;
    const miscEnabled = miscOptSwitch.checked;
    
    // Apply GMS optimization
    logOutput(`Applying GMS optimization: ${gmsEnabled ? "enabled" : "disabled"}`, false, LOG_CATEGORIES.COMMAND, {
        action: "apply_gms_optimization",
        state: gmsEnabled
    });
    
    try {
        const checkResult = await executeCommand("ls -la /data/ghost/gmslist.txt 2>/dev/null || echo 'File not found'");
        if (checkResult.stdout.includes("File not found")) {
            logOutput("Warning: gmslist.txt not found in /data/ghost, will attempt to create", true, LOG_CATEGORIES.SYSTEM, {
                action: "check_gmslist",
                result: "file_not_found"
            });
        }
        
        const gmsResult = await executeCommand(gmsEnabled ? "ghost-utils set_kill_logd 1" : "ghost-utils set_kill_logd 0");
        if (gmsResult.errno === 0) {
            logOutput(gmsEnabled ? "GMS services optimization applied successfully" : "GMS services optimization disabled successfully", false, LOG_CATEGORIES.COMMAND, {
                action: "apply_gms_optimization",
                state: gmsEnabled,
                result: "success"
            });
        } else {
            if (gmsResult.stderr && gmsResult.stderr.includes("not found")) {
                logOutput("The gmslist.txt file or 'pm' command may not be accessible. This could be due to insufficient permissions.", true, LOG_CATEGORIES.ERROR, {
                    action: "apply_gms_optimization",
                    state: gmsEnabled,
                    error: "permission_denied"
                });
            } else if (gmsResult.stderr) {
                logOutput(`GMS optimization status: ${gmsResult.stderr}`, true, LOG_CATEGORIES.ERROR, {
                    action: "apply_gms_optimization",
                    state: gmsEnabled,
                    error: gmsResult.stderr
                });
            } else {
                logOutput("GMS optimization status: Operation completed", true, LOG_CATEGORIES.COMMAND, {
                    action: "apply_gms_optimization",
                    state: gmsEnabled,
                    result: "completed"
                });
            }
        }
    } catch (err) {
        logOutput(`GMS optimization status: ${err.message}`, true, LOG_CATEGORIES.ERROR, {
            action: "apply_gms_optimization",
            state: gmsEnabled,
            error: err.message
        });
    }
    
    // Apply miscellaneous optimizations
    logOutput(`Applying miscellaneous optimizations: ${miscEnabled ? "enabled" : "disabled"}`, false, LOG_CATEGORIES.COMMAND, {
        action: "apply_misc_optimizations",
        state: miscEnabled
    });
    
    try {
        const miscResult = await executeCommand(miscEnabled ? "ghost-utils set_misc_opt 1" : "ghost-utils set_misc_opt 0");
        if (miscResult.errno === 0) {
            logOutput(miscEnabled ? "Miscellaneous optimizations applied successfully" : "Miscellaneous optimizations disabled successfully", false, LOG_CATEGORIES.COMMAND, {
                action: "apply_misc_optimizations",
                state: miscEnabled,
                result: "success"
            });
        } else {
            logOutput(`Error applying miscellaneous optimizations: ${miscResult.stderr || "Unknown error"}`, true, LOG_CATEGORIES.ERROR, {
                action: "apply_misc_optimizations",
                state: miscEnabled,
                error: miscResult.stderr
            });
        }
    } catch (err) {
        logOutput(`Exception during miscellaneous optimizations: ${err.message}`, true, LOG_CATEGORIES.ERROR, {
            action: "apply_misc_optimizations",
            state: miscEnabled,
            error: err.message
        });
    }
    
    logOutput("Settings application complete!", false, LOG_CATEGORIES.UI, {
        action: "apply_all_settings",
        result: "completed",
        timestamp: new Date().toISOString()
    });
    showToast("All optimization settings applied");
}

// Initialize the application
document.addEventListener("DOMContentLoaded", async () => {
    try {
        // Check if we're running on localhost
        if (!window.location.hostname.match(/^(localhost|127\.0\.0\.1)$/)) {
            showError("Access denied: Web interface can only be accessed from localhost");
            return;
        }

        // Check if we're using HTTPS
        if (window.location.protocol !== 'https:' && !window.location.hostname.match(/^(localhost|127\.0\.0\.1)$/)) {
            showError("Access denied: Web interface must be accessed via HTTPS");
            return;
        }

        // Initialize logging system
        const loggingInitialized = await initLogging();
        if (!loggingInitialized) {
            showError("Failed to initialize logging system");
            return;
        }

        // Initialize security
        const securityInitialized = await initSecurity();
        if (!securityInitialized) {
            return;
        }

        // Log initialization
        logOutput("Initializing GMS Control Panel...", false, LOG_CATEGORIES.SYSTEM, {
            timestamp: new Date().toISOString(),
            userAgent: navigator.userAgent,
            platform: navigator.platform
        });

        // Restore saved states
        restoreToggleStates();
        
        // Initialize components
        await initModuleVersion();
        await initServiceStatus();
        await initToggleStates();
        
        // Set up event listeners
        document.getElementById("killLogdSwitch")?.addEventListener("change", (e) => {
            logOutput(`GMS Optimization toggle changed: ${e.target.checked ? "enabled" : "disabled"}`, false, LOG_CATEGORIES.UI, {
                timestamp: new Date().toISOString(),
                previousState: !e.target.checked
            });
            applyGMSOptimization(e.target.checked);
        });
        
        document.getElementById("miscOptSwitch")?.addEventListener("change", (e) => {
            logOutput(`Miscellaneous Optimizations toggle changed: ${e.target.checked ? "enabled" : "disabled"}`, false, LOG_CATEGORIES.UI, {
                timestamp: new Date().toISOString(),
                previousState: !e.target.checked
            });
            applyMiscOptimizations(e.target.checked);
        });
        
        document.getElementById("applySettings")?.addEventListener("click", () => {
            logOutput("Applying all settings...", false, LOG_CATEGORIES.UI, {
                timestamp: new Date().toISOString()
            });
            applyAllSettings();
        });
        
    } catch (error) {
        console.error("Application initialization failed:", error);
        logOutput("Application initialization failed", true, LOG_CATEGORIES.ERROR, {
            error: error.message,
            stack: error.stack,
            timestamp: new Date().toISOString()
        });
        showError("Application initialization failed. Please refresh the page.");
    }
});

// Clean up on page unload
window.addEventListener("beforeunload", () => {
    cleanupPendingRequests();
}); 