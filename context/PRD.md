---
type: prd
tier: T0
status: DRAFT
last_reviewed: "2026-08-17"
---

# PRD — CORE-VIPER

> **Mô tả sản phẩm ở lát cắt của VÒNG HIỆN TẠI.** Điền ở pha V. Sau khi khoá scope, file này là nguồn sự thật cho mọi quyết định của agent.
> Cấu trúc §1–§6 lấy theo `intake/_PRD-TEMPLATE.md` để hai đường vào dùng chung một khung.

---

## 1. Pain point

Lần dựng LiveKit trước tốn khoảng một buổi sáng và dừng đúng ở chỗ "hai người nhìn thấy
nhau" — đủ để biết bộ thông tin kết nối dùng được, rồi bỏ đó. Không test, không xử ca biên,
không có luồng giao diện: bấm trúng chỗ nào là hỏng chỗ đó, và không dùng lại được cho việc
sau. Cái đau không nằm ở người dùng cuối mà ở người viết code — một bản "chạy được" không
tin được thì mỗi lần cần call lại phải dựng lại từ đầu.

<!-- Một đoạn. Vấn đề CỤ THỂ đang làm ai đó khó chịu, mất thời gian, hoặc mất tiền.
     Không viết "chưa có giải pháp tốt" — viết cái đau thật, kèm bằng chứng nếu có.
     Ví dụ: "Chủ gara nhỏ ghi lịch hẹn sửa xe bằng sổ giấy và Zalo. Trùng lịch 2-3 lần/tuần,
     mỗi lần mất khoảng 1 giờ gọi lại khách và xếp lại thợ."
     Đường intake: giữ nguyên ý của intake/PRD.md §1, KHÔNG paraphrase. -->

## 2. Đối tượng

Người thử demo: Authority và tech lead ngồi cạnh nghiệm thu, bấm trực tiếp trên máy. Thiết bị
là điện thoại Android cầm tay, thao tác bằng một ngón cái. Họ biết rõ app làm gì, nên không
cần onboarding — nhưng chính vì biết rõ nên sẽ đi tìm chỗ vỡ: từ chối quyền, rớt mạng, thoát
giữa chừng. Hai bên trong cuộc gọi ngang vai, không ai có quyền gì hơn ai.

<!-- CỤ THỂ, không phải "người dùng nói chung". Ai? Bao nhiêu người kiểu này? Họ đang xoay xở bằng gì?
     Ví dụ: "Chủ gara 3-10 thợ ở TP lớn. Hiện dùng sổ giấy + Zalo. Không có nhân viên IT."
     Đường intake: tóm tắt từ intake/PRD.md §2, giữ mã P-… -->

Chân dung chi tiết + năng lực từng vai + ma trận phân quyền: `context/PERSONAS.md`.

## 3. Tiêu chí chấp nhận (AC) — vòng này

<!-- Làm được những cái này thì coi như xong vòng hiện tại. Viết theo góc nhìn người dùng,
     quan sát được. Đánh số AC-1..AC-n — agent tham chiếu số này trong DECISIONS và test.

     SỐ LƯỢNG khác nhau theo đường vào (VIPER.md §1.3):
     · Đường phỏng vấn — 3 đến 7. Nhiều hơn 7 là scope quá lớn cho một tuần, gate V báo đỏ.
     · Đường intake   — không có trần. Đổi lại mỗi AC phải điền cột "Capability" và mã đó
       phải có mặt trong CAPABILITIES-MAP.md; gate V kiểm truy vết này thay cho trần số.

     Cột "Capability": đường phỏng vấn để trống. -->

| # | Làm được gì | Coi là xong khi | Capability |
|---|---|---|---|
| AC-1 | Mở app thấy danh bạ 2 người, bấm một người để gọi | Máy bên kia hiện màn "cuộc gọi đến" kèm tên người gọi trong vòng 3 giây | |
| AC-2 | Bấm **Nghe** để vào cuộc gọi | Hai bên thấy hình nhau và nghe được tiếng nhau | |
| AC-3 | Bấm **Từ chối** để khước từ | Máy gọi hiện "bị từ chối" rồi tự về danh bạ, không màn nào treo | |
| AC-4 | Điều khiển trong cuộc gọi: tắt/bật mic, tắt/bật cam, đổi cam trước-sau, cúp máy | Mỗi nút phản hồi thấy được ngay trên màn hình, và bên kia thấy đúng trạng thái đó | |
| AC-5 | Từ chối quyền mic hoặc camera | Hiện màn giải thích + nút mở Cài đặt hệ thống; không crash, không màn trắng | |
| AC-6 | Một bên rớt mạng hoặc thoát đột ngột | Bên kia hiện trạng thái rõ ràng trong vài giây rồi về danh bạ | |
| AC-7 | Đang gọi mà chuyển sang background, rồi thoát hẳn app | Ở background tiếng vẫn thông, quay lại vẫn đang trong cuộc gọi; thoát hẳn thì cuộc gọi kết thúc gọn ở **cả hai** máy | |

<!-- Dòng AC trống không được gate đếm — điền đủ ô "Làm được gì" hoặc xoá dòng thừa. -->

## 4. Ưu tiên — vòng này giao gì, phần còn lại nằm đâu

<!-- Đường phỏng vấn: một dòng — "Vòng 1 giao toàn bộ AC ở §3; phần khác ở ROADMAP.md §3 backlog".
     Đường intake: một đoạn ngắn nói rõ vòng này là lát cắt nào của hệ thống (thường = một
     wave của intake/ROADMAP.md), vì sao lát này trước. Bản đồ đầy đủ ở CAPABILITIES-MAP.md,
     kế hoạch chia vòng ở ROADMAP.md §1. -->

