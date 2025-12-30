#!/bin/bash # 使用 bash 解释器执行脚本
# 空行占位：分隔 shebang 与参数处理，提升可读性
CERT_HOST=$1 # 传入的证书主机名或 IP，作为 CN/SAN 值
CERT_DIR=$2  # 证书输出目录路径
CONF_FILE=$3 # OpenSSL 配置文件输出路径
# 空行占位：分隔变量定义与核心逻辑，提升可读性
echo "[req]                                   # OpenSSL 请求配置节
default_bits  = 2048                         # 密钥长度 2048 位
distinguished_name = req_distinguished_name  # 指定可分辨名称段
req_extensions = req_ext                     # 指定请求扩展段
x509_extensions = v3_req                     # 自签证书扩展段
prompt = no                                  # 禁止交互式输入

[req_distinguished_name]                     # 可分辨名称配置
countryName = XX                             # 国家代号占位
stateOrProvinceName = N/A                    # 省份占位
localityName = N/A                           # 城市占位
organizationName = Self-signed certificate   # 组织名称占位
commonName = $CERT_HOST: Self-signed certificate # CN 使用传入主机名

[req_ext]                                    # 请求扩展配置
subjectAltName = @alt_names                  # 引用备用名称列表

[v3_req]                                     # x509 扩展配置
subjectAltName = @alt_names                  # 引用备用名称列表

[alt_names]                                  # 备用名称列表
IP.1 = $CERT_HOST                            # 将传入主机名作为 IP SAN
" > "$CONF_FILE" # 将配置内容写入目标配置文件
# 空行占位：分隔配置文件生成与目录创建逻辑
mkdir -p "$CERT_DIR" # 创建证书目录（若不存在则递归创建）
# 空行占位：分隔目录创建与证书生成逻辑
openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout "$CERT_DIR/$CERT_HOST.key" -out "$CERT_DIR/$CERT_HOST.crt" -config "$CONF_FILE" # 生成 5 年有效期的 RSA2048 自签名证书与私钥
# 结尾行占位：保持文件末尾换行
# 文件结束（无额外逻辑）
