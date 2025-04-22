# Keycloak Custom Image with Plugins

## Hướng dẫn thêm plugin vào Keycloak

Để thêm các plugin tùy chỉnh vào Keycloak, hãy làm theo các bước sau:

1. Mở file `Dockerfile` trong thư mục này
2. Tìm đến phần comment "Download and install custom providers/plugins here"
3. Thêm plugin theo một trong các cách sau:

### Cách 1: Tải plugin từ URL

```dockerfile
# Download plugin from URL
ADD https://repo1.maven.org/maven2/org/example/custom-plugin/1.0.0/custom-plugin-1.0.0.jar /opt/keycloak/providers/
```

### Cách 2: Sao chép plugin từ thư mục local

Đặt các file JAR plugin vào thư mục `plugins` và thêm dòng sau vào Dockerfile:

```dockerfile
# Copy plugins from local directory
COPY plugins/*.jar /opt/keycloak/providers/
```

### Cách 3: Biên dịch plugin từ mã nguồn

```dockerfile
# Build plugin from source
RUN git clone https://github.com/example/keycloak-plugin.git /tmp/keycloak-plugin && \
    cd /tmp/keycloak-plugin && \
    ./mvnw clean package && \
    cp target/*.jar /opt/keycloak/providers/ && \
    rm -rf /tmp/keycloak-plugin
```

## Lưu ý quan trọng

1. Sau khi thêm plugin, bạn cần build lại Docker image
2. Các plugin sẽ được cài đặt vĩnh viễn vào image và không bị mất khi container khởi động lại
3. Để các plugin hoạt động chính xác, đảm bảo chúng tương thích với phiên bản Keycloak được sử dụng (23.0.5)

## Ví dụ các plugin phổ biến cho Keycloak

1. **Keycloak Phone Provider**: Xác thực bằng số điện thoại
   - https://github.com/aerogear/keycloak-metrics-spi

2. **Keycloak Metrics SPI**: Thu thập metrics
   - https://github.com/aerogear/keycloak-metrics-spi

3. **Event Listener Email**: Gửi email khi có sự kiện
   - https://github.com/micedre/keycloak-mail-whitelisting 