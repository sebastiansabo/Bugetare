# J.A.R.V.I.S. - Enterprise Platform

A modular enterprise platform for accounting, HR, and business operations management.

## Sections

| Section | Apps | Description |
|---------|------|-------------|
| **Accounting** | Invoices, Templates, Bugetare, Statements, e-Factura | Invoice allocation, bank statement parsing, ANAF e-invoicing |
| **HR** | Events | Employee event bonus management |
| **AI** | AI Agent | Multi-provider chatbot with RAG (Claude, OpenAI, Groq, Gemini) |
| **Core** | Auth, Roles, Organization, Settings, Profile, Tags, Presets, Notifications, Connectors, Drive | User management, permissions, platform configuration |

## Tech Stack

- **Backend**: Flask + Gunicorn (17 blueprints, ~30 repository classes)
- **Database**: PostgreSQL (pgvector for RAG)
- **Frontend**: React 19 + TypeScript + Vite + Tailwind + shadcn/ui (at `/app/*`)
- **AI**: Multi-provider (Claude, OpenAI, Groq, Gemini) for chatbot + Claude Sonnet vision for invoice parsing
- **Storage**: Google Drive integration
- **Deployment**: DigitalOcean App Platform (Docker)

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export DATABASE_URL='postgresql://user@localhost:5432/defaultdb'
export ANTHROPIC_API_KEY='your-key'

# Run locally
python jarvis/app.py
```

## Project Structure

```
jarvis/
├── app.py                 # Flask app (484 lines, 17 blueprints)
├── database.py            # DB pool + helpers (235 lines)
├── migrations/            # Schema & seed data (init_schema.py)
├── core/                  # Core platform
│   ├── auth/              # Authentication & users
│   ├── roles/             # Roles & permissions
│   ├── organization/      # Companies & structure
│   ├── settings/          # Themes, menus, dropdowns
│   ├── tags/              # Platform-wide tagging
│   ├── presets/           # User filter presets
│   ├── notifications/     # Email notifications
│   ├── profile/           # User profile
│   ├── connectors/        # External connectors (e-Factura/ANAF)
│   ├── drive/             # Google Drive integration
│   └── services/          # Shared utilities
├── accounting/            # Accounting section
│   ├── invoices/          # Invoice & allocation management
│   ├── templates/         # Invoice parsing templates
│   ├── bugetare/          # Bulk processor & invoice parser
│   ├── statements/        # Bank statement parsing
│   └── efactura/          # e-Factura accounting UI
├── hr/                    # HR section
│   └── events/            # Event bonus management
├── ai_agent/              # AI chatbot (multi-provider + RAG)
└── frontend/              # React SPA (Vite + TS + Tailwind)
```

## Documentation

- **[docs/CLAUDE.md](docs/CLAUDE.md)** - Detailed project documentation and development guide
- **[docs/CHANGELOG.md](docs/CHANGELOG.md)** - Version history and release notes

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string (required) |
| `ANTHROPIC_API_KEY` | Claude API key for invoice parsing |
| `GOOGLE_CREDENTIALS_JSON` | Google Drive API credentials |
| `EFACTURA_MOCK_MODE` | Set `true` for dev without ANAF certificate |

## Deployment

Configured for DigitalOcean App Platform via `.do/app.yaml`. Auto-deploys on push to `main` branch.

## Branch Workflow

| Branch | Purpose |
|--------|---------|
| `staging` | Development & testing |
| `main` | Production |

## License

Proprietary - All rights reserved.
