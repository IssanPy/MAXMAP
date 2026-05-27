# MAXMAP — Automated Reconnaissance Pipeline

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0-red?style=for-the-badge">
  <img src="https://img.shields.io/badge/platform-Kali%20Linux-black?style=for-the-badge">
  <img src="https://img.shields.io/badge/bash-framework-darkred?style=for-the-badge">
  <img src="https://img.shields.io/github/stars/IssanPy/MAXMAP?style=for-the-badge">
  <img src="https://img.shields.io/badge/license-MIT-darkred?style=for-the-badge">
</p>

<p align="center">
  <img src="maxmap.png" width="320" alt="MAXMAP Logo">
</p>

<p align="center">
  <b>Advanced Automated Reconnaissance Framework for Bug Bounty Hunters, Pentesters & Red Teamers</b>
</p>

---

# 🩸 Overview

**MAXMAP** is a high-performance automated reconnaissance framework designed for modern offensive security operations.  
It combines passive intelligence gathering, active enumeration, endpoint discovery, parameter harvesting, JavaScript extraction, port scanning, and HTTP fingerprinting into one powerful reconnaissance pipeline.

MAXMAP focuses on:
- ⚡ Speed
- 🧠 Clean reconnaissance workflows
- 📡 Attack surface discovery
- 🧹 Data normalization
- 🔥 Scalable recon automation

Built for:
- Bug bounty hunters
- Penetration testers
- Red team operators
- Security researchers
- Web application hunters

---

# ⚔️ Core Features

- 🔎 Passive subdomain enumeration
- 🌐 Certificate Transparency scraping (`crt.sh`)
- 🟢 Live host probing with `httpx`
- 🔌 Port scanning using `naabu`
- 🛰️ Deep service enumeration with `nmap`
- 📁 Directory brute-forcing with `dirsearch`
- 📊 Historical parameter harvesting (`gau`)
- 📜 JavaScript file extraction
- 🧹 URL & hostname normalization
- ⚡ Auto dependency installation
- 📂 Organized timestamped reporting
- 📈 Real-time progress tracking
- ⏱️ Timeout protection & stable execution

---

# 🧠 Recon Pipeline

```text
Subfinder
    ↓
crt.sh Enumeration
    ↓
Live Host Detection
    ↓
Port Discovery
    ↓
Service Enumeration
    ↓
Directory Bruteforce
    ↓
Parameter Harvesting
    ↓
JavaScript Extraction
    ↓
Deduplication & Filtering
    ↓
Structured Recon Reports
```

---

# 🚀 Installation

## Clone Repository

```bash
git clone https://github.com/IssanPy/MAXMAP.git
cd MAXMAP
chmod +x maxmap.sh
```

---

# ⚡ Usage

```bash
./maxmap.sh example.com
```

Example:

```bash
./maxmap.sh target.com
```

---

# 📂 Output Structure

```text
maxmap_reports/<domain>_<timestamp>/
├── all_subdomains.txt
├── crt_info.json
├── crt_raw.json
├── crt_subdomains.txt
├── subdomains.txt
├── subdomains_alive_raw.txt
├── subdomains_alive_hosts.txt
├── subdomains_alive_urls.txt
├── naabu_raw.txt
├── naabu_ports.txt
├── nmap_full.txt
├── directory.txt
├── param.txt
├── filterparam.txt
├── jsfiles.txt
├── jsfiles_uro.txt
└── https/
    ├── httpx_results.txt
    └── 200_ok.txt
```

---

# 🛠️ Dependencies

MAXMAP automatically installs missing dependencies.

### System Packages
- `nmap`
- `jq`
- `curl`
- `git`
- `pip3`

### Go Tools
- `subfinder`
- `httpx`
- `naabu`
- `gau`
- `anew`

### Python Tools
- `uro`
- `dirsearch`

---

# ⚙️ Custom Wordlists

You can specify your own directory brute-force wordlist:

```bash
export WORDLIST="/path/to/wordlist.txt"
./maxmap.sh example.com
```

---

# 🔥 Technologies Used

- Bash
- ProjectDiscovery Toolchain
- Nmap
- Dirsearch
- jq
- curl
- Linux Networking Utilities

---

# 🛡️ Use Cases

- Bug Bounty Reconnaissance
- Attack Surface Mapping
- Web Application Enumeration
- VAPT Automation
- Red Team Recon
- Asset Discovery
- Endpoint Harvesting
- Parameter Mining

---

# 📸 Screenshots

<p align="center">
  <img src="maxmap.png" width="500">
</p>

---

# ⚠️ Disclaimer

This tool is created strictly for:
- Educational purposes
- Authorized security testing
- Legal reconnaissance activities

The developer is not responsible for any misuse or illegal activity performed using this framework.

---

# 🤝 Contributing

Pull requests, improvements, and feature suggestions are welcome.

If you'd like to improve MAXMAP:
1. Fork the repository
2. Create your feature branch
3. Commit changes
4. Open a pull request

---

# 📜 License

MIT License © Max

---

# 🩸 Developer

<p align="center">
  <b>MAX — 2026 Edition</b><br>
  Offensive Security • Recon Automation • Cyber Operations
</p>
