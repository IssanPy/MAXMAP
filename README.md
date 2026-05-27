# MAXMAP - Automated Reconnaissance Pipeline

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0-brightgreen" alt="Version 1.0">
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License MIT"></a>
  <img src="https://img.shields.io/badge/made%20with-%E2%9D%A4%20by%20Max-red" alt="Made with love by Max"/>
  <img src="https://img.shields.io/github/stars/IssanPy/MAXMAP?style=social" alt="Stars">
</p>

<p align="center">
  <img src="logo.png" width="200" alt="MAXMAP Logo"/>
</p>

**MAXMAP** is a one‑command reconnaissance framework that automates:
- 🔎 Subdomain discovery (Subfinder + crt.sh)
- 🟢 Live host probing (httpx)
- 🔌 Port & service scanning (naabu → nmap)
- 📁 Directory brute‑forcing (dirsearch)
- 📊 Parameter harvesting (gau + uro)
- 📜 JavaScript file extraction
- 🧹 Clean, deduplicated outputs ready for further exploitation

---

## ✨ Features

- **12‑step pipeline** – from domain to full report in a single command
- **Auto‑dependency install** – missing tools are fetched and installed on the fly
- **Clean URL normalization** – no duplicate hosts, no protocol/port confusion
- **Progress bar** – live step completion shown during the run
- **Timestamped reports** – organized under `maxmap_reports/domain_timestamp/`

---

## 🛠️ Requirements

The script will automatically install any missing tools (requires `sudo`). It sets up:
- `subfinder`, `httpx`, `naabu`, `gau`, `anew` (via Go)
- `uro` (via pip)
- `dirsearch` (via git)
- `nmap`, `jq`, `curl`, `git`, `pip3` (via apt)

> Tested on: Ubuntu 22.04 / Kali Linux 2024+

---

## 🚀 Quick Start

```bash
git clone https://github.com/your-username/MAXMAP.git
cd MAXMAP
chmod +x maxmap.sh
./maxmap.sh example.com
