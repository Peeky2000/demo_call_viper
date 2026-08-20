# CORE-VIPER — AGENTS.md (VIPER v1.9)

> **Đọc top-to-bottom mỗi phiên.** Quy trình đầy đủ: [VIPER.md](VIPER.md). Trạng thái hiện tại: [STATE.md](STATE.md).

---

## 0. ĐANG ĐI ĐƯỜNG NÀO

VIPER có **hai đường vào**, ràng buộc khác nhau. Nhận diện bằng đúng một dấu hiệu: `context/INTERVIEW.md` có marker `NGUỒN: INTAKE` (ngoài comment) hay không.

| | **Đường phỏng vấn** | **Đường intake** |
|---|---|---|
| Bối cảnh | Founder/PO có ý tưởng, test thị trường 1 tuần | Tài liệu MESH-render đã phân tích kỹ; hệ thống lớn chia vòng chạy dần |
| Cỡ | 1 app, 1 DB, 1 nơi deploy | Đa target `srcroot/{boundaries,web-experiences,mobile-experiences}/<tên>/` |
| Số AC · persona | 3–7 AC · 2–3 persona | Không trần — AC truy về `CAPABILITIES-MAP.md`; persona theo intake |
| Nhịp | 1 tuần, khoá scope 2 tiếng | Mỗi vòng tự khai thời lượng |
| Pha mỗi vòng | **V + I bắt buộc**; P/E/R theo mục tiêu vòng | **V + I bắt buộc**; P/E/R theo `intake/loops/l<N>/_PROPOSAL.md` |
| Prototype | MỘT `prototype/index.html` | `prototype/<experience>/index.html` |

**Đừng mang luật của đường này áp sang đường kia** — ràng buộc của đường phỏng vấn là ràng buộc tốc độ của bối cảnh một tuần, không phải luật của VIPER. Chi tiết: [VIPER.md §0, §1.3, §1.4](VIPER.md).

---

## 1. TÁM LUẬT

1. **Scope khoá sau pha V.** Phát sinh → `context/ROADMAP.md` backlog, không chèn vào vòng này.
2. **Sau pha V: toàn quyền, không hỏi lại.** Từ pha I trở đi không gọi
   `request_user_input` và không hỏi bằng văn bản thường (§3); tự quyết theo context rồi
   ghi `DECISIONS.md`.
3. **Quyết định không hiển nhiên → 1 dòng `context/DECISIONS.md` TRƯỚC khi code.**
4. **Context là nguồn sự thật.** Code lệch tài liệu → sửa tài liệu **cùng commit**.
5. **Cỡ sản phẩm theo đường vào** (§0). Phỏng vấn: một app, một DB, một nơi deploy, scaffold gốc repo. Intake ([VIPER.md §1.3](VIPER.md)): đa target theo intake ARCHITECTURE, code ở `srcroot/<nhóm>/<tên>/` (ba nhóm: `boundaries` · `web-experiences` · `mobile-experiences`), **không tự đẻ target ngoài danh sách** và không gộp hai target cho gọn.
6. **Không secret trong code, không bypass test/lint.**
7. **Tiếng Việt có dấu** cho mọi văn bản người đọc (giữ tiếng Anh cho identifier, API path, schema field, tên lệnh, tên file).
8. **Im lặng với Authority, đối kháng với nhau.** Challenge trước khi code + dogfood trước khi báo xong (§4).

---

## 2. NĂM PHA

```
V Validate ─► I Implement ─► P Polish&Publish ─► E Evaluate ─► R Repeat
  ↑ nơi DUY NHẤT được hỏi Authority

phỏng vấn: V + I bắt buộc trong D1; P/E/R theo mục tiêu, publish thì trong tuần
intake:    V và I bắt buộc mọi vòng; P/E/R chỉ ở vòng khai trong _PROPOSAL.md
```

Pha hiện tại nằm ở [STATE.md](STATE.md). Kiểm gate: `python3 scripts/gate.py` (tự đọc pha từ STATE.md) hoặc `python3 scripts/gate.py <V|I|P|P1|P2|E|R>`.

