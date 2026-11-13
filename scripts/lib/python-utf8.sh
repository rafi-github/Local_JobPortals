# Windows pythoncore stdout is cp1252 under Git Bash. Force UTF-8 stdio for
# every Python the home launchers start (all portals, not one script).
export PYTHONIOENCODING="utf-8:replace"
export PYTHONUTF8=1
