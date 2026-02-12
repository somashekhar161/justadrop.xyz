# Just a Drop

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](docs/CONTRIBUTING.md)

A platform connecting volunteers with organizations that need help.

## Stack

- **Runtime**: Bun
- **Backend**: Elysia
- **Database**: PostgreSQL + Drizzle ORM
- **Monorepo**: Bun workspaces

## Structure

```
apps/
  api/         Elysia backend API
  view/        Frontend application (to be implemented)
  dashboard/   Admin dashboard (to be implemented)
packages/
  db/          Drizzle schema and migrations
  types/       Shared TypeScript types
  common/      Common utilities and shared logic
```

## Prerequisites

- Bun >= 1.0 ([install](https://bun.sh))
- Docker (for PostgreSQL)

## Setup

```bash
# Install dependencies
bun install

# Copy environment file
cp .env.example .env

# Setup PostgreSQL (Docker)
# Note: Add your database setup command here

# Generate and run migrations (after defining schema)
bun run db:generate
bun run db:migrate

# Build packages
bun run build:packages
```

## Development

```bash
# Start all apps
bun run dev

# Start individually
bun run dev:api       # API on :3001
bun run dev:view      # View on :3000 (to be implemented)
bun run dev:dashboard # Dashboard on :3002 (to be implemented)

# Database studio
bun run db:studio
```

## Build

```bash
bun run build
```

## API Documentation

OpenAPI docs available at <http://localhost:3001/swagger>

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for contribution guidelines.

## Documentation

- [Contributing Guide](docs/CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Changelog](CHANGELOG.md)

## License

MIT License - see [LICENSE](LICENSE) file for details.
