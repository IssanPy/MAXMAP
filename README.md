```markdown
# MAXMAP - Automated Reconnaissance Pipeline

<p align="center">
  <img src="<https://img.shields.io/badge/version-1.0-brightgreen>" alt="Version 1.0">
  <a href="<https://opensource.org/licenses/MIT>"><img src="<https://img.shields.io/badge/license-MIT-blue.svg>" alt="License MIT"></a>
  <img src="<https://img.shields.io/badge/made%20with-%E2%9D%A4%20by%20Max-red>" alt="Made with love by Max"/>
  <img src="<https://img.shields.io/github/stars/IssanPy/MAXMAP?style=social>" alt="Stars">
</p>

<p align="center">
  <img src="maxmap.png" width="200" alt="MAXMAP Logo">
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

> **Tested on:** Ubuntu 22.04 / Kali Linux 2024+

---

## 📂 Output Structure
```

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

## 🚀 Quick Start

```bash
git clone <https://github.com/IssanPy/MAXMAP.git>
cd MAXMAP
chmod +x maxmap.sh
./maxmap.sh example.com
```

---

## ⚙️ Customisation

You can change the wordlist used by `dirsearch` by setting the `WORDLIST` environment variable:

```bash
export WORDLIST="/path/to/your/wordlist.txt"
./maxmap.sh example.com
```

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 📜 License

MIT © [Max](https://github.com/IssanPy)

```

4. **Commit the changes** with a message like `Clean README – logo display fix`.

---

## 🖼️ Verify the logo file

- Confirm that the uploaded image is named **exactly** `maxmap.png` (case-sensitive).
- If it's actually `maxmap.PNG` or `maxmap.jpg`, rename it on GitHub: click the file → “Rename” → set the correct name.
- After committing the README, **hard refresh** the repo page (`Ctrl + Shift + R` on Windows) to see the logo.

---

Your MAXMAP repository will now look crisp, professional, and showcase your logo immediately.
If the logo still doesn’t appear, double‑check that the file is a valid PNG image (not corrupted). You can re‑upload it via “Add file” → “Upload files” and replace it.

You’re now ready to share this link with the world – great job, Max! 🚀
```
