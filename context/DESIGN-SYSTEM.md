---
type: design-system
tier: T0
status: DRAFT
last_reviewed: "2026-08-17"
---

# DESIGN SYSTEM — CORE-VIPER

> **Nguồn sự thật cho hình thức** — ngang vai với `ARCHITECTURE.md` cho backend và
> `PROTOTYPE.md` cho kiến trúc thông tin.
> Điền ở pha V, SAU khi viết context, **TRƯỚC khi dựng prototype** (`PROTOTYPE.md §4`).
>
> **Vì sao trước prototype, không phải sau.** Dựng prototype trước rồi mới rút token ra thì
> token chỉ là bản mô tả những màu đã lỡ chọn — mỗi màn một sắc xám khác nhau, chữ phụ không
> đọc nổi, pha I phải đoán lại. Quyết thang màu/chữ/nhịp trước thì prototype chỉ còn là việc
> lắp component, và Authority bấm thử đúng thứ sẽ lên production.
>
> **Có gói design system từ intake** (`intake/design-systems/<ds>/tokens.json`) thì file này
> là **bản dịch trung thành của gói đó**, không phải chỗ chọn lại: không bịa token mới, không
> bỏ rơi token của gói, không đổi giá trị. Hook `scripts/guard_ds.py` chặn ngay lúc ghi file
> và `gate.py V` đối chiếu lại toàn bộ. Cần token mới thật sự → hỏi Authority (đang pha V)
> rồi ghi 1 dòng `DECISIONS.md`.

<!-- DỰ ÁN KHÔNG CÓ GIAO DIỆN NGƯỜI DÙNG (API thuần / CLI / worker):
     `PROTOTYPE.md` đã mang marker `KHÔNG CÓ UI` thì gate bỏ qua luôn file này.
     Xoá toàn bộ nội dung từ §1 trở xuống, thay bằng đúng một dòng:

         KHÔNG CÓ UI — bỏ qua design system

     để file không nằm lại với khung rỗng gây hiểu nhầm. -->

---

## 0. Sản phẩm này có mấy design system

**Một** — mặc định, và là trường hợp của cả đường phỏng vấn. Không phải khai gì thêm;
mọi bảng dưới đây không cần cột `DS`.

**Nhiều** — hệ lớn ở đường intake có thể mặc nhiều gói (`intake/design-systems/<ds>/`),
ví dụ màn quản trị nội bộ và app cho khách hàng không dùng chung bảng màu. Khi đó:

1. **Ánh xạ experience → gói nằm ở [`ARCHITECTURE.md §2–§3`](ARCHITECTURE.md), cột
   `Design system`** — nguồn DUY NHẤT. Đừng chép bảng ánh xạ vào đây: hai bảng song
   song thì sớm muộn cũng lệch nhau mà không ai hay.
2. **Mọi bảng ở §2 · §3 · §4 phải thêm cột cuối `DS`**, giá trị là tên thư mục gói.
   Hai gói cùng khai `--color-primary` khác giá trị thì thành **hai dòng riêng** — đó
   là lý do có cột này, chứ không phải để trang trí.
3. `prototype/<experience>/index.html` **chỉ được dùng token của gói mình**. Mượn token
   gói khác là *trộn design system*: hook `guard_ds.py` chặn lúc ghi, `gate.py V` báo đỏ,
   và vai `viper-user-picky` bắt lại trên app đã chạy khi dogfood.

