---
type: interview
tier: T1
status: DRAFT
last_reviewed: "2026-08-17"
---

# INTERVIEW — CORE-VIPER

> **Sổ phỏng vấn pha V của VÒNG 1 — ghi NGAY trong lúc hỏi, không ghi hồi tưởng.** PRD là
> bản nén; sổ này giữ nguyên liệu thô để chi tiết không bị mất ngay lúc nén.
> Mỗi mục phải có dòng `Bằng chứng:` không rỗng — `python3 scripts/gate.py V` kiểm đúng 14 dòng này.
>
> **Đường intake vòng 1** (`VIPER.md §1.3`): không phỏng vấn — xoá 14 mục dưới, thay bằng dòng đầu
> `NGUỒN: INTAKE — render nhận ngày <ISO>` (ngoài comment) + `## Truy vết intake → context`
> + `## Lỗ hổng & cách xử`. Gate V khi đó kiểm bộ intake thay cho 14 dòng bằng chứng —
> xem `/viper-validate` mục "Đường intake".
>
> **Từ vòng 2 file này ĐÓNG BĂNG** — hiện vật của vòng 1, không sửa, gate không đọc nữa.
> Phỏng vấn là công cụ mở rộng tư duy lúc khởi đầu; nguồn của vòng ≥2 nằm ở `intake/loops/l<N>/`:
> đường phỏng vấn là tài liệu vòng Authority thả, đường intake là `_PROPOSAL.md` — kế hoạch
> vòng lập sẵn từ vòng 1 (xem `VIPER.md §1.3–§1.4`).
>
> **Marker `NGUỒN: INTAKE` là thứ quyết định chế độ của cả dự án**, không riêng vòng 1: nó ở
> lại đây khi file đóng băng, và `gate.py` / `/viper-implement` đọc nó để biết đang đi đường
> nào. Đừng xoá marker ở vòng sau — xoá là dự án tự rơi về luật của đường phỏng vấn.

<!-- BẰNG CHỨNG là gì: một CÂU CHUYỆN THẬT đã xảy ra (kèm thời điểm), một CON SỐ
     (tần suất, chi phí, số người), hoặc một HIỆN VẬT (ảnh cuốn sổ, file Excel đang dùng,
     tin nhắn Zalo). Diễn đạt lại câu trả lời KHÔNG phải bằng chứng.
     Với mục thuần quyết định (đăng nhập, tên/domain, deploy): Bằng chứng = ràng buộc thật
     khiến chọn phương án đó ("đội chỉ có tài khoản Vercel", "khách quen đăng nhập Google").

     Ví dụ mục 1:
     Trả lời: Chủ gara ghi lịch bằng sổ giấy + Zalo, trùng lịch thường xuyên
     Bằng chứng: "Thứ 3 tuần trước 2 khách cùng đặt 9h sáng, mất gần 1 tiếng gọi xếp lại" —
                 trùng 2-3 lần/tuần, mỗi lần ~1 giờ; đã xem ảnh cuốn sổ thật
-->

## 1. Pain point

Trả lời: Đã dựng LiveKit call một lần, nhưng chỉ tới mức "cho nó chạy": nhập tên phòng,
connect, hai người nhìn thấy nhau — rồi dừng. Mục đích lần đó chỉ là kiểm xem bộ thông tin
kết nối (server URL / key / secret) dùng được không, nên dừng ngay khi thấy hình là đủ.
Hệ quả: không test, không xử ca biên, không có luồng giao diện hợp lý. Lần này muốn làm lại
cho tử tế — **dù chỉ là demo call, vẫn phải đi thành luồng như một app thật, không tạm bợ**.
Nỗi đau nằm ở người viết code, không ở người dùng cuối: bản "chạy được" không dùng lại được,
không tin được, và không biết nó hỏng chỗ nào cho tới lúc bấm trúng.

Bằng chứng: Lần dựng trước tốn khoảng **một buổi sáng**, nhờ AI làm. Kết quả dừng đúng ở
"hai người nhìn thấy nhau" — chưa viết test nào, chưa thử ca biên nào (rớt mạng, từ chối
quyền, người kia thoát), chưa có màn hình nào ngoài chỗ nhập tên phòng.

## 2. Persona + năng lực được cấp

Trả lời: Một loại người dùng duy nhất: **người thử demo** — chính Authority và tech lead ngồi cạnh
nghiệm thu. Hai bên trong cuộc gọi **ngang vai tuyệt đối**: không ai đuổi được ai, không ai
tắt mic người khác, không khoá phòng. Ai bấm gọi trước thì là bên gọi, chỉ khác nhau đúng ở
màn hình đang đứng, không khác về quyền. Tech lead KHÔNG phải một vai trong app — họ là người
nghiệm thu, ngồi ngoài. Vì không có phân vai nên không có ma trận quyền để thử A↛B.

