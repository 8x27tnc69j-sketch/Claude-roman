#!/usr/bin/env bash
#
# mcp-prereqs.sh — ставит «движки» MCP-серверов, которым НЕ нужны ключи:
#   • fal-mcp   (через pipx)
#   • playwright + браузер chromium (через npx)
#   • firecrawl-proxy — npm install в ~/.claude/mcp-helpers (если там есть package.json)
#
# Ключи (FAL/GEMINI/APIFY/VIDEO_DB) и регистрацию серверов делаем отдельно.
# Каждый шаг терпим к ошибке — если что-то не встанет, увидишь ❌ и пойдём дальше.
#
# Запуск в НОВОМ окне терминала:  bash ~/Downloads/mcp-prereqs.sh
#
set -uo pipefail
say()  { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
ok()   { printf '  \033[1;32m✅ %s\033[0m\n' "$*"; }
warn() { printf '  \033[1;33m⚠️  %s\033[0m\n' "$*"; }
bad()  { printf '  \033[1;31m❌ %s\033[0m\n' "$*"; }

# brew в PATH (на случай, если окно не совсем новое)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

command -v node  >/dev/null || { bad "node не найден — открой НОВОЕ окно терминала и запусти снова"; exit 1; }
command -v pipx  >/dev/null || { bad "pipx не найден — открой НОВОЕ окно терминала и запусти снова"; exit 1; }
ok "node $(node -v), pipx есть"

# ── 1. fal-mcp ──────────────────────────────────────────────────────
say "1/3 — fal-mcp (через pipx)"
if pipx list 2>/dev/null | grep -qi 'fal-mcp'; then
  ok "fal-mcp уже установлен"
elif pipx install fal-mcp; then
  ok "fal-mcp установлен (ключ FAL_KEY добавим позже)"
else
  bad "fal-mcp не встал через pipx. Попробуем позже другим способом — не страшно."
fi

# ── 2. playwright + chromium ────────────────────────────────────────
say "2/3 — playwright, браузер chromium (качается ~150 МБ, подожди)"
if npx -y playwright install chromium; then
  ok "chromium для playwright установлен"
else
  bad "playwright/chromium не встал — вернёмся к этому позже."
fi

# ── 3. firecrawl-proxy: npm install в ~/.claude/mcp-helpers ──────────
say "3/3 — firecrawl-proxy (npm install в ~/.claude/mcp-helpers)"
HELP="$HOME/.claude/mcp-helpers"
if [ -d "$HELP" ] && [ -f "$HELP/package.json" ]; then
  if ( cd "$HELP" && npm install ); then
    ok "зависимости mcp-helpers установлены"
  else
    bad "npm install в mcp-helpers упал — покажи мне ошибку."
  fi
elif [ -d "$HELP" ]; then
  warn "в ~/.claude/mcp-helpers нет package.json — покажи мне: ls -la ~/.claude/mcp-helpers"
else
  warn "папки ~/.claude/mcp-helpers нет — пропускаю"
fi

say "ГОТОВО. Что дальше:"
echo "  • ключи FAL / GEMINI / APIFY / VIDEO_DB — из файла SECRETS-INVENTORY"
echo "  • регистрация серверов в Claude Code"
echo "  Пришли Claude вывод этого окна — подскажет следующий шаг."
