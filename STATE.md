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
| 2026-08-21 | **Gọi hai đầu chưa nối được.** Emulator(Long) bấm Gọi → máy thật(Minh) hiện "Cuộc gọi đến Long" ĐÚNG → bấm Nghe → **cả hai về danh bạ**, không vào cuộc gọi | Giả thuyết ban đầu — `setCameraEnabled(true)` ném lỗi trên emulator, bản cũ gộp chung try với `connect()` nên bị hiểu là "không vào được phòng" — **SAI**. Vá xong build lại, cài `emulator-5554`(Long) + Honor `0000NX25A8007794`(Minh): gọi thông ngay, video hai chiều, đứng vững, cúp máy sạch, lặp lại hai lần. Nhưng `debugPrint` của chính bản vá **không bắn một dòng nào** — nhánh `catch` mới chưa từng được chạm tới, camera giả của emulator vẫn chạy tốt. Thứ khác lần hỏng là quyền được cấp **trước khi mở app**. Tái lập cho chắc: gỡ quyền mic/cam ở máy nhận rồi gọi lại → hỏng đúng y lần cũ | **ĐÃ GỠ 2026-08-21.** Nguyên nhân thật: **máy nhận chưa có quyền mic/cam**. `ensureCallPermissions()` (`lib/infrastructure/device_permissions.dart:10`) đòi đủ cả hai quyền trước khi chạm tới LiveKit, nên lỗi camera chưa bao giờ có cơ hội xảy ra. B bấm Nghe → hệ thống bật `GrantPermissionsActivity` → tín hiệu accept không bao giờ được gửi → A ngồi hết 30 giây thành "Không trả lời" → hai máy cùng về danh bạ. Bản vá tách try **giữ lại** vì đúng về thiết kế (cuộc gọi không hình vẫn là cuộc gọi), nhưng **không phải thứ đã chữa lỗi này** — đừng ghi công cho nó |
| 2026-08-21 | `pm grant` quyền runtime **giết tiến trình app** | Cấp quyền bằng `adb shell pm grant` giữa lượt thử làm app khởi động lại, mất vai đã chọn và mất kết nối phòng chờ — làm nhiễu chẩn đoán một lượt | **Cùng gốc với dòng trên.** Dòng này đã trỏ đúng thủ phạm từ đầu, chỉ là lần trước không ai nối hai dòng lại với nhau. Cách đúng: `pm grant` **rồi mới** `am start`, hoặc bấm tay trên hộp thoại hệ thống. Đã thành ca 18 của `CHECKLIST.md` |

---

## Phát hiện từ dogfood chưa xử

Thứ tìm được khi dùng thử nhưng chưa sửa (nhỏ thì sửa ngay, ngoài scope thì đẩy `ROADMAP.md`).

