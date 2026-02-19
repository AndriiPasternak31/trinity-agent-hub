# SMARTS News Sentiment Analyzer

Analyzes news, earnings, and sentiment for watchlist symbols.

## Part of SMARTS Pipeline

This agent is part of the SMARTS 8-agent trading pipeline. See the [system README](../smarts-trading/README.md) for full pipeline documentation.

## Credentials Required

| Variable | Description | Where to Get |
|----------|-------------|--------------|
| ALPACA_API_KEY | Alpaca Markets API key | [Alpaca Dashboard](https://app.alpaca.markets) |
| ALPACA_SECRET_KEY | Alpaca Markets secret key | [Alpaca Dashboard](https://app.alpaca.markets) |
| SUPABASE_URL | Supabase project URL | [Supabase Dashboard](https://supabase.com/dashboard) |
| SUPABASE_SERVICE_KEY | Supabase service role key | [Supabase Dashboard](https://supabase.com/dashboard) > Settings > API |

## Setup

1. Copy `.env.example` to `.env` and fill in your credentials
2. Credentials are injected automatically by Trinity at startup

## Configuration

See `config.yaml` for agent-specific settings (schedules, thresholds, etc.).
