#!/usr/bin/env bash
# Bash-native entrypoint for lint.ps1.
#
# Tooling drives a bash shell, so running the PowerShell linter directly
# means hand-composing `powershell.exe -NoProfile -ExecutionPolicy Bypass
# -File ...` on every call -- error-prone, and straying to `-Command` lets
# bash eat PowerShell variables before PowerShell sees them. This wraps the
# incantation once so the linter is invoked the same way every time.
#
#   bash lint.sh            lint + format-check (read-only)
#   bash lint.sh -Fix       lint + format rewrite
#   bash lint.sh <path> ... restrict to specific files / dirs
#
# In a PowerShell terminal, run ./lint.ps1 directly instead.
cd "$(dirname "$0")" || exit 1
exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./lint.ps1 "$@"
