---
name: viper-mobile
description: >
  Điều khiển app mobile thật trên iOS Simulator / Android Emulator để dùng thử sản phẩm VIPER — mở app, chạm,
  gõ, vuốt, xoay màn hình, chụp màn hình, đọc widget/accessibility tree, app log và crash log. App Flutter dùng
  marionette_flutter + marionette_mcp làm lớp tương tác trong app, song song mobile-mcp làm lớp thiết bị. Nạp khi
  $viper-dogfood chạm một experience thuộc srcroot/mobile-experiences/, khi cần kiểm một luồng chạm được thật
  trên app native hay không, hoặc khi đóng vai người dùng thử (viper-user-*) trên mobile. Gồm: cách gọi,
  bộ tool hai lớp, ràng buộc thiết-bị-dùng-chung (các vai chạy TUẦN TỰ), công thức cho từng vai dogfood,
  và cách chứng minh mình đã dùng thật. Web experience thì dùng viper-browse, không dùng skill này.
---

# viper-mobile — dùng thử app mobile thật trên simulator/emulator

> Luật #8 nói **không báo xong khi chưa tự dùng**. Với experience mobile, "dùng" nghĩa là mở app thật
> trên thiết bị (giả lập), chạm, nhìn màn hình. Đọc code React Native/Flutter rồi suy ra "chắc chạy được"
> **không tính** — y như web không được đọc code thay cho bấm.

## 1. Chạy bằng gì

Có hai lớp, không thay thế nhau:

| Lớp | Công cụ | Dùng cho |
|---|---|---|
| **Trong app Flutter** | `marionette_flutter` + server `marionette_mcp` | widget tree, tap/double-tap/long-press, nhập chữ, scroll/swipe, screenshot, app log, hot reload/restart |
| **Thiết bị iOS/Android** | `@mobilenext/mobile-mcp` | boot/chọn thiết bị, cài/launch/kill app, HOME/BACK, xoay, deep link, screen recording, crash report, notification center |

App Flutter dùng **CẢ HAI**. Marionette nhìn đúng widget/key/semantics của Flutter nên là đường chính để
đi luồng UI; mobile-mcp giữ những ca Marionette không sở hữu ở cấp hệ điều hành. React Native/native khác
không cài `marionette_flutter`, chỉ dùng mobile-mcp qua cây accessibility.

Template khai cả hai server ở hai nơi:

| Nơi khai | Dùng cho | Tên server |
|---|---|---|
| `.codex/config.toml` ở gốc repo | Phiên chính (meta tự tay dùng) | `mobile` + `marionette` |
| `[mcp_servers.*]` trong agent TOML mỗi `viper-user-*` | 6 vai dùng thử | `mobile` + `marionette` (bên cạnh `browser`) |

**Khác biệt SỐNG CÒN so với viper-browse: không có `--isolated`.** Trình duyệt mỗi vai một cái được;
simulator/emulator là **một thiết bị dùng chung** — hai vai cùng chạm vào một màn hình là giẫm nhau
theo nghĩa đen. Vì vậy với experience mobile, các vai trong một đợt dogfood chạy **tuần tự**, không
song song (vẫn hai đợt, vẫn seed lại giữa hai đợt — xem `$viper-dogfood`).

**Điều kiện chung trước khi gọi tool** (web chỉ cần URL; mobile cần thiết bị + app đã cài):

1. **Đúng MỘT thiết bị đang bật** — iOS: `xcrun simctl list devices booted` · Android: `adb devices`.
   Nhiều thiết bị cùng bật thì server không biết chọn cái nào; tắt bớt trước.
2. **App đã build + cài lên thiết bị đó** — đây là việc của `make dev` target mobile
   (boot simulator/emulator + cài bản dev, ghi trong stack skill hoặc `custom (intake)`).
   Chưa cài thì `mobile_list_apps` không thấy app, và đó cũng là một phát hiện: `make dev` chưa tròn hợp đồng.
3. Ghi lại **bundle id / package name** của app (iOS: `vn.example.app` · Android: `com.example.app`) —
   tool `mobile_launch_app` nhận đúng chuỗi này, lấy từ `context/TECHSTACK.md` target mobile.

**Điều kiện thêm cho Flutter — là hợp đồng scaffold, không đợi tới lúc dogfood mới vá:**

