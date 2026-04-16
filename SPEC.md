# SPEC.md — Trạm Thiền Trà

## 1. Tổng quan

**Tên dự án:** Trạm Thiền Trà

**Mô tả ngắn:** Ứng dụng iOS giúp người dùng thực hành thiền định qua nghi thức uống trà và viết nhật ký biết ơn mỗi ngày. Giao diện mang đậm phong cách **Việt Nam** — mộc mạc, gần gũi, chữa lành, lấy cảm hứng từ văn hóa trà shan tuyết, cảnh sắc Tây Bắc, và tâm hồn thiền của người Việt.

**Nền tảng:** iOS only (SwiftUI), hỗ trợ iOS 16.0+

**Đối tượng:** Người Việt yêu thiền, yêu trà, muốn thực hành mindfulness mỗi ngày — đặc biệt phù hợp với thế hệ trẻ trở về với gốc cây.

**Phân loại App Store:** Lifestyle / Personal Journaling

**Lưu ý Apple Review:** Tuyệt đối không dùng từ "Mental Health", "Therapy", "Mental Wellness" — chỉ dùng "Personal Journaling App", "Ghi lại điều tốt đẹp".

## 1.1 Các quyết định đã xác nhận

| # | Quyết định | Giá trị |
| --- | --- | --- |
| 1 | Streak | 1 entry/ngày (nhiều lần viết cùng ngày → chỉ +1) |
| 2 | Guest → Login migration | Đồng bộ local entries lên BE sau khi đăng nhập |
| 3 | Push Notification | APNs (Apple Push Notification) — v1: Local only |
| 4 | Dark Mode | Xử lý riêng, nền động 4 khung giờ áp dụng cho cả light & dark mode |
| 5 | App Icon | Sẽ bổ sung sau — concept: tách trà / lá trà / chữ thư pháp |
| 6 | Orientation | Chỉ Portrait (iPhone) |
| 7 | Gratitude validation | Không bắt buộc — cho lưu 1, 2 hoặc 3 fields |
| 8 | Character limit | 300 ký tự mỗi entry |
| 9 | Midnight cutoff | Reset đúng 00:00 local device — so sánh `Calendar.current.startOfDay(for: Date())` với ngày entry |
| 10 | Gratitude entry/ngày | Ghi đè entry cùng ngày (nếu viết lại → cập nhật items) |
| 11 | API Versioning | Prefix /api/v1/ |
| 12 | Sound Buông bỏ | Im lặng — không phát âm thanh |
| 13 | Haptic + Sound | Dùng haptic built-in + audio file riêng (droplet.wav) |
| 14 | Error handling | Retry tự động 3 lần, sau đó hiện toast nhẹ (không blocking) |
| 15 | History pagination | Load 20 entry, infinite scroll |
| 16 | History search | Không cần — để v2 |
| 17 | Accessibility | VoiceOver labels đầy đủ cho tất cả interactive elements |
| 18 | Streak animation | Chỉ animate trên streak bar (LeafStreakView), không ảnh hưởng TeaRoom |
| 19 | Privacy Policy | Sẽ bổ sung URL — bắt buộc trước khi submit App Store |
| 20 | Gradient hướng | Top → Bottom (LinearGradient, startPoint .top, endPoint .bottom) |
| 21 | Font serif | Noto Serif cho tiêu đề (fallback .serif iOS) |
| 22 | Login popup "Để sau" | Cho lưu local guest — không ép login, streak vẫn +1 |
| 23 | Onboarding skip | Bỏ qua onboarding → vào Tea Room, streak = 0 |

## 2. Màn hình & Luồng người dùng

### 2.1 Luồng khởi động

```
Mở app
  ↓
  ├── Đã onboarding → Tea Room
  └── Chưa onboarding → Onboarding (3 màn hình)
                            ↓
                         Tea Room
```

### 2.2 Onboarding — 3 màn hình

