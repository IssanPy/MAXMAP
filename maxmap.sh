#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  MAXMAP v1.0 (PRO) – Automated Reconnaissance Pipeline
#  Developer: Max  |  2026 Edition
#  Production Level: Industrial Grade (Zero-Interruption)
# ──────────────────────────────────────────────────────────────────────────────
set -Eeuo pipefail

# ── Colors & UI ───────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "\n${BLUE}${BOLD}[*]${NC} $*"; }
ok()      { echo -e "${GREEN}${BOLD}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[!]${NC} $*"; }
err()     { echo -e "${RED}${BOLD}[-]${NC} $*"; exit 1; }
section() { echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; \
            echo -e "${CYAN}${BOLD}  $*${NC}"; \
            echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ── Typewriter effect ─────────────────────────────────────────────────────────
typewriter() {
    local msg="$1"
    for ((i=0; i<${#msg}; i++)); do
        echo -ne "${CYAN}${BOLD}${msg:$i:1}${NC}"
        sleep 0.02
    done
    echo
}

# ── Progress bar ──────────────────────────────────────────────────────────────
progress() {
    local step="$1" total="$2" desc="$3"
    local pct=$(( step * 100 / total ))
    local filled=$(( pct / 2 ))
    local bar=""
    for ((i=0; i<50; i++)); do
        [[ $i -lt $filled ]] && bar+="█" || bar+="░"
    done
    printf "\r  ${CYAN}[%02d/%02d]${NC} %-40s ${CYAN}[${GREEN}%s${CYAN}]${NC} ${BOLD}%3d%%${NC}" \
        "$step" "$total" "$desc" "$bar" "$pct"
    echo
}

lc() { [[ -f "$1" ]] && wc -l < "$1" || echo 0; }

# ── Pre-Flight Sudo Check (The "No Stuck" Fix) ────────────────────────────────
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo -e "${YELLOW}${BOLD}[!] Sudo privileges required for dependency setup.${NC}"
        sudo -v || err "Sudo authentication failed."
    fi
}

# ── Dependency Engine ─────────────────────────────────────────────────────────
install_deps() {
    section "Initializing Recon Environment"

    # Mapping commands to their apt packages
    declare -A pkg_map=(
        ["nmap"]="nmap"
        ["jq"]="jq"
        ["curl"]="curl"
        ["git"]="git"
        ["pip3"]="python3-pip"
        ["pipx"]="pipx"
        ["massdns"]="massdns"
    )

    local missing_apt=()
    for cmd in "${!pkg_map[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_apt+=("${pkg_map[$cmd]}")
        fi
    done
    
    if [[ ${#missing_apt[@]} -gt 0 ]]; then
        info "Installing missing tools: ${missing_apt[*]}"
        sudo apt-get update -qq && sudo apt-get install -y "${missing_apt[@]}" -qq
    fi

    # PureDNS Resolver Setup
    mkdir -p ~/.config/puredns
    if [[ ! -f ~/.config/puredns/resolvers.txt ]]; then
        info "Downloading high-performance DNS resolvers..."
        curl -s https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt -o ~/.config/puredns/resolvers.txt
    fi

    export PATH="$PATH:$HOME/go/bin:/usr/local/go/bin"

    # Go Tools Setup
    declare -A go_pkgs=(
        ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
        ["naabu"]="github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
        ["gau"]="github.com/lc/gau/v2/cmd/gau@latest"
        ["anew"]="github.com/tomnomnom/anew@latest"
        ["puredns"]="github.com/d3mondev/puredns/v2@latest"
    )

    for tool in "${!go_pkgs[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            info "Go install: $tool…"
            go install "${go_pkgs[$tool]}" >/dev/null 2>&1 || true
        fi
    done

    command -v uro &>/dev/null || pipx install uro -q || true
    command -v dirsearch &>/dev/null || pipx install dirsearch -q || true
    ok "Environment synchronized."
}

# ── Banner ────────────────────────────────────────────────────────────────────
banner() {
    clear
    echo -e "${GREEN}${BOLD}"
    echo '███╗   ███╗ █████╗ ██╗  ██╗███╗   ███╗ █████╗ ██████╗ '
    echo '████╗ ████║██╔══██╗╚██╗██╔╝████╗ ████║██╔══██╗██╔══██╗'
    echo '██╔████╔██║███████║ ╚███╔╝ ██╔████╔██║███████║██████╔╝'
    echo '██║╚██╔╝██║██╔══██║ ██╔██╗ ██║╚██╔╝██║██╔══██║██╔═══╝ '
    echo '██║ ╚═╝ ██║██║  ██║██╔╝ ██╗██║ ╚═╝ ██║██║  ██║██║     '
    echo '╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     '
    echo -e "${NC}"
    typewriter "              developed by Max  •  2026 Edition"
    echo -e "${CYAN}         Automated Reconnaissance Pipeline${NC}\n"
}

# ── Main Pipeline ─────────────────────────────────────────────────────────────
main() {
    local domain="$1"
    [[ ! "$domain" =~ ^[a-z0-9.-]+\.[a-z]{2,}$ ]] && err "Invalid domain format."

    check_sudo
    banner
    install_deps

    local ts=$(date +%Y%m%d_%H%M%S)
    local out="maxmap_reports/${domain}_${ts}"
    mkdir -p "$out" "$out/https/status_codes"
    
    local total=11 step=0
    section "Target: $domain"

    # 1. Passive Discovery
    (( ++step ))
    progress $step $total "Subdomain Discovery (Passive)"
    timeout 300 subfinder -d "$domain" -all -silent -o "$out/sub_raw.txt" 2>/dev/null &
    (curl -s -A "Mozilla/5.0" "https://crt.sh/?q=%25.${domain}&output=json" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u > "$out/crt_raw.txt" || touch "$out/crt_raw.txt") &
    wait

    # 2. Cleanup
    (( ++step ))
    progress $step $total "Sanitizing Subdomains"
    cat "$out/sub_raw.txt" "$out/crt_raw.txt" | grep -E "([a-zA-Z0-9-]+\.)+$domain$" | sort -u > "$out/subdomains.txt"

    # 3. DNS (PureDNS)
    (( ++step ))
    progress $step $total "DNS Resolution (PureDNS)"
    if command -v puredns &>/dev/null; then
        puredns resolve "$out/subdomains.txt" -r ~/.config/puredns/resolvers.txt --quiet > "$out/resolved.txt"
    else
        cp "$out/subdomains.txt" "$out/resolved.txt"
    fi

    # 4. HTTPX
    (( ++step ))
    progress $step $total "HTTP Probing (Httpx)"
    httpx -l "$out/resolved.txt" -threads 100 -silent -o "$out/alive_urls.txt" > /dev/null
    sed -E 's#^https?://##' "$out/alive_urls.txt" | sort -u > "$out/alive_hosts.txt"

    # 5. Naabu
    (( ++step ))
    progress $step $total "Port Scanning (Naabu)"
    naabu -list "$out/resolved.txt" -rate 1000 -retries 2 -timeout 5 -silent -o "$out/ports.txt" > /dev/null

    # 6. Dirsearch
    (( ++step ))
    progress $step $total "Directory Fuzzing (Dirsearch)"
    if [[ -s "$out/alive_urls.txt" ]]; then
        head -n 15 "$out/alive_urls.txt" > "$out/fuzz_targets.txt"
        dirsearch -l "$out/fuzz_targets.txt" -t 50 --random-agent --max-rate=50 --quiet -o "$out/dir_results.txt" > /dev/null 2>&1 || true
    fi

    # 7. GAU
    (( ++step ))
    progress $step $total "URL Harvesting (GAU)"
    gau "$domain" --subs --threads 20 > "$out/all_urls.txt" 2>/dev/null || true

    # 8. JS (Fixed Logic)
    (( ++step ))
    progress $step $total "Extracting JS Intel"
    grep -iE '\.js(\?|$)' "$out/all_urls.txt" | sort -u > "$out/js_raw.txt" || touch "$out/js_raw.txt"
    [[ -s "$out/js_raw.txt" ]] && (uro -i "$out/js_raw.txt" -o "$out/jsfiles_unique.txt" > /dev/null 2>&1 || cp "$out/js_raw.txt" "$out/jsfiles_unique.txt")

    # 9. Parameters
    (( ++step ))
    progress $step $total "Parameter Mining"
    grep "=" "$out/all_urls.txt" | sort -u > "$out/params_raw.txt" || touch "$out/params_raw.txt"
    [[ -s "$out/params_raw.txt" ]] && (uro -i "$out/params_raw.txt" -o "$out/filterparam.txt" > /dev/null 2>&1 || cp "$out/params_raw.txt" "$out/filterparam.txt")

    # 10. Status Codes
    (( ++step ))
    progress $step $total "Analyzing Response Codes"
    if [[ -s "$out/alive_urls.txt" ]]; then
        cat "$out/alive_urls.txt" | httpx -silent -sc -td -title -o "$out/https/httpx_full.txt" > /dev/null
        while IFS= read -r line; do
            code=$(echo "$line" | grep -oE '\[[0-9]{3}\]' | tr -d '[]' || echo "unknown")
            echo "$line" >> "$out/https/status_codes/${code}.txt"
        done < "$out/https/httpx_full.txt"
    fi

    # 11. Final Packaging
    (( ++step ))
    progress $step $total "Finalizing Report"
    
    section "RECON COMPLETE"
    echo -e "  ${BOLD}Results :${NC} ${CYAN}${out}/${NC}"
    echo -e "  ${BOLD}Hosts   :${NC} $(lc "$out/alive_hosts.txt")"
    echo -e "  ${BOLD}JS Files:${NC} $(lc "$out/jsfiles_unique.txt")"
    echo -e "  ${BOLD}Time    :${NC} $(date '+%H:%M:%S')\n"
}

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

main "$1"