Bảng dưới là bản rút gọn. **Định nghĩa chuẩn ở [VIPER.md §1.1](VIPER.md) — lệch nhau thì VIPER.md thắng.**

| Pha | Gate rời pha |
|---|---|
| V | PRD + PERSONAS + TECHSTACK + ARCHITECTURE đủ mục · số AC: phỏng vấn 3–7, intake không trần nhưng mọi AC phải có ở `CAPABILITIES-MAP.md` · **vòng 1**: phỏng vấn → INTERVIEW đủ 14 dòng bằng chứng; intake → `intake/PRD.md` render thật + marker `NGUỒN: INTAKE` + bảng truy vết + `CAPABILITIES-MAP.md` đã tách + **kế hoạch vòng** (`ROADMAP.md §1` khớp `l<N>/_PROPOSAL.md`, [VIPER.md §1.4](VIPER.md)) · **vòng ≥2 (không phỏng vấn, INTERVIEW đóng băng)**: phỏng vấn → `intake/loops/l<N>/` có ≥1 tài liệu vòng thật từ Authority; intake → `_PROPOSAL.md` thật + dòng `Rà lại vòng N: <ISO>` ngày ≥ `Vòng mở` · có UI thì DESIGN-SYSTEM chốt **trước** prototype (token dùng thật · không dùng token ngoài bảng · tương phản AA · component có màn dùng · khớp gói intake nếu có, **đối chiếu riêng từng gói**; nhiều gói → §2 có cột `DS` + mọi experience khai `Design system` ở ARCHITECTURE §2–§3) rồi prototype tương tác **Authority đã chốt**, mọi màn khai ở §1 đã dựng (backend-only: marker `KHÔNG CÓ UI`; intake vòng ≥2 khai `không có màn mới`: bỏ qua) · challenge pha V PASS (vòng ≥2: ngày ≥ `Vòng mở`) · ≥2 dòng DECISIONS **của vòng này** · scope khoá |
| I | Challenge PASS · `make dev/check/migrate` có thân · luồng lõi end-to-end ở local · `make check` xanh · **đã dogfood** |
| P1 | Vòng không khai `P` → bỏ qua cả pha P · 4 nhóm `PRODUCTION-READY.md` xanh trừ mục `(sau deploy)` · vòng ≥2: `BACKWARD-COMPATIBILITY-CHECKLIST.md §3` xanh (hook `guard_bc` chặn deploy tới khi xanh) · `make test/deploy/doctor` có thân → được deploy |
| P2 | 4 nhóm xanh toàn bộ · `DEPLOY.md` có rollback · production sống · smoke test pass · **đã thử rollback** · **dogfood lần 2** |
| E | Vòng không khai `E` → bỏ qua · tracking đang đếm · sổ EXPERIMENTS **của vòng** có số liệu thật (vòng 1: `EXPERIMENTS.md`; vòng N ≥2: `EXPERIMENTS-v<N>.md`) |
| R / đóng vòng | Vòng khai R: go/pivot/kill ghi `DECISIONS.md` + sổ EXPERIMENTS. `$viper-repeat` còn archive/bookkeeping và mở vòng mới cho vòng không khai R (`scripts/repeat.py --go` — **không reset gì**); gọi workflow không tự biến bookkeeping thành pha R. **Không code tiếp trên vết vòng cũ**; legacy vòng trước là hợp đồng ([VIPER.md §1.2](VIPER.md)) |

Pha P tách hai gate vì backup / HTTPS / push-là-deploy / analytics chỉ làm được **sau** khi production tồn tại.

---

## 3. LUẬT #2 — KHÔNG HỎI SAU PHA V

Từ pha I trở đi, gặp mơ hồ thì **tự quyết**, không hỏi:

```
mơ hồ → chọn phương án hợp lý nhất theo PRD/ARCHITECTURE/TECHSTACK
      → ghi 1 dòng context/DECISIONS.md (có cột "giả định" + "đảo ngược được không")
      → đi tiếp
```

**Ba trường hợp duy nhất được dừng:**

