# Authoring Marketplace-Ready Agents

This guide explains how to structure, validate, and publish agents for the Trinity marketplace.

## Overview

A marketplace-ready agent is a Trinity agent template packaged so that anyone can install it with a single command. The user only needs to provide their own API credentials — everything else is handled by the template and the CLI.

## Single Agent Structure

```
my-agent/
├── template.yaml          # Required: agent metadata
├── CLAUDE.md              # Required: agent instructions
├── .mcp.json.template     # Required: MCP config with ${VAR} placeholders
├── .env.example           # Required: list of needed credentials
├── .gitignore             # Required: exclude .env, .mcp.json
├── README.md              # Recommended: human-readable setup guide
├── config.yaml            # Optional: agent-specific configuration
└── memory/                # Optional: initial memory files
```

## Required Files

### `template.yaml`

Agent metadata used by Trinity and the marketplace registry:

```yaml
name: my-agent
display_name: "My Agent"
description: "What this agent does in one sentence"
version: "1.0.0"
author: "Your Name"
type: research-assistant

mcp_servers:
  - name: my-service
    command: npx
    args: ["-y", "@service/mcp-server"]
```

Required fields: `name`, `display_name`, `description`, `version`, `author`.

### `CLAUDE.md`

The agent's brain — instructions that define its behavior. This is loaded into the agent's system prompt by Trinity.

### `.mcp.json.template`

MCP server configuration with `${VARIABLE}` placeholders for credentials:

```json
{
  "mcpServers": {
    "my-service": {
      "command": "npx",
      "args": ["-y", "@service/mcp-server"],
      "env": {
        "API_KEY": "${MY_SERVICE_API_KEY}",
        "API_SECRET": "${MY_SERVICE_SECRET}"
      }
    }
  }
}
```

Rules:
- Every credential value uses `${VAR_NAME}` syntax
- Variable names match entries in `.env.example`
- Non-secret values (commands, args) can be hardcoded
- Must be valid JSON when placeholders are replaced
- Default values supported: `${VAR:-default_value}`

### `.env.example`

Lists all required environment variables with placeholder values:

```bash
# Service Name - get your key at https://service.com/keys
MY_SERVICE_API_KEY=your-api-key-here
MY_SERVICE_SECRET=your-secret-here

# Optional: Feature name (leave empty to disable)
OPTIONAL_VAR=
```

Include comments with links to where users can get each credential.

### `.gitignore`

Must exclude sensitive files:

```
.env
.mcp.json
.credentials.enc
```

## Multi-Agent System Structure

Systems (pipelines of multiple agents) add these files:

```
my-system/
├── system.yaml            # Required: system manifest
├── .env.example           # Required: union of all agent credentials
├── agents/
│   ├── agent-one/         # Each follows single-agent spec
│   │   ├── template.yaml
│   │   ├── CLAUDE.md
│   │   ├── .mcp.json.template
│   │   └── ...
│   └── agent-two/
│       └── ...
├── infra/                 # Optional: external dependencies
│   ├── db/
│   │   └── 001_create_tables.sql
│   └── README.md
└── README.md
```

## Credential Security

### Never commit:
- `.env` files with real values
- `.mcp.json` files with real credentials
- API keys, tokens, or secrets in any file
- Real service URLs (use `your-project.supabase.co`)

### Secret detection patterns the validator checks:
- `sk-...` (OpenAI keys)
- `ghp_...` (GitHub PATs)
- `eyJ...` (JWT/base64 tokens longer than 40 chars)
- `AKIA...` (AWS access keys)
- Project-specific Supabase URLs

## Validating Your Agent

Use the validation script to check marketplace readiness:

```bash
# Single agent
python scripts/validate-marketplace-agent.py ./my-agent/

# Multi-agent system
python scripts/validate-marketplace-agent.py ./my-system/ --system
```

The validator checks:
- All required files exist
- `template.yaml` has required fields
- `.mcp.json.template` uses `${VAR}` placeholders
- `.env.example` covers all template variables
- `.gitignore` excludes sensitive files
- No hardcoded secrets detected

## Publishing to the Registry

### 1. Create a GitHub repo for your agent

Push your marketplace-ready agent to a GitHub repo (e.g., `your-org/my-agent`).

### 2. Submit a PR to the registry

Add an entry to `registry.yaml` in the trinity-hub repo:

```yaml
agents:
  my-agent:
    type: single
    display_name: "My Agent"
    description: "What this agent does"
    author: "Your Name"
    version: "1.0.0"
    template: "github:your-org/my-agent"
    categories: [category1, category2]
    credentials:
      - name: MY_API_KEY
        description: "API key for service"
        service: my-service
        required: true
```

### 3. Required for the PR:
- Validation script passes with no failures
- No credentials in committed files
- README.md with setup instructions
- All credential sources documented in `.env.example`

## How Credentials Flow at Install Time

```
User runs: trinity-market install my-agent

1. CLI reads registry.yaml → finds agent entry
2. CLI prompts user for each credential in entry.credentials
3. CLI calls Trinity API:
   POST /api/agents {name, template: "github:org/repo"}
4. Trinity clones the repo, creates container
5. CLI builds .env from user input
6. CLI fetches .mcp.json.template from repo
7. CLI substitutes ${VAR} with user values → .mcp.json
8. CLI calls Trinity API:
   POST /api/agents/{name}/credentials/inject {files: {".env": ..., ".mcp.json": ...}}
9. CLI calls Trinity API:
   POST /api/agents/{name}/start
10. Agent starts with credentials loaded
```

## Tips

- Keep agent scope focused — one clear purpose per agent
- Include example workflows in CLAUDE.md (slash commands)
- Test with paper/sandbox credentials before publishing
- Version your agent with semver
- Document all external dependencies (databases, APIs) in README and infra/
