# ==========================================
# 階段 1: 建置 Flutter Web 靜態資源
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app

# 複製 pub 依賴清單並預先下載套件
COPY pubspec.yaml ./
RUN flutter pub get

# 複製專案原始碼並執行 Web Release 建置
COPY . .
RUN flutter build web --release

# ==========================================
# 階段 2: 使用 Nginx 託管靜態檔案
# ==========================================
FROM nginx:alpine

# 複製 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 複製編譯完成的 Flutter Web 靜態檔案
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Cloud Run 預設監聽 8080 埠號
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
