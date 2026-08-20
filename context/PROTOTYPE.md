---
type: prototype
tier: T0
status: DRAFT
last_reviewed: "2026-08-17"
---

# PROTOTYPE — CORE-VIPER

> **Nguồn sự thật cho kiến trúc thông tin** — ngang vai với `ARCHITECTURE.md` cho backend;
> hình thức (màu, chữ, component) nằm ở `DESIGN-SYSTEM.md`, điền TRƯỚC khi dựng prototype.
> Điền ở pha V, sau khi đã hiểu sản phẩm (phỏng vấn hoặc dịch intake), TRƯỚC khi khoá scope.
> Pha I làm theo màn hình đã chốt ở đây; UI lệch bản đã chốt là phát hiện khi dogfood.
>
> **Quy trình bắt buộc ở vòng 1**: dựng file prototype (§4) → **DỪNG LẠI**, mời Authority mở
> bấm thử hết luồng lõi → ghi phản hồi vào §5, sửa, lặp → Authority nói "chốt" → ghi ngày vào
> dòng `Chốt bởi Authority` → lúc đó mới được khoá scope. Đây vẫn là pha V nên hỏi thoải mái.
>
> **Vòng ≥2**: ngày chốt cũ còn nguyên hiệu lực, không có nghi thức chốt lại — thêm/sửa màn
> delta rồi đi tiếp. Đường intake: vòng khai `UI vòng này: không có màn mới` trong
> `intake/loops/l<N>/_PROPOSAL.md` thì `gate.py V` bỏ qua toàn bộ phần prototype
> ([VIPER.md §1.4](../VIPER.md)).

<!-- DỰ ÁN KHÔNG CÓ GIAO DIỆN NGƯỜI DÙNG (API thuần / CLI / worker):
     xoá toàn bộ nội dung từ §1 trở xuống, thay bằng đúng một dòng:

         KHÔNG CÓ UI — bỏ qua prototype

     kèm 1 dòng lý do trong DECISIONS.md. gate.py V thấy marker này sẽ bỏ qua
     toàn bộ kiểm prototype và KHÔNG chặn khoá scope. -->

---

## 1. Bản đồ màn hình

<!-- Mỗi màn một dòng. "Thông tin bắt buộc" xếp theo thứ tự ưu tiên — thứ persona cần thấy
     TRƯỚC đứng trước; đây chính là kiến trúc thông tin, đừng liệt kê cho có.
     Cột cuối bắt buộc nghĩ trước 3 trạng thái: chưa có dữ liệu / lỗi / đang tải.

     Ví dụ:
     | S1 | Lịch tuần | Chốt hẹn trong lúc nghe điện thoại | Khung giờ trống hôm nay → tên thợ → hẹn kế tiếp | Bấm khung giờ → tạo hẹn | Rỗng: nút "Tạo hẹn đầu tiên" · Lỗi: giữ số đang nhập |
-->

