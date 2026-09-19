#!/bin/bash
set -euo pipefail
ROOT=/opt/pythia-school
mkdir -p "$ROOT" /var/lib/pythia-school
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/main/mail-intake.mjs -o "$ROOT/mail-intake.mjs"
node --check "$ROOT/mail-intake.mjs"
(crontab -l 2>/dev/null | grep -v mail-intake.mjs | crontab -) || true
systemctl start pythia-mail-intake.service || true
echo OK