| Tình huống | Xử lý |
|---|---|
| Ngoài scope đã khoá | **Không hỏi** — ghi `ROADMAP.md` backlog, làm tiếp phần còn lại |
| Không đảo ngược được / hướng ra ngoài (xoá dữ liệu production, tiêu tiền, đăng ký dịch vụ, công bố, đổi DNS, **phá legacy vòng trước chưa được Authority chốt** ở một trong ba nơi: `intake/loops/l<N>/*.md` · mục "Legacy được phép phá" của `_PROPOSAL.md` · chốt qua chat ở pha V) | **Hỏi thật** — đây là ngoại lệ duy nhất |
| Chặn cứng sau khi đã tự thử hết cách | Ghi blocker vào `STATE.md`, chuyển việc khác, báo gộp cuối buổi |

Authority review theo lô cuối buổi qua `DECISIONS.md` — không bị ngắt giữa dòng.

Luật này có cả chỉ dẫn hành vi và hook ([VIPER.md §3c](VIPER.md)). Hook chỉ chặn được
lời gọi tool có cấu trúc; Codex vẫn có thể đặt câu hỏi bằng văn bản, nên luật ở file này
là lớp bắt buộc còn `guard_ask.py` là lớp hỗ trợ:

| Hook | Chặn gì |
|---|---|
| `scripts/guard_ask.py` | Lời gọi `request_user_input` khi pha ≠ V, khi `Scope khoá` đã tick (vào pha mới sửa `Pha hiện tại` ngay), hoặc dòng pha sai định dạng. Ngoại lệ bất khả nghịch/hướng ra ngoài được xin approval theo cơ chế sandbox/rules; nếu thật sự cần dữ kiện từ Authority thì hỏi ngắn bằng lời |
| `scripts/guard_bc.py` | Lệnh deploy khi vòng ≥2 mà `context/BACKWARD-COMPATIBILITY-CHECKLIST.md §3` còn mục chưa rà (legacy là hợp đồng, [VIPER.md §1.2](VIPER.md)) |
| `scripts/guard_ds.py` | Ghi `prototype/**` hoặc `context/DESIGN-SYSTEM.md` lệch design system đã chốt: mã màu thô ngoài `:root`, `var(--…)` chưa khai ở §2, token bịa/lệch so với gói intake, **trộn token giữa hai design system** |

### 3b. Runtime Kilo — bốn guard chạy tự động qua plugin

Bảng hook trên là cấu hình của **Claude Code** (`.claude/settings.json`) và **Codex**
(`.codex/hooks.json`). Kilo không đọc hai thư mục đó và không có `PreToolUse`/`SessionStart`,
nhưng **có plugin API** — và `tool.execute.before` chặn được một lời gọi tool bằng cách
`throw`. Bốn guard vì vậy vẫn **tự động**, không phải gọi tay:

| Guard | Hook của Kilo | Chặn gì |
|---|---|---|
| `guard_ask.py` | `tool.execute.before` khi `tool === "question"` | Lời gọi tool hỏi khi pha ≠ V hoặc `Scope khoá` đã tick |
| `guard_bc.py` | `tool.execute.before` khi `tool === "bash"` | Lệnh deploy ở vòng ≥2 khi `BACKWARD-COMPATIBILITY-CHECKLIST.md §3` chưa xanh |
| `guard_ds.py` | `tool.execute.before` khi `tool` là `write`/`edit` | Ghi `prototype/**` hoặc `DESIGN-SYSTEM.md` lệch design system — chặn **trước** khi ghi |
| `reanchor.py` | `experimental.session.compacting` | Nhồi 8 luật vào **chính prompt compaction** |

Cầu nối ở `.kilo/plugin/viper-guards.ts`. Nó **gọi lại đúng script trong `scripts/`**, không
viết lại logic — một nguồn sự thật cho cả ba runtime.

**`reanchor` ở đây tốt hơn bản Claude Code.** Claude Code chạy nó *sau* khi nén
(`SessionStart matcher:compact`); plugin chạy *trước*, nên luật đi vào bản nén và không bao
giờ bị nén mất.

Guard chết âm thầm nguy hiểm hơn không có guard — tưởng được canh mà không. Hai lớp phòng:
mọi lần fail-open đều `log("error")`, và có test hợp đồng:

