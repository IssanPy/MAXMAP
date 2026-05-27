#!/usr/bin/env bash
#  MAXMAP - Automated Reconnaissance Pipeline
#  Developer: Max 
set -uo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
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
        sleep 0.03
    done
    echo
}

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
    echo -e "${BOLD}Usage:${NC} $0 <domain>"
    echo -e "${BOLD}Example:${NC} $0 example.com"
    echo -e "Outputs saved in: ${CYAN}maxmap_reports/<domain>_<timestamp>/${NC}"
    exit 0
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
    echo -e "${CYAN}         Automated Reconnaissance Pipeline${NC}"
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

# ── Count lines safely ────────────────────────────────────────────────────────
lc() { [[ -f "$1" ]] && wc -l < "$1" || echo 0; }

# ── Dependency check & install ────────────────────────────────────────────────
install_deps() {
    section "Checking Dependencies"

    local apt_tools=("nmap" "jq" "curl" "git" "pip3")
    local go_tools=("subfinder" "httpx" "naabu" "gau" "anew")
    local pip_tools=("uro")
    local missing_apt=() missing_go=() missing_pip=()

    for t in "${apt_tools[@]}";  do command -v "$t"        &>/dev/null || missing_apt+=("$t"); done
    for t in "${go_tools[@]}";   do command -v "$t"        &>/dev/null || missing_go+=("$t");  done
    for t in "${pip_tools[@]}";  do command -v "$t"        &>/dev/null || missing_pip+=("$t"); done

    local total_missing=$(( ${#missing_apt[@]} + ${#missing_go[@]} + ${#missing_pip[@]} ))

    if [[ $total_missing -eq 0 ]]; then
        ok "All dependencies satisfied. Proceeding…"
        return 0
    fi

    warn "Missing tools detected: ${missing_apt[*]:-} ${missing_go[*]:-} ${missing_pip[*]:-}"
    info "Requesting elevated privileges for installation…"
    sudo -v || err "sudo access required for dependency installation."

    # ── APT packages ──────────────────────────────────────────────────────
    if [[ ${#missing_apt[@]} -gt 0 ]]; then
        info "Installing system packages: ${missing_apt[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y "${missing_apt[@]}" -qq || true
        ok "System packages installed."
    fi

    # ── Go environment ────────────────────────────────────────────────────
    if [[ ${#missing_go[@]} -gt 0 ]]; then
        if ! command -v go &>/dev/null; then
            info "Go not found – installing Go 1.22.4…"
            local GO_VER="1.22.4"
            local GO_TAR="go${GO_VER}.linux-amd64.tar.gz"
            curl -fsSL "https://go.dev/dl/${GO_TAR}" -o "/tmp/${GO_TAR}" || true
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf "/tmp/${GO_TAR}" || true
            export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
            ok "Go installed."
        else
            export PATH="$HOME/go/bin:$PATH"
        fi

        declare -A GO_PKGS=(
            [subfinder]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
            [httpx]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
            [naabu]="github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
            [gau]="github.com/lc/gau/v2/cmd/gau@latest"
            [anew]="github.com/tomnomnom/anew@latest"
        )

        for tool in "${missing_go[@]}"; do
            info "Installing $tool…"
            GOPATH="$HOME/go" go install "${GO_PKGS[$tool]}" 2>/dev/null || true
            sudo cp "$HOME/go/bin/$tool" /usr/local/bin/ 2>/dev/null || true
            command -v "$tool" &>/dev/null && ok "$tool installed." || warn "$tool install may have failed."
        done
    fi

    # ── Python / pip tools ────────────────────────────────────────────────
    if [[ ${#missing_pip[@]} -gt 0 ]]; then
        for tool in "${missing_pip[@]}"; do
            info "Installing $tool via pip…"
            pip3 install "$tool" --break-system-packages -q 2>/dev/null || pip3 install --user "$tool" -q || true
            export PATH="$HOME/.local/bin:$PATH"
            command -v "$tool" &>/dev/null && ok "$tool installed." || warn "$tool install may have failed."
        done
    fi

    ok "Dependency installation complete."
}

# ── Main pipeline ─────────────────────────────────────────────────────────────
main() {
    local domain="$1"

    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        err "Invalid domain format: $domain"
    fi

    local ts; ts=$(date +%Y%m%d_%H%M%S)
    local base="maxmap_reports"
    local out="${base}/${domain}_${ts}"
    local total=12 step=0

    mkdir -p "$out" "$out/https"
    banner

    echo -e "  ${BOLD}Target  :${NC} ${GREEN}${domain}${NC}"
    echo -e "  ${BOLD}Output  :${NC} ${CYAN}${out}/${NC}"
    echo -e "  ${BOLD}Started :${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo

    # ── 1: Subfinder (with timeout) ─────────────────────────────────────────
    (( step++ ))
    progress $step $total "Subfinder – passive subdomain enum"
    timeout 300 subfinder -d "$domain" -all -silent -o "$out/all_subdomains.txt" 2>/dev/null || true
    ok "Subfinder: $(lc "$out/all_subdomains.txt") subdomains"

    # ── 2: crt.sh JSON dump (two queries merged) ─────────────────────────────
    (( step++ ))
    progress $step $total "crt.sh – full certificate info"
    local crt_raw="$out/crt_raw.json"
    {
        timeout 30 curl -s "https://crt.sh/?q=${domain}&output=json" || true
        timeout 30 curl -s "https://crt.sh/?q=%.${domain}&output=json" || true
    } | jq -s 'add' > "$crt_raw" 2>/dev/null || true
    if [[ -s "$crt_raw" ]]; then
        jq '.' "$crt_raw" > "$out/crt_info.json" 2>/dev/null || true
        ok "crt.sh info saved → crt_info.json"
    else
        warn "crt.sh returned no data – using empty dataset."
        echo '[]' > "$out/crt_info.json"
        echo '[]' > "$crt_raw"
    fi

    # ── 3: crt.sh subdomain extraction ──────────────────────────────────────
    (( step++ ))
    progress $step $total "crt.sh – subdomain extraction"
    if [[ -s "$crt_raw" ]]; then
        jq -r '.[].name_value' "$crt_raw" 2>/dev/null \
            | sed 's/\*\.//g' \
            | grep -F "$domain" \
            | sort -u > "$out/crt_subdomains.txt" || true
        ok "crt.sh extracted: $(lc "$out/crt_subdomains.txt") subdomains"
    else
        touch "$out/crt_subdomains.txt"
        warn "No crt.sh data – skipping extraction."
    fi

    # Merge → subdomains.txt
    cat "$out/all_subdomains.txt" "$out/crt_subdomains.txt" 2>/dev/null \
        | sort -u > "$out/subdomains.txt"
    ok "Combined unique subdomains: $(lc "$out/subdomains.txt")"

    # ── 4: httpx – alive probe, separate hostnames and base URLs ─────────────
    (( step++ ))
    progress $step $total "httpx – probing live hosts"
    timeout 120 httpx -l "$out/subdomains.txt" \
          -ports 443,80,8080,8000,8888 \
          -threads 200 -silent \
          2>/dev/null | tee "$out/subdomains_alive_raw.txt" >/dev/null || true

    if [[ -s "$out/subdomains_alive_raw.txt" ]]; then
        # Unique hostnames (no scheme/port/path)
        sed -E 's#^https?://##; s#:[0-9]+(/.*)?$##; s#/.*$##' "$out/subdomains_alive_raw.txt" \
            | sort -u > "$out/subdomains_alive_hosts.txt"
        # Full base URLs (scheme, no port) for dirsearch etc.
        sed -E 's#^(https?://[^:/]+).*#\1#' "$out/subdomains_alive_raw.txt" \
            | sort -u > "$out/subdomains_alive_urls.txt"
    else
        touch "$out/subdomains_alive_hosts.txt" "$out/subdomains_alive_urls.txt"
    fi
    ok "Live hosts: $(lc "$out/subdomains_alive_hosts.txt")"

    # ── 5: naabu + nmap deep scan ────────────────────────────────────────────
    (( step++ ))
    progress $step $total "naabu + nmap – port & service scan"
    timeout 300 naabu -list "$out/subdomains.txt" -c 50 -silent -o "$out/naabu_raw.txt" 2>/dev/null || true
    if [[ -s "$out/naabu_raw.txt" ]]; then
        cut -d: -f1 "$out/naabu_raw.txt" | sort -u > "$out/nmap_targets.txt"
        timeout 600 nmap -iL "$out/nmap_targets.txt" -sV -sC -T4 --open \
             -oN "$out/nmap_full.txt" &>/dev/null || true
        ok "nmap report → nmap_full.txt"
    else
        warn "naabu found no open ports – skipping nmap."
    fi

    # ── 6: naabu URL list with ports (correct protocol) ─────────────────────
    (( step++ ))
    progress $step $total "Building URL list with ports"
    if [[ -s "$out/naabu_raw.txt" ]]; then
        awk -F: '{
            if ($2 == 443) print "https://" $1 ":" $2;
            else print "http://" $1 ":" $2;
        }' "$out/naabu_raw.txt" | sort -u > "$out/naabu_ports.txt" || true
        ok "Port URLs → naabu_ports.txt ($(lc "$out/naabu_ports.txt") entries)"
    else
        touch "$out/naabu_ports.txt"
        warn "No open ports – naabu_ports.txt empty."
    fi

    # ── 7: dirsearch directory brute-force ───────────────────────────────────
    (( step++ ))
    progress $step $total "dirsearch – directory brute-force"
    WORDLIST="${WORDLIST:-/home/coffinxp/oneforall/onelistforallshort.txt}"
    if [[ ! -f "$WORDLIST" ]]; then
        WORDLIST="/usr/share/seclists/Discovery/Web-Content/common.txt"
    fi
    if [[ ! -f "$WORDLIST" ]]; then
        WORDLIST="/usr/share/wordlists/dirb/common.txt"
    fi

    if ! command -v dirsearch &>/dev/null; then
        warn "dirsearch not found – attempting install…"
        pip3 install dirsearch --break-system-packages -q 2>/dev/null || true
    fi

    if command -v dirsearch &>/dev/null && [[ -f "$WORDLIST" ]] && [[ -s "$out/subdomains_alive_urls.txt" ]]; then
        timeout 600 dirsearch -l "$out/subdomains_alive_urls.txt" \
                  -x 500,502,429,404,403 -r -R 2 \
                  --random-user-agent -t 50 -F \
                  -o "$out/directory.txt" \
                  -w "$WORDLIST" \
                  --quiet 2>/dev/null || true
        ok "dirsearch → directory.txt"
    else
        warn "dirsearch, wordlist, or alive URLs missing – step skipped."
    fi

    # ── 8: gau – parameter discovery (hostnames only) ────────────────────────
    (( step++ ))
    progress $step $total "gau – parameter URL discovery"
    if [[ -s "$out/subdomains_alive_hosts.txt" ]]; then
        timeout 300 cat "$out/subdomains_alive_hosts.txt" \
            | gau --threads 10 2>/dev/null \
            | grep "=" | sort -u > "$out/param.txt" || true
    else
        touch "$out/param.txt"
    fi
    ok "Raw parameter URLs → param.txt ($(lc "$out/param.txt") lines)"

    # ── 9: uro – deduplicate parameters ─────────────────────────────────────
    (( step++ ))
    progress $step $total "uro – deduplicating parameters"
    if [[ -s "$out/param.txt" ]]; then
        uro -i "$out/param.txt" -o "$out/filterparam.txt" 2>/dev/null || true
        ok "Unique params → filterparam.txt ($(lc "$out/filterparam.txt") entries)"
    else
        warn "param.txt is empty – skipping uro."
        touch "$out/filterparam.txt"
    fi

    # ── 10: grep JS files ────────────────────────────────────────────────────
    (( step++ ))
    progress $step $total "Extracting JavaScript file URLs"
    grep -iE '\.js(\?|$)' "$out/filterparam.txt" 2>/dev/null \
        | sort -u > "$out/jsfiles.txt" || true
    ok "JS file URLs → jsfiles.txt ($(lc "$out/jsfiles.txt") entries)"

    # ── 11: uro on JS files ──────────────────────────────────────────────────
    (( step++ ))
    progress $step $total "uro – deduplicating JS URLs"
    if [[ -s "$out/jsfiles.txt" ]]; then
        uro -i "$out/jsfiles.txt" -o "$out/jsfiles_uro.txt" 2>/dev/null || true
        ok "Unique JS URLs → jsfiles_uro.txt ($(lc "$out/jsfiles_uro.txt") entries)"
    else
        warn "jsfiles.txt is empty – skipping."
        touch "$out/jsfiles_uro.txt"
    fi

    # ── 12: httpx deep scan + 200 OK ────────────────────────────────────────
    (( step++ ))
    progress $step $total "httpx – deep scan + 200 OK filter"
    if [[ -s "$out/subdomains_alive_hosts.txt" ]]; then
        timeout 120 httpx -l "$out/subdomains_alive_hosts.txt" \
              -sc -title -td -cl \
              -silent \
              -o "$out/https/httpx_results.txt" 2>/dev/null || true
        grep -F ' [200]' "$out/https/httpx_results.txt" 2>/dev/null \
            > "$out/https/200_ok.txt" || true
    else
        touch "$out/https/httpx_results.txt" "$out/https/200_ok.txt"
    fi
    ok "httpx results → https/httpx_results.txt"
    ok "200 OK hosts → https/200_ok.txt ($(lc "$out/https/200_ok.txt") hosts)"

    # ── Summary ──────────────────────────────────────────────────────────────
    echo
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}  ✔  MAXMAP COMPLETED${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BOLD}Output directory:${NC}          ${CYAN}${out}/${NC}"
    echo -e "  ${BOLD}Total subdomains:${NC}            $(lc "$out/subdomains.txt")"
    echo -e "  ${BOLD}Live hosts:${NC}                  $(lc "$out/subdomains_alive_hosts.txt")"
    echo -e "  ${BOLD}Parameter URLs (unique):${NC}     $(lc "$out/filterparam.txt")"
    echo -e "  ${BOLD}JS files (unique):${NC}           $(lc "$out/jsfiles_uro.txt")"
    echo -e "  ${BOLD}200 OK endpoints:${NC}            $(lc "$out/https/200_ok.txt")"
    echo
    echo -e "${BLUE}${BOLD}  Finished:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo
}

# ── Entry point ───────────────────────────────────────────────────────────────
[[ $# -ne 1 ]] && usage
[[ "$1" == "-h" || "$1" == "--help" ]] && usage

trap 'echo -e "\n\n${RED}${BOLD}[!] Interrupted by user.${NC}\n"; exit 130' INT TERM

install_deps
main "$1"
