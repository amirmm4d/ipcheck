# IPCheck Suite v2.2.32
**بررسی اعتبار IP + تحلیل پیشرفته شبکه + نصب تعاملی VPN**

---

# بخش فارسی / Persian Section

## درباره پروژه

IPCheck یک ابزار خط فرمان (CLI) قدرتمند و سریع است که برای بررسی اعتبار و شهرت آدرس‌های IP طراحی شده است. این ابزار به صورت همزمان اطلاعات را از چندین منبع معتبر دریافت کرده و تحلیل‌های جامعی شامل امتیازدهی اعتبار، تشخیص CDN، سلامت مسیریابی، اسکن پورت، تست Reality و موارد دیگر ارائه می‌دهد.

## ویژگی‌های کلیدی

### بررسی اعتبار IP
- **چندین سرویس بررسی اعتبار**: پشتیبانی از IPQualityScore، AbuseIPDB، Scamalytics، RIPE Atlas، Check-Host، ipapi.co، ipregistry.io و Spamhaus
- **بررسی موازی**: تمام بررسی‌ها به صورت همزمان اجرا می‌شوند برای سریع‌ترین نتایج
- **بررسی انتخابی**: اجرای بررسی‌های خاص با استفاده از فلگ‌ها (-q, -a, -s, -r, -c, -h) یا اجرای همه به صورت پیش‌فرض
- **امتیازدهی کیفیت IP**: تولید امتیاز Clean Score (0-100) با استفاده از معیارهای وزنی از چندین منبع

### تحلیل پیشرفته
- **تشخیص CDN**: تشخیص Cloudflare، AWS CloudFront، Google Cloud CDN، Azure CDN، Fastly و موارد دیگر
- **سلامت مسیریابی**: تحلیل تاخیر، از دست رفتن بسته، فاصله hop و پایداری مسیر
- **اسکن ریسک پورت**: اسکن پورت‌های بحرانی (22, 80, 443, 8080, 8443, 53, 3389) برای ارزیابی امنیتی
- **تست Reality Fingerprint**: تست TLS handshake، رفتار SNI، سازگاری MTU برای Sing-box Reality
- **تشخیص استفاده قبلی**: شناسایی تاریخچه VPN، پروکسی، botnet یا spam
- **موتور پیشنهادات**: تولید توصیه‌های هوشمند بر اساس تمام نتایج تست

### خروجی و یکپارچه‌سازی
- **ورودی‌های چندگانه**: IPهای تکی، لیست جدا شده با کاما، ورودی فایل، یا تشخیص خودکار IP سرور
- **خروجی‌های استاندارد**: گزارش‌های جدول خوانا برای انسان و JSON ساختاریافته برای خودکارسازی
- **آستانه شکست**: آستانه قابل تنظیم برای یکپارچه‌سازی CI/CD
- **لاگ‌گیری جامع**: فرمت JSON یا TXT با چرخش خودکار
- **گزارش‌های JSON چندگانه**: گزارش‌های جداگانه برای امتیازها، CDN، مسیریابی، پورت‌ها، Reality، تاریخچه استفاده و پیشنهادات

### خودکارسازی
- **نصب‌کننده تعاملی VPN**: پس از بررسی IP سرور، برای نصب VPN (Sing-box، Xray، V2Ray، Shadowsocks، OpenVPN یا OpenConnect) درخواست می‌کند
- **نصب‌کننده هوشمند**: راه‌اندازی تعاملی با بررسی وابستگی‌ها و پیکربندی کلید API
- **آماده CI/CD**: کدهای خروجی مناسب و خروجی JSON برای یکپارچه‌سازی pipeline
- **امتیازدهی خودکار**: هنگام بررسی IP سرور، به صورت خودکار Clean Score را قبل از درخواست VPN تولید می‌کند

## نصب

### نصب سریع (یک خطی) ⭐

**روش توصیه شده** - مستقیماً دانلود و نصب می‌کند بدون نیاز به کلون کردن کل پروژه:

```bash
curl -fsSL https://raw.githubusercontent.com/amirmm4d/ipcheck/main/setup.sh | sudo bash
```

در حین نصب:
- نیازمندی‌ها (curl, jq) به صورت خودکار بررسی و نصب می‌شوند
- از شما برای وارد کردن کلیدهای API سوال می‌شود
- ابزار در `/usr/local/bin/ipcheck` نصب می‌شود
- صفحه راهنما در `/usr/share/man/man1/ipcheck.1.gz` نصب می‌شود

