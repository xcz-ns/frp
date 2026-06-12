# 第一阶段：构建 frps 二进制文件
FROM golang:1.22-alpine AS builder

# 安装 make, git 以及用于编译前端 web UI 的 nodejs 和 npm
RUN apk add --no-cache make git nodejs npm

WORKDIR /src

# 复制源代码
COPY . .

# 编译 frps 
# 注意：Makefile 会自动判断是否需要编译 web UI。
# 如果前端编译报错，您可以将其修改为： RUN make frps NOWEB_TAG=,noweb 来跳过前端编译
RUN make frps

# 第二阶段：构建最终运行镜像
FROM alpine:latest

# 安装 ca-certificates 以支持 HTTPS 请求，安装 tzdata 以支持时区
RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /src/bin/frps /app/frps

# 暴露 frps 默认端口 (7000 用于绑定，7500 用于 Dashboard)
EXPOSE 7000 7500

# 设置入口点
ENTRYPOINT ["/app/frps"]
# 默认启动命令，可以通过 docker run 覆盖，例如：docker run ... -c /etc/frp/frps.toml