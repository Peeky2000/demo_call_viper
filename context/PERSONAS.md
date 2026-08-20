---
type: personas
tier: T0
status: DRAFT
last_reviewed: "2026-08-17"
---

# PERSONAS — CORE-VIPER

> **Ai dùng sản phẩm, và họ được cấp năng lực gì.** Điền ở pha V. Đây là nguồn sự thật cho
> phân quyền khi code (pha I), và là chân dung để 6 vai `viper-user-*` đóng khi dogfood —
> lăng kính hành vi (vội, phá, mới, khó tính…) là *cách dùng*, persona là *ai đang dùng*.

---

## 1. Persona

<!-- SỐ LƯỢNG khác nhau theo đường vào (VIPER.md §1.3):
     · Đường phỏng vấn — tối đa 2–3. Nhiều hơn là dấu hiệu scope quá lớn cho một tuần.
     · Đường intake   — bao nhiêu persona thì intake/PRD.md §2 định nghĩa bấy nhiêu; giữ
       nguyên mã P-… để truy vết ngược. Hệ thống lớn có nhiều vai là chuyện bình thường.

     Persona CHÍNH để đầu tiên. Ví dụ:

     ### Persona 1 — Chủ gara (role: owner) ← persona chính
     | Mục | Nội dung |
     |---|---|
     | Mã (intake) | P-OWNER |
     | Chân dung + bối cảnh | 35–50 tuổi, quản 3–10 thợ, đứng giữa xưởng vừa nghe điện thoại vừa thao tác, mỗi lần dưới 1 phút |
     | Thiết bị chính | Điện thoại (link chia sẻ qua Zalo) |
     | Mức thành thạo | Thấp — chỉ quen Zalo, không quen phần mềm quản lý |
     | Năng lực được cấp | Tạo/sửa/huỷ lịch hẹn của MỌI thợ trong gara mình; xem báo cáo tuần |
     | KHÔNG được làm | Thấy dữ liệu của gara khác |
     | Luồng chính | Nhận cuộc gọi → mở app → thấy khung giờ trống → chốt hẹn → xong |
     | Vào từ vòng | 1 |
-->

### Persona 1 — Người thử demo (role: `peer`) ← persona chính

| Mục | Nội dung |
|---|---|
| Mã (intake) | — (đường phỏng vấn để `—`) |
| Chân dung + bối cảnh | Dev hoặc tech lead, đang ngồi nghiệm thu. Cầm điện thoại Android một tay, thao tác bằng ngón cái, có khi cầm hai máy cùng lúc để tự gọi cho chính mình. Biết rõ app làm gì nên không đọc hướng dẫn — bấm thẳng, và cố tình bấm những chỗ dễ vỡ |
| Thiết bị chính | Điện thoại Android thật (một máy) + một emulator Android làm đầu thứ hai |
| Mức thành thạo | Cao về kỹ thuật, nhưng dùng app này lần đầu — luồng phải tự nói được nó đang ở đâu |
| Năng lực được cấp | Chọn danh tính mình đang đóng · gọi một người trong danh bạ · nghe / từ chối cuộc gọi đến · tắt-bật mic, tắt-bật cam, đổi cam trước-sau · cúp máy |
| KHÔNG được làm | Không có gì bị chặn theo vai — hai bên ngang quyền tuyệt đối. Không ai đuổi được ai, không ai tắt mic người khác, không ai khoá phòng |
| Luồng chính | Mở app → chọn mình là ai → thấy danh bạ → bấm gọi một người → (máy kia hiện cuộc gọi đến) → bên kia bấm Nghe → nói chuyện, thử mic/cam → cúp máy → về danh bạ |
| Vào từ vòng | 1 |

<!-- Persona 2, 3… — copy đúng khung trên. Sản phẩm chỉ có một loại người dùng thì một
     persona là đủ, đừng bịa thêm cho có.
     "Vào từ vòng": persona chỉ xuất hiện ở vòng sau vẫn khai đủ ở đây (để ma trận §2
     đầy đủ ngay từ đầu), nhưng ghi rõ vòng nào mới cấp năng lực thật. -->

## 2. Ma trận vai × hành động

