# Codepods Templates

Colección de **plantillas de contenedores** para ejecutar distintos **asistentes de IA en línea de comandos (CLI)** accesibles desde el navegador web. Estas plantillas están diseñadas para ser consumidas por [**Codepods**](https://github.com/lualab-xyz/codepods), el orquestador que despliega cada plantilla como un *pod* contenerizado con un terminal web interactivo.

## ¿Cómo funciona?

Cada plantilla empaqueta un CLI de IA dentro de una imagen Docker basada en `ubuntu:24.04`. El propio `entrypoint` solo mantiene el contenedor vivo; los servicios se arrancan de forma independiente mediante el comando `start_agent` del orquestador:

1. `start_agent` lanza **[ttyd](https://github.com/tsl0922/ttyd)** en el puerto configurado (`7681` por defecto).
2. ttyd adjunta una sesión persistente de **[tmux](https://github.com/tmux/tmux)** que ejecuta el CLI correspondiente en `/workspace`.
3. Para los agentes con UI web, `start_agent` arranca también ese segundo servicio en su puerto correspondiente.
4. `stop_agent` detiene limpiamente la instancia anterior para poder reiniciar (`stop_agent` → `start_agent`).
5. `set_provider` configura el proveedor BYOK en la configuración nativa de cada CLI.

## Plantillas disponibles

| Plantilla | CLI | Servicios | Origen |
|-----------|-----|-----------|--------|
| [`copilot/`](./copilot) | GitHub Copilot CLI | Copilot CLI | [`@github/copilot`](https://www.npmjs.com/package/@github/copilot) |
| [`codex/`](./codex) | OpenAI Codex CLI | Codex CLI | [`@openai/codex`](https://www.npmjs.com/package/@openai/codex) |
| [`opencode/`](./opencode) | OpenCode CLI | OpenCode CLI + OpenCode Web | [`opencode-ai`](https://www.npmjs.com/package/opencode-ai) |
| [`claude/`](./claude) | Anthropic Claude Code CLI | Claude Code | [claude.ai/install.sh](https://code.claude.com/docs/en/quickstart) |
| [`kimi/`](./kimi) | Moonshot Kimi Code CLI | Kimi Code CLI + Kimi Web UI | [kimi-cli](https://github.com/MoonshotAI/kimi-cli) |
| [`openclaw/`](./openclaw) | OpenClaw gateway | OpenClaw + Control UI | [`openclaw`](https://www.npmjs.com/package/openclaw) |

## Estructura de una plantilla

```
<plantilla>/
├── manifest.yml        # Metadatos: nombre, descripción, iconos, servicios y comandos
├── Dockerfile          # Imagen base + instalación del CLI + ttyd
├── entrypoint.sh       # Keepalive del contenedor (tail -f /dev/null)
├── start-agent.sh      # Arranca ttyd/tmux (y la UI web si aplica)
├── stop-agent.sh       # Detiene la instancia anterior de start_agent
├── set-provider.sh     # Configura el proveedor BYOK del CLI
├── defaults.env        # Variables por defecto (puertos, terminal, modelo…)
├── files/              # Configuraciones nativas del CLI
└── *-light.svg|png     # Icono en modo claro
└── *-dark.svg|png      # Icono en modo oscuro
```

### `manifest.yml`

Describe la plantilla para Codepods:

```yaml
display_name: "Copilot"
description: "GitHub Copilot CLI configuration"
workspace_path: "/workspace"
icon: "copilot-light.svg"
icon_dark: "copilot-dark.svg"
services:
  - "terminal|Copilot CLI|7681"   # <nombre>|<tipo>|<puerto>
commands:
  - set_provider: "/usr/local/bin/set-provider.sh $baseUrl $modelName $apiKey $providerName $providerType"
  - start_agent: "/usr/local/bin/start-agent.sh"
  - stop_agent: "/usr/local/bin/stop-agent.sh"
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
docker run -d --name copilot-test -p 7681:7681 -e CODEPODS_TERMINAL_PORT=7681 codepods/copilot

# Arrancar los servicios
docker exec copilot-test /usr/local/bin/start-agent.sh
# o, si ya estaba arrancado, reiniciar:
docker exec copilot-test /usr/local/bin/stop-agent.sh
docker exec copilot-test /usr/local/bin/start-agent.sh

# Abre http://localhost:7681 en el navegador
```

> ⚠️ El primer arranque del CLI dentro del contenedor requerirá autenticación (p. ej. `/login`) con las credenciales del proveedor correspondiente. En su lugar, `set_provider` permite inyectar la configuración BYOK desde el orquestador.

## Añadir una nueva plantilla

1. Crea una carpeta nueva (p. ej. `mi-cli/`) replicando la estructura anterior.
2. Escribe un `Dockerfile` que instale el CLI y `ttyd`, y copie `entrypoint.sh`, `start-agent.sh`, `stop-agent.sh` y `set-provider.sh`.
3. `entrypoint.sh` debe ser keepalive (`tail -f /dev/null`); el arranque real va en `start-agent.sh`.
4. Escribe `start-agent.sh` para lanzar `ttyd` + `tmux` con el CLI en `/workspace`. Si el CLI tiene UI web, añade un servicio `web` como en `opencode/`, `kimi/` u `openclaw/`.
5. Añade `stop-agent.sh` para poder reiniciar limpiamente la sesión.
6. Define `manifest.yml`, `defaults.env` y los iconos.
7. Registra la plantilla en Codepods.

## Licencia

Este repositorio forma parte del ecosistema [Codepods](https://github.com/lualab-xyz/codepods). Consulta el proyecto principal para detalles de licencia.