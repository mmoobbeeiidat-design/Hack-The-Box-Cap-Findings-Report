🛡️ Hack The Box - Cap Findings Report
📋 Overview
This repository contains a comprehensive penetration test report for the Hack The Box machine Cap.

🔍 Key Findings

* Insecure Direct Object Reference (IDOR) - High Severity
* Unauthenticated access to network capture files (`/data/{id}`) exposing cleartext FTP credentials
* Privilege Escalation via Linux File Capabilities (`cap_setuid`) - Critical Severity
* Root access obtained via `/usr/bin/python3.8` capability abuse
* User flag captured: `c86861c0e7ea933d33b371d176ac0a31`
* Root flag captured: `97e3503a73fb9562aa302cdfbabb072e`

🛠️ Frameworks Used

* PentNote - Automated documentation - https://github.com/A1GCH-afk/PentNote
* MITRE ATT&CK - T1190, T1552.004, T1078.003, T1548.001
* NSA D3FEND - D3-EAP, D3-FUAC

🧰 Tools & Scripts

**idor-enum.sh** - Custom Bash IDOR enumeration script used to identify accessible numerical endpoints on the target web application.

The script fuzzes a sequential range of numeric IDs against a base URL, reports every endpoint that returns `HTTP 200` (a valid hit) or `HTTP 301/302` (a redirect), and prints a color-coded summary of all valid URLs discovered at the end of the scan.

Download / usage:

```bash
# Download the script
wget https://raw.githubusercontent.com/mmoobbeeiidat-design/Hack-The-Box-Cap-Findings-Report/main/idor-enum.sh

# Make it executable
chmod +x idor-enum.sh

# Run it against a target
./idor-enum.sh <BASE_URL> [START_ID] [END_ID]

# Example
./idor-enum.sh "http://10.129.45.111/data" 0 20
```

If `START_ID` and `END_ID` are omitted, the script defaults to a range of `0` to `20`.

📄 Full Report
View the complete report: [Cap.md](https://github.com/mmoobbeeiidat-design/Hack-The-Box-Cap-Findings-Report/blob/main/Cap.md)
