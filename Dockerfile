FROM node:20-alpine AS deps
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
# 安装 Python 3、pip 及构建原生模块所需依赖
RUN apk add --no-cache \
    python3 \
    py3-pip \
    make \
    g++ \
    gcc \
    musl-dev \
    && ln -sf python3 /usr/bin/python

# 可选：验证 Python 和 pip 版本
RUN python --version && pip --version
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm@9.11.0 --registry=https://registry.npmmirror.com
ENV FFMPEG_BINARIES_URL="https://cdn.npmmirror.com/binaries/ffmpeg-static"
RUN pnpm install --registry=https://registry.npmmirror.com

FROM node:20-alpine AS builder
ARG APP_ENV
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /usr/app
ARG APP_ENV
COPY --from=builder /app/build ./build
COPY package.json ./
COPY ./config ./config
COPY ./public ./public
RUN rm -rf /usr/app/public/temp
RUN npm install -g pnpm@9.11.0 --registry=https://registry.npmmirror.com
ENV FFMPEG_BINARIES_URL="https://cdn.npmmirror.com/binaries/ffmpeg-static"
RUN pnpm install --prod --registry=https://registry.npmmirror.com
RUN chown -R node ./
USER node
ENV NODE_ENV="production"
EXPOSE 5050
CMD ["npm", "start"]
