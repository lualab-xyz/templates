# Codepods Templates

Colección de **plantillas de contenedores** para ejecutar distintos **asistentes de IA en línea de comandos (CLI)** accesibles desde el navegador web. Estas plantillas están diseñadas para ser consumidas por [**Codepods**](https://github.com/lualab-xyz/codepods), el orquestador que despliega cada plantilla como un *pod* contenerizado con un terminal web interactivo.

## ¿Cómo funciona?

Cada plantilla empaqueta un CLI de IA dentro de una imagen Docker basada en `ubuntu:24.04`. Al arrancar el contenedor:

1. Se lanza **[ttyd](https://github.com/tsl0922/ttyd)** (un terminal web) en el puerto `7681`.
2. ttyd adjunta una sesión persistente de **[tmux](https://github.com/tmux/tmux)** que ejecuta el CLI correspondiente.
3. El usuario accede vía navegador y obtiene un terminal interactivo con el asistente, listo para autenticarse y trabajar sobre el directorio `/workspace`.

Algunos CLIs exponen además una **interfaz web adicional** (p. ej. OpenCode y Kimi Code) que se lanza como un segundo servicio.

## Plantillas disponibles

| Plantilla | CLI | Servicios | Origen |
|-----------|-----|-----------|--------|
| [`copilot/`](./copilot) | GitHub Copilot CLI | terminal | [`@github/copilot`](https://www.npmjs.com/package/@github/copilot) |
| [`codex/`](./codex) | OpenAI Codex CLI | terminal | [`@openai/codex`](https://www.npmjs.com/package/@openai/codex) |
| [`opencode/`](./opencode) | OpenCode CLI | terminal + web | [`opencode-ai`](https://www.npmjs.com/package/opencode-ai) |
| [`claude/`](./claude) | Anthropic Claude Code CLI | terminal | [claude.ai/install.sh](https://code.claude.com/docs/en/quickstart) |
| [`kimi/`](./kimi) | Moonshot Kimi Code CLI | terminal + web | [kimi-cli](https://github.com/MoonshotAI/kimi-cli) |

## Estructura de una plantilla

```
<plantilla>/
├── manifest.yml        # Metadatos: nombre, descripción, iconos y servicios expuestos
├── Dockerfile          # Imagen base + instalación del CLI + ttyd
├── entrypoint.sh       # Arranca ttyd (y opcionalmente la UI web) sobre tmux
├── defaults.env        # Variables por defecto (puertos, terminal, modelo…)
├── files/              # Configuraciones (p. ej. ~/.tmux.conf, ~/.codex/config.toml)
└── *-light.svg|png     # Icono en modo claro
└── *-dark.svg|png      # Icono en modo oscuro
```

### `manifest.yml`

Describe la plantilla para Codepods:

```yaml
display_name: "Copilot"
description: "GitHub Copilot CLI configuration"
icon: "copilot-light.svg"
icon_dark: "copilot-dark.svg"
services:
  - terminal|ttyd|7681        # <nombre>|<tipo>|<puerto>
  # - web|web|4096             # servicio web opcional
```

### Puertos y variables

Los puertos se pueden sobreescribir mediante variables de entorno, con *fallback* a las variables de Codepods (`CODEPODS_*`):

| Variable | Default | Origen Codepods | Descripción |
|----------|---------|-----------------|-------------|
| `TERMINAL_PORT` | `7681` | `CODEPODS_TERMINAL_PORT` | Puerto del terminal web (ttyd) |
| `WEB_PORT` | `4096` / `5494` | `CODEPODS_WEB_PORT` | Puerto de la UI web (si aplica) |
| `TERM_FONT_SIZE` | `14` | — | Tamaño de fuente del terminal |
| `TERM` | `tmux-256color` | — | Tipo de terminal |
| `LANG` | `en_US.UTF-8` | — | Locale |

## Uso

Estas plantillas no se ejecutan directamente: Codepods las descubre, construye la imagen correspondiente y despliega el pod. Consulta la documentación de [Codepods](https://github.com/lualab-xyz/codepods) para saber cómo registrar y lanzar una plantilla.

Para construir y probar una imagen manualmente:

```bash
cd copilot
docker build -t codepods/copilot .
docker run --rm -p 7681:7681 -e CODEPODS_TERMINAL_PORT=7681 codepods/copilot
# Abre http://localhost:7681 en el navegador
```

> ⚠️ El primer arranque del CLI dentro del contenedor requerirá autenticación (p. ej. `/login`) con las credenciales del proveedor correspondiente.

## Añadir una nueva plantilla

1. Crea una carpeta nueva (p. ej. `mi-cli/`) replicando la estructura anterior.
2. Escribe un `Dockerfile` que instale el CLI y `ttyd`.
3. Escribe un `entrypoint.sh` que lance `ttyd` + `tmux` ejecutando el CLI en `/workspace`. Si el CLI tiene UI web, añade un servicio `web` como en `opencode/` o `kimi/`.
4. Define `manifest.yml`, `defaults.env` y los iconos.
5. Registra la plantilla en Codepods.

## Licencia

Este repositorio forma parte del ecosistema [Codepods](https://github.com/lualab-xyz/codepods). Consulta el proyecto principal para detalles de licencia.