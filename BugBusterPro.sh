#!/bin/bash

# BugBusterPro - Advanced Bug Bounty Reconnaissance Tool
# Author: Bug Bounty Professional
# Version: 1.0.0
# Description: Comprehensive bug bounty hunting reconnaissance script using ffuf
# License: MIT
# GitHub: https://github.com/yourname/bugbusterpro

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log file setup
LOGDIR="./bugbusterpro_logs"
timestamp=$(date +"%Y%m%d_%H%M%S")
LOGFILE="$LOGDIR/bugbusterpro_$timestamp.log"

# Banner function
print_banner() {
    echo -e "${CYAN}"
    echo "██████╗ ██╗   ██╗ ██████╗ ██████╗ ██╗   ██╗███████╗████████╗███████╗██████╗ ██████╗ ██████╗  ██████╗ "
    echo "██╔══██╗██║   ██║██╔════╝ ██╔══██╗██║   ██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔═══██╗"
    echo "██████╔╝██║   ██║██║  ███╗██████╔╝██║   ██║███████╗   ██║   █████╗  ██████╔╝██████╔╝██████╔╝██║   ██║"
    echo "██╔══██╗██║   ██║██║   ██║██╔══██╗██║   ██║╚════██║   ██║   ██╔══╝  ██╔══██╗██╔═══╝ ██╔══██╗██║   ██║"
    echo "██████╔╝╚██████╔╝╚██████╔╝██████╔╝╚██████╔╝███████║   ██║   ███████╗██║  ██║██║     ██║  ██║╚██████╔╝"
    echo "╚═════╝  ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ "
    echo -e "${NC}"
    echo -e "${YELLOW}The Advanced Bug Bounty Reconnaissance Tool${NC}"
    echo -e "${BLUE}Version: 1.0.0${NC}"
    echo -e "${BLUE}Author: Bug Bounty Professional${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo ""
}

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}[*] Checking dependencies...${NC}"
    local deps=("ffuf" "nmap" "subfinder" "httpx" "nuclei" "jq" "curl" "git")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}[-] Missing dependencies: ${missing[*]}${NC}"
        echo -e "${YELLOW}[*] Please install the missing dependencies and run the script again.${NC}"
        echo -e "${YELLOW}[*] You might install them using:${NC}"
        echo -e "${GREEN}    apt install nmap jq curl git${NC}"
        echo -e "${GREEN}    go install github.com/ffuf/ffuf/v2@latest${NC}"
        echo -e "${GREEN}    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest${NC}"
        echo -e "${GREEN}    go install github.com/projectdiscovery/httpx/cmd/httpx@latest${NC}"
        echo -e "${GREEN}    go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest${NC}"
        exit 1
    else
        echo -e "${GREEN}[+] All dependencies are installed.${NC}"
    fi
}

# Usage information
usage() {
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  ./bugbusterpro.sh -d <domain> [options]"
    echo -e ""
    echo -e "${CYAN}Options:${NC}"
    echo -e "  -d, --domain <domain>        Target domain to scan"
    echo -e "  -o, --output <directory>     Output directory (default: ./results)"
    echo -e "  -w, --wordlist <wordlist>    Path to wordlist for fuzzing (default: SecLists paths)"
    echo -e "  -t, --threads <number>       Number of threads (default: 50)"
    echo -e "  -a, --aggressive             Enable aggressive scanning mode"
    echo -e "  -s, --subdomain-enum         Perform subdomain enumeration"
    echo -e "  -p, --port-scan              Perform port scanning"
    echo -e "  -v, --vulnerabilities        Check for vulnerabilities using nuclei"
    echo -e "  -f, --full                   Perform full reconnaissance (all options)"
    echo -e "  -h, --help                   Display this help message"
    echo -e ""
    echo -e "${CYAN}Examples:${NC}"
    echo -e "  ./bugbusterpro.sh -d example.com -f"
    echo -e "  ./bugbusterpro.sh -d example.com -s -p -v"
    echo -e "  ./bugbusterpro.sh -d example.com -w /path/to/wordlist.txt -t 100"
    echo -e ""
    exit 0
}