> Phong cách: Giấy dó, nét vẽ thủy mặc Việt Nam. Màu sắc: nâu trà, xanh lá nhạt, kem ngà. Không dùng icon/emoji — thay bằng hình vẽ tay đơn giản bằng SwiftUI paths.

| # | Tiêu đề | Nội dung |
| --- | --- | --- |
| 1 | Chào mừng đến Trạm Thiền Trà | "Mỗi ngày, một tách trà. Mỗi ngày, một bước gần hơn với con người ta." |
| 2 | Nghi thức Tích luỹ | "Ghi lại 3 điều bạn biết ơn mỗi ngày. Những điều nhỏ bé thường là quý giá nhất. Như sương mai trên núi, như hương sen hồ Tây." |
| 3 | Nghi thức Buông bỏ | "Viết ra những bực dọc, buồn phiền. Rồi buông nó đi — chúng tan theo làn khói trà, nhẹ nhàng như chưa từng có." |

- Navigation: Swipeable PageTabViewStyle
- Nút "Bắt đầu" ở cuối màn cuối
- Nút "Bỏ qua" góc phải trên (bỏ qua → vào thẳng Trà Thất)
- Đánh dấu đã onboarding: UserDefaults key `hasCompletedOnboarding = true`

### 2.3 Màn hình chính — Trà Thất

**Phong cách:** Giấy dó Việt Nam — màu trầm ấm, texture giấy rờm, nét vẽ thủy mặc đơn giản. Giữa màn hình là **ấm trà shan tuyết** bốc khói, vẽ bằng SwiftUI Canvas paths.

**Bố cục:**

```
[Settings — góc trái trên]
[History — góc phải trên]

      [Ấm trà bốc khói — giữa màn hình]

    [  Buông bỏ  ]      [  Tích luỹ  ]
   (icon làn khói)    (icon giọt sương)

   ─── Cây thiền ───
```

**Nền động theo thời gian thực:**

| Khung giờ | Màu nền | Hex Light | Hex Dark |
| --- | --- | --- | --- |
| 05:00–07:59 | Sương mai núi rừng | #E8F0F2 → #F5E6D3 | #1A2A2E → #2A1E18 |
| 08:00–16:59 | Nắng trưa Tây Bắc | #FFF8E7 → #FFECD2 | #2A2518 → #3A2518 |
| 17:00–18:59 | Hoàng hôn hồ Tây | #FFB347 → #FF6B6B | #3A2010 → #3A1010 |
| 19:00–04:59 | Đêm trà shan | #2C2416 → #1A1209 | #0F0C08 → #0A0804 |

- Gợi ý: màu sắc lấy cảm hứng từ sương mai Hà Giang, nắng trưa Mộc Châu, hoàng hôn hồ Tây, đêm trà shan tuyết
- Transition mượt 2 giây khi giờ thay đổi (dùng `withAnimation(.easeInOut(duration: 2))`)
- Dùng `Color("DynamicBackground")` asset với multiple color sets trong Assets.xcassets

### 2.4 Nghi thức 1: Tích luỹ (Gratitude)

**Màn hình:**

- Header: "Tích luỹ — Ngày [dd/MM/yyyy]"
- 3 TextField riêng biệt, mỗi field giới hạn **300 ký tự**:
  - "Điều biết ơn thứ 1..."
  - "Điều biết ơn thứ 2..."
  - "Điều biết ơn thứ 3..."
- Mỗi TextField có icon con trỏ nhỏ phía trước
- **Validation:** Không bắt buộc điền đủ 3 fields — cho lưu 1, 2 hoặc 3 fields
- **Behavior cùng ngày:** Nếu đã viết rồi viết lại → **ghi đè** entry cùng ngày (update items)

**Nút Lưu:**

