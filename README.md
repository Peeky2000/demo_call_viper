# KaiCall

Demo cuộc gọi video qua LiveKit trên Android: danh bạ 2 người, bấm gọi, máy kia
hiện màn cuộc gọi đến với Nghe / Từ chối. Làm cho người viết code — một bản
"chạy được" mà **có luồng như app thật và xử được ca biên**, để lần sau cần call
thì bóc `lib/domain` + `lib/application` ra dùng lại, không phải dựng lại từ đầu.

Dựng theo quy trình **VIPER**: solo, một tuần, production-ready.
Luật và năm pha: [VIPER.md](VIPER.md) · Đang ở đâu: [STATE.md](STATE.md)

---

## Chạy

```bash
cp deployment/.env.example deployment/local/.env   # rồi điền 4 giá trị
make doctor   # kiểm 4 biến + liệt kê thiết bị
make dev      # chạy lên máy/emulator đang cắm
make check    # flutter analyze
make test     # 22 test — máy trạng thái + ký token + tên phòng
make deploy   # build APK debug để cài tay
make migrate  # không có DB — in ra lý do rồi thoát
```

**Chạy đúng bản Flutter đã ghim (3.41.9).** `~/fvm/default` đang là 3.44.8 và
chạy test bằng bản đó sẽ đỏ vì lệch shader (`ink_sparkle.frag`), không phải vì
code sai. Makefile đã trỏ sẵn `~/fvm/versions/3.41.9`.

**Thử gọi cần HAI đầu**: một máy Android thật + một emulator. Mở app ở cả hai,
một bên bấm "đổi sang …" để hai máy đóng hai vai khác nhau, rồi bấm gọi.
Emulator mic là giả — ca "nghe rõ không" phải kiểm bằng tai trên máy thật.

## Trạng thái

```bash
python3 scripts/gate.py     # gate của pha hiện tại còn thiếu gì
```

## Tài liệu

| File | Nội dung |
|---|---|
| [context/PRD.md](context/PRD.md) | Pain point · đối tượng · AC · out-of-scope · success metric |
| [context/INTERVIEW.md](context/INTERVIEW.md) | Sổ phỏng vấn pha V — 14 mục, mỗi mục có bằng chứng |
| [context/PERSONAS.md](context/PERSONAS.md) | Persona · năng lực được cấp · ma trận vai × hành động |
| [context/CAPABILITIES-MAP.md](context/CAPABILITIES-MAP.md) | Đường intake: bản đồ năng lực tách từ `intake/PRD.md §3` |
| [context/DESIGN-SYSTEM.md](context/DESIGN-SYSTEM.md) | Token · tương phản · kho component — nguồn sự thật cho hình thức |
| [context/PROTOTYPE.md](context/PROTOTYPE.md) | Bản đồ màn hình · map AC ↔ màn hình · vết Authority chốt prototype |
| [context/ARCHITECTURE.md](context/ARCHITECTURE.md) | Sơ đồ · mô hình dữ liệu · luồng lõi · ranh giới module |
| [context/TECHSTACK.md](context/TECHSTACK.md) | Stack + version đã chốt |
| [context/DECISIONS.md](context/DECISIONS.md) | Mọi quyết định, append-only |
| [context/ROADMAP.md](context/ROADMAP.md) | Tuần này + backlog Phase 2 |
| [context/shared/DEPLOY.md](context/shared/DEPLOY.md) | Nơi chạy · env · migration · **rollback** |

## Bắt đầu

```bash
claude
/viper-validate     # pha V — nơi DUY NHẤT được hỏi Authority
```

Có sẵn tài liệu MESH-render? Thả vào `intake/` (xem [intake/README.md](intake/README.md))
trước khi chạy `/viper-validate` — pha V sẽ đi **đường intake**: dịch tài liệu thay cho
phỏng vấn (`VIPER.md §1.3`).
