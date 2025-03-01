# BugBusterPro

![BugBusterPro Logo](https://imgur.com/placeholder/400/200)

## Komplexní nástroj pro bug bounty hunting a bezpečnostní testování

BugBusterPro je výkonný, automatizovaný nástroj pro bug bounty hunting, který využívá ffuf a další populární nástroje k provedení komplexního průzkumu cílové domény. Tento skript je navržen tak, aby usnadnil a zefektivnil proces hledání zranitelností v rámci bug bounty programů.

## Hlavní funkce

- **Subdomain enumeration**: Objevování subdomén pomocí nástroje subfinder a ověření jejich dostupnosti pomocí httpx
- **Port scanning**: Skenování otevřených portů pomocí nmap
- **Directory & file fuzzing**: Vyhledávání skrytých adresářů a souborů pomocí ffuf
- **Parameter fuzzing**: Objevování parametrů webových aplikací s ffuf
- **Vulnerability scanning**: Detekce běžných zranitelností pomocí nástroje nuclei
- **Comprehensive reporting**: Generování přehledných reportů ve formátu Markdown
- **Aggressive mode**: Možnost zapnout agresivnější skenování pro důkladnější průzkum

## Závislosti

BugBusterPro vyžaduje následující nástroje:

- ffuf
- nmap
- subfinder
- httpx
- nuclei
- jq
- curl
- git

## Instalace

1. Naklonujte repozitář:

```bash
git clone https://github.com/yourusername/bugbusterpro.git
cd bugbusterpro
```

2. Nastavte oprávnění pro spouštění:

```bash
chmod +x bugbusterpro.sh
```

3. Nainstalujte závislosti (pokud již nejsou nainstalovány):

```bash
# Základní nástroje
sudo apt install nmap jq curl git

# Go nástroje
go install github.com/ffuf/ffuf/v2@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
```

## Použití

### Základní použití:

```bash
./bugbusterpro.sh -d example.com
```

### Plný průzkum s agresivním režimem:

```bash
./bugbusterpro.sh -d example.com -f -a
```

### Vlastní volby:

```bash
./bugbusterpro.sh -d example.com -s -p -v -w /path/to/wordlist.txt -t 100
```

### Dostupné parametry:

- `-d, --domain <domain>`: Cílová doména pro skenování
- `-o, --output <directory>`: Výstupní adresář (výchozí: ./results)
- `-w, --wordlist <wordlist>`: Cesta k wordlistu pro fuzzing (výchozí: SecLists paths)
- `-t, --threads <number>`: Počet vláken (výchozí: 50)
- `-a, --aggressive`: Povolení agresivního režimu skenování
- `-s, --subdomain-enum`: Provedení enumerace subdomén
- `-p, --port-scan`: Provedení skenování portů
- `-v, --vulnerabilities`: Kontrola zranitelností pomocí nuclei
- `-f, --full`: Provedení plného průzkumu (všechny možnosti)
- `-h, --help`: Zobrazení nápovědy

## Struktura výstupu

Po dokončení skriptu bude vytvořen adresář `results` (nebo vámi zadaný výstupní adresář) s následující strukturou:

```
results/
├── subdomains/
│   ├── subdomains.txt
│   └── live_subdomains.txt
├── paths/
│   ├── example.com_paths.json
│   └── example.com_paths_interesting.txt
├── parameters/
│   ├── example.com_params.json
│   └── example.com_params_interesting.txt
├── ports/
│   └── ports_example.com.txt
├── vulnerabilities/
│   └── example.com_vulns.txt
├── screenshots/
├── wordlists/
└── report.md
```

## Příklady použití

### 1. Rychlé skenování jednoho cíle:

```bash
./bugbusterpro.sh -d example.com
```

### 2. Kompletní skenování včetně hledání zranitelností:

```bash
./bugbusterpro.sh -d example.com -f
```

### 3. Pouze enumerace subdomén a skenování portů:

```bash
./bugbusterpro.sh -d example.com -s -p
```

### 4. Použití vlastního wordlistu s více vlákny:

```bash
./bugbusterpro.sh -d example.com -w /path/to/wordlist.txt -t 100
```

## Bezpečnostní upozornění

Tento nástroj je určen pouze pro etické hackování a testování v rámci bug bounty programů nebo na systémech, ke kterým máte oprávnění. Použití tohoto nástroje proti neoprávněným cílům může být nelegální.

## Přispívání

Příspěvky jsou vítány! Pokud máte nápady na vylepšení nebo jste našli chyby, neváhejte vytvořit issue nebo pull request.

## Licence

Tento projekt je licencován pod [MIT licencí](LICENSE).
