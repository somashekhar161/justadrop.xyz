# syntax = docker/dockerfile:1

FROM oven/bun:1 AS base
WORKDIR /app

# Install dependencies
FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json bun.lockb* /temp/dev/
COPY apps/view/package.json /temp/dev/apps/view/
COPY packages/types/package.json /temp/dev/packages/types/
COPY packages/common/package.json /temp/dev/packages/common/
RUN cd /temp/dev && bun install --frozen-lockfile

# Production dependencies
RUN mkdir -p /temp/prod
COPY package.json bun.lockb* /temp/prod/
COPY apps/view/package.json /temp/prod/apps/view/
COPY packages/types/package.json /temp/prod/packages/types/
COPY packages/common/package.json /temp/prod/packages/common/
RUN cd /temp/prod && bun install --frozen-lockfile --production

# Build stage
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

# Build packages
RUN cd packages/common && bun run build || echo "No build script"
RUN cd packages/types && bun run build

# Build the view app
RUN cd apps/view && bun run build

# Production image
FROM base AS release
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /app/apps/view/dist ./apps/view/dist
COPY --from=prerelease /app/packages/types/dist ./packages/types/dist
COPY --from=prerelease /app/packages/common/dist ./packages/common/dist
COPY --from=prerelease /app/apps/view/package.json ./apps/view/package.json
COPY --from=prerelease /app/packages/types/package.json ./packages/types/package.json
COPY --from=prerelease /app/packages/common/package.json ./packages/common/package.json
COPY --from=prerelease /app/package.json ./package.json

EXPOSE 3000

CMD ["bun", "run", "apps/view/dist/index.js"]
