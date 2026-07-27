#!/usr/bin/env bash
#
# mcp-register-basic.sh — аккуратно добавляет в ~/.claude.json те MCP-серверы,
# что заводятся без ключей: playwright (браузер уже установлен) и mcp-image.
#
# Безопасно: проверяет валидность JSON, делает бэкап, мержит только .mcpServers,
# всё остальное (авторизацию, проекты) НЕ трогает. Повторный запуск не дублирует.
#
# Запуск:  bash ~/Downloads/mcp-register-basic.sh
#
set -uo pipefail
CJ="$HOME/.claude.json"
TS="$(date +%Y%m%d-%H%M%S)"

command -v jq >/dev/null || { echo "❌ нет jq (открой новое окно терминала)"; exit 1; }
[ -f "$CJ" ] || { echo "❌ нет ~/.claude.json — открой Claude Code хотя бы раз, потом запусти снова"; exit 1; }
jq empty "$CJ" 2>/dev/null || { echo "❌ ~/.claude.json — битый JSON, не трогаю. Покажи Claude."; exit 1; }

cp "$CJ" "$CJ.mig-bak-$TS"
echo "  бэкап: $CJ.mig-bak-$TS"

jq '.mcpServers = ((.mcpServers // {}) + {
  "playwright": {"command":"npx","args":["-y","@playwright/mcp@latest"]},
  "mcp-image": {"command":"npx","args":["-y","mcp-image"]}
})' "$CJ" > "$CJ.tmp" && mv "$CJ.tmp" "$CJ"

echo "✅ Добавлены: playwright, mcp-image"
echo "Текущий список MCP-серверов в ~/.claude.json:"
jq -r '.mcpServers | keys[]' "$CJ" | sed 's/^/  • /'
echo
echo "➡️  Перезапусти Claude Code (закрой и открой), затем набери /doctor —"
echo "    он покажет, какие серверы поднялись."