<!-- Đây là SPEC cho phân quyền — pha I code theo đây, không tự quyết rồi ghi DECISIONS.
     Mỗi ô ✗ là một ca kiểm bắt buộc: gọi thẳng URL/API phải bị chặn.
     `viper-user-breaker` (dogfood) và phép thử A↛B (/viper-polish nhóm 2) chạy đúng theo bảng này.
     Luôn có cột "chưa đăng nhập" — kể cả khi sản phẩm không có đăng nhập (khi đó ghi rõ
     "không có auth, mọi người thấy mọi thứ" ở dòng đầu và cân nhắc lại với Authority ở pha V).

     Ví dụ:
     | Hành động | owner | mechanic | chưa đăng nhập |
     |---|---|---|---|
     | Tạo / sửa / huỷ lịch hẹn | ✓ | ✗ | ✗ |
     | Xem lịch của thợ khác | ✓ | ✗ | ✗ |
     | Đánh dấu hoàn thành | ✓ | ✓ (của mình) | ✗ |
-->

**Sản phẩm KHÔNG có đăng nhập** — danh bạ mock 2 người cắm cứng, chọn danh tính bằng cách
bấm, không mật khẩu, không phiên. Mọi người mở app đều thấy mọi thứ. Đã cân nhắc với Authority
ở pha V và chốt giữ nguyên: đây là demo nghiệm thu tại chỗ trên máy của chính người thử, không
phát hành, nên thêm auth chỉ tốn thời gian mà không chặn được rủi ro nào có thật.

Vì chỉ có **một vai duy nhất** (`peer`) và hai bên ngang quyền, bảng này không có ô `✗` nào —
tức **không có phép thử A↛B** để chạy ở `/viper-polish` nhóm 2. Đó là kết luận, không phải
thiếu sót; ghi rõ ở đây để pha P không đi tìm một phép thử không tồn tại.

| Hành động | `peer` | chưa đăng nhập |
|---|---|---|
| Chọn danh tính đang đóng | ✓ | — (không có khái niệm đăng nhập) |
| Gọi một người trong danh bạ | ✓ | — |
| Nghe / từ chối cuộc gọi đến | ✓ | — |
| Tắt-bật mic, tắt-bật cam, đổi cam | ✓ (của chính mình) | — |
| Tắt mic / cam của người kia | ✗ | ✗ |
| Đuổi người kia khỏi cuộc gọi | ✗ | ✗ |
| Cúp máy | ✓ (kết thúc cho cả hai) | — |

## 3. Gán persona cho 6 vai dogfood

<!-- Mặc định mọi lăng kính đóng persona chính; đổi ở đây nếu muốn khác.
     Sản phẩm nhiều vai → chạy thêm lượt newbie cho từng persona còn lại nếu kịp.

     Cột "Đợt" là thứ /viper-dogfood đọc để chia lượt spawn. Sáu vai KHÔNG chạy cùng
     lúc: trình duyệt thì riêng (mcpServers inline + --isolated) nhưng server dev và DB
     dùng chung, nên vai ghi dữ liệu đè lên cảnh vai khác đang nhìn — và trạng thái rỗng
     chết ngay khi có bản ghi đầu tiên.
       Đợt 1 = cần DB SẠCH, đọc là chính.   Đợt 2 = cần DB CÓ DỮ LIỆU, ghi và phá.
     Giữa hai đợt: seed lại (deployment/local/). Tối đa 3 vai một đợt.
     Experience mobile (srcroot/mobile-experiences/): thêm ràng buộc — các vai trong một
     đợt chạy TUẦN TỰ, vì simulator/emulator là MỘT thiết bị dùng chung (viper-mobile §1);
     vẫn hai đợt, vẫn seed giữa đợt.
     Đổi cột này nếu sản phẩm có lý do riêng — ví dụ vai phá của bạn chỉ đọc, cho lên
     đợt 1 cũng được; nhưng đừng dồn quá 3 vai vào một đợt. -->

| Lăng kính | Persona đóng | Đợt |
|---|---|---|
| `viper-user-edge` | persona chính | 1 |
| `viper-user-newbie` | persona chính | 1 |
| `viper-user-picky` | persona chính, một experience + lát token của gói experience đó | 1 |
| `viper-user-rushed` | persona chính | 2 |
| `viper-user-breaker` | persona chính + đánh xuyên ranh giới vai theo ma trận §2 | 2 |
| `viper-user-mobile` | persona chính, viewport theo "Thiết bị chính" | 2 |

<!-- Đa target (đường intake): mỗi experience có persona riêng thì gán theo experience mà
     vòng này chạm tới, không dồn hết vào persona chính của cả hệ thống. -->