| Ngày | Vai phát hiện | Vấn đề | Xử lý |
|---|---|---|---|
| 2026-08-21 | Dogfood Kilo, đợt dựng 2 emulator | Hai máy cùng mặc định chọn "Long" → LiveKit đá máy vào trước ra vì trùng identity. App chỉ hiện "Chưa vào được máy chủ" **trống trơn**, không nói bị đá, không nói phải làm gì. Nút "Thử lại" còn tệ hơn: bấm là vào lại rồi đá ngược máy kia — hai máy đá nhau vô hạn | **Đã sửa.** `RoomDisconnectedEvent.reason` trước bị vứt, giờ giữ lại: banner nói thẳng "Máy khác đang dùng danh tính Long" và thay nút Thử lại bằng hướng dẫn đổi vai. Thêm test cho ca này (24/24 xanh) |
| 2026-08-21 | Dogfood Kilo — **lỗ hợp đồng, nặng nhất tới giờ** | `SignalingPort` thiếu hẳn tín hiệu **accept**. B bấm Nghe thì B vào phòng, còn A KHÔNG được báo — ngồi ở "Đang gọi…" đủ 30 giây rồi kết luận "Không trả lời" trong khi B đã ở trong phòng chờ A. **Luồng lõi chưa bao giờ nối được**, mà 24 test vẫn xanh vì test AC-2 chỉ đi từ phía người NHẬN | **Đã sửa.** Thêm `accept`/`acceptances` (additive, không phá gì) + `_onAcceptanceArrived`. Bên nhận báo TRƯỚC rồi mới join. 2 test hồi quy, 26/26 xanh |
| 2026-08-21 | Dogfood Kilo — vai người mới | App tự bắn `SelfChosen(kDemoContacts.first)` lúc dựng bloc, nên hai máy mở lên là cùng vai `long` và LiveKit đá một cái ra. Tái lập 100% | **Đã sửa.** Bỏ tự chọn hộ: cờ `identityChosen`, chưa bấm thì chưa vào phòng chờ |
| 2026-08-21 | Dogfood Kilo — vai khó tính hình thức | Chip "Long" tô xanh kèm tick trong khi app chưa hề chọn ai, và chip đang-chọn có `onTap: null` nên bấm vào không có tác dụng gì — người dùng kẹt ở màn đầu. Chỉ lộ khi nhìn screenshot; dump accessibility tree không thấy | **Đã sửa.** Chưa chọn thì không chip nào tô xanh, cả hai đều bấm được; nhãn đổi thành "Chọn máy này là ai để bắt đầu", và giấu danh sách gọi cho tới khi chọn xong |
| 2026-08-21 | CHECKLIST ca 5 · 13 · 14 | **Không phân biệt "tắt camera" với "mất người".** Màn cuộc gọi quyết định bằng `remote != null` — track thô móc thẳng từ `room` — chứ không dùng `state.peerHasVideo`, mà trường này được `call_bloc.dart` gán tử tế nhưng **không nơi nào đọc**: state chết. Song song, session chỉ nghe `TrackSubscribed`/`TrackUnsubscribed`; tắt cam chỉ **mute** chứ không gỡ đăng ký nên không ai hay. Bên kia tắt cam → khung đen trơn, đúng thứ `DESIGN-SYSTEM.md §5` cấm | **Đã sửa.** Nghe thêm `TrackMutedEvent`/`TrackUnmutedEvent` (lọc theo `source == camera`, chỉ tính RemoteParticipant), đọc luôn `publication.muted` lúc subscribe, và cho UI đọc `peerHasVideo`. Đo lại trên máy: Honor tắt cam → emulator hiện avatar + "Minh đã tắt camera", bật lại thì hình về. Thêm test hồi quy "tắt camera khác hẳn rời đi" (29/29 xanh) |
| 2026-08-21 | CHECKLIST ca 14 | **Giết app một đầu thì đầu kia kẹt vĩnh viễn** — đo hơn 2 phút A vẫn không về danh bạ | **Đã sửa.** Log mới cho thấy vì sao: tiến trình B chết rồi mà participant **vẫn nằm trong phòng** với `connectionQuality=lost` suốt ~12 giây, SDK mới bắn `ParticipantDisconnected`. Thêm nhịp canh 2 giây: đối phương vắng mặt hoặc `lost` liên tục **15 giây** (Authority chốt) thì tự kết thúc, không phó mặc sự kiện SDK. Đo lại: A về danh bạ sau ~15 giây với đúng lý do "Người kia đã rời cuộc gọi" |
| 2026-08-21 | CHECKLIST ca 16 | **Vuốt tắt app không ngắt cuộc gọi.** ⚠ Lần đo đầu tôi ghi sai: cú vuốt qua `adb` KHÔNG xoá task (dumpsys cho thấy task còn nguyên), nên cái "90 giây bên kia vẫn kẹt" thật ra là hành vi **bấm Home** — mà nền vẫn giữ cuộc gọi thì đúng AC-7 chứ không sai. Vuốt thật trên Honor mới lộ lỗi thật | **Đã sửa.** Thêm `WidgetsBindingObserver`: `detached` → `session.leave()` (chỉ `detached`; `paused` là bấm Home, ngắt ở đó là phá AC-7). Thêm `MainActivity.onDestroy` + `isFinishing` → đóng tiến trình để socket đứt theo. Đo lại bằng cách vuốt thẻ thật trên Honor: Flutter nhận `detached`, tiến trình chết, đầu kia kết thúc sau ~13 giây thay vì treo |
| 2026-08-21 | CHECKLIST ca 13 | **Máy mất mạng không được báo gì** — bật máy bay giữa cuộc gọi, máy đó đứng nhìn khung hình chết 45 giây, không một chữ; `RoomReconnectingEvent` không hề bắn | **Đã sửa.** Hàng rào cũ chỉ canh đối phương, mà mình mất mạng thì đối phương vẫn nằm nguyên trong danh sách nên không bao giờ nổ. Nhịp canh giờ xem cả `room.connectionState` của CHÍNH MÌNH: khác `connected` → báo "Đang kết nối lại…" ngay; quá 15 giây → kết thúc với "Mất kết nối". Đo lại: banner đỏ hiện từ giây 0, kết thúc ở giây 16 |
| 2026-08-21 | CHECKLIST ca 15 — **cần Authority quyết** | **AC-7 không đạt, và trước giờ chỉ có vẻ đạt.** Sau ~10 giây ở nền, Android treo websocket của app: `room.connectionState` tụt xuống `disconnected` và **không tự hồi** khi quay lại. Bản cũ vẫn hiện màn cuộc gọi có hình nên tưởng là đạt — nhưng đó là cái xác: thử bấm Cúp máy sau khi quay lại, **đầu kia không nhận được gì**, phải đợi hàng rào 15 giây mới biết. Đo ngưỡng: nền **5 giây thì sống, 10 giây là đứt** | **Chưa xử — không sửa được trong scope vòng 1.** Giữ kết nối khi chạy nền cần **foreground service**, thứ challenge pha V đã cố ý đẩy sang backlog (`ARCHITECTURE.md §7d`). Hai đường: (a) hạ AC-7 xuống "~5 giây" và ghi ca 15 là chưa đạt, hoặc (b) làm foreground service ở vòng sau. Hàng rào mới ít nhất đã đổi cái xác im lặng thành một dòng "Mất kết nối" tử tế |
| 2026-08-21 | CHECKLIST ca 3 · 4 · 15 (phần tiếng) — **CHƯA KIỂM** | Không nghe được tiếng ở đầu máy ảo dù đo cho thấy **cả hai đầu đang thu/phát thật**: Honor `Recording active: true` + ra loa ngoài, máy ảo `AudioPlaybackConfiguration state:started, usage=VOICE_COMMUNICATION, mutedState:none`. Đã loại trừ máy Mac: `afplay` phát chuông qua tai nghe thì Authority nghe rõ, nên đường ra của macOS tốt. Nghi máy ảo **giành thiết bị âm thanh lúc khởi động** nên vẫn ghi vào thiết bị cũ, tai nghe Bluetooth nối sau thì không nhận được. Vặn hết âm lượng hai phía vẫn câm | **Chưa kiểm — KHÔNG đánh dấu xanh** (luật chấm điểm của `CHECKLIST.md`). Chú ý: `PRD.md §3 AC-2` đã chốt từ pha V rằng mic máy ảo là giả nên chỉ có MỘT chiều có tiếng thật (nói vào máy thật, nghe ở máy ảo). Việc tiếp: khởi động lại máy ảo khi tai nghe đã cắm sẵn, rồi nói vào Honor và nghe ở máy Mac |
| 2026-08-21 | Đo tiếng, phát hiện kèm | **App chưa bao giờ tự chọn loa.** `grep -rn "speaker\|setSpeakerphone" lib` không ra một dòng nào. Lần này Honor ra loa ngoài là do hệ điều hành quyết hộ, không phải app. Máy khác rơi vào loa tai nghe thì người dùng áp tai vào loa ngoài sẽ tưởng app hỏng — đúng thứ vừa xảy ra khi đi kiểm | **Chưa sửa — đẩy `ROADMAP.md` backlog.** App gọi video nên mặc định loa ngoài và có nút đổi loa/tai nghe. Ngoài scope vòng 1 |

