ARG NODE_VERSION=24

FROM node:${NODE_VERSION}-alpine as builder

RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

FROM nginx:alpine

COPY nginx/default.conf /etc/nginx/nginx.conf

COPY --chown=nginx:nginx --from=builder /app/dist /usr/share/nginx/html

ENTRYPOINT ["nginx", "-c", "/etc/nginx/nginx.conf"]
CMD ["-g", "daemon off;"]