1. Trong target Flutter chạy `flutter pub add marionette_flutter`; ghi version resolve thật vào
   `context/TECHSTACK.md`. Đây là dependency của app, không phải package cài toàn máy.
2. `main.dart` khởi tạo `MarionetteBinding.ensureInitialized()` **chỉ khi `kDebugMode`**, còn release dùng
   `WidgetsFlutterBinding.ensureInitialized()`. Marionette phải là binding đầu tiên và duy nhất; nếu test gọi
   `main()`, bỏ qua khi có `FLUTTER_TEST` hoặc dùng entrypoint test riêng.
3. App dùng design system riêng phải cấu hình `MarionetteConfiguration.isInteractiveWidget` + `extractText`,
   và gắn `Semantics(identifier: ...)` cho control custom. `get_interactive_elements` không thấy một control
   lõi thì **chưa đủ điều kiện dogfood**, không được rơi về chạm toạ độ rồi coi như xong.
4. Kích hoạt bridge một lần: `dart pub global activate marionette_mcp`. `make dev` của target Flutter phải
   chạy `flutter run` ở debug, giữ process sống và in rõ **VM Service URI** dạng `ws://127.0.0.1:<port>/ws`.
   Gửi URI này cho meta và từng vai; mỗi vai gọi Marionette `connect` trước mọi tool khác.

Không cần cài mobile-mcp trước — `npm exec` tải lần đầu. Simulator/emulator vẫn phải có sẵn: iOS cần
Xcode (macOS), Android cần Android SDK + platform-tools.

## 2. Tool dùng nhiều nhất

### Flutter — Marionette là đường UI chính

| Tool Marionette | Việc |
|---|---|
| `connect` | Nối tới VM Service URI; bắt buộc trước mọi tool khác, và nối lại nếu `flutter run` cấp URI mới |
| `get_interactive_elements` | “Nhìn” màn hình qua widget tree: type, text, key, Semantics identifier; gọi lại sau mỗi thao tác |
| `tap` · `double_tap` · `long_press` · `enter_text` | Tương tác theo `key`/`identifier`/text; ưu tiên key, rồi identifier, không lấy toạ độ khi đã có selector ổn định |
| `swipe` · `scroll_to` · `press_back_button` | Đi qua danh sách, drawer, route và nội dung ngoài viewport |
| `take_screenshots` · `get_logs` | Bằng chứng thị giác và exception/log trong app; `get_logs` cần cấu hình `LogCollector` |
| `hot_restart` | Quay lại từ `main()` giữa kịch bản mà vẫn giữ kết nối; không thay cho ca kill app thật bằng mobile-mcp |

### Lớp thiết bị — áp cho mọi mobile experience

| Tool | Việc |
|---|---|
| `mobile_launch_app` | Mở app theo bundle id. **Luôn vào từ màn đầu** — kill app (`mobile_terminate_app`) rồi mở lại, đừng tiếp tục từ trạng thái dở của vai trước |
| `mobile_list_elements_on_screen` | Đọc cây accessibility + frame ở cấp OS; với Flutter dùng để đối chứng kích thước/vị trí, không thay widget tree Marionette |
| `mobile_click_on_screen_at_coordinates` · `mobile_type_keys` · `mobile_swipe_on_screen` | Đường fallback cho app không phải Flutter hoặc control hệ điều hành; Flutter ưu tiên Marionette |
| `mobile_take_screenshot` | Bằng chứng cho báo cáo, và là cách duy nhất bắt lỗi thị giác (accessibility tree không có màu) |

Với Flutter, `get_interactive_elements` là nguồn chính để biết màn có gì; `mobile_list_elements_on_screen`
là đối chứng OS và nguồn frame. Cả hai đều **không mang màu sắc/phong cách** — soi hình thức vẫn bắt buộc
screenshot (xem vai picky ở §3).

Còn lại: `mobile_list_available_devices` · `mobile_get_screen_size` · `mobile_get_orientation` ·
`mobile_set_orientation` · `mobile_list_apps` · `mobile_terminate_app` · `mobile_install_app` ·
`mobile_uninstall_app` · `mobile_save_screenshot` · `mobile_double_tap_on_screen` ·
`mobile_long_press_on_screen_at_coordinates` · `mobile_start_screen_recording` ·
`mobile_stop_screen_recording` · `mobile_press_button` (HOME, BACK, VOLUME…) · `mobile_open_url`
(deep link) · `mobile_list_crashes` · `mobile_get_crash`.