# Log message function
log_message() {
    local message="$1"
    local level="$2"
    local color=""

    case "$level" in
        "INFO") color="${BLUE}" ;;
        "SUCCESS") color="${GREEN}" ;;
        "WARNING") color="${YELLOW}" ;;
        "ERROR") color="${RED}" ;;
        *) color="${NC}" ;;
    esac

    echo -e "${color}[$(date +"%Y-%m-%d %H:%M:%S")] [$level] $message${NC}"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$level] $message" >> "$LOGFILE"
}

# Initialize results directory
init_directories() {
    if [ ! -d "$LOGDIR" ]; then
        mkdir -p "$LOGDIR"
        log_message "Created log directory: $LOGDIR" "INFO"
    fi

    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        log_message "Created output directory: $OUTPUT_DIR" "INFO"
    fi

    # Create subdirectories for different types of results
    mkdir -p "$OUTPUT_DIR/subdomains"
    mkdir -p "$OUTPUT_DIR/endpoints"
    mkdir -p "$OUTPUT_DIR/paths"
    mkdir -p "$OUTPUT_DIR/parameters"
    mkdir -p "$OUTPUT_DIR/ports"
    mkdir -p "$OUTPUT_DIR/vulnerabilities"
    mkdir -p "$OUTPUT_DIR/screenshots"
    mkdir -p "$OUTPUT_DIR/wordlists"
}

# Subdomain enumeration
enumerate_subdomains() {
    log_message "Starting subdomain enumeration for $TARGET_DOMAIN" "INFO"
    
    local subdomains_file="$OUTPUT_DIR/subdomains/subdomains.txt"
    local live_subdomains_file="$OUTPUT_DIR/subdomains/live_subdomains.txt"
    
    # Run subfinder
    log_message "Running subfinder..." "INFO"
    subfinder -d "$TARGET_DOMAIN" -silent -o "$subdomains_file"
    
    # Count discovered subdomains
    local subdomain_count=$(wc -l < "$subdomains_file")
    log_message "Discovered $subdomain_count subdomains" "SUCCESS"
    
    # Check for live subdomains
    log_message "Checking for live subdomains with httpx..." "INFO"
    cat "$subdomains_file" | httpx -silent -o "$live_subdomains_file"
    
    # Count live subdomains
    local live_subdomain_count=$(wc -l < "$live_subdomains_file")
    log_message "Found $live_subdomain_count live subdomains" "SUCCESS"
    
    # Return the file with live subdomains
    echo "$live_subdomains_file"
}

# Port scanning
scan_ports() {
    local target="$1"
    local output_file="$OUTPUT_DIR/ports/ports_$target.txt"
    
    log_message "Starting port scan for $target" "INFO"
    
    # Quick scan of common ports first
    nmap -T4 -F "$target" -oN "$output_file"
    
    # If aggressive mode is enabled, perform a more thorough scan
    if [ "$AGGRESSIVE" = true ]; then
        log_message "Performing aggressive port scan for $target" "INFO"
        nmap -T4 -p- --max-retries 1 "$target" -oN "${output_file%.txt}_full.txt"
    fi
    
    log_message "Port scan completed for $target" "SUCCESS"
}

# Directory and file fuzzing with ffuf
fuzz_directories() {
    local target="$1"
    local wordlist="$2"
    local output_file="$OUTPUT_DIR/paths/${target//\//_}_paths.json"
    
    log_message "Starting directory fuzzing for $target" "INFO"
    
    # Run ffuf for directory and file fuzzing
    ffuf -u "$target/FUZZ" \
         -w "$wordlist" \
         -mc 200,201,202,203,204,301,302,307,308,401,403,405 \
         -t "$THREADS" \
         -o "$output_file" \
         -of json
    
    # Extract successful findings
    local path_count=$(jq '.results | length' "$output_file")
    log_message "Discovered $path_count paths on $target" "SUCCESS"
    
    # Create a filtered list of interesting paths
    jq -r '.results[] | select(.status >= 200 and .status < 404) | .url' "$output_file" > "${output_file%.json}_interesting.txt"
}