Bằng chứng: Authority nói nguyên văn khi được hỏi về quyền: "t nghĩ là không". Bối cảnh nghiệm thu:
"Tech lead ngồi vs t để kiểm tra nhưng mà trước đó t cx phải ngồi tự làm với 1 2 thiết bị".

## 3. Tiêu chí chấp nhận (AC)

Trả lời: 7 AC, xem `PRD.md §3`. Lõi: danh bạ 2 người → bấm gọi → máy kia hiện màn cuộc gọi đến →
Nghe/Từ chối → cuộc gọi có hình và tiếng → điều khiển mic/cam/đổi cam/cúp máy → xử được
từ chối quyền, rớt mạng, đối phương thoát, và chuyển sang background.

Bằng chứng: Chốt từ câu "làm demo tử tế nhìn ok có luồng chứ k hẳn phải xây dựng cả 1 đội", cộng ca
background Authority nêu thêm: "gọi xong thoát nhảy sang background thì nó sao". Authority
không chốt danh sách mà giao: "cứ chạy đi sai đâu thiếu đâu chưa ưng ở đâu sửa thêm ở đó".

## 4. Out-of-scope

Trả lời: Cắt tường minh: **iOS** (không có thiết bị thử) · **push / đổ chuông khi app đóng hoặc máy
khoá** (cần FCM + ConnectionService) · **backend cấp token** (ký ngay trong app, có cờ chặn) ·
**đăng ký / đăng nhập** · **danh bạ thật, trạng thái online** · **cuộc gọi nhóm >2 người** ·
**lịch sử cuộc gọi** · **chat**. Tất cả đẩy `ROADMAP.md §3`.