## 3. Công thức cho từng vai dogfood

### Màn hình nhỏ (`viper-user-mobile`)
Trên native, "màn hình nhỏ" nghĩa là **thiết bị nhỏ + xoay + bàn phím**:
- Boot đúng thiết bị nhỏ trong dải hỗ trợ (iPhone SE / Pixel nhỏ), không phải máy to nhất cho dễ nhìn.
- `mobile_set_orientation landscape` giữa chừng một form — layout có vỡ, dữ liệu đang gõ có mất không.
- Chạm vào ô nhập **cuối màn hình** — bàn phím ảo hiện lên có che mất nút gửi không, màn có tự cuộn không.
- Flutter dùng Marionette `scroll_to`/`swipe` tới cuối danh sách dài; dùng mobile-mcp xoay thiết bị và
  đối chứng frame — có bị cắt, có cuộn được không.

### Trạng thái biên (`viper-user-edge`)
- **Rỗng**: mở app trên DB sạch (đợt 1) — màn đầu hiện gì.
- **Gián đoạn**: `mobile_press_button HOME` giữa luồng rồi mở lại — còn đứng đúng chỗ không;
  `mobile_terminate_app` giữa form rồi `mobile_launch_app` lại — dữ liệu dở dang ra sao.
- **API lỗi / mất mạng**: dừng server dev backend (hoặc Android: `adb shell svc wifi disable` +
  `svc data disable` qua Bash) rồi thao tác tiếp — app hiện khuôn lỗi hay treo/crash.
  iOS Simulator dùng mạng của máy host, không tắt riêng được — dùng cách dừng backend.
- Kết mỗi kịch bản: `mobile_list_crashes` — gián đoạn mà sinh crash report là phát hiện **nặng**.

### Người vội (`viper-user-rushed`)
- Flutter dùng Marionette `double_tap` theo key/identifier của nút gửi; app khác dùng
  `mobile_double_tap_on_screen` — bản ghi có nhân đôi không.
- HOME → mở app khác → quay lại giữa chừng; kill app giữa luồng rồi vào lại.
- `mobile_open_url` deep link nhảy thẳng vào màn giữa luồng — app có gãy khi thiếu ngữ cảnh không.

### Người phá (`viper-user-breaker`)
- Flutter dùng Marionette `enter_text` chuỗi 10.000 ký tự, emoji, `<script>alert(1)</script>`,
  `'; DROP TABLE x;--`, số âm; app khác dùng `mobile_type_keys`.
- Phép thử phân quyền A↛B: **tuần tự trên một thiết bị** (không có hai profile song song như web) —
  đăng nhập A tạo bản ghi, đăng xuất, đăng nhập B, thử mở bản ghi của A qua deep link/danh sách.
- `mobile_open_url` deep link tới màn của vai bị cấm — chặn ở server hay chỉ giấu nút.
- Sau mỗi đòn: `mobile_list_elements_on_screen` xem hiển thị, `mobile_list_crashes` xem có crash.

### Người mới (`viper-user-newbie`)
Không tool đặc biệt. Mở app từ đầu; Flutter gọi `connect` rồi `get_interactive_elements`, app khác gọi
`mobile_list_elements_on_screen` — và **đọc như người chưa biết gì**, đừng dùng kiến thức về code để đoán
màn kế tiếp. Mất vai là mất giá trị lượt thử.

### Khó tính về hình thức (`viper-user-picky`)
Native **không có `getComputedStyle`** — luật "đo, đừng nhìn" đổi thước đo, không đổi tinh thần:
- **Kích thước & vị trí**: lấy frame từ `mobile_list_elements_on_screen` — nút dưới 44×44 điểm,
  phần tử lệch lưới nhịp đã chốt ở `DESIGN-SYSTEM.md §2.3`, đều là số đo được, trích thẳng vào báo cáo.
- **Khả năng tìm control Flutter**: mọi C<n> tương tác trong luồng phải xuất hiện ở
  `get_interactive_elements` với key/identifier/text có nghĩa. Control custom “vô hình” với Marionette là
  thiếu Semantics/configuration và là phát hiện accessibility/testability, không được chạm toạ độ để che đi.
