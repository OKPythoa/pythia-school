#!/bin/bash
set -euo pipefail
ROOT=/opt/pythia-school
UNIT=/etc/systemd/system/pythia-mail-intake.service
mkdir -p "$ROOT" /var/lib/pythia-school
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/main/mail-intake.mjs -o "$ROOT/mail-intake.mjs"
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/main/pythia-mail-intake.service -o "$ROOT/pythia-mail-intake.service"
node --check "$ROOT/mail-intake.mjs"
if [ "$(id -u)" -eq 0 ]; then
  cp "$ROOT/pythia-mail-intake.service" "$UNIT"
  systemctl daemon-reload
  systemctl enable --now pythia-mail-intake.timer 2>/dev/null || systemctl enable --now pythia-mail-intake.service || true
  systemctl restart pythia-mail-intake.service || true
else
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl start pythia-mail-intake.service 2>/dev/null || true
fi
(crontab -l 2>/dev/null | grep -v mail-intake.mjs | crontab -) || true
echo OK