- Icon: Giọt nước rơi xuống mặt hồ (SF Symbol: `drop.fill` kết hợp sóng nước)
- Khi bấm:
    1. Haptic feedback nhẹ (`UIImpactFeedbackGenerator(.light)`)
    2. Phát âm thanh "Tí tách" (AVFoundation)
    3. Animation: giọt rơi → sóng lan toả
    4. Lưu xuống SwiftData
    5. Ngầm sync lên BE nếu đã login
- Sau lưu thành công → quay về Tea Room, streak tăng

**Yêu cầu login:**

- Nếu chưa login → trước khi lưu, hiện popup nhẹ nhàng:"Hãy tạo một góc nhỏ để giữ lại những điều tốt đẹp này không bao giờ mất"[Đăng nhập với Apple] [Để sau]

### 2.5 Nghi thức 2: Buông bỏ (Release)

**Màn hình:**

- Header: "Buông bỏ"
- TextEditor lớn: "Viết ra những gì đang chiếm lấy tâm trí bạn..."
- Placeholder text mờ nhạt

**Nút Buông:**

- Icon: Làn khói trà bay tan (vẽ bằng SwiftUI Canvas — không dùng SF Symbol `wind`)
- Khi bấm:
    1. Haptic nhẹ
    2. Animation: text mờ dần → các hạt khói bay lên → tan biến (2 giây)
    3. Xoá sạch nội dung TextEditor
    4. **KHÔNG LƯU** — riêng tư tuyệt đối

**Lưu ý:** Không cần login cho tính năng này. Nội dung KHÔNG bao giờ được lưu đâu.

### 2.6 Streak System — Nuôi dưỡng cây thiền

**Các giai đoạn của cây thiền:**

| Streak | Tên giai đoạn | Mô tả |
| --- | --- | --- |
| 0 | Hạt giống | Chỉ một chấm nhỏ trên đất — streak bị gián đoạn |
| 1–2 | Nảy mầm | Cuống nhỏ vừa nhú khỏi đất |
| 3–6 | Lá non | 1 lá nhỏ xòe ra, hơi cong |
| 7–29 | Cây xanh | 2 lá xòe đều, màu xanh trà, có đường gân lá |
| 30–59 | Sum suê | 3-4 lá xung quanh 1 nhánh chính, có cành nhỏ |
| 60+ | Đại thụ | Cây nhỏ hoàn chỉnh, nhiều lá, có thân gỗ |

**Quy tắc:**

- Viết "Tích luỹ" thành công 1 lần/ngày → streak +1
- Lỡ 1 ngày → streak reset về 0 → quay lại giai đoạn "Hạt giống"
- Hiển thị số ngày liên tiếp bên cạnh icon
- Animation: cây thiền lớn dần khi streak tăng (phase-based animation)

### 2.7 Lịch sử (History)

- List các ngày đã viết "Tích luỹ"
- Mỗi item: ngày (dd/MM/yyyy) + 3 điều biết ơn (preview 1 dòng đầu)
- Tap item → màn hình chi tiết: ngày + đầy đủ 3 điều biết ơn
- Swipe left → xoá entry (với xác nhận)
- Empty state: "Chưa có ngày nào được ghi lại. Hãy bắt đầu hành trình ngay hôm nay."

### 2.8 Cài đặt (Settings)

| Mục | Mô tả |
| --- | --- |
| Nhắc nhở hàng ngày | Toggle bật/tắt — mặc định bật, gửi lúc 21:00 mỗi tối |
| Đăng nhập / Đăng xuất | Sign in with Apple (bắt buộc) |
| Chính sách quyền riêng tư | Link đến trang Privacy Policy |
| Phiên bản | Hiển thị version app |

## 3. Kiến trúc kỹ thuật

### 3.1 iOS

**Cấu trúc thư mục:**