# Parameter fuzzing with ffuf
fuzz_parameters() {
    local target="$1"
    local wordlist="$2"
    local output_file="$OUTPUT_DIR/parameters/${target//\//_}_params.json"
    
    log_message "Starting parameter fuzzing for $target" "INFO"
    
    # Run ffuf for parameter fuzzing
    ffuf -u "$target?FUZZ=test" \
         -w "$wordlist" \
         -mc 200,201,202,203,204,301,302,307,308,401,403,405 \
         -t "$THREADS" \
         -o "$output_file" \
         -of json
    
    # Extract successful findings
    local param_count=$(jq '.results | length' "$output_file")
    log_message "Discovered $param_count potential parameters on $target" "SUCCESS"
    
    # Create a filtered list of interesting parameters
    jq -r '.results[] | select(.status >= 200 and .status < 404) | .input.FUZZ' "$output_file" > "${output_file%.json}_interesting.txt"
}

# Check for common vulnerabilities using nuclei
check_vulnerabilities() {
    local target="$1"
    local output_file="$OUTPUT_DIR/vulnerabilities/${target//\//_}_vulns.txt"
    
    log_message "Starting vulnerability scanning for $target" "INFO"
    
    # Run nuclei with common templates
    nuclei -u "$target" \
           -t cves/,vulnerabilities/,misconfiguration/,exposures/ \
           -o "$output_file" \
           -silent
    
    # Count found vulnerabilities
    local vuln_count=$(wc -l < "$output_file")
    
    if [ "$vuln_count" -gt 0 ]; then
        log_message "Found $vuln_count potential vulnerabilities on $target" "WARNING"
    else
        log_message "No common vulnerabilities found on $target" "INFO"
    fi
}

