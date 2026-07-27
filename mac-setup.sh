#!/usr/bin/env bash
#
# mac-setup.sh — ставит базовый инструментарий для Claude Code на Mac:
#   Homebrew → node, python, git, gh, ffmpeg, imagemagick, jq, pipx → прокси в ~/.zshrc
#
# НЕ ставит сам Claude Code (у тебя он уже в десктоп-приложении).
# НЕ ставит MCP-серверы (это отдельным шагом, позже).
#
# Запуск на Маке:  bash ~/Downloads/mac-setup.sh
#
set -uo pipefail
PROXY_URL="http://127.0.0.1:10809"   # локальный прокси Happ (из твоего MCP-SERVERS.md)
say()  { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
ok()   { printf '  \033[1;32m✅ %s\033[0m\n' "$*"; }
warn() { printf '  \033[1;33m⚠️  %s\033[0m\n' "$*"; }
die()  { printf '  \033[1;31m❌ %s\033[0m\n' "$*"; exit 1; }

# ── 0. Проверка интернета (нужен Happ) ──────────────────────────────
say "Шаг 0 — проверяю интернет"
NEED_PROXY=0
if curl -sI --max-time 8 https://github.com >/dev/null 2>&1; then
  ok "интернет есть напрямую (Happ, похоже, в режиме VPN)"
elif curl -sI --max-time 8 -x "$PROXY_URL" https://github.com >/dev/null 2>&1; then
  ok "интернет есть через прокси Happ ($PROXY_URL)"
  export HTTPS_PROXY="$PROXY_URL" HTTP_PROXY="$PROXY_URL"; NEED_PROXY=1
else
  die "Интернета нет. Включи Happ («Подключиться») и запусти скрипт заново."
fi

# ── 1. Homebrew ─────────────────────────────────────────────────────
say "Шаг 1 — Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "уже установлен"
else
  # Проверим права администратора — без них Homebrew не встанет
  if ! groups 2>/dev/null | grep -qw admin; then
    die "Твоя учётка НЕ администратор — Homebrew без этого не поставить.
     Заведи/включи админ-права: Системные настройки → Пользователи и группы,
     либо войди под админ-учёткой, потом запусти скрипт снова."
  fi
  warn "ставлю Homebrew (интерактивно)."
  warn "1) появится «Press RETURN/ENTER to continue» — нажми Enter"
  warn "2) спросит ПАРОЛЬ от Мака — печатай вслепую (буквы не видно), Enter"
  warn "3) может предложить Command Line Tools — соглашайся (окошко Install)"
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty \
    || die "Homebrew не установился. Скинь мне последние строки ошибки."
fi
# Подключаем brew к текущей сессии и к будущим (Apple Silicon vs Intel)
if [ -x /opt/homebrew/bin/brew ]; then BREW=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then BREW=/usr/local/bin/brew
else die "Не нашёл brew после установки."; fi
eval "$("$BREW" shellenv)"
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  echo "eval \"\$($BREW shellenv)\"" >> "$HOME/.zprofile"
  ok "brew добавлен в ~/.zprofile (будущие терминалы его увидят)"
fi
ok "brew готов: $(brew --version | head -1)"

# ── 2. Базовые программы ────────────────────────────────────────────
say "Шаг 2 — ставлю node, python, git, gh, ffmpeg, imagemagick, jq, pipx"
brew install node python@3.12 git gh ffmpeg imagemagick jq pipx \
  || warn "часть пакетов могла не встать — глянем ниже по списку"
pipx ensurepath >/dev/null 2>&1 || true
say "Проверка версий"
for t in node npm python3 git gh ffmpeg jq pipx; do
  if command -v "$t" >/dev/null 2>&1; then ok "$t → $(command -v "$t")"; else warn "$t не найден"; fi
done

# ── 3. Прокси в ~/.zshrc (для терминальных npm/pip и claude в терминале) ──
say "Шаг 3 — прописываю прокси в ~/.zshrc"
# Пишем только если прокси Happ реально отвечает (иначе сломали бы терминал)
if curl -sI --max-time 8 -x "$PROXY_URL" https://github.com >/dev/null 2>&1; then
  if ! grep -q 'HTTPS_PROXY' "$HOME/.zshrc" 2>/dev/null; then
    {
      echo ""
      echo "# Happ proxy для терминальных инструментов"
      echo "export HTTPS_PROXY=$PROXY_URL"
      echo "export HTTP_PROXY=$PROXY_URL"
    } >> "$HOME/.zshrc"
    ok "прокси добавлен в ~/.zshrc"
  else
    ok "прокси уже прописан в ~/.zshrc"
  fi
else
  warn "локальный прокси Happ ($PROXY_URL) не отвечает — НЕ трогаю ~/.zshrc"
  warn "(значит Happ в режиме VPN — прокси в терминале и не нужен)"
fi

# ── Готово ──────────────────────────────────────────────────────────
say "ГОТОВО. Базовый инструментарий установлен."
echo "  Дальше (по одному, когда скажет Claude):"
echo "    • MCP-серверы: fal-mcp, playwright, firecrawl-proxy и т.д."
echo "    • ключи FAL / GEMINI / APIFY / VIDEO_DB"
echo "  ВАЖНО: закрой это окно Терминала и открой НОВОЕ, чтобы node/brew подхватились."
