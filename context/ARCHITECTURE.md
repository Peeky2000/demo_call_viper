---
type: architecture
tier: T0
status: DRAFT
last_reviewed: "2026-08-17"
---

# ARCHITECTURE — CORE-VIPER

> **Mỏng nhưng quyết đủ.** Đủ để agent tự quyết khi code mà không phải hỏi. Không phải HLD 20 trang.
> Cấu trúc §1–§5 lấy theo `intake/_ARCHITECTURE-TEMPLATE.md` để hai đường vào dùng chung một khung.
>
> **Cỡ hệ thống — khác nhau theo đường vào** ([VIPER.md §1.3](../VIPER.md), luật #5):
> - **Đường phỏng vấn**: một app, một DB, một nơi deploy — không micro-service. §1 đúng một dòng, §2 đúng một dòng, §3 ghi `—`.
> - **Đường intake**: đa target theo `intake/ARCHITECTURE.md` — mỗi boundary/experience một thư mục dưới `srcroot/boundaries/` · `srcroot/web-experiences/` · `srcroot/mobile-experiences/`. **Không tự đẻ target ngoài danh sách intake.**
>

---

## 1. Backend boundaries

<!-- Đường phỏng vấn: đúng MỘT dòng, tên `app`, "Sở hữu dữ liệu" ghi các thực thể ở §6.
     Đường intake: mỗi boundary trong intake/ARCHITECTURE.md §1 một dòng, GIỮ NGUYÊN tên
     — tên này là tên thư mục code srcroot/boundaries/<tên>/ ở pha I.
     Cột "Vòng": vòng nào giao boundary này (theo context/ROADMAP.md §1). -->

| Boundary | Nhiệm vụ (1 dòng) | Sở hữu dữ liệu | Vòng |
|---|---|---|---|
| `app` | Toàn bộ KaiCall trong một app Flutter — không có backend nào cả | `Contact`, `CallInvite`, `CallSession` (đều trong bộ nhớ, mất khi tắt app) | 1 |

## 2. Frontend experiences — web

<!-- Đường phỏng vấn: một dòng (hoặc ghi `—` nếu backend-only).
     Đường intake: theo intake/ARCHITECTURE.md §2; tên = thư mục srcroot/web-experiences/<tên>/.
     (§3 mobile tương tự, dưới srcroot/mobile-experiences/.)

     Cột "Design system" là NGUỒN ÁNH XẠ DUY NHẤT experience → gói design system, dùng
     bởi gate.py, hook guard_ds.py và vai dogfood `viper-user-picky`. Giá trị = tên thư
     mục gói `intake/design-systems/<ds>/`. Tên experience ở cột đầu đồng thời là tên
     thư mục code `srcroot/<nhóm>/<tên>/` và thư mục `prototype/<tên>/` — chính nhờ vậy
     máy tra được file prototype nào phải theo bảng token nào.

     · Một design system (hoặc đường phỏng vấn) → để `—`, mọi phép kiểm chạy trên cả
       bảng token như trước, không phải khai gì thêm.
     · NHIỀU gói trong intake/design-systems/ → cột này BẮT BUỘC cho mọi dòng, bỏ trống
       là gate V đỏ. Hai experience dùng chung một gói là chuyện bình thường.

     Ví dụ (hai design system):
     | admin-console | P-OWNER | quản trị lịch, báo cáo | 1 | admin |
     | shop-web      | P-BUYER | đặt lịch, xem trạng thái | 2 | shop  | -->

| Experience | Persona | Năng lực lộ ra | Vòng | Design system |
|---|---|---|---|---|
| — (không có web — `PRD.md §5`) | | | | — |

## 3. Frontend experiences — mobile

<!-- Không có mobile thì ghi `—` và xoá bảng. Cột "Design system": xem §2. -->

| Experience | Nền tảng | Persona | Vòng | Design system |
|---|---|---|---|---|
| `kaicall` | Android (Flutter 3.41.9) | Người thử demo (`peer`) | 1 | `DESIGN-SYSTEM.md` (gói duy nhất) |

## 4. Sơ đồ

```
   Máy A (Android thật)                              Máy B (emulator)
  ┌─────────────────────┐                          ┌─────────────────────┐
  │  KaiCall (Flutter)  │                          │  KaiCall (Flutter)  │
  │  presentation       │                          │  presentation       │
  │  application (bloc) │                          │  application (bloc) │
  │  infrastructure     │                          │  infrastructure     │
  └──────────┬──────────┘                          └──────────┬──────────┘
             │                                                │
             │        ┌──────────────────────────┐            │
             ├───────►│  LiveKit Cloud           │◄───────────┤
             │        │                          │            │
             │        │  phòng "lobby"           │            │
             │        │   └─ data channel  ──────┼── lời mời gọi / từ chối
             │        │                          │
             └───────►│  phòng "kaicall-a-b"     │◄───────────┘
                      │   └─ audio + video       │
                      └──────────────────────────┘

  Token: KHÔNG có backend. Mỗi máy tự ký bằng API secret nạp qua --dart-define,
         và chỉ ký khi cờ KAICALL_ALLOW_INSECURE_LOCAL_TOKEN bật (DECISIONS.md).
```

<!-- ASCII hoặc mermaid. Đường phỏng vấn chỉ cần: người dùng → app → DB → dịch vụ ngoài.
     Ví dụ:
       Người dùng ──► Next.js (Vercel) ──► Postgres (Neon)
                           ├──► Clerk (auth)
                           └──► Resend (email)

     Đường intake: giữ topology của intake/ARCHITECTURE.md §4 — experience → BFF (nếu có)
     → boundary → datastore, kèm hạ tầng ngoài đáng chú ý. -->

## 5. Contract giữa các target

<!-- CHỈ đường intake, và chỉ khi có nhiều hơn một target. Một app thì xoá bảng, ghi `—`:
     không có ranh giới nào để ký contract.
     Mỗi dòng = một mặt tiếp xúc mà bên khác bám vào. Đây cũng là nguồn của
     BACKWARD-COMPATIBILITY-CHECKLIST.md §1 từ vòng 2 — đổi ở đây là đổi hợp đồng. -->

| Contract | Bên cung cấp | Bên dùng | Kiểu | Vòng |
|---|---|---|---|---|
| — | | | | |

## 6. Mô hình dữ liệu lõi

<!-- Các thực thể chính + quan hệ + ràng buộc quan trọng. Đây là chỗ agent tra khi phân vân
     "field này để đâu", "cái này unique không". Ghi đủ để không phải hỏi.
     Đa target: một khối bảng cho mỗi boundary sở hữu dữ liệu, đặt tiêu đề ### <boundary>. -->

**Không có database.** Cả ba thực thể sống trong bộ nhớ tiến trình và mất khi tắt app —
đó là quyết định, không phải thiếu sót (`DECISIONS.md` 2026-08-20).

| Thực thể | Field chính | Quan hệ | Ràng buộc |
|---|---|---|---|
| `Contact` | `id`, `displayName`, `avatarSeed` | — | Đúng **2 bản ghi**, hằng số trong source. `id` là chuỗi ổn định, dùng làm khoá dựng tên phòng |
| `CallInvite` | `fromId`, `toId`, `roomName`, `sentAt` | trỏ tới 2 `Contact` | `roomName` dựng **tất định** từ cặp id đã sắp xếp (`kaicall-<idNhỏ>-<idLớn>`) — hai bên tự tính ra cùng một tên, không cần ai cấp |
| `CallSession` | `roomName`, `state`, `localMuted`, `localCameraOff`, `facing`, `remoteJoined` | 1 phòng ↔ tối đa 2 người | `state` là **máy trạng thái đóng**: `idle → outgoing → connecting → inCall → ended`, và `idle → incoming → connecting → inCall → ended`. Không có chuyển trạng thái nào ngoài bảng ở §7 |

**Ca biên đã quyết** (nguồn: `PRD.md §7`):

| Tình huống | Xử lý |
|---|---|
| Trùng dữ liệu | Không có dữ liệu bền nên không có trùng. Trùng **phòng** thì ngược lại là mong muốn: tên phòng tất định nên hai bên luôn gặp nhau đúng một chỗ |
| Xoá | Không có xoá — không có gì được lưu |
| Sửa đồng thời | **Hai bên bấm gọi nhau cùng lúc**: mỗi bên đang ở `outgoing` mà nhận được lời mời từ đúng người mình đang gọi → coi như đã đồng ý, cả hai đi thẳng `connecting`, không ai phải bấm Nghe. Vì tên phòng tất định nên hai bên vào cùng phòng, không tạo ra hai cuộc |
| Gửi hai lần (double submit) | Bấm Gọi liên tiếp: nút khoá ngay khi chuyển sang `outgoing`. Bấm Nghe hai lần: chuyển trạng thái là idempotent, lần thứ hai rơi vào nhánh không làm gì. **Bấm Nghe khi bên kia đã cúp** → không có ai trong phòng → về `ended` với lý do "cuộc gọi đã kết thúc", không treo |

## 7. Luồng lõi

<!-- Luồng end-to-end quan trọng nhất — cái mà pha I phải làm chạy được, và pha dogfood phải đi hết.
     Viết theo bước, kèm chỗ nào chạm DB, chỗ nào gọi ra ngoài, chỗ nào đi qua ranh giới target. -->

Luồng lõi là **gọi thành công từ danh bạ tới lúc cúp máy**. Pha I phải làm chạy được nguyên
chuỗi này; dogfood phải đi hết.

```
 0. Mở app → đọc 4 biến --dart-define
       thiếu biến  → màn chặn, nói rõ thiếu biến nào, DỪNG
 1. Chọn mình là ai (2 lựa chọn) → vào phòng chờ "lobby" của LiveKit
       không vào được → danh bạ hiện banner, nút Gọi mờ
 2. Danh bạ 2 người                                        ← AC-1
 3. A bấm Gọi B
       xin quyền mic + cam
         bị từ chối → màn giải thích + nút mở Cài đặt      ← AC-5
       tính roomName = kaicall-<idNhỏ>-<idLớn>  (tất định, hai bên tự ra cùng kết quả)
       gửi CallInvite qua data channel của lobby
       A → trạng thái `outgoing`, hiện màn "Đang gọi…", có nút Huỷ
 4. B nhận lời mời → màn "Cuộc gọi đến" + tên A            ← AC-1
       ├── B bấm Từ chối → gửi lại lời từ chối qua lobby
       │      A hiện "Bị từ chối" → về danh bạ             ← AC-3
       └── B bấm Nghe → cả hai `connecting`
 5. Hai bên ký token cho roomName → connect vào phòng gọi
       thấy hình + nghe tiếng nhau → `inCall`              ← AC-2
 6. Trong cuộc gọi: mic on/off · cam on/off · đổi cam · cúp máy
       mỗi nút đổi state ngay tại máy mình, bên kia thấy qua sự kiện của LiveKit  ← AC-4
 7. Kết thúc — bốn đường vào cùng một chỗ:
       ├── một bên bấm Cúp máy       → bên kia thấy "đã kết thúc"     ← AC-4
       ├── một bên rớt mạng/thoát    → bên kia banner rồi kết thúc    ← AC-6
       ├── background rồi quay lại   → KHÔNG kết thúc, giữ nguyên cuộc gọi ← AC-7
       └── thoát hẳn app             → ngắt phòng tường minh để bên kia
                                        không treo màn chờ            ← AC-7
    → cả hai về `ended` rồi về danh bạ
```

**Chỗ gọi ra ngoài**: bước 1, 3, 4 (data channel lobby) và bước 5–7 (phòng gọi) — đều tới
LiveKit Cloud. **Không có chỗ nào chạm DB** vì không có DB.

### Bốn chỗ challenge pha V bắt được — quyết luôn ở đây

**a. B chưa mở app thì A bấm gọi thấy gì?** Không có push nên lời mời rơi vào hư không. A ở
`outgoing` **tối đa 30 giây**, hết giờ → "Không trả lời" → về danh bạ. Không có timeout thì
màn "Đang gọi…" quay vĩnh viễn — đúng kiểu treo mà `PRD.md §1` nói là nỗi đau.

**b. Token hết hạn giữa cuộc gọi?** TTL **2 giờ**, cấp mới mỗi lần vào phòng. `livekit_client`
không tự gia hạn được, nên cuộc gọi dài hơn 2 giờ sẽ rớt — chấp nhận: demo nghiệm thu không có
ca đó. Ghi ra để sau này ai thấy rớt ở phút 121 thì biết ngay vì sao.

**c. Cuộc gọi trước kết thúc bẩn, một bên còn kẹt trong phòng?** `roomName` tất định nên cuộc
mới dùng lại đúng phòng cũ. Xử bằng **`identity` = `Contact.id`**: LiveKit đá bản cũ cùng
identity ra khi bản mới vào. Không đặt identity ngẫu nhiên — đặt ngẫu nhiên thì hai bản của
cùng một người cùng tồn tại trong phòng, và bên kia thấy hai ô video.

**d. Background — mâu thuẫn giữa AC-7 và thực tế Android.** Giữ tiếng ở nền *lâu* cần
foreground service; vòng 1 **không làm**. AC-7 vì vậy giới hạn ở **chuyển nền ngắn** (bấm Home,
mở app khác rồi quay lại trong khoảng nửa phút) — tiến trình còn sống thì tiếng còn thông.
Thoát hẳn app → `disconnect()` tường minh trong `dispose`, để bên kia thoát treo ngay chứ
không đợi LiveKit tự phát hiện mất kết nối. Foreground service đẩy `ROADMAP.md §3`.

## 8. Ranh giới module

<!-- Chia code thành mấy phần, phần nào được gọi phần nào. Ngăn agent để logic sai chỗ.
     Đường phỏng vấn — cấu trúc trong app duy nhất ở gốc repo:
       app/       routing + layout
       features/  theo tính năng: UI + hook + state cục bộ
       lib/       dùng chung: db client, auth, tiện ích
       server/    logic nghiệp vụ + truy cập DB   ← CHỈ chỗ này chạm DB
     Đường intake — cấu trúc BÊN TRONG mỗi srcroot/<nhóm>/<tên>/ (theo stack skill của target đó),
     cộng luật: target không import thẳng code của target khác, đi qua contract ở §5. -->

Cấu trúc trong app duy nhất ở gốc repo (`lib/`), phân tầng để **phần call bóc ra dùng lại
được** — đó là mục tiêu Authority nêu từ đầu:

| Thư mục | Chứa gì | Được gọi bởi | Không được làm gì |
|---|---|---|---|
| `lib/domain/` | Kiểu dữ liệu thuần Dart: `Contact`, `CallInvite`, `CallSession`, `CallState`, lỗi | mọi tầng | **Không import `livekit_client`, không import `flutter`** — đây là chỗ giữ cho logic test được không cần thiết bị |
| `lib/application/` | `CallBloc` — máy trạng thái ở §7, và `SignalingBloc` cho phòng chờ | tầng presentation | Không chạm thẳng SDK LiveKit; chỉ nói chuyện qua interface ở `domain` |
| `lib/infrastructure/` | Hiện thực thật: `LiveKitCallSession`, `LiveKitSignaling`, `LocalTokenSigner`, `DevicePermissions` | tầng application (qua interface) | **Không chứa logic nghiệp vụ** — dịch SDK sang kiểu của `domain`, hết |
| `lib/presentation/` | 4 màn + widget: danh bạ, cuộc gọi đến, đang gọi, trong cuộc gọi | Flutter | Không gọi SDK, không tự quyết chuyển trạng thái — chỉ bắn event vào bloc và vẽ theo state |
| `lib/config/` | Đọc 4 biến `--dart-define`, kiểm đủ/thiếu | app khởi động | Không chứa giá trị mặc định nào cho key/secret |

**Ranh giới quan trọng nhất**: `domain` + `application` không biết LiveKit tồn tại. Đổi sang
SDK khác, hay thay ký-token-trong-app bằng gọi backend, chỉ đụng `infrastructure`.

Quy tắc chung không đổi:
- Chỉ **một tầng** được chạm DB. UI không query trực tiếp.
- Logic nghiệp vụ không nằm trong component.
- Gọi dịch vụ ngoài đi qua một chỗ duy nhất (dễ mock khi test, dễ đổi khi provider hỏng).

## 9. Dịch vụ ngoài

| Dịch vụ | Dùng để | Hỏng thì sao |
|---|---|---|
| **LiveKit Cloud** | Truyền tiếng + hình, và làm kênh báo cuộc gọi (data channel trong phòng chờ) | Không vào được phòng chờ → danh bạ hiện banner "chưa kết nối được máy chủ", nút Gọi mờ đi. Rớt giữa cuộc → banner "đang kết nối lại" đếm giây, quá ngưỡng thì kết thúc và về danh bạ |

## 10. Thứ cố tình KHÔNG làm

<!-- Ghi rõ để agent không "tốt bụng" thêm vào: cache layer, queue, websocket, multi-tenant,
     i18n, dark mode... Vòng này không có nghĩa là không bao giờ — thứ nào cần thì vào ROADMAP. -->

- Backend cấp token — ký trong app sau cờ chặn (`DECISIONS.md`)
- Push notification / đổ chuông khi app đóng
- Database, lưu trữ bền, lịch sử cuộc gọi
- Đăng nhập, tài khoản, danh bạ thật
- Cuộc gọi nhóm >2 người
- Chia sẻ màn hình, chat, gửi file
- i18n — chỉ tiếng Việt
- Dark mode như một lựa chọn — màn cuộc gọi vốn đã nền tối, đó là thiết kế chứ không phải theme
- Cache, queue, websocket riêng — data channel của LiveKit đã đủ
