# STATE — CORE-VIPER

> Trạng thái sống. Người và agent cùng đọc/ghi. Cập nhật ngay khi đổi pha hoặc tick gate.

```
Pha hiện tại : I
Vòng          : 1
Đường vào     : phỏng vấn (không có intake/PRD.md — xác định 2026-08-18)
Pha vòng này  : V, I, P, E, R
Ngày          : D1
Stack         : Flutter 3.41.9 + livekit_client 2.5.3 + flutter_bloc (Android)
URL local     : APK debug — build/app/outputs/flutter-apk/app-debug.apk
URL production: (chưa có)
```

> **Vòng** = một lượt V→I→(P)→(E)→(R). Vòng mới mở bằng `python3 scripts/repeat.py --go`
> (xem `/viper-repeat`) — không code tiếp trên vết vòng cũ. Từ vòng 2, script chèn thêm
> dòng `Vòng mở: <ngày>` — challenge của gate chỉ tính dòng có ngày từ đó trở đi (tài liệu
> không reset, hàng rào đếm theo vòng — `VIPER.md §1.2`).
>
> **Đường vào** quyết định ràng buộc nào áp (`VIPER.md §0`) — nguồn sự thật là marker
> `NGUỒN: INTAKE` trong `context/INTERVIEW.md`; dòng ở đây chỉ để người đọc thấy nhanh.
>
> **Pha vòng này**: đường phỏng vấn luôn đủ 5 pha. Đường intake lấy theo dòng `Pha vòng này`
> của `intake/loops/l<N>/_PROPOSAL.md` — V và I bắt buộc, P/E/R chỉ ở vòng Authority chốt
> (`VIPER.md §1.4`); `gate.py` bỏ qua gate của pha không khai.

---

## Gate