Bằng chứng: Ràng buộc thật ép cắt: deadline **chiều mai** (Authority: "deadline ngày mai là buôri chièu
chúng ta k còn nhiều thời gian đâu") và chỉ có **1 máy Android** để thử. iOS bị cắt vì không
test được — ship thứ chưa từng chạy là ship rủi ro.

## 5. Success metric

Trả lời: Chạy trọn **7/7 AC** trên cặp máy Android thật + emulator mà **không lần nào phải khởi động
lại app**. Dưới 7/7 → còn nợ, sửa tiếp; đúng 7/7 → demo được nghiệm thu.

Bằng chứng: Ngưỡng lấy từ chính nỗi đau lần trước: bản cũ dừng ở "hai người nhìn thấy nhau", chưa ca
biên nào được thử. Con số 7 là số AC đã chốt; ràng buộc "không phải khởi động lại" đến từ yêu
cầu "thành luồng như 1 app thật k tạm bợ".

## 6. Đăng nhập

Trả lời: Không có. Danh bạ mock 2 người cắm cứng trong code, chọn danh tính bằng cách bấm, không
mật khẩu, không tài khoản.

Bằng chứng: Ràng buộc thật: demo chạy trong một buổi, không có backend, và Authority chốt "tạo mock
danh bạ có 2 cái gọi thì chúng ta set up 2 cái đó rồi ấn thôi".

## 7. Thu tiền

Trả lời: Không. Không có bất kỳ luồng thanh toán nào.

Bằng chứng: Ràng buộc thật: đây là demo kỹ thuật để nghiệm thu nội bộ, không có người mua.

## 8. Mô hình dữ liệu + ca biên

Trả lời: Không có database. Ba thực thể sống trong bộ nhớ: **Contact** (id, tên, avatar — 2 bản ghi
cứng), **CallInvite** (người gọi, người nhận, tên phòng, thời điểm), **CallSession** (phòng,
trạng thái, danh sách người tham gia, cờ mic/cam).

Ca biên phải xử: bấm gọi khi người kia chưa mở app · hai bên bấm gọi nhau **cùng lúc** ·
bấm Nghe khi bên gọi đã cúp · từ chối quyền mic hoặc cam · rớt mạng giữa cuộc · đối phương
thoát đột ngột · chuyển app sang background rồi quay lại · thoát hẳn app khi đang gọi.

Bằng chứng: Ca background do Authority nêu thẳng: "ví dụ ở case background thì sao các thứ nữa kiểu gọi
xong thoát nhảy sang background thì nó sao". Ca "chưa mở app" đến từ ràng buộc đã cắt push —
không có push thì không đổ chuông được, phải hiện trạng thái tử tế thay vì treo.

## 9. Trạng thái rỗng và lỗi

Trả lời: Rỗng: danh bạ luôn có 2 người nên không có màn rỗng thật; màn cuộc gọi khi chưa ai bật cam
hiện avatar + tên thay cho khung đen. Lỗi: **thiếu cấu hình LiveKit** → màn chặn nói rõ thiếu
biến nào, không vào được danh bạ · **từ chối quyền** → màn giải thích + nút mở Cài đặt hệ
thống · **mất mạng / kết nối hỏng** → banner "đang kết nối lại" đếm giây, quá ngưỡng thì kết
thúc và về danh bạ · **bị từ chối** → thông báo ngắn rồi về danh bạ, không treo.

Bằng chứng: Nỗi đau lần trước là bản cũ không có màn nào cho các ca này — "chưa test các case chưa có
luồng giao diện hợp lí". Yêu cầu "không crash, không treo màn trắng" là phản ứng trực tiếp
với chỗ đó.

## 10. Dữ liệu mẫu

Trả lời: 2 liên hệ cắm cứng trong code, đủ để hai máy gọi nhau. Không seed, không file dữ liệu, không
DB — đúng nghĩa hằng số trong source.

Bằng chứng: Authority chốt nguyên văn: "ví dụ có tạo mock danh bạ có 2 cái gọi thì chúng ta set up 2
cái đó rồi ấn thôi".

## 11. Tên, domain, giọng, nơi deploy

Trả lời: Tên: **KaiCall**. Không domain, không web. Giọng: ngắn, thẳng, tiếng Việt có dấu — chữ trên
nút là động từ ("Gọi", "Nghe", "Từ chối", "Cúp máy"), không dùng thuật ngữ kỹ thuật trên UI.
Nơi deploy: **không deploy** — sản phẩm là file APK debug cài thẳng vào máy Android và một
emulator để nghiệm thu tại chỗ.

Bằng chứng: Tên do Authority đặt: "tên app bằng để là KaiCall đi". Không deploy vì ràng buộc thật: chỉ
có 1 máy Android, nghiệm thu là ngồi cạnh bấm thử chứ không phát hành.

## 12. Giao diện

Trả lời: **CÓ UI** — đây gần như là toàn bộ sản phẩm. Màn đầu tiên người dùng thấy: **danh bạ** 2
người, mỗi dòng có avatar, tên, nút gọi. Trong 10 giây đầu họ phải hiểu ngay: đây là app gọi
điện, bấm vào một người là gọi được. Bốn màn: Danh bạ · Cuộc gọi đến · Đang gọi (chờ bắt máy)
· Trong cuộc gọi.

Bằng chứng: Neo tham chiếu do Authority chỉ định: "nó sẽ hơi giống như gọi điện thoại bình thường như
trong điện thoại ý có danh bạ xong ấn gọi ý nó sẽ hoạt động như 1 app gọi điện bình thường
nhưu zalo ý chỉ phần call thôi".

## 13. Phong cách thị giác

<!-- Nuôi context/DESIGN-SYSTEM.md §1. Hỏi bằng HIỆN VẬT, không hỏi thẩm mỹ suông:
     "app nào anh dùng hằng ngày thấy dễ nhìn — mở lên cho tôi xem?", "cái nào nhìn là ngợp?".
     Backend-only (mục 12 đã chốt KHÔNG CÓ UI): ghi "KHÔNG CÓ UI" vào cả hai dòng. -->

Trả lời: Ba tính từ: **quen thuộc · rõ ràng · bình tĩnh**. Quen thuộc vì phải "nhìn là biết app gọi
điện" — không sáng tạo lại bố cục; nút cúp máy tròn đỏ, nút nghe tròn xanh, đặt đúng chỗ mắt
quen tìm. Rõ ràng vì dùng trên điện thoại cầm tay, trạng thái phải đọc được liếc một cái.
Bình tĩnh vì màn cuộc gọi nền tối, chữ sáng — mắt nghỉ, và video nổi lên trên nền tối.

Bằng chứng: Hiện vật neo do Authority chỉ đích danh: **app gọi điện mặc định của điện thoại** (danh bạ →
bấm gọi) và **Zalo, chỉ phần call**. Đây là hai app Authority dùng hằng ngày, nêu ra như chuẩn
"trông giống app thật".

## 14. Legacy & tương thích

<!-- Sổ này chỉ dùng vòng 1 nên ghi "Vòng 1 — chưa có legacy" vào cả hai dòng.
     Từ vòng 2, legacy là HỢP ĐỒNG (VIPER.md §1.2) và chuyện phá được Authority chốt
     trong tài liệu vòng intake/loops/l<N>/ (mục "Legacy được phép phá") — không quay
     lại sửa sổ này. Phá legacy chưa chốt ở đó = ngoại lệ "hỏi thật" của luật #2. -->

Trả lời: Vòng 1 — chưa có legacy.
Bằng chứng: Vòng 1 — chưa có legacy.