### نصب دستی

اگر ترجیح می‌دهید ابتدا پروژه را کلون کنید:

```bash
# 1. کلون کردن پروژه
git clone https://github.com/amirmm4d/ipcheck.git

# 2. رفتن به دایرکتوری پروژه
cd ipcheck-suite

# 3. اجرای اسکریپت نصب
sudo bash setup.sh
```

## استفاده

### منوی تعاملی

اجرای بدون آرگومان برای نمایش منوی تعاملی:

```bash
ipcheck
```

این منو شامل:
- گزینه 1: بررسی آدرس IP - راهنمای ورودی IP و انتخاب بررسی
- گزینه 2: نصب سرور VPN - منوی تعاملی نصب VPN
- گزینه 3: حذف IPCheck - حذف ipcheck و فایل‌های مرتبط
- گزینه 4: خروج

### مرجع سریع فلگ‌ها

**تمام فلگ‌ها تک حرفی برای راحتی:**
- ورودی: `-i` (IPها), `-f` (فایل), `-S` (سرور)
- بررسی‌ها: `-q` (IPQS), `-a` (AbuseIPDB), `-s` (Scamalytics), `-r` (RIPE), `-c` (Check-Host), `-h` (HostTracker)
- پیشرفته: `-g` (امتیاز), `-d` (CDN), `-t` (مسیریابی), `-p` (اسکن پورت), `-R` (reality), `-u` (استفاده), `-n` (پیشنهادات)
- خروجی: `-j` (JSON), `-F` (fail-if), `-l` (لاگ), `-L` (فرمت لاگ), `-v` (درخواست VPN)
- خودکارسازی: `-A` یا `--all` (همه چک‌ها), `-y <type>` (نصب خودکار VPN), `--ally` (همه چک‌ها + نصب خودکار VPN)
- سایر: `-U` (حذف), `-H` (راهنما)

**فلگ‌ها را می‌توان ترکیب کرد:** از `-gdt` به جای `-g -d -t` برای راحتی استفاده کنید!

## مثال‌ها

### بررسی‌های پایه IP

**بررسی یک IP تکی (همه سرویس‌ها):**
```bash
ipcheck -i 8.8.8.8
```

**بررسی چند IP:**
```bash
ipcheck -i 1.2.3.4,5.6.7.8
```

**بررسی از فایل:**
```bash
ipcheck -f /path/to/ips.txt
```

**بررسی IP سرور (تشخیص خودکار):**
```bash
ipcheck -S
```

**اجرای بررسی‌های خاص:**
```bash
ipcheck -i 8.8.8.8 -q -a -s
```

### ویژگی‌های پیشرفته

**تولید امتیاز کیفیت IP:**
```bash
ipcheck -i 8.8.8.8 -g
```

**تشخیص CDN:**
```bash
ipcheck -i 8.8.8.8 -d
```

**تحلیل سلامت مسیریابی:**
```bash
ipcheck -i 8.8.8.8 -t
```

**اسکن ریسک پورت:**
```bash
ipcheck -i 8.8.8.8 -p
```

**تست سازگاری Sing-box Reality:**
```bash
ipcheck -i 8.8.8.8 -R
```

**بررسی تاریخچه استفاده قبلی:**
```bash
ipcheck -i 8.8.8.8 -u
```

**تولید پیشنهادات هوشمند:**
```bash
ipcheck -i 8.8.8.8 -n
```

### خروجی و لاگ

**فرمت‌های خروجی پشتیبانی شده:**
- `table` (پیش‌فرض) - جدول خوانا برای انسان
- `json` - JSON ساختاریافته
- `yaml` - YAML
- `csv` - CSV برای Excel/Spreadsheet
- `xml` - XML

**خروجی JSON:**
```bash
ipcheck -i 8.8.8.8 -j
# یا
ipcheck -i 8.8.8.8 -o json
```

**خروجی YAML:**
```bash
ipcheck -i 8.8.8.8 -o yaml
```

**خروجی CSV:**
```bash
ipcheck -i 8.8.8.8 -o csv
```

**خروجی XML:**
```bash
ipcheck -i 8.8.8.8 -o xml
```