```
TramThienTra/
├── App/
│   └── TramThienTraApp.swift
├── Models/
│   ├── GratitudeLog.swift       # @Model SwiftData
│   └── AppUser.swift            # @Model SwiftData
├── ViewModels/
│   ├── TraThatViewModel.swift
│   ├── TichLuyViewModel.swift
│   ├── BuongBoViewModel.swift
│   └── StreakViewModel.swift
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── TraThat/
│   │   ├── TraThatView.swift        # Màn hình chính
│   │   └── TraXongView.swift        # Ấm trà + khói (Canvas animation)
│   ├── TichLuy/
│   │   ├── TichLuyView.swift
│   │   └── NutGiotNuocView.swift
│   ├── BuongBo/
│   │   ├── BuongBoView.swift
│   │   └── KhoiTanView.swift        # Animation khói bay tan
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── HistoryDetailView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── NenDongView.swift        # Dynamic background
│       ├── CayThienView.swift       # Leaf streak visualization
│       └── AppleDangNhapView.swift
├── Services/
│   ├── AuthService.swift
│   ├── SyncService.swift
│   ├── NotificationService.swift
│   └── HapticService.swift
├── Utilities/
│   ├── ThoiGian.swift             # Enum + color mapping
│   └── Constants.swift
└── Resources/
    ├── Assets.xcassets
    └── droplet.wav                # Sound asset: tiếng nước nhỏ
```

**Công nghệ sử dụng:**

- SwiftUI + SwiftData
- MVVM architecture
- `@StateObject` / `@EnvironmentObject` (iOS 16 compatible)
- `@Observable` (iOS 17+) cho iOS 17+
- TimelineView cho animations liên tục
- UserNotifications cho nhắc nhở
- AuthenticationServices cho Sign in with Apple
- AVFoundation cho âm thanh
- UIImpactFeedbackGenerator cho haptic

### 3.2 Backend — Go

**Mục đích:** Đồng bộ & Backup data (gratitude logs) + Push Notification APNs (v2)

**Database schema:**

```sql
CREATE TABLE users (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apple_user_id VARCHAR(255) UNIQUE NOT NULL,
    apns_token   VARCHAR(255),          -- Apple Push Notification token
    created_at   TIMESTAMP DEFAULT NOW()
);

CREATE TABLE gratitude_logs (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID REFERENCES users(id) ON DELETE CASCADE,
    date       DATE NOT NULL,
    items      JSONB NOT NULL,          -- ["item1", "item2", "item3"]
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, date)
);

CREATE INDEX idx_logs_user_date ON gratitude_logs(user_id, date);
```

**API Endpoints (v1):**

| Method | Endpoint | Auth | Mô tả |
| --- | --- | --- | --- |
| POST | /api/v1/auth/apple | No | Verify Apple ID token → upsert user → return JWT |
| GET | /api/v1/logs | JWT | Lấy tất cả gratitude logs của user |
| POST | /api/v1/logs | JWT | Tạo/update 1 gratitude log (upsert by date) |
| GET | /api/v1/logs/:date | JWT | Lấy log theo ngày (YYYY-MM-DD) |
| DELETE | /api/v1/logs/:date | JWT | Xoá log theo ngày |
| PUT | /api/v1/apns-token | JWT | Cập nhật APNs token (cho Push v2) |

**Sync Logic (iOS side):**

1. **Guest → Login migration:** Khi user đăng nhập, đọc toàn bộ local entries (SwiftData) chưa sync, gọi POST `/api/v1/logs` cho từng entry
2. **Normal sync:** Mỗi khi app có mạng AND user đã login → chạy background sync
3. Đọc các log chưa sync từ SwiftData (field `synced = false`)
4. Gọi POST `/api/v1/logs` cho từng log (upsert: BE ghi đè nếu date đã tồn tại)
5. Cập nhật field `synced = true` sau khi thành công
6. Conflict resolution: server timestamp sau cùng thắng (last-write-wins)
7. Retry: tự động thử lại 3 lần nếu fail → đánh dấu `syncPending = true` và retry lần sau

## 4. Thiết kế (Design)

### 4.1 Colors

**Accent Color:** Trà xanh nhạt — `#8FBC8F`

**Semantic Colors (Light Mode):**

