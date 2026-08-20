---
type: techstack
tier: T0
status: DRAFT
last_reviewed: "2026-08-17"
---

# TECHSTACK — CORE-VIPER

> Chốt ở pha V, kèm 1 dòng lý do trong `DECISIONS.md`. Đổi stack sau pha V = phá luật #1, phải ghi đánh đổi.
> Cấu trúc per-target lấy theo `intake/_TECHSTACK-TEMPLATE.md`.

---

## 1. Stack theo target

<!-- ĐƯỜNG PHỎNG VẤN: đúng MỘT khối dưới đây, giữ tên target là `app` — một app, một DB,
     một nơi deploy (luật #5), scaffold thẳng vào gốc repo theo stack skill.

     ĐƯỜNG INTAKE: lặp khối `### Target: <tên>` cho mỗi boundary/experience trong
     ARCHITECTURE.md §1–§3, tên khớp thư mục code `srcroot/<nhóm>/<tên>/` — nhóm là
     boundaries | web-experiences | mobile-experiences. Giữ nguyên Choice +
     Reason của intake/TECHSTACK.md — INTAKE THẮNG DEFAULT CỦA STACK SKILL (VIPER.md §1.3):
     intake nói Prisma + Chakra thì không đổi sang Drizzle + shadcn cho hợp skill.
     Xoá dòng nào target không dùng; thêm dòng nào intake có mà bảng chưa liệt kê. -->

### Target: `app`

| Hạng mục | Chọn | Version | Lý do |
|---|---|---|---|
| Skill đang dùng | `custom — Flutter` | — | Repo có 5 stack skill (nextjs · nestjs-react · fastapi · go · spring-boot), **không cái nào là mobile**. Dựng theo `viper-mobile` §2 (Flutter + Marionette) thay cho stack skill |
| Ngôn ngữ | Dart | 3.10+ | Đi kèm Flutter |
| Framework | Flutter | 3.41.9 (ghim qua fvm) | Bản đã có sẵn trên máy; Android build được ngay |
| Database | **Không có** | — | Danh bạ mock 2 người là hằng số trong source; không có gì cần lưu qua lần chạy |
| ORM / query layer | **Không có** | — | Hệ quả của việc không có DB |
| Auth | **Không có** | — | `PRD.md §7`; chọn danh tính bằng cách bấm |
| UI kit | Material 3 (có sẵn trong Flutter) | — | Không thêm thư viện UI: đúng tinh thần "quen thuộc", và bớt một chỗ vỡ trước deadline |
| State management | `flutter_bloc` | ^9.1.1 | Máy trạng thái cuộc gọi có nhiều nhánh (đang gọi / đến / trong cuộc / lỗi) — bloc buộc phải khai rõ chuyển trạng thái, và test được không cần thiết bị |
| Media / SFU | `livekit_client` | 2.5.3 | Chính là thứ cần thử |
| Quyền hệ thống | `permission_handler` | ^12.0.1 | Mic + camera, và mở được màn Cài đặt khi bị từ chối vĩnh viễn (AC-5) |
| Test runner | `flutter_test` | đi kèm SDK | Bloc test + widget test chạy không cần thiết bị |
| Deploy | **Không deploy** | — | Sản phẩm là APK debug cài thẳng vào máy, nghiệm thu tại chỗ |

`Skill đang dùng` phải là một trong: `stack-nextjs-fullstack` · `stack-nestjs-react` · `stack-fastapi` · `stack-go` · `stack-spring-boot` (+ `addon-graphql` nếu có), hoặc — chỉ ở đường intake — `custom (intake — theo intake/TECHSTACK.md)`. Chi tiết cách dựng, cấu trúc thư mục, preset production-ready nằm trong `.claude/skills/<tên>/SKILL.md` — **không chép lại vào đây**.

<!-- Đường intake chọn được skill khớp nhất nhưng intake khác default ở vài chỗ → thêm
     mục này ngay dưới bảng của target đó, liệt kê từng chỗ lệch. Không có thì xoá.

     ### Sai khác so với skill
     | Hạng mục | Skill mặc định | Intake chốt | Vì sao theo intake |
-->

## 2. Hạ tầng dùng chung

<!-- Thứ nằm ngoài từng target: DB dùng chung, cache, message broker, object storage,
     error tracking, analytics, CI. Đường phỏng vấn thường chỉ có 2–3 dòng. -->

| Hạng mục | Chọn | Version | Dùng cho target nào |
|---|---|---|---|
| Error tracking | **Không có** — lỗi in ra log, đọc bằng `adb logcat` | — | `app` |
| Analytics | **Không có** | — | `app` |
| SFU / máy chủ media | **LiveKit Cloud** (dự án sẵn có) | — | `app` |

Hai dòng "không có" ở trên là quyết định, không phải bỏ trống: demo nghiệm thu tại chỗ, hai
người ngồi cạnh nhau nhìn cùng một màn hình — dựng Sentry hay analytics không ai đọc chỉ tốn
thời gian trước deadline. `PRODUCTION-READY.md` nhóm tương ứng ghi rõ lý do miễn.

## 3. Vì sao chọn stack này

Ràng buộc thật: deadline chiều mai, chỉ có **một máy Android** để thử, và đầu ra phải là thứ
**cắm sang chỗ khác dùng lại được**. Flutter là nền duy nhất trên máy này đã sẵn sàng chạy
Android ngay (fvm 3.41.9, `adb` + `emulator` có, `marionette_mcp` đã activate) — chọn nền khác
là mất nửa ngày dựng môi trường trước khi viết dòng đầu tiên.

`livekit_client` không phải lựa chọn mà là đề bài. Phần thật sự được chọn là **cách bọc quanh
nó**: `flutter_bloc` để máy trạng thái cuộc gọi khai tường minh và test được không cần thiết
bị — vì với một máy Android thật + một emulator không mic, phần lớn ca biên (rớt mạng, từ chối
quyền, đối phương thoát) chỉ kiểm được bằng test, không kiểm được bằng tay.

Bỏ DB, bỏ auth, bỏ error tracking đều cùng một lý do: không có gì cần sống qua lần chạy, và
mỗi thứ thêm vào là một chỗ có thể vỡ trong ngày cuối. Chi tiết ở `DECISIONS.md`.

<!-- 2-3 câu. Ràng buộc thật là gì (quen tay? cần AI? cần deploy nhanh? đội sẵn có?).
     Quyết định tương ứng đã ghi ở DECISIONS.md dòng nào.
     Đường intake: stack do intake chốt — ghi lại ràng buộc mà intake nêu, và những chỗ
     phải tự quyết vì intake không nói. -->

## 4. Version pinning

Ghi version thật sau khi scaffold xong (đọc từ `package.json` / `go.mod` / `pyproject.toml` / `pom.xml`), để lần sau dựng lại được đúng.

```
Ghi lại sau khi scaffold xong ở pha I — đọc từ pubspec.lock:
  flutter        3.41.9   (ghim ở .fvmrc)
  dart           đi kèm SDK
  livekit_client 2.5.3
  flutter_bloc   ^9.1.1
  permission_handler ^12.0.1
```

## 5. Hợp đồng lệnh

Sáu lệnh dưới đây phải chạy được sau pha I. Phần thân do stack skill quy định.

| Lệnh | Làm gì | Đã hoạt động? |
|---|---|---|
| `make dev` | Chạy local (app + db) | ☐ |
| `make check` | Lint + typecheck + build | ☐ |
| `make test` | Smoke + luồng quan trọng | ☐ |
| `make migrate` | DB migration có version | ☐ |
| `make deploy` | Đẩy lên PaaS | ☐ |
| `make doctor` | Kiểm env + kết nối, in cái gì thiếu | ☐ |

Đa target: **root `Makefile` vẫn là hợp đồng 6 lệnh duy nhất** — thân từng lệnh điều phối xuống các target (`make -C srcroot/<nhóm>/<tên> …`). Deploy luôn đi qua root `make deploy`; đó là chỗ hook `guard_bc` đứng.

## 6. Biến môi trường

Danh sách đầy đủ ở `deployment/.env.example`. Không bao giờ commit `.env` thật —
bản điền giá trị local nằm ở `deployment/local/.env` (đã bị `.gitignore` chặn).

Ở Flutter, biến vào app qua `--dart-define`, không qua file `.env` lúc chạy. Giá trị thật để
ở `deployment/local/.env` (đã bị `.gitignore` chặn) và `make dev` đọc từ đó dựng cờ
`--dart-define`. **API secret không bao giờ được commit và không được vào bản release.**

| Biến | Dùng để | Target | Bắt buộc? |
|---|---|---|---|
| `KAICALL_LIVEKIT_URL` | Địa chỉ LiveKit Cloud (`wss://…`) | `app` | ✓ |
| `KAICALL_LIVEKIT_API_KEY` | Khoá để ký token ngay trong app | `app` | ✓ |
| `KAICALL_LIVEKIT_API_SECRET` | Bí mật để ký token — **chỉ demo** | `app` | ✓ |
| `KAICALL_ALLOW_INSECURE_LOCAL_TOKEN` | Cờ chặn: không bật thì app từ chối ký token trong máy | `app` | ✓ |

Thiếu bất kỳ biến nào → app hiện màn chặn nói rõ thiếu biến nào, không vào được danh bạ
(`PRD.md §7` trạng thái lỗi). `make doctor` kiểm đúng bốn biến này.