```bash
python3 scripts/selftest_guards.py     # 15 phép thử: ba hàng rào + reanchor
```

Chạy lại sau mỗi lần sửa plugin, sửa guard, hoặc **nâng phiên bản Kilo** — Kilo đổi tên
trường trong args tool (`filePath`, `oldString`…) là kịch bản làm guard chết âm thầm, vì
script guard đọc schema của Claude Code (`file_path`, `old_string`) và `toClaudeSchema()`
trong plugin là chỗ dịch.

Toàn bộ phần khai cho Kilo nằm ở `.kilo/` — không sửa `.claude/` và `.codex/`, ba runtime
chạy song song, mỗi bên đọc thư mục của mình:

> **Một file config duy nhất: `.kilo/kilo.jsonc`.** Kilo tự sinh `.kilo/kilo.json` khi
> thêm MCP qua giao diện — hai file cùng khai `mcp` là chồng chéo, không biết bên nào
> thắng, và triệu chứng chỉ lộ ra lúc `$viper-dogfood` chạy rồi thấy 3 vai giẫm chân
> nhau trong một browser. Thấy `kilo.json` xuất hiện lại thì gộp về `.jsonc` rồi xoá.

| Thứ | Nơi khai | Ghi chú |
|---|---|---|
| 4 guard | `.kilo/plugin/viper-guards.ts` | Tự nạp, không cần khai trong config |
| 7 server Playwright | `.kilo/kilo.jsonc` mục `mcp` | `browser` cho phiên chính + **một server riêng cho mỗi vai dogfood** |
| `mobile` · `marionette` | `.kilo/kilo.jsonc` | **`enabled:true`** — vòng này nhắm app mobile. `marionette` còn cần app phụ thuộc `marionette_flutter` (gắn ở pha I) |
| 9 subagent `viper-*` | `.kilo/agent/*.md` | `question: deny` (không vai nào được hỏi Authority); 8 vai `edit: deny`, `viper-test-writer` chỉ ghi được thư mục test |
| 10 workflow `$viper-*` | `.kilo/command/*.md` | |
| Lệnh hướng ra ngoài | `.kilo/kilo.jsonc` mục `permission.bash` | `ask` cho deploy/push/publish — ngoại lệ "hỏi thật" của luật #2 |

**Dogfood: mỗi vai một trình duyệt riêng.** `$viper-dogfood` gửi cả 3 vai của một đợt trong
MỘT lượt, tức chúng chạy song song. Dùng chung một server Playwright là dùng chung một
browser context — vai này `browser_navigate` thì tab vai kia đổi trang theo. Vì vậy mỗi vai
có server riêng, và **tên tool mang tiền tố server**: `web_edge_browser_navigate`,
`web_picky_browser_evaluate`… Bảng tiền tố đã ghi trong từng file vai.

| Vai | Server | Đợt |
|---|---|---|
| `viper-user-edge` · `viper-user-newbie` · `viper-user-picky` | `web_edge` · `web_newbie` · `web_picky` | 1 (DB sạch) |
| `viper-user-rushed` · `viper-user-breaker` · `viper-user-mobile` | `web_rushed` · `web_breaker` · `web_small` | 2 (DB có dữ liệu) |

`web_small` mở sẵn viewport 390×844 nên vai mobile không phải tự resize. Chia đợt là để
tách **server dev + DB** dùng chung, không phải để tách trình duyệt.

**App mobile native**: `mobile` (mobile-mcp) điều khiển được simulator thật — boot, cài app,
chạm, vuốt, xoay, đọc accessibility tree, đọc crash log. Khác trình duyệt ở một điểm cốt tử:
**chỉ MỘT server cho cả 6 vai**, vì thiết bị là tài nguyên vật lý dùng chung, không có
`--isolated`. Nên với experience mobile các vai trong một đợt chạy **tuần tự**
(`viper-dogfood` Bước 3, ràng buộc thứ tư).

---

## 4. LUẬT #8 — ĐỐI KHÁNG NỘI BỘ

