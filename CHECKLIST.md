# KaiCall — checklist nghiệm thu

Đi một lượt là biết 7 AC ở `context/PRD.md §3` đã xong chưa. Khoảng 15 phút.

**Chuẩn bị hai đầu.** Máy A và máy B phải chọn **hai người khác nhau** ở thẻ
"Máy này là ai?" — cùng một người thì LiveKit đá một máy ra vì trùng identity.

| Đầu | Chọn | Ghi chú |
|---|---|---|
| A | Long | emulator cũng được |
| B | Minh | máy thật thì mới kiểm được tiếng |

Cột **Máy thật?** = ca đó bắt buộc phải có máy Android thật, emulator không thay được.

---

## Luồng chính

| # | AC | Làm gì | Phải thấy gì | Máy thật? | ☐ |
|---|---|---|---|---|---|
| 1 | AC-1 | A bấm nút gọi Minh | B hiện màn "Cuộc gọi đến" + tên **Long**, trong ≤3 giây | | ☐ |
| 2 | AC-2 | B bấm **Nghe** | Hai bên vào cuộc gọi, **thấy hình** nhau | | ☐ |
| 3 | AC-2 | Nói vào máy A | B **nghe được tiếng** | ✔ | ☐ |
| 4 | AC-4 | A bấm **Tắt mic** | Nút đổi màu + chữ thành "Bật mic" ngay; B không nghe thấy nữa | ✔ | ☐ |
| 5 | AC-4 | A bấm **Tắt cam** | B thấy avatar + "Long đã tắt camera" thay cho khung đen | | ☐ |
| 6 | AC-4 | A bấm **Đổi cam** | Hình đổi giữa cam trước / cam sau | ✔ | ☐ |
| 7 | AC-4 | A bấm **Cúp máy** | Cả hai về danh bạ, B thấy báo cuộc gọi kết thúc | | ☐ |

## Từ chối và huỷ

| # | AC | Làm gì | Phải thấy gì | ☐ |
|---|---|---|---|---|
| 8 | AC-3 | A gọi → B bấm **Từ chối** | A hiện "Bị từ chối" rồi tự về danh bạ, **không treo** | ☐ |
| 9 | — | A gọi → A bấm **Huỷ** | B tắt màn cuộc gọi đến, A về danh bạ | ☐ |
| 10 | §7a | A gọi → **để yên 30 giây** | A hiện "Không trả lời" rồi tự về danh bạ | ☐ |
| 11 | §6 | Hai máy bấm gọi nhau **cùng lúc** | Vào thẳng cuộc gọi, **không ai phải bấm Nghe** | ☐ |

## Ca hỏng

| # | AC | Làm gì | Phải thấy gì | ☐ |
|---|---|---|---|---|
| 12 | AC-5 | Gỡ quyền mic trong Cài đặt → mở app → bấm gọi | Màn "Cần quyền" + nút **Mở Cài đặt**. **Không crash, không màn trắng** | ☐ |
| 13 | AC-6 | Đang gọi, **bật chế độ máy bay** ở B | A hiện "Đang kết nối lại…" rồi kết thúc, về danh bạ | ☐ |
| 14 | AC-6 | Đang gọi, **giết app** ở B | A biết bên kia đã rời, về danh bạ — **không ngồi chờ mãi** | ☐ |
| 15 | AC-7 | Đang gọi, A bấm **Home** rồi quay lại sau ~20 giây | Vẫn đang trong cuộc gọi, tiếng vẫn thông | ☐ |
| 16 | AC-7 | Đang gọi, A **vuốt tắt app** | B thấy cuộc gọi kết thúc **ngay**, không treo màn chờ | ☐ |
| 17 | — | Sửa `KAICALL_LIVEKIT_API_KEY` thành rỗng rồi `make dev` | Màn chặn S0 nói rõ thiếu biến nào | ☐ |
| 18 | AC-5 | Gỡ quyền mic/cam ở **B** → mở app B → A gọi → B bấm **Nghe** | B hiện hộp thoại quyền hệ thống; cấp xong thì **vào được cuộc gọi**. Bỏ mặc hộp thoại thì A phải về "Không trả lời" sau 30 giây, **không đứng mãi** | ☐ |

Ca 18 khác ca 12: ca 12 thiếu quyền ở **máy gọi**, chặn ngay trước khi gọi. Ca
18 thiếu quyền ở **máy nhận** — app vẫn gọi được, chuông vẫn reo, chỉ chết lúc
bấm Nghe. Đây đúng là lỗi đã ăn mất một buổi ngày 2026-08-21 (`STATE.md §Blocker`),
nên đừng bỏ.

---

## Chấm điểm

**Success metric** (`PRD.md §6`): chạy trọn **7/7 AC** mà **không lần nào phải khởi
động lại app**.

- 18/18 dòng xanh → đạt, nghiệm thu được
- Dòng nào đỏ → ghi vào `STATE.md §Phát hiện từ dogfood chưa xử`, sửa rồi chạy lại

Ca 3, 4, 6 cần máy thật. Chưa có máy thì bỏ qua ba dòng đó và ghi rõ là **chưa
kiểm**, đừng đánh dấu xanh — success metric tính theo cái đã thật sự thử.
