#!/usr/bin/env bash
#
# fix-remaining-paths.sh — добивает оставшиеся Windows-пути во ВСЕХ файлах
# (проектах и скиллах), не только в памяти/конфигах.
#
# Безопасно: правит ТОЛЬКО твой путь "Hi-Tech Center" — чужие C:\Users и
# плагинные файлы не трогает. Делает бэкапы *.mig-bak-<время>.
#
# Запуск на Маке:  bash ~/Downloads/fix-remaining-paths.sh
#
set -uo pipefail
TS="$(date +%Y%m%d-%H%M%S)"

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

printf '\033[1;36m▶ Ищу файлы с путём Hi-Tech Center в ~/.claude и ~/ClaudeHome...\033[0m\n'
c=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  rewrite_one "$f"
  c=$((c+1))
  printf '  \033[1;32m✅ %s\033[0m\n' "$f"
done < <(grep -rIl 'Hi-Tech Center' "$HOME/.claude" "$HOME/ClaudeHome" 2>/dev/null | grep -v '\.mig-bak-')

printf '\n\033[1;36m▶ Готово. Поправлено файлов: %s\033[0m\n' "$c"
LEFT=$(grep -rIl 'Hi-Tech Center' "$HOME/.claude" "$HOME/ClaudeHome" 2>/dev/null | grep -v '\.mig-bak-' || true)
if [ -n "$LEFT" ]; then
  printf '  \033[1;33m⚠️  Осталось (глянь вручную, там путь в необычной форме):\033[0m\n'
  echo "$LEFT" | sed 's/^/     /'
else
  printf '  \033[1;32m✅ Путей Hi-Tech Center больше не осталось.\033[0m\n'
fi
