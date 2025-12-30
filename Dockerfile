# 构建阶段：使用 Go 官方镜像以编译 derper
FROM golang:latest AS builder
# 空行占位：分隔构建阶段与元数据

# 镜像元数据：标注源码仓库地址
LABEL org.opencontainers.image.source https://github.com/yangchuansheng/ip_derper
# 空行占位：分隔元数据与工作目录

# 进入构建阶段的工作目录 /app
WORKDIR /app
# 空行占位：分隔工作目录与源码拷贝

# 拷贝 tailscale 子模块源码用于编译
ADD tailscale /app/tailscale
# 空行占位：分隔拷贝与编译步骤

# 构建自定义 derper（二进制静态编译后清理源码）
RUN cd /app/tailscale/cmd/derper && \
    CGO_ENABLED=0 /usr/local/go/bin/go build -buildvcs=false -ldflags "-s -w" -o /app/derper && \
    cd /app && \
    rm -rf /app/tailscale
# 空行占位：分隔构建阶段与运行阶段

# 运行阶段：选择 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04
# 设置运行阶段工作目录 /app
WORKDIR /app
# 空行占位：分隔工作目录与配置段

# ========= CONFIG ========= # 配置段说明
# derper TLS 监听地址（含端口）
ENV DERP_ADDR :443
# derper HTTP 端口
ENV DERP_HTTP_PORT 80
# derper 主机名/证书 CN
ENV DERP_HOST=127.0.0.1
# 证书存放目录
ENV DERP_CERTS=/app/certs/
# 是否启用 STUN
ENV DERP_STUN true
# 是否验证客户端证书
ENV DERP_VERIFY_CLIENTS false
# ========================== # 配置段结束
# 空行占位：分隔配置与依赖安装

# 安装 openssl 与 curl 以支持证书生成和网络探测
RUN apt-get update && \
    apt-get install -y openssl curl
# 空行占位：分隔依赖安装与文件复制

# 复制证书生成脚本到工作目录
COPY build_cert.sh /app/
# 复制构建好的 derper 二进制到运行镜像
COPY --from=builder /app/derper /app/derper
# 空行占位：分隔文件复制与启动命令

# 容器启动：生成自签证书后以手动证书模式启动 derper
CMD bash /app/build_cert.sh $DERP_HOST $DERP_CERTS /app/san.conf && \
    /app/derper --hostname=$DERP_HOST \
    --certmode=manual \
    --certdir=$DERP_CERTS \
    --stun=$DERP_STUN  \
    --a=$DERP_ADDR \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS
