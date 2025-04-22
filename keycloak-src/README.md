# Keycloak Source Code Directory

Thư mục này được sử dụng để chứa mã nguồn Keycloak đã được fork từ repository chính thức. Đây là nơi bạn có thể thực hiện các tùy chỉnh trên mã nguồn Keycloak.

## Thiết lập tự động

Khi chạy script `setup_github_repo.sh`, thư mục này sẽ được tự động điền với mã nguồn Keycloak và cấu hình để kết nối với repository GitHub của bạn.

```bash
# Chạy từ thư mục gốc của repository
./keycloak-cluster/scripts/setup_github_repo.sh
```

## Cấu trúc thư mục sau khi thiết lập

Sau khi chạy script thiết lập, thư mục này sẽ chứa:

```
keycloak-src/
├── adapters/           # Adapters cho các ứng dụng client
├── authz/              # Authorization services
├── common/             # Thư viện chung
├── core/               # Core services
├── custom-extensions/  # Thư mục chứa các extension tùy chỉnh của bạn
├── quarkus/            # Quarkus distribution
├── server-spi/         # Service Provider Interfaces
├── services/           # Services implementation
├── themes/             # Themes mặc định
└── ...                 # Các thư mục và file khác
```

## Custom Extensions

Thêm plugins và tùy chỉnh của bạn vào thư mục `custom-extensions/`:

- `custom-extensions/themes/`: Custom themes
- `custom-extensions/providers/`: Custom authentication providers và SPI

## Quản lý mã nguồn

Sau khi tùy chỉnh mã nguồn, đẩy các thay đổi lên GitHub:

```bash
cd keycloak-src
git add .
git commit -m "Add custom theme and providers"
git push origin custom-main  # hoặc tên branch của bạn
```

## Cập nhật Docker Image

Sau khi đẩy các thay đổi lên GitHub, rebuild Docker image để áp dụng các thay đổi:

```bash
cd ../docker-compose
docker-compose up -d --build
```

## Tham khảo

- [Keycloak Official Docs](https://www.keycloak.org/documentation)
- [Keycloak GitHub Repository](https://github.com/keycloak/keycloak)
- [Developing Themes](https://www.keycloak.org/docs/latest/server_development/#_themes)
- [Service Provider Interfaces](https://www.keycloak.org/docs/latest/server_development/#_providers) 