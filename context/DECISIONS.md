---
type: decisions
tier: T1
append_only: true
last_reviewed: "2026-08-17"
---

# DECISIONS — CORE-VIPER

> **Append-only.** Không sửa dòng cũ; quyết định mới đè quyết định cũ thì thêm dòng mới và ghi `thay cho: <ngày>`.
>
> File này **thay thế cho việc hỏi Authority**. Từ pha I trở đi, gặp mơ hồ → chọn phương án hợp lý nhất theo
> `PRD.md` / `ARCHITECTURE.md` / `TECHSTACK.md` → ghi một dòng ở đây → đi tiếp.
> Authority đọc một lượt cuối buổi, không bị ngắt giữa dòng.

**Khi nào phải ghi**: stack, thư viện chính, mô hình dữ liệu, cách tính tiền, auth, cách xử ca biên, đánh đổi hiệu năng, bất cứ thứ gì mà 3 ngày sau nhìn lại sẽ hỏi "sao lúc đó làm thế?".

**Khi nào không cần**: đặt tên biến, chia file, chọn thư viện tiện ích nhỏ đổi lúc nào cũng được.

---

| Ngày | Quyết định | Lý do | Giả định đang mang | Đảo ngược được? |
|---|---|---|---|---|
| (template) | Dùng quy trình VIPER cho dự án này | Sản phẩm nhỏ, solo, cần ra trong 1 tuần để test phản ứng | Phạm vi khoá được trong 2h ở pha V | Có — chuyển sang MESH nếu vượt ngưỡng |
| 2026-08-20 | Stack: Flutter 3.41.9 + `livekit_client` 2.5.3 + `flutter_bloc`, Android only. Không dùng stack skill nào — repo không có skill mobile, đi theo `viper-mobile` §2 | Flutter là nền duy nhất đã sẵn sàng trên máy (fvm, adb, emulator, marionette đều có). Nền khác mất nửa ngày dựng môi trường trước khi viết dòng đầu | Deadline chiều mai; chỉ có 1 máy Android thật + 1 emulator để thử | Khó — đổi nền là viết lại từ đầu |
| 2026-08-20 | Ký token LiveKit **ngay trong app** bằng API secret, chặn sau cờ `KAICALL_ALLOW_INSECURE_LOCAL_TOKEN` | Dựng backend cấp token là thêm một service + một nơi deploy, không kịp trước deadline và không phục vụ AC nào | Demo chỉ chạy trên máy người thử, APK debug không phát hành | Có — thay `TokenProvider` bằng bản gọi backend, phần còn lại không đổi |
| 2026-08-20 | Đổ chuông bằng **data channel của LiveKit qua một "phòng chờ"**, không dùng FCM | Cả hai máy vào phòng chờ khi mở app; A gửi lời mời qua data channel, B hiện màn cuộc gọi đến. Tận dụng đúng thứ đang có, không thêm hạ tầng | Cả hai app phải đang mở — đã cắt "đổ chuông khi app đóng" ở `PRD.md §5` | Có — thay lớp signaling bằng FCM, máy trạng thái cuộc gọi giữ nguyên |
| 2026-08-20 | Bỏ database, bỏ auth, bỏ error tracking | Không có gì cần sống qua lần chạy; mỗi thứ thêm vào là một chỗ có thể vỡ trong ngày cuối | Danh bạ 2 người là đủ để chạy hết 7 AC | Có — thêm về sau không phá gì đang có |
| 2026-08-20 | Cắt iOS khỏi vòng 1 dù muốn làm cả hai nền | Không có thiết bị iOS để thử. Ship thứ chưa từng chạy là ship rủi ro, không phải ship nhanh | Flutter giữ được phần lớn code khi thêm iOS sau | Có — thêm iOS là thêm cấu hình quyền + bản build, logic dùng lại |

<!-- Dòng seed trên cố ý ghi ngày là "(template)" để gate V KHÔNG đếm nó —
     gate đòi ≥2 quyết định có ngày ISO do chính dự án này ghi ra. -->

<!-- Mẫu dòng:
| 2026-08-01 | Xoá mềm thay vì xoá cứng cho đơn hàng | Cần khôi phục khi khách gọi lại; AC-4 nhắc "huỷ nhầm" | Lượng đơn nhỏ, không lo phình bảng trong Phase 1 | Có — đổi sang xoá cứng kèm migration |
| 2026-08-01 | Clerk cho auth thay vì tự viết | Mất 20 phút thay vì 1 ngày; PRD §7 chốt đăng nhập Google | Chấp nhận phụ thuộc bên thứ ba + chi phí khi scale | Khó — đổi provider phải migrate user |
-->
