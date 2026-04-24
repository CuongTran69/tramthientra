# Hướng dẫn cấu hình Xcode Cloud — Trạm Thiền Trà

## Tổng quan

Xcode Cloud sẽ tự động build + test + upload TestFlight mỗi khi push code lên `main`.

Script `ci_scripts/ci_post_clone.sh` đã sẵn sàng — nó cài XcodeGen và generate `.xcodeproj` từ `project.yml` trên CI.

## Các bước cấu hình (trong Xcode)

### 1. Mở project trong Xcode

Mở `TramThienTra.xcodeproj` (hoặc dùng `xcodegen generate` nếu chưa có).

### 2. Tạo Xcode Cloud workflow

- **Product → Xcode Cloud → Create Workflow**
- Hoặc: Navigator panel → chọn tab **Cloud** (icon đám mây) → **Get Started**

### 3. Kết nối GitHub

- Xcode sẽ yêu cầu authorize GitHub account
- Chọn repo: `CuongTran69/tramthientra`
- Grant quyền cho Xcode Cloud đọc repo

### 4. Cấu hình workflow

| Mục | Giá trị |
|-----|---------|
| **Product** | TramThienTra |
| **Start Condition** | Branch `main` — Push |
| **Environment** | Xcode: Latest Release, macOS: Latest |
| **Build Action** | Archive (Release) |
| **Test Action** | Scheme: TramThienTra, Destination: iPhone 16 Pro (hoặc bất kỳ) |
| **Post-Action** | TestFlight (Internal Testing) |

### 5. Signing (tự động)

Xcode Cloud tự quản lý certificates và provisioning profiles thông qua Apple Developer account. Không cần export `.p12` hay tạo API key thủ công.

Đảm bảo:
- Apple Developer account đã đăng ký trong Xcode → Preferences → Accounts
- Bundle ID `com.tramthientra.app` đã register trên Apple Developer Portal
- App đã tạo trên App Store Connect (đã có vì đã upload TestFlight trước đó)

### 6. Verify workflow

Sau khi save workflow:
1. Push 1 commit nhỏ lên `main`
2. Vào **Xcode → Report Navigator → Cloud** để xem build status
3. Hoặc vào App Store Connect → Xcode Cloud để theo dõi

## Lưu ý

- **Free tier**: 25 giờ compute/tháng (đủ cho project cá nhân)
- **ci_post_clone.sh**: Xcode Cloud tự tìm và chạy script này sau khi clone repo. Không cần cấu hình gì thêm.
- **Mỗi build mới tự tăng build number** trên TestFlight (Xcode Cloud quản lý)
- **Nếu build fail**: kiểm tra logs trong Xcode → Report Navigator → Cloud, hoặc App Store Connect → Xcode Cloud