- **Màu & chữ**: bắt buộc qua `mobile_take_screenshot` từng màn, đối chiếu **bằng mắt có kỷ luật** với
  lát token: nêu đích danh *phần tử + màn + khác gì bảng token* ("nút chính S3 nền xanh nhạt hơn
  `--color-primary`, ảnh kèm"). Ảnh chụp là bằng chứng thay cho con số computed style.
- **Trạng thái component §4 + ba khuôn §5**: ép hiện thật — chạm nút gửi rồi chụp ngay để bắt "đang gửi",
  dừng backend để bắt khuôn lỗi, DB sạch cho khuôn rỗng.
- Báo cáo không kèm được **frame/toạ độ hoặc screenshot** nào thì chưa tính là đã soi — tương đương
  luật "không có computed style thì không tính" ở web.

## 4. Chứng minh đã dùng thật

Mọi phát hiện phải nêu được **thao tác cụ thể** và **thứ thấy trên màn hình**. Bằng chứng gồm:

```
mobile_list_elements_on_screen  → trích đúng nhãn/phần tử + toạ độ đã thấy
mobile_take_screenshot          → ảnh chỗ hỏng
mobile_list_crashes             → crash report kèm mã, mobile_get_crash lấy nguyên văn
mobile_start/stop_screen_recording → video cho luồng khó tả bằng lời (đừng commit file video)
Marionette get_interactive_elements → widget/key/identifier/text thật của app Flutter
Marionette take_screenshots/get_logs → ảnh + exception/log của Flutter
```

Báo "không thấy vấn đề gì" mà không kèm được thao tác đã làm thì gần như chắc chắn là chưa dùng —
xem `$viper-dogfood §Dấu hiệu dogfood giả`.

## 5. Ranh giới

- Chỉ thao tác trên **app của dự án này** trong simulator/emulator. Không đụng app khác trên thiết bị.
- Không sửa file dự án, không gọi `hot_reload` để thay code khi đang đóng vai. Sáu vai `viper-user-*` đã
  bị chặn `Write`/`Edit` — phát hiện thì **báo**. `hot_restart` chỉ dùng để reset app giữa kịch bản.
- **Các vai chạy TUẦN TỰ trên experience mobile** — thiết bị là tài nguyên dùng chung, không có
  chuyện 3 vai song song như trình duyệt. Vẫn giữ hai đợt + seed lại giữa đợt.
- Web experience (`srcroot/web-experiences/`) → skill `viper-browse`, không dùng skill này.
- Marionette là dogfood tương tác, không thay test tất định của `make test`; Flutter vẫn dùng
  `flutter_test`/integration test/golden test theo stack.

## 6. Hỏng thì xem đây

| Triệu chứng | Nguyên nhân thường gặp |
|---|---|
| Server `mobile` không lên | `npx` trong PATH là gói standalone đời cũ — template dùng `npm exec` chính vì vậy |
| Không thấy thiết bị nào | Chưa boot: iOS `xcrun simctl boot "<tên máy>"` (cần Xcode) · Android mở AVD từ Android Studio hoặc `emulator -avd <tên>`; kiểm bằng `xcrun simctl list devices booted` / `adb devices` |
| Thấy nhiều thiết bị, tool chọn sai | Tắt bớt, chỉ để đúng một thiết bị bật khi dogfood |
| `mobile_launch_app` không thấy app | App chưa cài lên thiết bị — chạy `make dev` của target mobile trước; bundle id sai thì tra `mobile_list_apps` |
| Server `marionette` không lên | Chưa chạy `dart pub global activate marionette_mcp`, hoặc thư mục pub global bin chưa ở `PATH` |
| Marionette `connect` thất bại | App không chạy debug, VM Service URI cũ/sai, hoặc `marionette_flutter` và server lệch version — lấy URI mới từ output `make dev` |
| Flutter app treo splash / lỗi binding | Một binding khác đã init trước Marionette (thường test/Sentry). Khởi tạo Marionette đầu tiên ở debug; bỏ qua dưới `FLUTTER_TEST` |
| `get_interactive_elements` thiếu nút custom | Bổ sung `isInteractiveWidget`/`extractText` và `Semantics(identifier: ...)`; không chữa bằng toạ độ |
| Android không kết nối | `adb` không có trong PATH — cài Android platform-tools, hoặc `ANDROID_HOME` chưa đặt |
| Chạm không ăn | Toạ độ lấy từ snapshot cũ — màn đã đổi; gọi lại `mobile_list_elements_on_screen` ngay trước khi chạm |
