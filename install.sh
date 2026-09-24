#!/bin/bash
# Owner lock 2026-09-24. This is NOT a second brain.
# One job on lv184: kill pythia-mail-intake and prove Brain watcher is the only mail path.
set -euo pipefail

echo "pythia-school/install.sh = DISABLE mail-intake. Not an agent."

if [ "$(id -u)" -eq 0 ]; then
  systemctl disable --now pythia-mail-intake.timer 2>/dev/null || true
  systemctl disable --now pythia-mail-intake.service 2>/dev/null || true
  systemctl daemon-reload || true
fi

(crontab -l 2>/dev/null | grep -v mail-intake.mjs | crontab -) || true

echo "--- intake ---"
systemctl is-enabled pythia-mail-intake.timer 2>/dev/null || echo "timer: not enabled"
systemctl is-active pythia-mail-intake.timer 2>/dev/null || echo "timer: inactive"
systemctl is-active pythia-mail-intake.service 2>/dev/null || echo "service: inactive"

echo "--- brain mail watcher ---"
systemctl is-active pythia-v2-background-work.service 2>/dev/null || echo "WARN: pythia-v2-background-work not active"
ss -lptn 2>/dev/null | grep -E ':8817|:8789' || true

echo OK