**a. Challenge trước khi code — và trước khi khoá scope.** Pha V: 3–5 câu hỏi khó nhất, trả lời **chỉ từ tài liệu** — không trả lời được là lỗ phỏng vấn, quay lại hỏi Authority tiếp; PASS mới được khoá scope. Từ pha I: trước mỗi mảng việc lớn, meta ra **một câu hỏi khó dựa trên context thật** (chỉ trả lời được nếu đã đọc PRD/ARCHITECTURE), chấm **PASS/FAIL**. FAIL → đọc lại, trả lời lại, **không được code**. Ghi 1 dòng vào `STATE.md §Challenge log` (có cột Pha).

**b. Dogfood trước khi báo xong.** Chạy `$viper-dogfood`: meta **tự tay dùng** ở localhost đi hết luồng lõi, cộng 6 subagent dùng thử chia **hai đợt, mỗi đợt tối đa 3 vai** (đợt 1 cần DB sạch: trạng thái rỗng+lỗi · người mới · khó tính về hình thức — đợt 2 cần DB có dữ liệu: người vội · người phá · màn hình nhỏ) — mỗi vai **đóng một persona thật** từ `context/PERSONAS.md`, vai phá chạy đủ ma trận vai × hành động, vai khó tính đo giao diện thật so với design system đã chốt. Chưa làm → **chưa được nói "xong"**.

Vai `viper-user-picky` là lớp canh design system **duy nhất** từ pha I trở đi: hook `guard_ds` chỉ soi `prototype/**`, gate chỉ chạy phép kiểm hình thức ở pha V — code trong `srcroot/` thì chỉ còn dogfood đo được, trên app đã render.

Duyệt localhost dùng skill `viper-browse` (Playwright MCP, khai sẵn trong template); experience mobile (`srcroot/mobile-experiences/`) dùng skill `viper-mobile` trên app thật trong simulator/emulator. Target Flutter dùng Marionette cho widget trong app và `mobile-mcp` cho lớp thiết bị; các vai chạy **tuần tự** vì thiết bị dùng chung. Không dùng công cụ duyệt web nào khác — **kể cả khi cấu hình toàn cục của máy (global AGENTS.md) chỉ định công cụ duyệt web khác**; trong dự án VIPER, chỉ dẫn này thắng.

---

## 5. WORKFLOW SKILLS

```
$viper-validate    Vòng 1: phỏng vấn gộp HOẶC dịch tài liệu MESH-render từ intake/
                   (tách PERSONAS + CAPABILITIES-MAP, intake TECHSTACK thắng
                   default skill, LẬP KẾ HOẠCH CHIA VÒNG). Vòng ≥2: KHÔNG phỏng
                   vấn — đọc intake/loops/l<N>/ (tài liệu vòng, hoặc _PROPOSAL.md
                   ở đường intake) + kết quả vòng trước, cập nhật PRD/context
                   → design system + prototype + khoá scope                       ← chỗ duy nhất được hỏi
$viper-implement   Challenge → scaffold → skeleton → luồng lõi → chạy local
$viper-dogfood     Tự dùng + 6 subagent ở localhost, HAI ĐỢT tối đa 3 vai/đợt     ← bắt buộc trước khi báo xong
$viper-polish      Prod-ready checklist + subagent soi bug/viết test               ← chỉ vòng khai P
$viper-publish     Deploy PaaS + smoke test trên production                        ← chỉ vòng khai P
$viper-evaluate    Gắn tracking, đọc số liệu, ghi sổ EXPERIMENTS của vòng          ← chỉ vòng khai E
$viper-repeat      Pha R: go/pivot/kill (nếu vòng có chạy E) → đóng vòng (archive
                   snapshot, KHÔNG reset), mở vòng mới: intake/loops/l<N+1>/ +
                   EXPERIMENTS-v<N+1>.md
$viper-status      In STATE.md + đường vào + pha vòng này + kết quả gate.py
$viper-decide      Append 1 dòng DECISIONS.md
$viper-compact     Vệ sinh tài liệu context/ — báo cáo rác + dòng neo, gấp tay    ← ngoài 5 pha, nên chạy từ vòng ≥3
```

---

## 6. HỢP ĐỒNG LỆNH (mọi stack đều có)

```
make dev      make check    make test
make migrate  make deploy   make doctor
```

