# Hướng dẫn triển khai Keycloak Cluster với tích hợp GitHub

## Tổng quan

Tài liệu này hướng dẫn cách triển khai cụm Keycloak (Keycloak Cluster) với các tính năng:

- Cụm High Availability với nhiều node Keycloak
- Tích hợp với GitHub để tùy biến mã nguồn
- MySQL làm cơ sở dữ liệu
- Nginx làm load balancer
- Sao lưu tự động
- Giám sát trạng thái cụm

## Tích hợp với GitHub

Hệ thống sử dụng mã nguồn Keycloak được fork từ repository chính thức và lưu trữ tại repository GitHub của bạn. Điều này cho phép:

1. Tùy biến mã nguồn Keycloak
2. Thêm plugins và themes tùy chỉnh
3. Kiểm soát phiên bản và cập nhật

### Thiết lập Repository

Repository GitHub đã được cấu hình sẵn tại: https://github.com/vinhluong/key-cloak

Quá trình thiết lập repository được tự động hóa qua script `setup_github_repo.sh`:

```bash
# Chạy script thiết lập repository
./keycloak-cluster/scripts/setup_github_repo.sh
```

Script này thực hiện các công việc sau:
- Clone mã nguồn Keycloak chính thức
- Tạo nhánh tùy chỉnh
- Kết nối với repository GitHub của bạn
- Cập nhật các file cấu hình với thông tin repository

### Cách thức hoạt động của tích hợp GitHub

1. **Fork và Tùy chỉnh**:
   - Mã nguồn Keycloak được clone từ repository chính thức
   - Các tùy chỉnh được áp dụng và lưu trong branch riêng
   - Tất cả được đẩy lên repository GitHub của bạn

2. **Xây dựng Image**:
   - Docker image tùy chỉnh được xây dựng từ mã nguồn trong repository của bạn
   - Dockerfile tự động pull mã nguồn từ GitHub và build

3. **Triển khai**:
   - Docker Compose sử dụng image tùy chỉnh để khởi chạy các node Keycloak
   - Cụm Keycloak được cấu hình để đồng bộ qua MySQL
   - Nginx cân bằng tải giữa các node

## Cấu trúc thư mục

```
keycloak-cluster/
├── backups/                 # Thư mục lưu trữ backup
│   ├── configs/             # Backup cấu hình
│   ├── mysql/               # Backup MySQL
│   └── volumes/             # Backup volume
├── certbot/                 # Dữ liệu cho Certbot (chứng chỉ Let's Encrypt)
├── conf.d/                  # Cấu hình Nginx
├── docker-compose/          # Cấu hình Docker Compose
├── docker-images/           # Custom Docker images
├── keycloak-src/            # Mã nguồn Keycloak từ GitHub
├── mysql_data/              # Dữ liệu MySQL
├── scripts/                 # Các script tự động
└── ssl/                     # Chứng chỉ SSL
```

## Quy trình triển khai

### Bước 1: Chuẩn bị môi trường

Cài đặt các phần mềm cần thiết:
```bash
sudo apt update
sudo apt install docker.io docker-compose git
```

### Bước 2: Clone repository

```bash
git clone https://github.com/vinhluong/key-cloak.git
cd key-cloak
```

### Bước 3: Thiết lập GitHub integration

```bash
./keycloak-cluster/scripts/setup_github_repo.sh
```

Quá trình này sẽ:
- Yêu cầu đăng nhập vào GitHub qua trình duyệt
- Clone Keycloak và thiết lập kết nối với repository của bạn
- Cho phép chọn phiên bản Keycloak muốn sử dụng
- Tạo nhánh tùy chỉnh và đẩy lên repository

### Bước 4: Tùy chỉnh mã nguồn (nếu cần)

```bash
cd keycloak-cluster/keycloak-src

# Thực hiện các thay đổi trên mã nguồn
# Ví dụ thêm plugin tùy chỉnh vào thư mục custom-extensions/

# Commit và push thay đổi
git add .
git commit -m "Thêm các tùy chỉnh cho Keycloak"
git push origin custom-main
```

### Bước 5: Triển khai Keycloak Cluster

```bash
cd ../docker-compose
docker-compose up -d
```

## Các tác vụ quản trị thường dùng

### Kiểm tra trạng thái cụm

```bash
./keycloak-cluster/scripts/check_cluster.sh
```

### Sao lưu dữ liệu

```bash
# Sao lưu MySQL
./keycloak-cluster/scripts/backup_mysql.sh

# Sao lưu cấu hình
./keycloak-cluster/scripts/backup_config.sh

# Sao lưu volume
./keycloak-cluster/scripts/backup_volumes.sh
```

### Phục hồi dữ liệu

```bash
# Liệt kê các bản sao lưu MySQL
./keycloak-cluster/scripts/restore_mysql.sh --list

# Phục hồi từ bản sao lưu mới nhất
./keycloak-cluster/scripts/restore_mysql.sh
```

## Cập nhật hệ thống

Khi muốn cập nhật Keycloak với các tùy chỉnh mới:

1. Push các thay đổi lên GitHub
2. Rebuild Docker image
```bash
cd keycloak-cluster/docker-compose
docker-compose up -d --build
```

## Xử lý sự cố

### Repository GitHub

Nếu gặp vấn đề với kết nối GitHub:

1. Kiểm tra xác thực GitHub:
```bash
gh auth status
```

2. Đăng nhập lại nếu cần:
```bash
gh auth login
```

3. Chạy lại script thiết lập:
```bash
./keycloak-cluster/scripts/setup_github_repo.sh
```

### Docker Build

Nếu gặp lỗi khi build Docker image:

1. Kiểm tra logs:
```bash
docker-compose logs -f
```

2. Kiểm tra kết nối đến GitHub:
```bash
git -C keycloak-cluster/keycloak-src remote -v
```

3. Thử pull mã nguồn thủ công:
```bash
cd keycloak-cluster/keycloak-src
git pull origin custom-main
```

## Kết luận

Với cách thiết lập này, bạn có thể tùy chỉnh Keycloak theo nhu cầu của tổ chức mà không cần sửa đổi container mỗi lần. Mọi thay đổi được quản lý qua GitHub và tự động áp dụng khi build image mới. 