Vòng 1 giao toàn bộ AC ở §3; phần còn lại nằm ở `ROADMAP.md §3` backlog.

## 5. Out-of-scope — chắc chắn KHÔNG làm ở vòng này

<!-- Đây là phần quan trọng nhất của scope-lock. Liệt kê tường minh những thứ dễ bị cuốn vào làm.
     Mọi thứ ở đây, nếu sau này thấy cần, đi thẳng vào ROADMAP.md — không chèn vào vòng này. -->

- **iOS** — không có thiết bị để thử. Ship thứ chưa từng chạy là ship rủi ro, không phải ship nhanh.
- **Push / đổ chuông khi app đóng hoặc máy khoá** — cần FCM + ConnectionService, một mình nó đã hơn một ngày.
- **Backend cấp token** — ký token ngay trong app, có cờ chặn. Xem §7 và `ARCHITECTURE.md §9`.
- **Đăng ký / đăng nhập / tài khoản thật**
- **Danh bạ thật, trạng thái online, tìm kiếm người dùng**
- **Cuộc gọi nhóm >2 người**
- **Lịch sử cuộc gọi, nhật ký, thống kê**
- **Chat, gửi file, chia sẻ màn hình**

## 6. Giả thuyết + success metric

**Giả thuyết**: một demo call đi trọn luồng như app thật — có màn cuộc gọi đến, có xử ca biên —
thì dùng lại được cho việc sau; còn bản "connect cho chạy" thì không.

**Success metric**: chạy trọn **7/7 AC** trên cặp máy Android thật + emulator mà **không lần nào
phải khởi động lại app**. 7/7 → nghiệm thu đạt. 5–6/7 → còn nợ, sửa tiếp trong vòng này.
Dưới 5/7 → luồng sai chỗ nào đó cơ bản, quay lại `ARCHITECTURE.md §3` xem lại máy trạng thái
cuộc gọi trước khi sửa tiếp.

<!-- MỘT con số, đo được, có ngưỡng quyết định. Đây là căn cứ go/pivot/kill ở pha R.
     Ví dụ: "≥10 gara tạo lịch hẹn thật trong 5 ngày đầu. <5 → kill. 5-9 → pivot cách tiếp cận."

     Đường intake: chọn MỘT giả thuyết đo được từ intake/PRD.md §6 làm metric; các giả thuyết
     còn lại vào sổ EXPERIMENTS của vòng. Vòng KHÔNG chạy pha E (theo _PROPOSAL.md) thì ghi
     "vòng này không đo — tiêu chí xong là AC §3" và nói rõ vòng nào sẽ đo. -->

---

## 7. Quyết định đã chốt ở pha V

<!-- Chốt luôn ở đây để agent không phải hỏi lại. Thiếu mục nào, agent tự quyết + ghi DECISIONS.md.
     Đây là thứ giữ luật #2 đứng được: sau khoá scope không hỏi nữa, nên chỗ hay phải hỏi
     nhất phải có câu trả lời sẵn ngay tại đây. -->

| Hạng mục | Chốt |
|---|---|
| Đăng nhập | Không cần — danh bạ mock 2 người cắm cứng, chọn danh tính bằng cách bấm |
| Thu tiền | Không |
| Mô hình dữ liệu lõi | Không có DB. Trong bộ nhớ: `Contact` (2 bản ghi cứng) · `CallInvite` (người gọi, người nhận, tên phòng) · `CallSession` (phòng, trạng thái, người tham gia, cờ mic/cam) |
| Ca biên phải xử | Gọi khi người kia chưa mở app · hai bên bấm gọi nhau **cùng lúc** · bấm Nghe khi bên gọi đã cúp · từ chối quyền mic/cam · rớt mạng giữa cuộc · đối phương thoát đột ngột · background rồi quay lại · thoát hẳn app khi đang gọi |
| Trạng thái rỗng | Danh bạ luôn có 2 người nên không có màn rỗng thật. Trong cuộc gọi, chưa ai bật cam → hiện avatar + tên thay cho khung đen |
| Trạng thái lỗi | Thiếu cấu hình LiveKit → màn chặn nói rõ thiếu biến nào · từ chối quyền → màn giải thích + nút mở Cài đặt · mất mạng → banner "đang kết nối lại" đếm giây, quá ngưỡng thì kết thúc và về danh bạ · bị từ chối → thông báo ngắn rồi về danh bạ |
| Dữ liệu mẫu | 2 liên hệ hằng số trong source, không seed, không file |
| Tên / domain / giọng | **KaiCall** · không domain · giọng ngắn và thẳng, chữ trên nút là động từ ("Gọi", "Nghe", "Từ chối", "Cúp máy"), không thuật ngữ kỹ thuật trên UI |
| Nơi deploy | Không deploy — sản phẩm là APK debug cài thẳng vào 1 máy Android thật + 1 emulator, nghiệm thu tại chỗ |

## 8. Nguồn

<!-- Đường phỏng vấn: `context/INTERVIEW.md` (14 mục có bằng chứng).
     Đường intake: liệt kê file intake đã dịch — bảng truy vết đầy đủ ở INTERVIEW.md;
     vòng ≥2 thêm `intake/loops/l<N>/_PROPOSAL.md` + tài liệu Authority thả thêm. -->

- `context/INTERVIEW.md` — sổ phỏng vấn vòng 1, 14 mục có bằng chứng (2026-08-20)

---

## 9. Change log

| Ngày | Thay đổi | Lý do |
|---|---|---|
| 2026-08-17 | Tạo từ template VIPER | — |