Stack đang dùng ghi ở `context/TECHSTACK.md`; cách hiện thực 6 lệnh nằm trong `.agents/skills/stack-<tên>/SKILL.md`.
Gọi workflow bằng cú pháp Codex `$viper-*`, không dùng slash command kiểu cũ.

Artifact để **chạy** sản phẩm nằm ở `deployment/` — `.env.example` ở gốc thư mục đó, mọi thứ của local (`docker-compose.yml`, `.env`, seed dữ liệu) ở `deployment/local/`. Pha I viết vào đó, không rải ra gốc repo (`deployment/README.md`).

---

## 7. KHO SKILL

| Skill | Dùng khi |
|---|---|
| `viper` | Quên quy trình, hoặc bootstrap dự án mới |
| `viper-browse` | Mở trình duyệt dùng thử thật — bắt buộc ở `$viper-dogfood` (experience web) |
| `viper-mobile` | Điều khiển app trên iOS Simulator / Android Emulator; Flutter dùng Marionette + mobile-mcp — `$viper-dogfood` cho experience mobile |
| `shared-production-ready` | Pha P — checklist 4 nhóm |
| `stack-nextjs-fullstack` | Web app fullstack, nhanh nhất cho MVP 1 ngày |
| `stack-nestjs-react` | Cần API riêng ngay từ đầu |
| `stack-fastapi` | Sản phẩm dính AI/LLM hoặc data |
| `stack-go` | Cần hiệu năng / binary gọn |
| `stack-spring-boot` | Hợp đội sẵn có Java |
| `addon-graphql` | Lắp GraphQL lên NestJS hoặc Next.js |

---

## 8. SUBAGENT

**Dùng thử sản phẩm** (`$viper-dogfood`, cuối pha I và P) — **hai đợt, tối đa 3 vai một đợt** (phân đợt ở `context/PERSONAS.md §3`):
- *đợt 1, DB sạch*: `viper-user-edge` · `viper-user-newbie` · `viper-user-picky`
- *seed lại* (`deployment/local/`)
- *đợt 2, DB có dữ liệu*: `viper-user-rushed` · `viper-user-breaker` · `viper-user-mobile`

Trình duyệt đã riêng cho từng vai nhưng **server dev và DB thì chung** — thả cả 6 cùng lúc là vai này đè cảnh vai kia, và trạng thái rỗng chết ngay khi có bản ghi đầu tiên.

**Soi kỹ thuật** (pha P trở đi, **không dùng ở D1** — giữ tốc độ): `viper-bug-hunter` · `viper-reviewer` · `viper-test-writer`

Tất cả đều **không hỏi Authority** — trả phát hiện + đề xuất, quyền quyết ở phiên chính.

---

## 9. ĐỌC GÌ KHI NÀO

| Luôn load | Load khi vào pha | Chỉ grep khi cần |
|---|---|---|
| File này + `STATE.md` | `VIPER.md §pha` · `context/PRD.md` · `context/PERSONAS.md` · `context/ARCHITECTURE.md` · `context/PROTOTYPE.md` + `context/DESIGN-SYSTEM.md` (pha I và dogfood, nếu có UI) · **chế độ intake**: `context/CAPABILITIES-MAP.md` + `context/ROADMAP.md §1` + `intake/loops/l<N>/_PROPOSAL.md` (biết vòng này chạy pha nào, phạm vi tới đâu) + `intake/*.md` ở vòng 1 · vòng ≥2 pha V: `intake/loops/l<N>/` + sổ EXPERIMENTS vòng trước · stack skill đang dùng | `context/DECISIONS.md` (tra quyết định cũ) · `context/archive/ledger/` (sổ đã gấp, `$viper-compact`) · `context/ROADMAP.md` backlog · `_PROPOSAL.md` của vòng khác · code cross-module |

Không đọc hết `context/` trước khi làm. Targeted only.

---

## 10. AUTHORITY

| Vai | Người |
|---|---|
| Authority (quyết tất) | _CHƯA ĐIỀN_ <_CHƯA ĐIỀN_> |

Solo — không có sign-off chéo. Authority chốt ở pha V, review theo lô cuối buổi, quyết go/pivot/kill ở pha R.