| # | Màn hình | Mục đích (theo persona nào) | Thông tin bắt buộc — theo thứ tự ưu tiên | Hành động chính | Rỗng / lỗi / đang tải |
|---|---|---|---|---|---|
| S0 | Chặn thiếu cấu hình | Người thử — biết ngay vì sao app không chạy được | Thiếu biến nào (liệt kê đúng tên) → cách nạp qua `--dart-định` | Không có (màn cụt) | Lỗi: đây chính là màn lỗi · Rỗng/tải: không có |
| S1 | Danh bạ | Người thử — nhìn là biết app gọi điện, bấm một người là gọi | Mình đang là ai → 2 liên hệ (avatar + tên) → nút gọi từng dòng | Bấm một người → gọi | Rỗng: không có (luôn 2 người) · Lỗi: banner "chưa kết nối được máy chủ", nút Gọi mờ · Tải: banner "đang kết nối" |
| S2 | Cuộc gọi đến | Người nhận — quyết nghe hay không trong 2 giây | Tên người gọi (chữ lớn nhất màn) → avatar → hai nút Nghe / Từ chối | Bấm Nghe hoặc Từ chối | Lỗi: bên kia đã cúp → "Cuộc gọi đã kết thúc" rồi tự về S1 |
| S3 | Đang gọi | Người gọi — biết máy bên kia đang đổ chuông, và huỷ được | Tên người được gọi → trạng thái ("Đang gọi…") → nút Huỷ | Bấm Huỷ | Lỗi: bị từ chối → "Bị từ chối" rồi về S1 · Tải: chính là trạng thái của màn |
| S4 | Trong cuộc gọi | Cả hai — nói chuyện, và điều khiển được mic/cam | Video người kia (toàn màn) → video mình (ô nhỏ góc) → banner trạng thái → hàng nút điều khiển | Mic · Cam · Đổi cam · Cúp máy | Rỗng: người kia tắt cam → avatar + tên · Lỗi: rớt mạng → banner "đang kết nối lại" đếm giây · Tải: ô video giữ chỗ sẵn |
| S5 | Quyền bị từ chối | Người thử — hiểu vì sao không gọi được và tự sửa được | Thiếu quyền nào (mic / camera) → vì sao cần → nút mở Cài đặt | Bấm mở Cài đặt hệ thống | Lỗi: đây chính là màn lỗi |

## 2. Sơ đồ điều hướng

<!-- Màn nào đi tới màn nào, bằng hành động gì. ASCII là đủ.
     Ví dụ:  S1 Lịch tuần ──bấm khung giờ──► S2 Tạo hẹn ──lưu──► S1 (hẹn mới nổi bật)
-->

```
  mở app
    │
    ├─ thiếu biến ──► S0 Chặn cấu hình  (cụt — sửa --dart-define rồi mở lại)
    │
    └─ đủ ──► S1 Danh bạ ◄──────────────────────────────────────┐
                 │                                              │
                 ├─ bấm gọi ─┬─ quyền bị từ chối ──► S5 Quyền ──┘
                 │           │
                 │           └─ có quyền ──► S3 Đang gọi
                 │                              │
                 │                              ├─ bấm Huỷ ─────────────┐
                 │                              ├─ bị từ chối ──────────┤
                 │                              └─ bên kia bấm Nghe ──► S4 Trong cuộc gọi
                 │                                                         │
                 └─ nhận lời mời ──► S2 Cuộc gọi đến                       │
                                        ├─ Từ chối ────────────────────────┤
                                        └─ Nghe ──────────────────────► S4 │
                                                                           │
                        S4 kết thúc: cúp máy · bên kia thoát · rớt mạng ────┘
```

**Hai chỗ cố ý** trong sơ đồ:

- **S0 là màn cụt** — không có đường ra. Thiếu cấu hình thì sửa `--dart-define` rồi mở lại app;
  cho đi tiếp vào danh bạ chỉ để hỏng sâu hơn ở chỗ khó đoán hơn.
- **Mọi nhánh kết thúc đều về S1**, kể cả nhánh lỗi. Không nhánh nào dừng ở màn không có nút
  bấm được — đây là phản ứng trực tiếp với nỗi đau "bấm trúng chỗ nào là hỏng chỗ đó"
  (`PRD.md §1`).

## 3. Map AC ↔ màn hình

<!-- Mỗi AC trong PRD.md §3 phải xuất hiện ít nhất một lần — gate.py V kiểm đúng điều này.
     AC không map được vào màn hình nào = hoặc thiếu màn hình, hoặc AC thừa. -->