**فعال‌سازی لاگ:**
```bash
ipcheck -i 8.8.8.8 -l /var/log/ipcheck
```

**لاگ با فرمت JSON:**
```bash
ipcheck -i 8.8.8.8 -l /var/log/ipcheck -L json
```

**تنظیم آستانه شکست برای CI/CD:**
```bash
ipcheck -i 8.8.8.8 -F 2
```

### مثال‌های ترکیبی

**تحلیل کامل با تمام ویژگی‌ها (استفاده از فلگ‌های ترکیبی):**
```bash
ipcheck -i 8.8.8.8 -gdtpRun -j
# معادل: ipcheck -i 8.8.8.8 -g -d -t -p -R -u -n -j
```

**بررسی IP سرور با امتیاز و درخواست تعاملی VPN:**
```bash
ipcheck -S -g
```
این دستور IP سرور شما را بررسی می‌کند، یک امتیاز تولید می‌کند و سپس از شما می‌پرسد که آیا می‌خواهید VPN نصب کنید.

**تحلیل کامل با لاگ (فلگ‌های ترکیبی):**
```bash
ipcheck -S -gdtR -l /var/log/ipcheck -L json
# معادل: ipcheck -S -g -d -t -R -l /var/log/ipcheck -L json
```

**ترکیب بررسی‌های پایه و پیشرفته:**
```bash
ipcheck -qasgdt -i 8.8.8.8
# اجرای IPQS، AbuseIPDB، Scamalytics، به علاوه امتیازدهی، CDN و بررسی‌های مسیریابی
```

## پیکربندی

### کلیدهای API

اسکریپت نصب به شما کمک می‌کند فایل پیکربندی را برای کلیدهای API خود ایجاد کنید، که در این مسیر قرار دارد:
```
~/.config/ipcheck/keys.conf
```

