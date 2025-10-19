---

## 🧠 Debugging WSL & Node.js Integration Issue — *DevSecOps Demo Project*

### 📅 Date

**19th October 2025**

### 💻 Context

While working on the **DevSecOps Demo project** inside **WSL (Ubuntu 24.04)**, `npm install` was consistently failing with UNC path errors.

The project path:

```bash
/home/saiteja/devopsProject/devsecops-demo
```

---

## 🚨 Problem Statement

Running `npm install` produced errors like:

```bash
npm error CMD.EXE was started with the above path as the current directory.
npm error UNC paths are not supported.  Defaulting to Windows directory.
npm error Error: Cannot find module 'C:\Windows\install.js'
```

and warnings such as:

```bash
npm warn cleanup Failed to remove some directories [...]
```

Even though Node.js and npm were installed in WSL, npm attempted to execute Windows paths (e.g., `C:\WINDOWS\system32\cmd.exe`).

---

## 🔍 Step-by-Step Debugging

### 1️⃣ Check Node.js and npm locations

```bash
which node
which npm
node -v
npm -v
```

Initial output:

```
node: Command not found
npm: /mnt/c/Program Files/nodejs/npm
```

🧩 **Observation:**
`npm` was picked from **Windows**, not WSL. That meant WSL’s Linux Node environment wasn’t being used properly.

---

### 2️⃣ Installed Node.js inside WSL

```bash
sudo apt install nodejs npm -y
```

Then verified:

```bash
which node
which npm
node -v
npm -v
```

✅ Output:

```
/usr/bin/node
/usr/bin/npm
v22.20.0
10.9.3
```

---

### 3️⃣ Cleaned the environment

To remove any stale modules and cache:

```bash
rm -rf node_modules package-lock.json
npm cache clean --force
```

Then retried `npm install`, but still got the **same error**.

---

### 4️⃣ Checked environment PATH

```bash
echo $PATH
```

Found:

```
/mnt/c/Program Files/nodejs/
```

👀 **Root cause identified:**
WSL automatically merges **Windows PATH entries** with Linux PATH.
This caused WSL’s `npm` to invoke **Windows CMD.EXE**, leading to the UNC path error.

---

### 5️⃣ Temporary Fix (for current session)

```bash
export PATH=$(echo $PATH | tr ':' '\n' | grep -v '/mnt/c/Program Files/nodejs' | tr '\n' ':')
```

Then verified:

```bash
which node
which npm
```

✅ Both pointed to `/usr/bin/`, confirming WSL’s Linux Node was being used.
After that, `npm install` worked perfectly.

---

### 6️⃣ Permanent Fix

To stop WSL from merging Windows paths by default, edited `/etc/wsl.conf`:

```bash
sudo nano /etc/wsl.conf
```

Updated content:

```ini
[boot]
systemd=true

[user]
default=saiteja

[interop]
appendWindowsPath = false
```

Then restarted WSL:

```bash
wsl --shutdown
wsl
```

---

### 7️⃣ Verified clean environment

```bash
echo $PATH | grep "/mnt/c/Program Files"
```

✅ No output — meaning WSL now runs with a **pure Linux environment**.

`npm install` worked flawlessly after that, even across reboots.

---

## 🧩 Key Learnings

| Concept                          | Description                                                                                                                                         |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| **PATH merging in WSL**          | By default, WSL merges Windows system paths into Linux PATH. This helps run Windows commands but can conflict with native Linux tools like Node.js. |
| **UNC Path errors**              | Occur when Windows executables are called from Linux file systems (`\\wsl.localhost\...`), which Windows doesn’t support.                           |
| **appendWindowsPath=false**      | Disables automatic path merging, isolating WSL’s Linux environment for cleaner toolchain behavior.                                                  |
| **Temporary vs Permanent fixes** | Temporary fix modifies PATH for the current session. Permanent fix changes `/etc/wsl.conf` so it persists.                                          |

---

## ✅ Final Outcome

* `npm install` now works cleanly inside WSL Ubuntu 24.04.
* The Node environment uses **Linux binaries** (`/usr/bin/node`, `/usr/bin/npm`).
* The project runs consistently with no cross-OS path issues.
* Environment stays isolated yet interoperable when needed (`explorer.exe`, `code .`, etc. still work).

---

## 💡 Bonus Tip

You can still use Windows tools inside WSL even with `appendWindowsPath=false`:

```bash
explorer.exe .
code .
notepad.exe myfile.txt
```

Interop remains functional — only automatic PATH injection is disabled.

---

## 🧾 Summary

**Root Cause:**
WSL merged Windows PATH (`/mnt/c/Program Files/nodejs`), making npm call Windows CMD.EXE.

**Fix:**
Disable path merging via `/etc/wsl.conf` and use native Linux Node.js binaries.

**Command Highlights:**

```bash
sudo apt install nodejs npm -y
export PATH=$(echo $PATH | tr ':' '\n' | grep -v '/mnt/c/Program Files/nodejs' | tr '\n' ':')
sudo nano /etc/wsl.conf
wsl --shutdown
```

---

## 🏁 Final Verification

```bash
which node      → /usr/bin/node
which npm       → /usr/bin/npm
node -v         → v22.20.0
npm -v          → 10.9.3
npm install     → ✅ Works successfully
```

---

### 📘 Author

**K Sai Teja**

> Documented as part of continuous learning on WSL, Node.js, and DevSecOps tooling environments.

---