| AC | Màn hình | Ghi chú |
|---|---|---|
| AC-1 | S1 → S2 | Bấm gọi ở S1, máy kia hiện S2 kèm tên người gọi trong ≤3 giây |
| AC-2 | S2 → S4 | Bấm Nghe ở S2 → cả hai vào S4, thấy hình và nghe tiếng nhau |
| AC-3 | S2 → S3 → S1 | Bấm Từ chối ở S2 → S3 của bên gọi hiện "Bị từ chối" → tự về S1 |
| AC-4 | S4 | Hàng nút điều khiển: mic, cam, đổi cam, cúp máy — mỗi nút phản hồi thấy được ngay |
| AC-5 | S1 → S5 | Từ chối quyền lúc bấm gọi → S5, có nút mở Cài đặt; không crash, không màn trắng |
| AC-6 | S4 → S1 | Bên kia rớt mạng/thoát → banner ở S4 rồi tự về S1 |
| AC-7 | S4 | Background: giữ nguyên S4 khi quay lại. Thoát hẳn: ngắt phòng tường minh để bên kia thoát treo |

## 4. File prototype tương tác

**Bao nhiêu file — theo đường vào** ([VIPER.md §1.3](../VIPER.md)):

| Đường phỏng vấn | Đường intake |
|---|---|
| `prototype/index.html` — MỘT file, một app | `prototype/<experience>/index.html` — mỗi experience có UI ở `ARCHITECTURE.md §2–§3` một file, tên thư mục khớp tên experience |

Mã màn hình `S<số>` là **toàn cục** cho cả hệ (S1, S2… — không đặt SW1/SM1); `gate.py` chỉ khớp `S\d+` và glob `prototype/**/*.html`.

Mỗi file phải là **HTML tự chứa** để Authority mở thẳng bằng trình duyệt:

- Đủ mọi màn hình của experience đó ở §1, điều hướng bấm được đúng sơ đồ §2 (hash routing hoặc show/hide, không cần backend)
- Dữ liệu giả lấy từ `PRD.md §7` (dữ liệu mẫu) — không lorem ipsum
- Có cả trạng thái rỗng và trạng thái lỗi của từng màn (nút chuyển trạng thái để xem)
- Responsive theo "Thiết bị chính" của persona dùng experience đó (`PERSONAS.md §1`)
- Không CDN, không thư viện ngoài — mở offline vẫn chạy
- **Hình thức lấy nguyên từ `DESIGN-SYSTEM.md`**: token §2 khai trong `:root` và dùng qua
  `var(--…)`; màn hình lắp từ kho component §4 — **không hardcode màu, không khai token
  mới ngay trong HTML, không vẽ khối ngoài kho**

Ba luật cuối không phải lời khuyên: hook `scripts/guard_ds.py` **chặn thẳng lệnh ghi file**
khi thấy mã màu thô ngoài `:root` hoặc `var(--…)` chưa khai ở §2, và `gate.py V` báo đỏ khi
màn khai ở §1 mà prototype chưa dựng. Design system chốt trước prototype chỉ có tác dụng nếu
prototype thật sự lắp từ token — gõ thẳng `#hex` cho nhanh là giết đúng cơ chế đó: phản hồi
"chữ nhỏ quá" của Authority lẽ ra sửa MỘT token rồi lan ra mọi màn.

**Prototype là tài liệu, không phải code nền.** Pha I scaffold từ stack skill và làm lại UI
theo bản đồ §1 — không phát triển tiếp file này, không copy nguyên khối vào codebase.

## 5. Chốt của Authority

<!-- Ghi từng LƯỢT phản hồi (lượt ở đây là một vòng bấm-thử-rồi-sửa, không phải "vòng"
     V-I-P-E-R). Authority nói "chốt" thì điền ngày ISO vào dòng dưới cùng — ví dụ:
     `Chốt bởi Authority: 2026-08-04` — gate.py V bắt đúng dòng này, chưa có thì chưa
     được khoá scope. Vòng ≥2 không xoá ngày này (repeat.py giữ nguyên): tài liệu vòng
     / kế hoạch vòng là chữ ký của Authority cho vòng mới. -->

| Lượt | Ngày | Phản hồi của Authority | Đã sửa |
|---|---|---|---|
| 1 | _CHƯA ĐIỀN_ | | |

Chốt bởi Authority: _CHƯA ĐIỀN_