---

## Bàn giao cho phiên sau

**Đang ở**: pha I, vòng 1. Luồng lõi **đã nối được** và đã đi hết `CHECKLIST.md`
một lượt trên emulator(Long) + Honor(Minh):

- **16 ca xanh** (ca 4 mới xanh phần giao diện)
- **1 ca đỏ**: ca 15 — AC-7, cần Authority quyết, xem §Phát hiện
- **1 ca chưa kiểm**: ca 3, cùng phần tiếng của ca 4 và ca 15 — không nghe được
  vì mic máy ảo là giả, xem §Phát hiện

Còn nợ: `/viper-dogfood` bước 3 (6 vai subagent — chưa chạy).

**Quyết định về pha**: vòng này chạy **V → I → R**, bỏ P và E. Không deploy đi
đâu (`PRD.md §7`) và không có người dùng để đo. Lưu ý: khai "vòng này chỉ V+I"
là cơ chế của đường intake — đường phỏng vấn luôn đủ 5 pha, nên bỏ P/E phải ghi
một dòng `DECISIONS.md` theo luật #1. **VẪN CHƯA GHI** — món nợ cũ nhất ở đây.

### Máy móc — chỗ này quan trọng nhất với phiên mới

**Authority KHÔNG cài được Claude trên máy mình** (không có tài khoản). Nên cách
làm việc cố định là: phiên chat mở trên **Mac mini công ty**, mọi thao tác thực
thi **qua SSH** sang máy Authority. Đừng đề nghị "mở Claude trên máy bạn" —
không làm được, và đó chính là lý do có cả lớp SSH này.

