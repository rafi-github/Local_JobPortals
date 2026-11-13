# Windows home: reuse real Chrome User Data (Default) so portal + Gmail sessions
# persist across daily runs (ABE cookies do not copy into isolated profiles).
# Source from portal-home-*.sh / home-headed-login.sh when CHROME_CDP_MODE unset.
chrome_cdp_mode_home_default() {
  if [[ -n "${CHROME_CDP_MODE:-}" ]]; then
    return 0
  fi
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) export CHROME_CDP_MODE=system ;;
  esac
  [[ "${OS:-}" == "Windows_NT" ]] && export CHROME_CDP_MODE=system
}

is_windows_home_shell() {
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
  esac
  [[ "${OS:-}" == "Windows_NT" ]]
}