# Generate a report
generate_report() {
    local report_file="$OUTPUT_DIR/report.md"
    
    log_message "Generating report..." "INFO"
    
    # Create report header
    cat > "$report_file" << EOF
# Bug Bounty Reconnaissance Report

## Target: $TARGET_DOMAIN
## Date: $(date +"%Y-%m-%d")
## Generated by: BugBusterPro v1.0.0

## Summary

EOF
    
    # Add subdomain information
    local subdomain_count=0
    local live_subdomain_count=0
    
    if [ -f "$OUTPUT_DIR/subdomains/subdomains.txt" ]; then
        subdomain_count=$(wc -l < "$OUTPUT_DIR/subdomains/subdomains.txt")
    fi
    
    if [ -f "$OUTPUT_DIR/subdomains/live_subdomains.txt" ]; then
        live_subdomain_count=$(wc -l < "$OUTPUT_DIR/subdomains/live_subdomains.txt")
    fi
    
    cat >> "$report_file" << EOF
### Subdomains
- Total discovered: $subdomain_count
- Live subdomains: $live_subdomain_count

EOF
    
    # Add paths information
    local path_files=("$OUTPUT_DIR/paths/"*_interesting.txt)
    local total_paths=0
    
    for file in "${path_files[@]}"; do
        if [ -f "$file" ]; then
            local count=$(wc -l < "$file")
            total_paths=$((total_paths + count))
        fi
    done
    
    cat >> "$report_file" << EOF
### Interesting Paths
- Total discovered: $total_paths

EOF
    
    # Add vulnerability information
    local vuln_files=("$OUTPUT_DIR/vulnerabilities/"*.txt)
    local total_vulns=0
    
    for file in "${vuln_files[@]}"; do
        if [ -f "$file" ]; then
            local count=$(wc -l < "$file")
            total_vulns=$((total_vulns + count))
        fi
    done
    
    cat >> "$report_file" << EOF
### Potential Vulnerabilities
- Total discovered: $total_vulns

EOF
    
    # Add details sections
    if [ "$live_subdomain_count" -gt 0 ]; then
        cat >> "$report_file" << EOF
## Live Subdomains

\`\`\`
$(cat "$OUTPUT_DIR/subdomains/live_subdomains.txt")
\`\`\`

EOF
    fi
    
    # Add details about potential vulnerabilities
    if [ "$total_vulns" -gt 0 ]; then
        cat >> "$report_file" << EOF
## Potential Vulnerabilities

EOF
        
        for file in "${vuln_files[@]}"; do
            if [ -f "$file" ] && [ -s "$file" ]; then
                local target=$(basename "$file" | sed 's/_vulns.txt//')
                
                cat >> "$report_file" << EOF
### $target

\`\`\`
$(cat "$file")
\`\`\`

EOF
            fi
        done
    fi
    
    log_message "Report generated: $report_file" "SUCCESS"
}

# Main function
main() {
    print_banner
    check_dependencies
    
    # Default values
    TARGET_DOMAIN=""
    OUTPUT_DIR="./results"
    WORDLIST="/usr/share/seclists/Discovery/Web-Content/common.txt"
    PARAMS_WORDLIST="/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt"
    THREADS=50
    AGGRESSIVE=false
    DO_SUBDOMAIN_ENUM=false
    DO_PORT_SCAN=false
    DO_VULN_CHECK=false
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -d|--domain) TARGET_DOMAIN="$2"; shift ;;
            -o|--output) OUTPUT_DIR="$2"; shift ;;
            -w|--wordlist) WORDLIST="$2"; shift ;;
            -t|--threads) THREADS="$2"; shift ;;
            -a|--aggressive) AGGRESSIVE=true ;;
            -s|--subdomain-enum) DO_SUBDOMAIN_ENUM=true ;;
            -p|--port-scan) DO_PORT_SCAN=true ;;
            -v|--vulnerabilities) DO_VULN_CHECK=true ;;
            -f|--full) 
                DO_SUBDOMAIN_ENUM=true
                DO_PORT_SCAN=true
                DO_VULN_CHECK=true
                ;;
            -h|--help) usage ;;
            *) echo -e "${RED}Unknown parameter: $1${NC}"; usage ;;
        esac
        shift
    done
    
    # Check mandatory arguments
    if [ -z "$TARGET_DOMAIN" ]; then
        echo -e "${RED}Error: Target domain is required${NC}"
        usage
    fi
    
    # Initialize directories
    init_directories
    
    log_message "Starting reconnaissance on $TARGET_DOMAIN" "INFO"
    log_message "Results will be saved to $OUTPUT_DIR" "INFO"
    
    # Perform subdomain enumeration if requested
    if [ "$DO_SUBDOMAIN_ENUM" = true ]; then
        live_subdomains_file=$(enumerate_subdomains)
        targets_file="$live_subdomains_file"
    else
        echo "https://$TARGET_DOMAIN" > "$OUTPUT_DIR/targets.txt"
        targets_file="$OUTPUT_DIR/targets.txt"
    fi
    
    # Check if SecLists is installed and use it, otherwise download common wordlists
    if [ ! -f "$WORDLIST" ]; then
        log_message "Wordlist not found: $WORDLIST" "WARNING"
        log_message "Downloading common wordlists..." "INFO"
        
        mkdir -p "$OUTPUT_DIR/wordlists"
        curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt" -o "$OUTPUT_DIR/wordlists/common.txt"
        curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/burp-parameter-names.txt" -o "$OUTPUT_DIR/wordlists/params.txt"
        
        WORDLIST="$OUTPUT_DIR/wordlists/common.txt"
        PARAMS_WORDLIST="$OUTPUT_DIR/wordlists/params.txt"
        
        log_message "Wordlists downloaded" "SUCCESS"
    fi
    
    # Process each target
    while read -r target; do
        # Skip empty lines
        [ -z "$target" ] && continue
        
        log_message "Processing target: $target" "INFO"
        
        # Port scanning
        if [ "$DO_PORT_SCAN" = true ]; then
            scan_ports "$target"
        fi
        
        # Directory and file fuzzing
        fuzz_directories "$target" "$WORDLIST"
        
        # Parameter fuzzing
        fuzz_parameters "$target" "$PARAMS_WORDLIST"
        
        # Vulnerability scanning
        if [ "$DO_VULN_CHECK" = true ]; then
            check_vulnerabilities "$target"
        fi
        
    done < "$targets_file"
    
    # Generate final report
    generate_report
    
    log_message "Reconnaissance completed for $TARGET_DOMAIN" "SUCCESS"
    log_message "Results and report saved to $OUTPUT_DIR" "SUCCESS"
}

# Run the main function
main "$@"