Repo sống ở **máy của Authority**, không phải máy chạy Claude:

```
long@longs-Mac-mini.local:~/demo_call_viper      ← BẢN DUY NHẤT
```

Phiên Claude chạy trên một Mac mini khác và điều khiển qua SSH. Lối tắt đã cấu
hình trong `~/.ssh/config` của máy đó:

```
Host longmac
  HostName longs-Mac-mini.local
  Port 22
  User long
  IdentityFile ~/.ssh/viper_agent_key
  IdentitiesOnly yes        # BẮT BUỘC — máy có nhiều khoá, chào nhầm là bị từ chối
```

Mọi lệnh đi qua `ssh longmac '...'`. Script Python dài thì **truyền qua stdin**
(`ssh longmac 'cd ~/demo_call_viper && python3 -' < script.py`) — heredoc lồng
trong ssh bị zsh nuốt mất dấu `?` và dấu nháy.

**Đẩy GitHub**: máy Authority không có credential. Đường vòng: từ máy chạy Claude
`git fetch longmac:demo_call_viper main` rồi
`git -c credential.helper='!gh auth git-credential' push origin <sha>:main`.

### Thiết bị

| Serial | Là gì | Vai |
|---|---|---|
| `0000NX25A8007794` | Honor ELA-LX2, máy thật, đã authorized | Minh |
| `emulator-5554` | Pixel_4_XL | Long |
| `emulator-5556` | bản clone AVD | (đang tắt app) |

`adb` ở `~/Library/Android/sdk/platform-tools/adb` — không có trong PATH của
shell SSH, phải gọi đường dẫn đầy đủ. Chụp màn hình: `screencap` rồi `pull` rồi
`scp -P 22 -i ~/.ssh/viper_agent_key -o IdentitiesOnly=yes` về mà xem.