> Bản thao tác. Định nghĩa chuẩn ở `VIPER.md §1.1` — lệch nhau thì sửa chỗ này cho khớp (luật #4).

**V — Validate**
- [x] `context/PRD.md`: pain point + đối tượng cụ thể
- [x] `context/PRD.md`: AC — phỏng vấn 3–7 · intake ≥3 không trần, mọi AC có mặt ở `CAPABILITIES-MAP.md`
- [x] `context/PRD.md`: out-of-scope tường minh
- [x] `context/PRD.md`: 1 success metric có số
- [x] (vòng 1 — phỏng vấn) `context/INTERVIEW.md`: 14 mục, mỗi mục có dòng `Bằng chứng:`
- [x] (vòng 1 — intake, thay dòng trên, `VIPER.md §1.3`) `intake/PRD.md` render thật · `INTERVIEW.md` mang `NGUỒN: INTAKE` + bảng truy vết · `context/CAPABILITIES-MAP.md` đã tách
- [x] (vòng 1 — intake) **kế hoạch vòng** (`VIPER.md §1.4`): `ROADMAP.md §1` có bảng chia vòng, mỗi dòng có `intake/loops/l<N>/_PROPOSAL.md` tương ứng
- [x] (vòng ≥2 — phỏng vấn; thay hai dòng INTERVIEW; INTERVIEW đóng băng) `intake/loops/l<N>/` có ≥1 tài liệu vòng thật từ Authority — đồng thời là chữ ký chốt
- [x] (vòng ≥2 — intake; thay dòng trên) `l<N>/_PROPOSAL.md` thật (có `Pha vòng này`) + dòng `Rà lại vòng N: <ISO>` ngày ≥ `Vòng mở`
- [x] `context/PERSONAS.md`: persona + năng lực được cấp + ma trận vai × hành động
- [x] `context/TECHSTACK.md` chốt + 1 dòng lý do trong `DECISIONS.md`
- [x] `context/DECISIONS.md`: ≥2 quyết định của vòng này (vòng ≥2: dưới mốc `(vòng N)`, ngày ≥ `Vòng mở`)
- [x] `context/ARCHITECTURE.md` (sơ đồ + mô hình dữ liệu + luồng lõi; intake: thêm boundary/experience + contract)
- [x] Design system: có UI → `context/DESIGN-SYSTEM.md` chốt **trước** prototype (token dùng thật · không dùng token ngoài bảng · tương phản AA · component có màn dùng · khớp gói `intake/design-systems/` nếu có) · backend-only → marker `KHÔNG CÓ UI`
- [x] Prototype: có UI → file tương tác **từ token/component đã chốt** (`prototype/index.html`, hoặc `prototype/<experience>/index.html` ở đường intake) + mọi màn khai ở `PROTOTYPE.md §1` đã dựng + **Authority đã chốt** (`PROTOTYPE.md §5`) · backend-only → marker `KHÔNG CÓ UI` · intake vòng ≥2 khai `UI vòng này: không có màn mới` → bỏ qua
- [x] Challenge pha V **PASS** (§Challenge log) — tài liệu trả lời được 3–5 câu khó nhất
- [x] **Scope khoá** — từ đây không hỏi Authority nữa

**I — Implement**
- [ ] Challenge PASS (ghi ở §Challenge log dưới)
- [ ] `make dev` · `make check` · `make migrate` đã hiện thực
- [ ] Đã có commit code ngoài commit khởi tạo
- [ ] Luồng lõi end-to-end bấm được ở local
- [ ] `make check` xanh
- [ ] `/viper-dogfood` xong — meta tự dùng + 6 subagent (2 đợt × 3 vai), phát hiện đã xử hoặc đã ghi

**P1 — sẵn sàng deploy lần đầu** (`gate.py P1`)
- [ ] (intake) Vòng này có khai `P` trong `_PROPOSAL.md`? Không → bỏ qua cả nhóm P1/P2, đi thẳng `/viper-repeat`
- [ ] `context/PRODUCTION-READY.md` 4 nhóm xanh, **trừ** mục gắn `(sau deploy)`
- [ ] Vòng ≥2: `BACKWARD-COMPATIBILITY-CHECKLIST.md §3` xanh — hook `guard_bc` chặn deploy tới khi xanh
- [ ] `make test` · `make deploy` · `make doctor` đã hiện thực
- [ ] `make check && make test` xanh
- [ ] Phép thử phân quyền A↛B đã chạy ở local

**P2 — production đã sống** (`gate.py P2`)
- [ ] 4 nhóm xanh **toàn bộ**, kể cả mục `(sau deploy)`
- [ ] `context/shared/DEPLOY.md` đủ §1–§5, có rollback (điền TRƯỚC lần deploy đầu)
- [ ] Production sống, health check 200, smoke test pass
- [ ] Đã **thử** rollback một lần
- [ ] `/viper-dogfood` lần 2 trên production

**E — Evaluate**
- [ ] (intake) Vòng này có khai `E` trong `_PROPOSAL.md`? Không → bỏ qua cả nhóm
- [ ] Tracking đang đếm
- [ ] Sổ EXPERIMENTS của vòng có số liệu thật (vòng 1: `EXPERIMENTS.md`; vòng N ≥2: `EXPERIMENTS-v<N>.md`)

**R — Repeat**
- [ ] Quyết định go / pivot / kill ghi ở `DECISIONS.md` (vòng không chạy E: bỏ qua — không có số liệu để quyết)
- [ ] `ROADMAP.md` cập nhật — backlog §3, và (intake) trạng thái vòng ở §1
- [ ] `python3 scripts/repeat.py --go` mở vòng mới (xem `/viper-repeat` — không reset, chỉ sổ sách theo vòng)

---

## Challenge log

Meta ra câu hỏi khó dựa trên context, chấm PASS/FAIL. **Pha V**: 3–5 câu tài liệu chưa trả lời được, trước khi khoá scope — không trả lời được thì vá theo đúng chế độ đang đi (vòng 1 phỏng vấn: hỏi Authority tiếp · vòng 1 intake: dịch lại + vá lỗ hổng · vòng ≥2: đọc lại `intake/loops/l<N>/` + kết quả vòng trước). **Pha I trở đi**: trước mỗi mảng việc lớn, trước khi code. FAIL → đọc lại context, trả lời lại.

| Ngày | Pha | Câu hỏi | Phán quyết | Ghi chú |
|---|---|---|---|---|
| 2026-08-20 | V | Không có push, vậy A bấm gọi khi B **chưa mở app** thì A thấy gì, và bao lâu thì thôi? | PASS | FAIL lần đầu, đã vá: Tài liệu để màn "Đang gọi…" quay vô hạn. Chốt timeout 30 giây → "Không trả lời" → về danh bạ (`ARCHITECTURE.md §7a`) |
| 2026-08-20 | V | Token ký trong app sống bao lâu? Hết hạn **giữa cuộc gọi** thì sao? | PASS | FAIL lần đầu, đã vá: Không chỗ nào nói. Chốt TTL 2 giờ, cấp mới mỗi lần vào phòng; `livekit_client` không tự gia hạn nên cuộc >2h sẽ rớt — chấp nhận và ghi rõ (`§7b`) |
| 2026-08-20 | V | `roomName` tất định nên cuộc mới dùng lại đúng phòng cũ. Cuộc trước kết thúc bẩn, một bên còn kẹt trong phòng thì sao? | PASS | FAIL lần đầu, đã vá: Chốt `identity` = `Contact.id` để LiveKit đá bản cũ ra. Identity ngẫu nhiên sẽ làm bên kia thấy hai ô video của cùng một người (`§7c`) |
| 2026-08-20 | V | AC-7 đòi "ở background tiếng vẫn thông", nhưng `ARCHITECTURE §7` lại nói có thể phải coi như kết thúc. **Hai chỗ mâu thuẫn — cái nào thắng?** | PASS | FAIL lần đầu, đã vá: Mâu thuẫn thật trong chính tài liệu. Chốt: vòng 1 không làm foreground service, AC-7 thu về "chuyển nền ngắn ~30 giây"; thoát hẳn thì `disconnect()` tường minh. Foreground service đẩy backlog (`§7d`) |
| 2026-08-20 | V | Success metric đòi chạy 7/7 AC trên **máy thật + emulator**, mà emulator mic là giả. Vậy AC-2 "nghe được tiếng nhau" kiểm bằng cách nào? | PASS | FAIL lần đầu, đã vá: Metric hứa thứ không kiểm được. Chốt cách kiểm bất đối xứng: tiếng soi bằng tai ở đầu máy thật, đầu emulator soi bằng chỉ báo mức âm của LiveKit (`PRD.md §3` AC-2) |
| 2026-08-20 | I | Kiến trúc giả định 4 thứ ở SDK: gửi được data trong phòng chờ · nhận được sự kiện data · giữ được HAI phòng cùng lúc (chờ + gọi) · LiveKit đá bản cũ khi trùng identity. **`livekit_client` 2.5.3 có đủ cả 4 không, hay kiến trúc đang xây trên giả định sai?** | PASS | Đọc thẳng source trong pub-cache, không đoán: `publishData(List<int>, {reliable, destinationIdentities, topic})` ở `participant/local.dart:553` · `DataReceivedEvent(participant, data, topic)` ở `events.dart:407` · `DisconnectReason.duplicateIdentity` ở `types/other.dart:110` · `Room` là instance nên tạo hai cái là được. Đủ cả 4 — code tiếp |

---

## Blocker

Chặn cứng sau khi đã tự thử hết cách. Không hỏi giữa chừng — dồn vào đây, báo gộp cuối buổi.

| Ngày | Blocker | Đã thử gì | Trạng thái |
|---|---|---|---|
| | | | |

---

## Phát hiện từ dogfood chưa xử

Thứ tìm được khi dùng thử nhưng chưa sửa (nhỏ thì sửa ngay, ngoài scope thì đẩy `ROADMAP.md`).

| Ngày | Vai phát hiện | Vấn đề | Xử lý |
|---|---|---|---|
| 2026-08-21 | Dogfood Kilo, đợt dựng 2 emulator | Hai máy cùng mặc định chọn "Long" → LiveKit đá máy vào trước ra vì trùng identity. App chỉ hiện "Chưa vào được máy chủ" **trống trơn**, không nói bị đá, không nói phải làm gì. Nút "Thử lại" còn tệ hơn: bấm là vào lại rồi đá ngược máy kia — hai máy đá nhau vô hạn | **Đã sửa.** `RoomDisconnectedEvent.reason` trước bị vứt, giờ giữ lại: banner nói thẳng "Máy khác đang dùng danh tính Long" và thay nút Thử lại bằng hướng dẫn đổi vai. Thêm test cho ca này (24/24 xanh) |
| 2026-08-21 | Dogfood Kilo — **lỗ hợp đồng, nặng nhất tới giờ** | `SignalingPort` thiếu hẳn tín hiệu **accept**. B bấm Nghe thì B vào phòng, còn A KHÔNG được báo — ngồi ở "Đang gọi…" đủ 30 giây rồi kết luận "Không trả lời" trong khi B đã ở trong phòng chờ A. **Luồng lõi chưa bao giờ nối được**, mà 24 test vẫn xanh vì test AC-2 chỉ đi từ phía người NHẬN | **Đã sửa.** Thêm `accept`/`acceptances` (additive, không phá gì) + `_onAcceptanceArrived`. Bên nhận báo TRƯỚC rồi mới join. 2 test hồi quy, 26/26 xanh |
| 2026-08-21 | Dogfood Kilo — vai người mới | App tự bắn `SelfChosen(kDemoContacts.first)` lúc dựng bloc, nên hai máy mở lên là cùng vai `long` và LiveKit đá một cái ra. Tái lập 100% | **Đã sửa.** Bỏ tự chọn hộ: cờ `identityChosen`, chưa bấm thì chưa vào phòng chờ |
| 2026-08-21 | Dogfood Kilo — vai khó tính hình thức | Chip "Long" tô xanh kèm tick trong khi app chưa hề chọn ai, và chip đang-chọn có `onTap: null` nên bấm vào không có tác dụng gì — người dùng kẹt ở màn đầu. Chỉ lộ khi nhìn screenshot; dump accessibility tree không thấy | **Đã sửa.** Chưa chọn thì không chip nào tô xanh, cả hai đều bấm được; nhãn đổi thành "Chọn máy này là ai để bắt đầu", và giấu danh sách gọi cho tới khi chọn xong |