- Background: Dynamic theo thời gian (xem mục 2.3)
- Text Primary: `#2C2C2C`
- Text Secondary: `#6B6B6B`
- Card Background: `#FFFFFF20` — semi-transparent white

**Semantic Colors (Dark Mode):**

- Background: Dynamic theo thời gian (áp dụng 4 khung giờ như light, nhưng giá trị hex tối hơn ~30%)
- Text Primary: `#F5F5F5`
- Text Secondary: `#AAAAAA`
- Card Background: `#FFFFFF10` — semi-transparent white

**Nền động 4 khung giờ — Light & Dark Mode:**

| Khung giờ | Tên | Light hex | Dark hex |
| --- | --- | --- | --- |
| 05:00–07:59 | Sương sớm | #E8F0F2 → #F5E6D3 | #1A2A2E → #2A1E18 |
| 08:00–16:59 | Ban ngày sáng | #FFF8E7 → #FFECD2 | #2A2518 → #3A2518 |
| 17:00–18:59 | Hoàng hôn | #FFB347 → #FF6B6B | #3A2010 → #3A1010 |
| 19:00–04:59 | Trà đen đêm | #2C2416 → #1A1209 | #0F0C08 → #0A0804 |

- Transition mượt 2 giây khi giờ thay đổi (dùng `withAnimation(.easeInOut(duration: 2))`)
- Dùng `Color("DynamicBackground")` asset với multiple color sets trong Assets.xcassets

### 4.2 Typography

**Font chữ Việt:** Dùng `.custom` với font serif cho tiêu đề (VD: Noto Serif, Bitter, hoặc fallback serif hệ thống). Body text dùng SF Pro.

| Style | Font | Size | Weight |
| --- | --- | --- | --- |
| Large Title | Serif fallback | 34pt | Bold |
| Title | Serif fallback | 28pt | Bold |
| Headline | System | 20pt | Medium |
| Body | System | 17pt | Regular |
| Caption | System | 13pt | Regular |

### 4.3 Spacing (8pt grid)

- Standard padding: 16pt
- Section spacing: 24pt
- Card corner radius: 16pt
- Button corner radius: 12pt
- Inter-element spacing: 8pt

### 4.4 Animation Specs

| Animation | Thư viện | Duration | Mô tả |
| --- | --- | --- | --- |
| Khói trà | TimelineView + Canvas | 0.8s loop | 5-8 hạt khói bay lên từ miệng ấm trà |
| Giọt rơi | spring | 0.5s | Bounce nhẹ khi chạm mặt nước |
| Sóng nước | easeOut | 0.4s | Scale 1→1.5, opacity 1→0 |
| Khói tan | easeInOut | 2.0s | opacity 1→0, scale 1→1.3, blur 0→3 (text fade đơn thuần, không particle khói vật lý) |
| Cây thiền growth | phase-based | 0.6s | Mỗi stage có hình/thành phần riêng |
| Nền đổi màu | easeInOut | 2.0s | Khi giờ thay đổi |

## 5. Apple Review Checklist

- ✅ Không ép Login từ đầu — dùng "Buông bỏ" không cần login
- ✅ Tích hợp Sign in with Apple (bắt buộc khi có login)
- ✅ Định nghĩa App Store: **Lifestyle** / **Personal Journaling**
- ✅ Ghi chú gửi Apple: "Ứng dụng nhật ký cá nhân giúp ghi lại điều tốt đẹp mỗi ngày"
- ✅ Privacy Policy URL bắt buộc có trên App Store Connect
- ✅ Không quảng cáo, không social feed → ít bị reject

## 6. Out of Scope v1

- Push Notification (v2)
- Android version
- Apple Watch companion
- Widget
- In-app purchases
- Social features

## 7. Version History

| Version | Ngày | Mô tả |
| --- | --- | --- |
| 1.0 | [today] | Spec v1 — baseline |

*Spec được viết bởi Claude Opus 4.6 — Anthropic, 2026*