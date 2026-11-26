# Stack defaults

This file is the plugin's **single source** of stack defaults. Any other file that names a default stack links here instead of restating it.

Design uses it once per stack area that the scope checklist marks *in*:

1. **Look for an established stack first.** Check the repository for the signal files listed under that area below. If any are present, the area has an established stack. **The established stack always wins.** Design for it, and don't propose replacing it with the default unless the user asks for a migration.
2. **Only if no signal is found,** propose the area's default from the table, and record in the design that none was found. For example: "No Prisma schema or other database code found; proposing the default, Postgres through Prisma."

A design states what it detected per area, so a reviewer can see why it chose the established stack or the default.

## Defaults

| Stack area | Default | Notes |
|---|---|---|
| Frontend | React + TypeScript | Vite is the scaffold's build tool (`init`) |
| Backend | Node.js + TypeScript, CQRS (commands and queries kept separate), Scalar API reference docs | The API is described in OpenAPI and rendered with Scalar |
| Database | PostgreSQL through Prisma (schema, client and migrations) | All schema changes go through Prisma migrations |
| Infrastructure | Terraform | Infrastructure as code. No other IaC tool is a default |

## Established-stack signals

A signal is a file or folder whose presence shows that the area is already built on some stack. The examples aren't exhaustive. Judge any other clear evidence the same way, and name what you found.

| Stack area | Signals (any one is enough) | Example of "established, design for it" |
|---|---|---|
| Frontend | `package.json` listing a UI framework (`react`, `vue`, `svelte`, `@angular/core`, `solid-js`); `src/**/*.{tsx,jsx,vue,svelte}`; framework config (`vite.config.*`, `next.config.*`, `nuxt.config.*`, `angular.json`, `svelte.config.*`) | `package.json` lists `vue` → design Vue components, not React |
| Backend | `package.json` listing a server framework (`express`, `fastify`, `@nestjs/core`, `koa`, `hono`); `pyproject.toml` or `requirements.txt` listing `fastapi`, `django` or `flask`; `go.mod`; `pom.xml` or `build.gradle*`; `*.csproj`; `Gemfile` with `rails` | `pyproject.toml` lists `fastapi` → design FastAPI endpoints, with no move to Node.js |
| Database | `prisma/schema.prisma`; migration folders (`migrations/`, `db/migrate/`, `alembic/`); `schema.sql`; ORM models (`models.py`, `db/schema.rb`, TypeORM or Sequelize entities); a database service in `docker-compose.yml` | `alembic/` with SQLAlchemy models → design SQLAlchemy models and an Alembic migration |
| Infrastructure | `*.tf` or `terraform/`; CloudFormation or SAM templates (`template.yaml`, `*.template.json`); `cdk.json`; `Pulumi.yaml`; `k8s/` or Helm `Chart.yaml`; `bicep` files | A CloudFormation template → design CloudFormation resources, with no move to Terraform |

## When an area is partly established

If an area has a stack but lacks a part the default would bring, keep the established stack and fill the gap in its own ecosystem. For example, an Express backend with no API docs gets OpenAPI docs that fit Express. Scalar is a fine choice there, but don't add Prisma to a backend that already uses another ORM. Raise any real tension as a significant choice, with options for the user.
