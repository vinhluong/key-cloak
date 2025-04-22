# Custom Extensions for Keycloak

Thư mục này chứa các extension tùy chỉnh cho Keycloak. Đây là nơi bạn nên thêm các theme, provider và SPI tùy chỉnh thay vì sửa trực tiếp mã nguồn Keycloak.

## Cấu trúc thư mục

```
custom-extensions/
├── themes/     # Custom themes
└── providers/  # Custom authentication providers và SPI
```

## Cách thêm custom theme

1. Tạo thư mục theme mới trong `themes/`:

```
themes/my-custom-theme/
├── login/
│   ├── resources/
│   │   ├── css/
│   │   ├── img/
│   │   └── js/
│   ├── theme.properties
│   └── login.ftl
└── account/
    └── ...
```

2. Dựa trên theme mặc định ở `../../themes/` để tạo theme của bạn
3. Trong `theme.properties` bạn có thể kế thừa theme mặc định:

```properties
parent=keycloak
import=common/keycloak
```

## Cách thêm custom provider

1. Tạo thư mục provider mới trong `providers/`:

```
providers/my-custom-provider/
└── src/
    └── main/
        ├── java/
        │   └── org/example/
        │       └── MyCustomProvider.java
        └── resources/
            └── META-INF/
                └── services/
```

2. Implement SPI interface từ Keycloak
3. Đăng ký provider trong file trong `META-INF/services/`

## Sử dụng trong Dockerfile

Khi custom extensions được đẩy lên GitHub, Docker build sẽ tự động sao chép các files này vào Keycloak:

```dockerfile
# Sao chép custom themes
COPY keycloak-src/custom-extensions/themes/* /opt/keycloak/themes/

# Sao chép custom providers
COPY keycloak-src/custom-extensions/providers/*.jar /opt/keycloak/providers/
```

## Tham khảo

- [Keycloak Server Development](https://www.keycloak.org/docs/latest/server_development/)
- [Keycloak Themes](https://www.keycloak.org/docs/latest/server_development/#_themes)
- [Keycloak SPIs](https://www.keycloak.org/docs/latest/server_development/#_providers) 