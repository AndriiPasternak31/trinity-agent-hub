# Trinity Hub - Agent Marketplace

Install agents on [Trinity](https://github.com/abilityai/trinity) with a single command. No fork required.

## Quick Start

```bash
# 1. Clone and start Trinity (the original repo)
git clone https://github.com/abilityai/trinity
cd trinity
./scripts/deploy/start.sh

# 2. Install the marketplace CLI
pip install requests pyyaml
curl -sSL https://raw.githubusercontent.com/AndriiPasternak31/trinity-agent-hub/main/trinity_market.py \
  -o ~/.local/bin/trinity-market && chmod +x ~/.local/bin/trinity-market

# 3. Configure (enter your Trinity admin password)
trinity-market configure

# 4. Install the SMARTS 8-agent trading pipeline
trinity-market install smarts-pipeline
```

That's it. The CLI handles everything:
- Starts a local PostgreSQL database (no Supabase account needed)
- Creates all 8 agents from Trinity's built-in templates
- Injects credentials (you just provide Alpaca paper trading keys)
- Starts all agents

## Available Agents

| Name | Type | Description |
|------|------|-------------|
| smarts-trader | single | Self-contained AI trading agent with Alpaca integration |
| smarts-pipeline | system | 8-agent trading pipeline: market analysis, decision, execution |

## Install Options

```bash
# Option A: pip install
pip install git+https://github.com/AndriiPasternak31/trinity-agent-hub.git

# Option B: curl one-liner
curl -sSL https://raw.githubusercontent.com/AndriiPasternak31/trinity-agent-hub/main/install.sh | bash

# Option C: clone and run directly
git clone https://github.com/AndriiPasternak31/trinity-agent-hub.git
cd trinity-hub && python trinity_market.py
```

## Commands

### `trinity-market configure`
Set up connection to your Trinity instance. Two auth methods:
- **Admin password** (simplest) — uses your Trinity admin login
- **MCP API key** — from Trinity Settings > API Keys

### `trinity-market list [--category <name>]`
List all agents in the registry.

### `trinity-market search <query>`
Search agents by name, description, or category.

### `trinity-market info <name>`
Show details including required credentials and infrastructure.

### `trinity-market install <name> [options]`
Install an agent or multi-agent system.

Options:
- `--agent-name <name>` — Custom name for the agent
- `--env-file <path>` — Load credentials from an env file
- `--set KEY=VALUE` — Set a credential value (repeatable)

Examples:
```bash
# Interactive (prompts for everything)
trinity-market install smarts-pipeline

# Non-interactive
trinity-market install smarts-pipeline \
  --set ALPACA_API_KEY=pk_xxx \
  --set ALPACA_SECRET_KEY=sk_xxx

# From env file
trinity-market install smarts-pipeline --env-file .env.smarts
```

### `trinity-market status`
Show all agents installed on your Trinity instance.

## How It Works

The CLI is fully external — it does **not modify Trinity**. It uses Trinity's existing REST API:

```
trinity-market install smarts-pipeline
  │
  ├─ [1] Starts local PostgreSQL + PostgREST (in Docker, on Trinity's network)
  │      No Supabase account needed — DB runs locally
  │
  ├─ [2] Prompts for Alpaca API keys (free paper trading account)
  │
  └─ [3] For each of 8 agents:
         POST /api/agents          → create from local: template
         POST /api/agents/*/start  → start container
         POST /api/agents/*/credentials/inject → inject .env + .mcp.json
```

Infrastructure files (docker-compose, SQL, nginx config) are embedded in the CLI itself and written to `~/.trinity-market/smarts-db/` when needed.

## For Agent Authors

See [AUTHORING_AGENTS.md](docs/AUTHORING_AGENTS.md) for how to create and publish marketplace-ready agents.

## Configuration

Config is stored at `~/.trinity-market/config.yaml`:

```yaml
# Option A: admin password auth
trinity_url: "http://localhost:8000"
admin_password: "your-admin-password"

# Option B: MCP API key auth
trinity_url: "http://localhost:8000"
api_key: "trinity_mcp_xxxxxxxx"
```
