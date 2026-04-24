# SETUP — установка полного стека на твоей машине

Это инструкция для новичка. Всё, что внутри Python-скрипта, работает уже сейчас. Этот документ — про расширенный режим: когда Claude напрямую управляет FreeCAD у тебя на компе.

---

## Уровень 1. Минимум (только Python-скрипт) — уже работает

Ничего дополнительного не нужно. В папке `metal-shelving/` запускай:

```bash
./venv/bin/python scripts/etazherka.py
```

Получишь STEP-модель и cut list. Этого достаточно, чтобы поехать в металлобазу и сварить этажерку.

---

## Уровень 2. FreeCAD локально (просмотр и правка чертежей)

### macOS

```bash
brew install --cask freecad
```

### Ubuntu / Debian

```bash
sudo apt install freecad
```

### Windows

Скачать инсталлятор: https://www.freecad.org/downloads.php

### Проверка

Открой в FreeCAD файл `metal-shelving/output/etazherka.step`. Должна появиться 3D-модель этажерки. Дальше:

1. Меню **View → Workbench → TechDraw**.
2. `TechDraw → New default Page (A3 Landscape)`.
3. Выдели модель в дереве слева, `TechDraw → Insert view`.
4. Добавь размеры: `TechDraw → Dimensions`.
5. `File → Export → PDF` — готовый рабочий чертёж.

Для сварных символов: `File → Import` → выбери `metal-shelving/welding-symbols/weld symbols project.dxf`, вставляй как блоки.

---

## Уровень 3. Claude управляет FreeCAD через MCP

Позволяет в чате с Claude писать «сделай полки 500 мм и добавь бортик 20 мм» — Claude сам переделает модель в FreeCAD.

### Шаг 1. Установи FreeCAD MCP

Рекомендуемый вариант — **contextform/freecad-mcp** (работает с Claude Code из коробки):

```bash
git clone https://github.com/contextform/freecad-mcp.git
cd freecad-mcp
# следуй инструкциям в их README, раздел "Installation"
# обычно это: pip install -e . + копирование плагина в FreeCAD Mod/
```

Альтернативы (если первая не заведётся):
- https://github.com/neka-nat/freecad-mcp
- https://github.com/proximile/FreeCAD-MCP (в Docker)
- https://github.com/jango-blockchained/mcp-freecad

### Шаг 2. Пропиши MCP-сервер в Claude Code

Открой файл `~/.claude/settings.json` (создай, если нет). Добавь секцию:

```json
{
  "mcpServers": {
    "freecad": {
      "command": "python",
      "args": ["-m", "freecad_mcp"],
      "env": {}
    }
  }
}
```

(Точная команда запуска — в README выбранного тобой MCP-сервера.)

Перезапусти Claude Code. Выполни в чате `/mcp` — должен появиться сервер `freecad` со статусом `connected`.

### Шаг 3. Проверка

В чате с Claude:

> «Открой `metal-shelving/output/etazherka.step` в FreeCAD, создай TechDraw-страницу A3 с четырьмя видами и экспортируй PDF в `metal-shelving/output/drawing.pdf`.»

Claude выполнит это через MCP.

---

## Уровень 4. OpenSCAD (альтернативный движок)

Если предпочитаешь текстовый CAD:

```bash
# macOS
brew install --cask openscad
# Ubuntu
sudo apt install openscad
```

Skill `openscad-3d-modeler` (в маркетплейсе Claude) научит Claude писать `.scad` файлы. Но для сварных рам `build123d` удобнее — умеет в STEP, что понимают промышленные станки.

---

## Уровень 5. Раскрой DXF на лазере / плазме (Deepnest)

Если полки будут вырезаться лазером — нужно оптимально разложить их на листе.

```bash
# Скачай готовые бинарники
# https://github.com/Jack000/Deepnest/releases
```

Процесс:
1. Экспортируй каждую полку в DXF (допиши в `etazherka.py` вызов `ezdxf` — могу добавить).
2. Запусти Deepnest, загрузи все DXF + размер листа (обычно 1250×2500 мм).
3. Получи раскладку и общий DXF для лазера.

---

## Уровень 6. Skills из маркетплейса Claude

Проверь `~/.claude/skills/` — скилы из этого репо (`metal-shelving-designer`, `build123d-cad`, `welding-drawings`) уже лежат в `.claude/skills/` проекта и подхватятся автоматически при открытии репы в Claude Code.

Дополнительно можешь поставить из маркетплейса:

```
/plugin install build123d-cad-modeling
/plugin install openscad-3d-modeler
```

(Команды выполняются в Claude Code, не в терминале.)

---

## Troubleshooting

**`ModuleNotFoundError: build123d`** — ты запустил системный `python3` вместо venv. Используй полный путь: `./venv/bin/python scripts/etazherka.py`.

**FreeCAD не видит MCP** — проверь `/mcp` в чате, логи MCP-сервера, версию FreeCAD (нужен 0.21+).

**STEP открывается пустой в FreeCAD** — обнови FreeCAD до 1.0+. Старые версии плохо читают STEP от build123d 0.10.

**Deepnest падает на Linux** — используй AppImage-сборку, не apt-пакет.

---

## Что я (Claude) смогу сделать для тебя после установки

- Принять от тебя габариты, число полок, материал → сгенерировать модель.
- Посмотреть на 3D-модель (если есть FreeCAD MCP) и прокомментировать пропорции.
- Сгенерировать DXF каждой детали + общий раскрой для лазера.
- Построить чертёж TechDraw с размерами и сварными швами.
- Выдать список покупок в металлобазу с ценами по рынку (по запросу — поиск в сети).