**Flutter**: máy Authority có 3.41.9 (đúng bản ghim) nhưng `PATH` trỏ 3.44.5
trước. Makefile tự dò nên `make` luôn đúng bản; gọi `flutter` trần thì sai bản.

### Việc tiếp theo, đúng thứ tự

1. **Authority chốt AC-7** — ca 15 đỏ vì sau ~10 giây ở nền thì kết nối đứt và
   không tự hồi. Hai đường (a) hạ AC-7 xuống "~5 giây" và ghi ca 15 chưa đạt,
   hoặc (b) làm foreground service ở vòng sau. Chốt xong ghi `DECISIONS.md`.
2. Ghi dòng `DECISIONS.md` bỏ P/E — nợ từ trước, luật #1.
3. Kiểm nốt phần tiếng (ca 3, và phần tiếng của ca 4/15) khi máy ảo chịu đổ
   tiếng ra thiết bị đúng. Chỉ MỘT chiều có tiếng thật: nói vào máy Honor, nghe
   ở máy chạy emulator.
4. `$viper-dogfood` bước 3 trong Kilo trên máy Authority.
5. Pha R.

### Chạy trên MỘT MÁY KHÁC (Codex, hoặc bất kỳ ai pull repo về)

Repo tự đứng được, nhưng có đúng **một cái bẫy chặn cứng ngay bước đầu**:

**`deployment/local/.env` KHÔNG có trong repo** — `.gitignore` chặn `.env` và
`.env.*` ở mọi cấp. Pull về là thiếu, và thiếu thì `make dev`/`make deploy` từ
chối chạy, còn app dựng lên sẽ hiện màn chặn S0 "Chưa chạy được". Không phải
hỏng, là cố ý (`DECISIONS.md` 2026-08-20: APK mang theo API secret là ai giải
nén cũng ký được token vào mọi phòng).

Dựng lại như sau:

```bash
mkdir -p deployment/local
cp deployment/.env.example deployment/local/.env
# rồi điền 4 biến — lấy từ LiveKit Cloud, hoặc xin Authority
make doctor        # kiểm đủ 4 biến + đúng Flutter 3.41.9 + đếm thiết bị
```

**Chạy được gì mà không cần thiết bị Android:**

```bash
make check    # analyzer, phải sạch
make test     # 29 test, phải xanh — không cần máy, không cần mạng, không cần .env
```

29 test đó là chỗ phần lớn AC được kiểm (`TECHSTACK.md §3`): domain tách hẳn
khỏi LiveKit nên ca biên chạy trọn trên máy tính.

**KHÔNG kiểm được nếu không có máy Android**: toàn bộ `CHECKLIST.md`. Nó cần hai
đầu — ít nhất một máy thật, vì emulator mic là giả.

**Đọc theo thứ tự này cho nhanh**: `AGENTS.md` (luật) → `STATE.md` mục Gate và
§Phát hiện (đang nợ gì) → `context/PRD.md §3` (7 AC) → `CHECKLIST.md` (cách
nghiệm thu). `VIPER.md` chỉ tra khi cần, nó dài.

**Cảnh báo tay lái**: từ pha I trở đi luật #2 cấm hỏi Authority. Đừng dừng lại
hỏi — tự quyết theo context rồi ghi `DECISIONS.md`. Ngoại lệ duy nhất đang mở là
AC-7 ở trên, và nó đã được hỏi rồi.

### Lưu ý về Kilo

Kilo đã chạy dogfood hai lượt và **chẩn đoán rất tốt** — nó tìm ra lỗ thiếu tín
hiệu `accept` làm luồng lõi chưa bao giờ nối được. Nhưng **cả hai lần nó báo
"đã sửa" mà trên đĩa không có gì**: `git status` sạch, không file nào đổi.
Đọc báo cáo của nó như **chẩn đoán**, và luôn kiểm lại bằng `git status` /
`grep` trước khi tin là đã sửa.