**کلیدهای API پشتیبانی شده:**
- `IPQS_KEY`: کلید API IPQualityScore - [دریافت کنید](https://www.ipqualityscore.com/)
- `ABUSEIPDB_KEY`: کلید API AbuseIPDB - [دریافت کنید](https://www.abuseipdb.com/account)
- `RIPE_KEY`: کلید API RIPE Atlas - [دریافت کنید](https://atlas.ripe.net/apply/)
- `HT_KEY`: کلید API HostTracker (اختیاری)
- `IPREGISTRY_KEY`: کلید API ipregistry.io (اختیاری، نسخه رایگان موجود است)

می‌توانید این فایل را در هر زمان ویرایش کنید. فایل به صورت خودکار با مجوزهای امنیتی (600) تنظیم می‌شود.

### فرمت‌های خروجی و کدهای خروج

ابزار از چندین فرمت خروجی پشتیبانی می‌کند:
- `table` (پیش‌فرض) - فرمت جدول خوانا برای انسان
- `json` - فرمت JSON ساختاریافته
- `yaml` - فرمت YAML
- `csv` - فرمت CSV برای Excel/Spreadsheet
- `xml` - فرمت XML

**انتخاب فرمت خروجی:**
```bash
ipcheck -i 8.8.8.8 -o json   # خروجی JSON
ipcheck -i 8.8.8.8 -o yaml   # خروجی YAML
ipcheck -i 8.8.8.8 -o csv    # خروجی CSV
ipcheck -i 8.8.8.8 -o xml    # خروجی XML
ipcheck -i 8.8.8.8 -j        # JSON (مخفف، همان -o json)
```

هنگام استفاده از فرمت‌های ساختاریافته (`-j`, `-o json`, `-o yaml`, `-o csv`, `-o xml`)، ابزار کدهای خروجی مناسب تنظیم می‌کند:
- **خروج 0**: تمام IPها آستانه شکست را گذراندند
- **خروج 1**: یک یا چند IP آستانه شکست را رد کردند
- **خروج 2**: خطای بحرانی (هیچ IP بررسی نشد، خطای پیکربندی)

**خروجی JSON/YAML/CSV/XML شامل:**
- `clean_score`: امتیاز Clean Score کیفیت IP (0-100) - محاسبه شده از چندین منبع
- `raw_data`: پاسخ‌های کامل API از تمام سرویس‌های بررسی شده (IPQualityScore، AbuseIPDB، Scamalytics و غیره)
- `checks`: وضعیت و جزئیات برای هر بررسی
- `overall_status`: PASSED یا FAILED
- `failed_checks`: تعداد بررسی‌های ناموفق
- `failure_threshold`: آستانه تنظیم شده

**توجه:** فایل‌های داده خام به صورت خودکار پس از تولید گزارش پاک می‌شوند، اما داده‌ها در خروجی برای مرجع شما موجود است.

**نکات فرمت‌ها:**
- **YAML**: برای بهترین نتایج، `yq` یا `python3` با `PyYAML` نصب کنید
- **CSV**: مناسب برای Excel و Spreadsheet، شامل IP، Clean Score، Overall Status، Failed Checks، Failure Threshold
- **XML**: فرمت XML ساختاریافته با تمام داده‌ها

این باعث می‌شود برای pipelineهای CI/CD و اسکریپت‌های خودکارسازی ایده‌آل باشد.

### فایل‌های خروجی

هنگام استفاده از ویژگی‌های پیشرفته، فایل‌های JSON زیر در دایرکتوری وضعیت تولید می‌شوند:
- `ip_score.json` - امتیاز Clean Score (0-100) و معیارها
- `cdn_status.json` - نتایج تشخیص CDN
- `route_report.json` - تحلیل سلامت مسیریابی
- `abuse_report.json` - نتایج بررسی پایگاه داده سوءاستفاده
- `port_scan.json` - نتایج اسکن پورت و ارزیابی ریسک
- `reality_test.json` - تست سازگاری Sing-box Reality
- `usage_history.json` - تشخیص استفاده قبلی (VPN/proxy/fraud)
- `suggestions.json` - توصیه‌های هوشمند بر اساس تمام تست‌ها

## نصب VPN

هنگامی که IP سرور خود را با فلگ `-S` بررسی می‌کنید، پس از بررسی‌های موفق و امتیازدهی، ابزار به صورت تعاملی می‌پرسد که آیا می‌خواهید یک سرور VPN نصب کنید:

**گزینه‌های VPN:**
1. **Sing-box** - توصیه شده برای پروتکل Reality
2. **Xray** - Xray-core (قدرتمند و غنی از ویژگی)
3. **V2Ray** - پروژه V2Fly
4. **Shadowsocks-libev** - Shadowsocks سبک
5. **OpenVPN** - پروتکل VPN استاندارد صنعتی
6. **OpenConnect** - کلاینت سازگار با Cisco AnyConnect

**مثال:**
```bash
ipcheck -S -g
```

پس از بررسی، خواهید دید:
```
✅ IP Check Complete!
IP Address: 1.2.3.4
Clean Score: 85/100

Would you like to install a VPN server?
  1) Sing-box (Recommended for Reality)
  2) Xray (Xray-core)
  3) V2Ray (V2Fly)
  4) Shadowsocks-libev
  5) OpenVPN
  6) OpenConnect (Cisco AnyConnect compatible)
  7) Skip installation

Select option (1-7):
```

## حذف برنامه

برای حذف کامل ipcheck:
```bash
sudo ipcheck -U
```

یا با استفاده از فلگ قدیمی:
```bash
sudo ipcheck --uninstall
```

یا اگر اسکریپت setup را دارید:
```bash
sudo ./setup.sh uninstall
```

**توجه:** فایل پیکربندی (`~/.config/ipcheck/keys.conf`) حذف نمی‌شود تا کلیدهای API شما حفظ شوند.

## نیازمندی‌ها

### ابزارهای مورد نیاز
- `curl` - برای درخواست‌های API
- `jq` - برای تجزیه JSON

### ابزارهای اختیاری (برای ویژگی‌های پیشرفته)
- `mtr` یا `traceroute` - برای `-t` (تحلیل مسیریابی)
- `nc` (netcat) یا `ss` - برای `-p` (اسکن پورت)
- `openssl` - برای `-R` (تست Reality)
- `dig` - برای جستجوی DNS (معمولاً از پیش نصب شده)
- `bc` - برای محاسبات (معمولاً از پیش نصب شده)
- `whois` - برای `-u` (تاریخچه استفاده، معمولاً از پیش نصب شده)

## مستندات

### صفحه راهنما

مشاهده راهنمای کامل:
```bash
man ipcheck
```

### راهنمای دستور

مشاهده تمام گزینه‌ها:
```bash
ipcheck -H
```

---

# English Section

## About the Project

IPCheck is a powerful and fast command-line (CLI) tool designed to check the reputation of IP addresses. It concurrently fetches data from multiple reputable sources and provides comprehensive analysis including reputation scoring, CDN detection, routing health, port scanning, Reality fingerprint testing, and more.

## Key Features

### Core IP Reputation
- **Multiple IP Reputation Services**: Supports IPQualityScore, AbuseIPDB, Scamalytics, RIPE Atlas, Check-Host, ipapi.co, ipregistry.io, and Spamhaus
- **Parallel Checks**: All checks run concurrently for fastest results
- **Selective Checks**: Run specific checks using flags (-q, -a, -s, -r, -c, -h) or run all by default
- **IP Quality Scoring**: Generate Clean Score (0-100) using weighted metrics from multiple sources

### Advanced Analysis
- **CDN Detection**: Detect Cloudflare, AWS CloudFront, Google Cloud CDN, Azure CDN, Fastly, and more
- **Routing Health**: Analyze latency, packet loss, hop distance, and route stability
- **Port Risk Scanning**: Scan critical ports (22, 80, 443, 8080, 8443, 53, 3389) for security assessment
- **Reality Fingerprint Testing**: Test TLS handshake, SNI behavior, MTU consistency for Sing-box Reality compatibility
- **Prior Usage Detection**: Identify VPN, proxy, botnet, or spam history
- **Suggestion Engine**: Generate smart recommendations based on all test results

### Output & Integration
- **Multiple Inputs**: Single IPs, comma-separated lists, file input, or auto-detect server IP
- **Standard Outputs**: Human-readable table reports and structured JSON for automation
- **Failure Threshold**: Configurable threshold for CI/CD integration
- **Comprehensive Logging**: JSON or TXT format with automatic rotation
- **Multiple JSON Reports**: Separate reports for scores, CDN, routing, ports, Reality, usage history, and suggestions

### Automation
- **Interactive VPN Installer**: After checking server IP, prompts to install VPN (Sing-box, Xray, V2Ray, Shadowsocks, OpenVPN, or Cisco-compatible OpenConnect)
- **Smart Installer**: Interactive setup with dependency checking and API key configuration
- **CI/CD Ready**: Proper exit codes and JSON output for pipeline integration
- **Auto-Scoring**: When checking server IP, automatically generates Clean Score before VPN prompt

## Installation

### Quick Install (One-Line) ⭐

**Recommended method** - Downloads and installs directly without cloning the repository:

```bash
curl -fsSL https://raw.githubusercontent.com/amirmm4d/ipcheck/main/setup.sh | sudo bash
```

During installation:
- Dependencies (curl, jq) are automatically checked and installed if needed
- You'll be prompted to configure API keys interactively
- The tool is installed to `/usr/local/bin/ipcheck`
- Man page is installed to `/usr/share/man/man1/ipcheck.1.gz`

### Manual Install

If you prefer to clone the repository first:

```bash
# 1. Clone the project
git clone https://github.com/amirmm4d/ipcheck.git

# 2. Navigate into the project directory
cd ipcheck-suite

# 3. Run the installation script
sudo bash setup.sh
```

## Usage

### Interactive Menu

Run without arguments to launch the interactive menu:

```bash
ipcheck
```

This menu provides:
- Option 1: Check IP Address - Guides you through IP input and check selection
- Option 2: Install VPN Server - Interactive VPN installation menu
- Option 3: Uninstall IPCheck - Remove ipcheck and associated files
- Option 4: Exit

### Quick Reference

**All flags are single-letter for convenience:**
- Input: `-i` (IPs), `-f` (file), `-S` (server)
- Checks: `-q` (IPQS), `-a` (AbuseIPDB), `-s` (Scamalytics), `-r` (RIPE), `-c` (Check-Host), `-h` (HostTracker)
- Advanced: `-g` (score), `-d` (CDN), `-t` (routing), `-p` (port-scan), `-R` (reality), `-u` (usage), `-n` (suggestions)
- Output: `-j` (JSON), `-F` (fail-if), `-l` (log), `-L` (log-format), `-v` (ask VPN)
- Other: `-U` (uninstall), `-H` (help)

**Flags can be combined:** Use `-gdt` instead of `-g -d -t` for convenience!

## Examples

### Basic IP Checks

**Check a single IP (all services):**
```bash
ipcheck -i 8.8.8.8
```

**Check multiple IPs:**
```bash
ipcheck -i 1.2.3.4,5.6.7.8
```

**Check from file:**
```bash
ipcheck -f /path/to/ips.txt
```

**Check server IP (auto-detect):**
```bash
ipcheck -S
```

**Run specific checks only:**
```bash
ipcheck -i 8.8.8.8 -q -a -s
```

### Advanced Features

**Generate IP Quality Score:**
```bash
ipcheck -i 8.8.8.8 -g
```

**Detect CDN presence:**
```bash
ipcheck -i 8.8.8.8 -d
```

**Run routing health analysis:**
```bash
ipcheck -i 8.8.8.8 -t
```

**Scan critical ports for risk:**
```bash
ipcheck -i 8.8.8.8 -p
```

**Test Sing-box Reality compatibility:**
```bash
ipcheck -i 8.8.8.8 -R
```

**Check prior usage history:**
```bash
ipcheck -i 8.8.8.8 -u
```

**Generate smart suggestions:**
```bash
ipcheck -i 8.8.8.8 -n
```

### Output & Logging

**Supported output formats:**
- `table` (default) - Human-readable table format
- `json` - Structured JSON format
- `yaml` - YAML format
- `csv` - CSV format for Excel/Spreadsheet
- `xml` - XML format

**JSON output:**
```bash
ipcheck -i 8.8.8.8 -j
# or
ipcheck -i 8.8.8.8 -o json
```

**YAML output:**
```bash
ipcheck -i 8.8.8.8 -o yaml
```

**CSV output:**
```bash
ipcheck -i 8.8.8.8 -o csv
```

**XML output:**
```bash
ipcheck -i 8.8.8.8 -o xml
```

**Enable logging:**
```bash
ipcheck -i 8.8.8.8 -l /var/log/ipcheck
```

**Log with JSON format:**
```bash
ipcheck -i 8.8.8.8 -l /var/log/ipcheck -L json
```

**Set failure threshold for CI/CD:**
```bash
ipcheck -i 8.8.8.8 -F 2
```

### Combined Examples

**Full analysis with all features (using combined flags):**
```bash
ipcheck -i 8.8.8.8 -gdtpRun -j
# Equivalent to: ipcheck -i 8.8.8.8 -g -d -t -p -R -u -n -j
```

**Check server IP with score and interactive VPN prompt:**
```bash
ipcheck -S -g
```
This will check your server IP, generate a score, and then ask if you want to install a VPN.

**Complete analysis with logging (combined flags):**
```bash
ipcheck -S -gdtR -l /var/log/ipcheck -L json
# Equivalent to: ipcheck -S -g -d -t -R -l /var/log/ipcheck -L json
```

**Combine basic and advanced checks:**
```bash
ipcheck -qasgdt -i 8.8.8.8
# Runs IPQS, AbuseIPDB, Scamalytics, plus scoring, CDN, and routing checks
```

## Configuration

### API Keys

The setup script helps you create the configuration file for your API keys, located at:
```
~/.config/ipcheck/keys.conf
```

**Supported API keys:**
- `IPQS_KEY`: IPQualityScore API key - [Get it here](https://www.ipqualityscore.com/)
- `ABUSEIPDB_KEY`: AbuseIPDB API key - [Get it here](https://www.abuseipdb.com/account)
- `RIPE_KEY`: RIPE Atlas API key - [Get it here](https://atlas.ripe.net/apply/)
- `HT_KEY`: HostTracker API key (optional)
- `IPREGISTRY_KEY`: ipregistry.io API key (optional, free tier available)

You can edit this file at any time. The file is automatically set to secure permissions (600).

### Output Formats & Exit Codes

The tool supports multiple output formats:
- `table` (default) - Human-readable table format
- `json` - Structured JSON format
- `yaml` - YAML format
- `csv` - CSV format for Excel/Spreadsheet
- `xml` - XML format

**Select output format:**
```bash
ipcheck -i 8.8.8.8 -o json   # JSON output
ipcheck -i 8.8.8.8 -o yaml   # YAML output
ipcheck -i 8.8.8.8 -o csv    # CSV output
ipcheck -i 8.8.8.8 -o xml    # XML output
ipcheck -i 8.8.8.8 -j        # JSON (shortcut, same as -o json)
```

When using structured output formats (`-j`, `-o json`, `-o yaml`, `-o csv`, `-o xml`), the tool sets proper exit codes:
- **Exit 0**: All IPs passed the failure threshold
- **Exit 1**: One or more IPs failed the failure threshold
- **Exit 2**: Critical error (no IPs checked, configuration error)

**Structured Output (JSON/YAML/CSV/XML) includes:**
- `clean_score`: IP Quality Clean Score (0-100) - calculated from multiple sources
- `raw_data`: Complete API responses from all checked services (IPQualityScore, AbuseIPDB, Scamalytics, etc.)
- `checks`: Status and details for each check
- `overall_status`: PASSED or FAILED
- `failed_checks`: Number of failed checks
- `failure_threshold`: Configured threshold

**Format Notes:**
- **YAML**: For best results, install `yq` or `python3` with `PyYAML` (`pip install pyyaml`)
- **CSV**: Suitable for Excel/Spreadsheet, contains: IP, Clean Score, Overall Status, Failed Checks, Failure Threshold
- **XML**: Structured XML format with all data included

**Note:** Raw data files are automatically cleaned up after the report is generated, but the data is included in the output for your reference.

This makes it ideal for CI/CD pipelines and automation scripts.

### Output Files

When using advanced features, the following JSON files are generated in the status directory:
- `ip_score.json` - IP Quality Clean Score (0-100) and metrics
- `cdn_status.json` - CDN detection results
- `route_report.json` - Routing health analysis
- `abuse_report.json` - Abuse database check results
- `port_scan.json` - Port scanning results and risk assessment
- `reality_test.json` - Sing-box Reality compatibility test
- `usage_history.json` - Prior usage detection (VPN/proxy/fraud)
- `suggestions.json` - Smart recommendations based on all tests

## VPN Installation

When you check your server IP with `-S` flag, after successful checks and scoring, the tool will **interactively ask** if you want to install a VPN server:

**VPN Options:**
1. **Sing-box** - Recommended for Reality protocol
2. **Xray** - Xray-core (powerful and feature-rich)
3. **V2Ray** - V2Fly project
4. **Shadowsocks-libev** - Lightweight Shadowsocks
5. **OpenVPN** - Industry-standard VPN protocol
6. **OpenConnect** - Cisco AnyConnect compatible client

**Example:**
```bash
ipcheck -S -g
```

After checking, you'll see:
```
✅ IP Check Complete!
IP Address: 1.2.3.4
Clean Score: 85/100

Would you like to install a VPN server?
  1) Sing-box (Recommended for Reality)
  2) Xray (Xray-core)
  3) V2Ray (V2Fly)
  4) Shadowsocks-libev
  5) OpenVPN
  6) OpenConnect (Cisco AnyConnect compatible)
  7) Skip installation

Select option (1-7):
```

## Uninstallation

To completely remove ipcheck:
```bash
sudo ipcheck -U
```

Or using the old flag:
```bash
sudo ipcheck --uninstall
```

Or if you have the setup script:
```bash
sudo ./setup.sh uninstall
```

**Note:** The configuration file (`~/.config/ipcheck/keys.conf`) is **not** removed to preserve your API keys.

## Requirements

### Required Tools
- `curl` - for API requests
- `jq` - for JSON parsing

### Optional Tools (for advanced features)
- `mtr` or `traceroute` - for `-t` (routing analysis)
- `nc` (netcat) or `ss` - for `-p` (port scanning)
- `openssl` - for `-R` (Reality testing)
- `dig` - for DNS lookups (usually pre-installed)
- `bc` - for calculations (usually pre-installed)
- `whois` - for `-u` (usage history, usually pre-installed)

## Documentation

### Man Page

View the complete manual:
```bash
man ipcheck
```

### Command Help

View all options:
```bash
ipcheck -H
```

## License

This project is licensed under the MIT License.

## Author

Developed with ❤️ by amirmm4d from Iran 🇮🇷

## Links

- **GitHub Repository**: [https://github.com/amirmm4d/ipcheck](https://github.com/amirmm4d/ipcheck)
- **Issues**: [https://github.com/amirmm4d/ipcheck/issues](https://github.com/amirmm4d/ipcheck/issues)