<!-- Bỏ trống ô DS trong khi dự án có nhiều gói → gate V đỏ ("token chưa khai thuộc
     design system nào"). Fail-closed có chủ đích: đối chiếu sai địa chỉ còn tệ hơn
     không đối chiếu. -->

---

## 1. Ba tính từ + neo tham chiếu

<!-- Ba tính từ lấy từ "giọng thương hiệu" đã hỏi ở INTERVIEW mục 11 và 13. Chúng là thứ để
     cãi nhau khi phân vân giữa hai phương án — "cái nào 'gọn' hơn?" quyết nhanh hơn "cái nào
     đẹp hơn?". Kèm 1–2 neo tham chiếu THẬT (sản phẩm Authority đang dùng và thấy dễ nhìn),
     vì tính từ một mình vẫn quá rộng.

     Ví dụ: Gọn · Rõ trong nắng · Không màu mè
            Neo: giao diện Zalo (chữ to, ít màu) — Authority đang dùng hằng ngày
            Tránh: dashboard nhiều biểu đồ kiểu Google Analytics — "nhìn là ngợp" -->

| Mục | Nội dung |
|---|---|
| Ba tính từ | **quen thuộc · rõ ràng · bình tĩnh** |
| Neo tham chiếu (thật) | **App gọi điện mặc định của Android** (danh bạ → bấm gọi → màn cuộc gọi đến) và **Zalo, chỉ phần call** — hai app Authority dùng hằng ngày, nêu ra ở phỏng vấn mục 13 làm chuẩn "trông giống app thật" |
| Cố tình tránh | Sáng tạo lại bố cục cuộc gọi — nút cúp máy phải tròn đỏ ở dưới, nút nghe tròn xanh, đúng chỗ mắt quen tìm. Tránh nền sáng ở màn cuộc gọi (chói khi gọi buổi tối, và video chìm). Tránh chữ mảnh, xám nhạt, icon không kèm nhãn |

## 2. Token

> Đây là **toàn bộ** bảng màu / thang chữ / nhịp của sản phẩm. Giá trị nào không nằm ở đây thì
> không được xuất hiện trong prototype lẫn code — hết đường "thêm một sắc xám nữa cho đẹp".
>
> Token khai ở đây mà prototype **không dùng** sẽ làm gate đỏ: hoặc dùng nó, hoặc **xoá dòng đó
> đi**. Bảng dưới là bộ khởi động tối thiểu, không phải hạn ngạch phải điền cho đủ.
>
> **Nhiều design system** (§0): thêm cột cuối `DS` vào cả ba bảng dưới, giá trị là tên thư mục
> gói. Một design system thì bỏ qua — không cần cột.

### 2.1 Màu

<!-- Semantic, không đặt tên theo màu: `--color-danger`, không phải `--color-red` — đổi đỏ sang
     cam thì tên vẫn đúng. Giá trị ghi mã hex, gate §3 đọc đúng ô này để tính tương phản.

     Ví dụ:  | `--color-text` | `#1A1A1A` | chữ chính | -->

| Token | Giá trị | Dùng cho |
|---|---|---|
| `--color-bg` | `#0E1116` | nền trang |
| `--color-surface` | `#1A1F27` | nền thẻ / hàng danh sách nổi trên nền trang |
| `--color-text` | `#F2F5F9` | chữ chính |
| `--color-text-muted` | `#9CA9BC` | chữ phụ, nhãn, chú thích |
| `--color-primary` | `#25C05C` | hành động chính — nút Gọi và nút Nghe |
| `--color-on-primary` | `#06210F` | chữ / icon nằm TRÊN nền `--color-primary` |
| `--color-border` | `#606E80` | viền, đường kẻ chia, viền nút phụ |
| `--color-danger` | `#FF6B6B` | lỗi, và **nút Cúp máy / Từ chối** |

### 2.2 Chữ

<!-- Một họ chữ. Thang cỡ 3–4 bậc là đủ cho một tuần — nhiều bậc hơn chỉ tạo chỗ để phân vân.
     Ví dụ:  | `--text-base` | `16px` | chữ thường trong nội dung | -->

| Token | Giá trị | Dùng cho |
|---|---|---|
| `--font-sans` | `system-ui, -apple-system, Roboto, sans-serif` | họ chữ duy nhất — font hệ thống, không tải, không nháy chữ |
| `--text-sm` | `14px` | chú thích, nhãn dưới icon |
| `--text-base` | `17px` | chữ thường — to hơn mặc định vì cầm tay, đọc bằng liếc |
| `--text-xl` | `28px` | tên người trên màn cuộc gọi đến / đang gọi |

### 2.3 Nhịp · bo góc · đổ bóng

<!-- Thang khoảng cách theo bội số cố định (4 hoặc 8). Mọi padding/margin lấy từ đây — đây là
     thứ làm giao diện "trông có kỷ luật" mà không cần ai biết vì sao. -->

| Token | Giá trị | Dùng cho |
|---|---|---|
| `--space-sm` | `8px` | khoảng hẹp trong một khối |
| `--space-md` | `16px` | khoảng chuẩn giữa các khối |
| `--space-lg` | `32px` | khoảng giữa các vùng lớn của màn hình |
| `--radius` | `14px` | bo góc thẻ và nút chữ nhật. Nút tròn (gọi/nghe/cúp) dùng bo tròn hoàn toàn, không qua token này |
| `--shadow` | `0 2px 8px rgba(0,0,0,0.45)` | đổ bóng thẻ nổi — một mức duy nhất |

### 2.4 Điểm gãy

<!-- CSS media query KHÔNG dùng được var(), nên breakpoint viết số thật trong @media và ghi
     ở đây để tra. Cố tình không đặt dạng `--token` để gate không đòi nó xuất hiện trong prototype.
     Mặc định: một điểm gãy là đủ. Thiết bị chính của persona (`PERSONAS.md §1`) quyết định
     thiết kế cho bên nào trước. -->

| Điểm gãy | Giá trị | Thiết kế trước cho |
|---|---|---|
| hẹp → rộng | `600px` | **điện thoại trước** — persona cầm Android một tay. Trên 600px chỉ giới hạn bề rộng nội dung và canh giữa, không đổi bố cục |

## 3. Tương phản — `gate.py V` tự tính

<!-- Đây là chỗ MVP một tuần hay chết: chữ xám nhạt trên nền trắng, nhìn trên màn hình đẹp
     trong phòng thì ổn, ra nắng hoặc trên điện thoại rẻ là không đọc được. Không cần công cụ
     ngoài — gate đọc mã hex ở §2.1, tự tính tỉ lệ tương phản và báo đỏ nếu chưa đạt.

     Ngưỡng WCAG AA:  chữ thường ≥ 4.5:1 · chữ lớn (≥24px, hoặc ≥19px in đậm) ≥ 3:1
                      thành phần giao diện (viền input, icon) ≥ 3:1
     Cột "Loại" nhận đúng ba giá trị: thường · lớn · thành phần.
     Thêm cặp nào cũng được, miễn hai ô giữa là tên token có ở §2.1. Cặp nào không áp dụng
     cho sản phẩm (vd không có input) thì xoá dòng — nhưng phải còn ít nhất một cặp.

     NHIỀU DESIGN SYSTEM (§0): thêm cột cuối `DS`. Mỗi gói phải có bộ cặp của riêng nó —
     chữ của gói A trên nền của gói B là cặp không tồn tại trên màn nào, gate giải token
     trong đúng lát của gói nên cặp lai sẽ đỏ ở mục "không tính được". -->

| Cặp | Token chữ / tiền cảnh | Token nền | Loại |
|---|---|---|---|
| Chữ chính trên nền trang | `--color-text` | `--color-bg` | thường |
| Chữ phụ trên nền thẻ | `--color-text-muted` | `--color-surface` | thường |
| Chữ trên nút chính | `--color-on-primary` | `--color-primary` | thường |
| Chữ lỗi trên nền trang | `--color-danger` | `--color-bg` | thường |
| Viền input trên nền trang | `--color-border` | `--color-bg` | thành phần |

## 4. Kho component

<!-- Danh sách ĐÓNG các khối được phép dùng. Prototype và pha I lắp từ đây; cần khối mới thì
     thêm vào bảng này trước, không vẽ thẳng vào màn hình.

     Cột "Dùng ở màn" trỏ tới mã màn hình ở `PROTOTYPE.md §1` (S1, S2…) — gate đòi mỗi
     component phải có ít nhất một màn dùng nó. Component không màn nào dùng là component
     tưởng tượng, xoá đi.

     Cột "Trạng thái bắt buộc" là thứ hay bị quên nhất: nút không có trạng thái "đang gửi" thì
     người dùng bấm hai lần, và đó chính là ca biên đã chốt ở `ARCHITECTURE.md §6`.
     Đây cũng là bảng vai dogfood `viper-user-picky` cầm đi soi trên app đã chạy.

     NHIỀU DESIGN SYSTEM (§0): thêm cột cuối `DS`. Component của gói A mà lại dùng ở màn
     thuộc experience mặc gói B → gate in cảnh báo (không đỏ, vì màn thuộc experience nào
     chỉ suy được từ file prototype nào chứa mã màn — suy đoán thì không đủ chắc để chặn). -->

| # | Component | Dùng ở màn | Trạng thái bắt buộc |
|---|---|---|---|
| C1 | Nút tròn hành động (gọi · nghe · từ chối · cúp máy) | S1, S2, S3, S4 | mặc định · đang xử lý (khoá lại, không bấm được lần hai) · bị vô hiệu (chưa kết nối được máy chủ) |
| C3 | Hàng danh bạ — avatar + tên + nút gọi | S1 | mặc định · đang nhấn · bị vô hiệu |
| C5 | Khối báo lỗi / màn chặn | S0, S5 | nói rõ hỏng gì và làm gì tiếp · có đường đi tiếp (nút mở Cài đặt, hoặc nút Thử lại) |
| C6 | Banner trạng thái kết nối | S3, S4 | đang kết nối · đang kết nối lại (đếm giây) · đã kết thúc |
| C7 | Ô video người tham gia | S4 | có hình · tắt cam (hiện avatar + tên) · đang chờ người kia vào |
| C8 | Hàng nút điều khiển trong cuộc gọi | S4 | mic bật/tắt · cam bật/tắt · đổi cam · cúp máy — mỗi nút có nhãn chữ dưới icon |

`C2` (trường nhập) và `C4` (trạng thái rỗng) **cố tình không có**: app không có ô nhập nào —
danh bạ cắm cứng, không tìm kiếm, không nhập tên phòng — và danh bạ luôn có 2 người nên
không tồn tại màn rỗng. Xoá khỏi kho thay vì để dòng trống, theo đúng ghi chú "component
không màn nào dùng là component tưởng tượng".

<!-- Thêm C6, C7… nếu bản đồ màn hình cần. Ít hơn 5 khối cũng được — xoá dòng không dùng. -->

## 5. Ba khuôn trạng thái dùng chung

<!-- Nội dung cụ thể của từng màn nằm ở `PROTOTYPE.md §1` (cột "Rỗng / lỗi / đang tải").
     Ở đây chỉ chốt KHUÔN — hình dạng chung, để năm màn hình không sinh ra năm kiểu báo lỗi. -->

| Khuôn | Chốt |
|---|---|
| Rỗng | Không có màn rỗng thật (danh bạ luôn 2 người). Khuôn duy nhất thuộc loại này: **ô video khi người kia tắt cam** → avatar tròn lớn + tên ở giữa ô, nền `--color-surface`, không để khung đen trơn |
| Lỗi | Tiếng Việt, một câu nói **hỏng gì**, một câu nói **làm gì tiếp**, và đúng một nút hành động. Không hiện mã lỗi kỹ thuật lên UI (log ra `adb logcat` cho dev). Không bao giờ để màn trắng hay treo im — mọi nhánh lỗi phải kết thúc ở một màn có nút bấm được |
| Đang tải | Ô video giữ đúng kích thước sẵn với avatar bên trong, video hiện lên thì thay tại chỗ — **không nhảy layout**. Chờ kết nối thì banner ở đỉnh màn hình, không phủ vòng xoay toàn màn (che mất nút Huỷ / Cúp máy là ca hỏng thật) |

## 6. Ràng buộc thực thi

Bốn ràng buộc này là thứ biến file trên thành hiệu lực thật, không phải bảng trang trí:

1. **`prototype/index.html` khai đúng token ở §2 trong `:root` và dùng qua `var(--…)`.**
   `gate.py V` đối chiếu từng token: khai mà không dùng → đỏ. Không hardcode màu/cỡ chữ trong
   prototype.
2. **Pha I dùng lại chính bảng token này** — đổ vào biến CSS, `tailwind.config`, hay theme của
   stack đang dùng (`TECHSTACK.md`), tuỳ stack. UI code không được đẻ ra giá trị mới.
   Nhiều design system (§0) → mỗi experience đổ **đúng lát token của gói mình**, không đổ cả
   bảng vào một theme dùng chung: gộp lại là mở đường cho việc mượn token gói khác.
3. **Đổi token sau khi Authority đã chốt prototype** → 1 dòng `DECISIONS.md` (luật #3). Token là
   thứ Authority đã bấm thử và chốt, không phải chi tiết nội bộ của người code.
4. **Từ pha I trở đi, thứ canh design system là dogfood, không phải hook.** `guard_ds.py` chỉ
   soi `prototype/**` và file này; code trong `srcroot/` thì mỗi stack một kiểu (Tailwind,
   CSS-in-JS…) nên bắt "mã màu thô" ở đó sẽ báo oan. Vai `viper-user-picky` (`/viper-dogfood`)
   đo trên **app đã render** — đúng với mọi stack, và là chỗ duy nhất chứng minh được pha I có
   thật sự dùng lại bảng token hay không.

## 7. Change log

| Ngày | Thay đổi | Lý do |
|---|---|---|
| 2026-08-17 | Tạo từ template VIPER | — |
