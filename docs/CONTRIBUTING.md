# Contributing to Just a Drop

First off, thank you for considering contributing to Just a Drop! It's people like you that make Just a Drop such a great tool for connecting volunteers with organizations.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

**Bug Report Template:**

- **Description**: Clear description of the bug
- **Steps to Reproduce**: Step-by-step guide to reproduce the issue
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Screenshots**: If applicable
- **Environment**:
  - OS: [e.g., macOS 14.0, Ubuntu 22.04]
  - Bun version: [e.g., 1.0.0]
  - Browser: [e.g., Chrome 120, Firefox 121]

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case**: Why is this enhancement needed?
- **Proposed solution**: How should it work?
- **Alternatives considered**: Other approaches you've thought about
- **Additional context**: Screenshots, mockups, etc.

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request**

## Development Setup

### Prerequisites

- Bun ([install](https://bun.sh))
- Docker (for PostgreSQL)
- Git

### Getting Started

1. **Fork and clone the repository**:

   ```bash
   git clone https://github.com/your-username/justadrop.xyz.git
   cd justadrop.xyz
   ```

2. **Install dependencies**:

   ```bash
   cd api && bun install
   cd ../view && bun install
   cd ../dashboard && bun install
   ```

3. **Set up the database**:

   ```bash
   docker-compose -f docker-compose.dev.yml up -d postgres
   ```

4. **Copy environment files**:

   ```bash
   cp api/.env.example api/.env
   cp view/.env.example view/.env
   cp dashboard/.env.example dashboard/.env
   ```

5. **Run migrations**:

   ```bash
   bun run db:migrate
   ```

6. **Start development servers**:

   ```bash
   bun run dev:api       # API on :3001
   bun run dev:view      # View on :3000
   bun run dev:dashboard # Dashboard on :3002
   ```

   The app will be available at:
   - View: <http://localhost:3000>
   - Dashboard: <http://localhost:3002>
   - API: <http://localhost:3001>
   - API Docs: <http://localhost:3001/swagger>

### Project Structure

```
justadrop.xyz/
├── api/              # Elysia backend (includes database schema & migrations)
├── view/             # Next.js frontend (includes UI components & utilities)
├── dashboard/        # Next.js admin dashboard (includes UI components & utilities)
└── docs/             # Documentation
```

## Coding Standards

### General Guidelines

- Write clear, readable code with meaningful variable names
- Follow the existing code style
- Add comments for complex logic
- Keep functions small and focused
- Prefer TypeScript over plain JavaScript

### TypeScript

- Use TypeScript for all new code
- Define proper types (avoid `any`)
- Define types locally in each app as needed
- Use Zod for runtime validation

### React/Next.js (Frontend)

- Use functional components with hooks
- Follow Next.js App Router conventions
- Use shadcn/ui components when possible
- Keep components small and reusable
- Use proper semantic HTML

### Elysia (Backend)

- Group related routes logically
- Use proper HTTP status codes
- Validate inputs with Zod
- Handle errors gracefully
- Document endpoints with Swagger/OpenAPI

### Database

- Create migrations for all schema changes
- Use descriptive column and table names
- Add indexes for frequently queried fields
- Use transactions for multi-step operations

### Git Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

**Examples:**

```
feat(api): add email verification endpoint

Add POST /auth/verify-email endpoint to verify user email addresses
using verification tokens sent via email.

Closes #123
```

```
fix(view): resolve mobile navigation menu not closing

The navigation menu on mobile devices wasn't closing after selecting
a link. Added onClick handler to close menu on route change.
```

## Database Migrations

When making database schema changes:

1. **Generate migration**:

   ```bash
   bun run db:generate
   ```

2. **Review the generated migration** in `api/drizzle/`

3. **Test the migration**:

   ```bash
   bun run db:migrate
   ```

4. **Commit both** the schema changes and the generated migration

## Documentation

- Update README.md if adding user-facing features
- Update API documentation (Swagger comments)
- Add JSDoc comments for complex functions
- Update CHANGELOG.md for notable changes

## Pull Request Process

1. **Update your fork** with the latest changes from `main`:

   ```bash
   git checkout main
   git pull upstream main
   git checkout your-feature-branch
   git rebase main
   ```

2. **Ensure code follows style guidelines**

3. **Update documentation** as needed

4. **Create a pull request** with:
   - Clear title describing the change
   - Description of what changed and why
   - Reference to related issues (e.g., "Closes #123")
   - Screenshots for UI changes

5. **Respond to review feedback** promptly

6. **Squash commits** if requested before merging

## Release Process

Releases are managed by maintainers:

1. Update CHANGELOG.md
2. Bump version in package.json files
3. Create a Git tag
4. Push to main
5. Create GitHub release

## Getting Help

- **Documentation**: Check [README.md](../README.md) and other docs
- **Issues**: Search existing issues or create a new one
- **Discussions**: Use GitHub Discussions for questions

## Recognition

Contributors will be recognized in:

- GitHub contributors page
- CHANGELOG.md for significant contributions

## License

By contributing to Just a Drop, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Just a Drop!
