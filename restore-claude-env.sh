#!/usr/bin/env bash
#
# restore-claude-env.sh — восстановление окружения Claude Code на Mac
# из папки mac-migration на внешнем SSD.
#
# ЗАПУСКАТЬ НА МАКЕ, в Terminal:
#     bash ~/Downloads/restore-claude-env.sh
#
# Свойства:
#   • НЕ трогает авторизацию (.credentials.json, ~/.claude.json остаются как есть)
#   • Делает бэкапы всего, что перезаписывает (*.mig-bak-<timestamp>)
#   • НИЧЕГО не устанавливает (MCP-серверы только показывает списком)
#   • Идёт по шагам, печатает ✅/⚠️ и падает при первой серьёзной ошибке
#
set -uo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
say()  { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
ok()   { printf '  \033[1;32m✅ %s\033[0m\n' "$*"; }
warn() { printf '  \033[1;33m⚠️  %s\033[0m\n' "$*"; }
die()  { printf '  \033[1;31m❌ %s\033[0m\n' "$*"; exit 1; }

# ── ШАГ 1. Найти SSD ────────────────────────────────────────────────
say "Шаг 1 — ищу SSD с папкой mac-migration"
MIG=""
for c in /Volumes/E9Ultra2T/mac-migration /Volumes/*/mac-migration; do
  [ -d "$c" ] && { MIG="$c"; break; }
done
[ -n "$MIG" ] || die "Не нашёл mac-migration в /Volumes. Подключён ли SSD?"
ok "Нашёл: $MIG"
CFG="$MIG/claude-config"
[ -d "$CFG" ] || die "Нет папки claude-config внутри $MIG"

# ── ШАГ 2. Прочитать план (для контекста) ───────────────────────────
say "Шаг 2 — план переноса (первые строки)"
for f in START-HERE-ON-MAC.md MIGRATION.md; do
  if [ -f "$MIG/$f" ]; then
    printf '\n----- %s -----\n' "$f"; sed -n '1,40p' "$MIG/$f"
  else
    warn "Нет $f (пропускаю)"
  fi
done

read -r -p $'\nПродолжить восстановление? [y/N] ' a; [ "$a" = y ] || die "Отменено."

# ── ШАГ 3. «Мозг» → ~/.claude ───────────────────────────────────────
say "Шаг 3 — восстанавливаю ~/.claude (авторизацию не трогаю)"
mkdir -p "$HOME/.claude"
# .gitconfig логически живёт в $HOME, остальное — в ~/.claude
CLAUDE_ITEMS=(skills agents commands plugins mcp-helpers
              settings.json settings.local.json
              CLAUDE.md LEARNED.md RESEARCH_SETUP.md)
for item in "${CLAUDE_ITEMS[@]}"; do
  src="$CFG/$item"; dst="$HOME/.claude/$item"
  if [ -e "$src" ]; then
    [ -e "$dst" ] && { cp -R "$dst" "$dst.mig-bak-$TS"; warn "бэкап $item.mig-bak-$TS"; }
    cp -R "$src" "$dst"; ok "$item"
  else
    warn "нет в переносе: $item (пропуск)"
  fi
done
# .gitconfig → ~/.gitconfig
if [ -f "$CFG/.gitconfig" ]; then
  [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$HOME/.gitconfig.mig-bak-$TS"
  cp "$CFG/.gitconfig" "$HOME/.gitconfig"; ok ".gitconfig → ~/.gitconfig"
fi
# Явно НЕ трогаем авторизацию
for auth in "$HOME/.claude/.credentials.json" "$HOME/.claude.json"; do
  [ -e "$auth" ] && ok "авторизация сохранена: $(basename "$auth")"
done

# ── ШАГ 4. Память → ~/.claude/memory/ + @import ─────────────────────
say "Шаг 4 — память (memory-PRIMARY) → ~/.claude/memory/"
MEMSRC="$CFG/memory-PRIMARY"
[ -d "$MEMSRC" ] || die "Нет $MEMSRC"
mkdir -p "$HOME/.claude/memory"
cp -R "$MEMSRC/." "$HOME/.claude/memory/"
n=$(find "$HOME/.claude/memory" -type f -name '*.md' | wc -l | tr -d ' ')
ok "скопировано .md файлов памяти: $n"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"; touch "$CLAUDE_MD"
if ! grep -q '@memory/MEMORY.md' "$CLAUDE_MD" 2>/dev/null; then
  { printf '\n# Долговременная память\n@memory/MEMORY.md\n'; } >> "$CLAUDE_MD"
  ok "в ~/.claude/CLAUDE.md добавлен @import → @memory/MEMORY.md"
else
  ok "@import уже есть в CLAUDE.md"
fi

# ── ШАГ 5. Проекты → ~/ClaudeHome ───────────────────────────────────
say "Шаг 5 — проекты → ~/ClaudeHome (локально, НЕ в облаке)"
PRJSRC="$MIG/projects"
[ -d "$PRJSRC" ] || die "Нет $PRJSRC"
mkdir -p "$HOME/ClaudeHome"
if command -v rsync >/dev/null; then
  rsync -a "$PRJSRC/" "$HOME/ClaudeHome/"
else
  cp -R "$PRJSRC/." "$HOME/ClaudeHome/"
fi
ok "перенесено проектов: $(ls -1 "$HOME/ClaudeHome" | wc -l | tr -d ' ') (имена _onedrive_ сохранены)"

# ── ШАГ 6. Переписать пути Windows → Mac (с бэкапами) ────────────────
say "Шаг 6 — переписываю пути Windows→Mac в памяти/конфигах"
# Правило заменяет три формы записи путей:
#   C:/Users/Hi-Tech Center...   (прямые слэши)
#   C:\Users\Hi-Tech Center...   (обратные, как в .md)
#   C:\\Users\\Hi-Tech Center... (экранированные, как в JSON)
# Хвост пути после корня тоже приводится к слэшам. Cyrillic (Документы) — ок.
# byte-mode (без -CSD): паттерны из env, чтобы \Q ничего не ломал.
REW_PROG='my $h=$ENV{HOME_ENV}; my $ch="$h/ClaudeHome";
sub variants { my $b=shift; my @v=($b); (my $s=$b)=~s{/}{\\}g; push @v,$s; (my $d=$b)=~s{/}{\\\\}g; push @v,$d; @v }
sub clean { my $t=shift; $t=~s{\\\\}{/}g; $t=~s{\\}{/}g; $t }
for my $b ($ENV{B_DOC},$ENV{B_OD}) { for my $p (variants($b)) { s/\Q$p\E([^\s"'"'"'`(),]*)/ $ch . clean($1) /ge; } }
for my $b ($ENV{B_HOME})           { for my $p (variants($b)) { s/\Q$p\E([^\s"'"'"'`(),]*)/ $h  . clean($1) /ge; } }'

rewrite_one() {
  local f="$1"
  cp "$f" "$f.mig-bak-$TS"
  env HOME_ENV="$HOME" \
      B_DOC='C:/Users/Hi-Tech Center/Documents/ClaudeHome' \
      B_OD='C:/Users/Hi-Tech Center/OneDrive/Документы/ClaudeHome' \
      B_HOME='C:/Users/Hi-Tech Center' \
      perl -pi -e "$REW_PROG" "$f"
}
c=0
while IFS= read -r -d '' f; do
  [ -f "$f" ] && { rewrite_one "$f"; c=$((c+1)); }
done < <(
  find "$HOME/.claude/memory" -type f -name '*.md' -print0
  find "$HOME/.claude" "$HOME/ClaudeHome" -maxdepth 3 \
       \( -name 'CLAUDE.md' -o -name 'settings.json' \
          -o -name 'settings.local.json' -o -name '.mcp.json' \) -type f -print0
)
ok "переписано файлов: $c (бэкапы *.mig-bak-$TS рядом)"
# Показать, что осталось от Windows-путей (если есть)
LEFT=$(grep -rIl -e 'C:\\Users' -e 'C:/Users' "$HOME/.claude" "$HOME/ClaudeHome" 2>/dev/null | grep -v '.mig-bak-' || true)
[ -n "$LEFT" ] && { warn "остались следы Windows-путей в:"; echo "$LEFT" | sed 's/^/     /'; } || ok "Windows-путей не осталось"

# ── ШАГ 7. SSH-ключи ────────────────────────────────────────────────
say "Шаг 7 — SSH-ключи → ~/.ssh"
SSHSRC="$MIG/ssh-keys"
if [ -d "$SSHSRC" ]; then
  [ -d "$HOME/.ssh" ] && [ -n "$(ls -A "$HOME/.ssh" 2>/dev/null)" ] && \
    { cp -R "$HOME/.ssh" "$HOME/.ssh.mig-bak-$TS"; warn "бэкап старого ~/.ssh"; }
  mkdir -p "$HOME/.ssh"
  cp -R "$SSHSRC/." "$HOME/.ssh/"
  chmod 700 "$HOME/.ssh"
  chmod 600 "$HOME"/.ssh/* 2>/dev/null || true
  chmod 644 "$HOME"/.ssh/*.pub 2>/dev/null || true   # публичные — 644
  ok "ключи скопированы, права выставлены (700/.ssh, 600 приватные, 644 .pub)"
  [ -f "$HOME/.ssh/hetzner_amb" ] && ok "ключ hetzner_amb на месте (доступ к серверу)"
else
  warn "нет $SSHSRC — SSH-ключи пропущены"
fi

# ── ШАГ 8. MCP-серверы — только показать, НЕ ставить ────────────────
say "Шаг 8 — MCP-серверы: что доустановить (НИЧЕГО не ставлю)"
MCPDOC="$CFG/mac-migration/MCP-SERVERS.md"
if [ -f "$MCPDOC" ]; then
  echo "  Читаю $MCPDOC:"; echo
  sed -n '1,120p' "$MCPDOC" | sed 's/^/    /'
else
  warn "нет $MCPDOC — покажи мне его содержимое вручную"
fi

say "ГОТОВО. Проверь отчёт выше. Бэкапы помечены суффиксом .mig-bak-$TS"
