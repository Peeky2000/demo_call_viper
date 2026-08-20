#!/usr/bin/env python3
"""selftest_guards.py — kiểm hợp đồng giữa plugin Kilo và ba guard script.

VÌ SAO CÓ FILE NÀY
    `.kilo/plugin/viper-guards.ts` dịch args tool của Kilo (camelCase: `filePath`,
    `oldString`…) sang schema mà guard script mong đợi (snake_case, bọc trong
    `tool_input`). Dịch sai thì guard nhận payload rỗng, exit 0, và **im lặng cho qua
    mọi thứ** — hàng rào biến thành trang trí mà không ai biết.

    File này kiểm đúng một câu hỏi: đưa payload y như plugin dựng, guard có phán
    quyết đúng không. Nó KHÔNG kiểm logic bên trong guard (mỗi script tự lo).

CHẠY
    python3 scripts/selftest_guards.py

    Exit 0 = ba hàng rào đều phản ứng đúng. Exit 1 = có hàng rào chết.
    Chạy lại sau mỗi lần sửa plugin, sửa guard, hoặc nâng phiên bản Kilo (schema tool
    của Kilo đổi tên trường là kịch bản làm guard chết âm thầm).

    Test dùng thư mục tạm cho các ca cần STATE.md ở trạng thái khác — không đụng
    STATE.md thật của dự án.
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"

PASS = "  ok  "
FAIL = " FAIL "


def run(script: Path, payload: dict, cwd: Path) -> tuple[int, str]:
    """Gọi guard script y như plugin gọi: payload JSON qua stdin."""
    proc = subprocess.run(
        [sys.executable, str(script)],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        cwd=str(cwd),
    )
    return proc.returncode, (proc.stderr or proc.stdout).strip()


# ── Bản dịch schema — PHẢI khớp toClaudeSchema() trong viper-guards.ts ────────────
def to_claude_schema(tool: str, args: dict) -> dict:
    if tool == "bash":
        return {"command": str(args.get("command") or "")}
    if tool == "write":
        return {
            "file_path": str(args.get("filePath") or ""),
            "content": str(args.get("content") or ""),
        }
    if tool == "edit":
        return {
            "file_path": str(args.get("filePath") or ""),
            "old_string": str(args.get("oldString") or ""),
            "new_string": str(args.get("newString") or ""),
            "replace_all": bool(args.get("replaceAll") or False),
        }
    return {}


results: list[tuple[bool, str]] = []


def check(name: str, ok: bool, detail: str = "") -> None:
    results.append((ok, name))
    print(f"[{PASS if ok else FAIL}] {name}" + (f"\n            {detail}" if detail and not ok else ""))


# ── 1. guard_ask — luật #2 ───────────────────────────────────────────────────────
print("\nguard_ask.py — luật #2 (không hỏi Authority sau khi khoá scope)")

with tempfile.TemporaryDirectory() as td:
    tmp = Path(td)
    (tmp / "scripts").mkdir()
    shutil.copy(SCRIPTS / "guard_ask.py", tmp / "scripts" / "guard_ask.py")

    # Ca 1: pha V, chưa khoá scope → phải CHO QUA
    (tmp / "STATE.md").write_text("Pha hiện tại : V\nVòng          : 1\n", encoding="utf-8")
    code, _ = run(tmp / "scripts" / "guard_ask.py", {}, tmp)
    check("pha V, chưa khoá scope → cho hỏi", code == 0, f"exit={code}, muốn 0")

    # Ca 2: pha I → phải CHẶN
    (tmp / "STATE.md").write_text("Pha hiện tại : I\nVòng          : 1\n", encoding="utf-8")
    code, msg = run(tmp / "scripts" / "guard_ask.py", {}, tmp)
    check("pha I → chặn", code != 0, f"exit={code}, muốn ≠0")
    check("thông điệp chặn nhắc luật #2", "LUẬT #2" in msg, f"stderr={msg[:80]!r}")

    # Ca 3: scope đã khoá (kể cả khi dòng pha còn ghi V) → phải CHẶN
    (tmp / "STATE.md").write_text(
        "Pha hiện tại : V\n\n## Gate\n- [x] **Scope khoá** — từ đây không hỏi nữa\n",
        encoding="utf-8",
    )
    code, _ = run(tmp / "scripts" / "guard_ask.py", {}, tmp)
    check("scope đã khoá dù pha ghi V → chặn", code != 0, f"exit={code}, muốn ≠0")

# ── 2. guard_bc — legacy là hợp đồng ────────────────────────────────────────────
print("\nguard_bc.py — không deploy khi legacy chưa rà (vòng ≥2)")

# Lệnh thường phải cho qua, và payload phải đúng khoá `tool_input.command`.
code, _ = run(SCRIPTS / "guard_bc.py", {"tool_input": to_claude_schema("bash", {"command": "ls -la"})}, ROOT)
check("lệnh thường (ls) → cho qua", code == 0, f"exit={code}, muốn 0")

# Hợp đồng schema: guard_bc đọc tool_input.command. Payload sai khoá thì nó
# thấy chuỗi rỗng và cho qua — đó chính là kiểu chết âm thầm cần bắt.
schema = to_claude_schema("bash", {"command": "make deploy"})
check("bash: args.command → tool_input.command", schema.get("command") == "make deploy", f"dịch ra {schema!r}")

# ── 3. guard_ds — design system là hợp đồng hình thức ───────────────────────────
print("\nguard_ds.py — không ghi prototype lệch design system")

# Ca 1: file ngoài phạm vi → cho qua (chạy trên dự án thật, không cần fixture)
code, _ = run(
    SCRIPTS / "guard_ds.py",
    {"tool_input": to_claude_schema("write", {"filePath": "README.md", "content": "x"})},
    ROOT,
)
check("file ngoài prototype → cho qua", code == 0, f"exit={code}, muốn 0")

# Ca 2–4 cần một design system ĐÃ CHỐT. Trên dự án chưa qua pha V,
# context/DESIGN-SYSTEM.md còn `_CHƯA ĐIỀN_` nên guard_ds fail-open đúng theo spec
# (chưa chốt thì chưa có hợp đồng nào để đối chiếu) — chạy trên đó sẽ ra exit 0 và
# nhìn giống hàng rào chết. Vì vậy dựng fixture riêng có bảng token thật.
DS_FIXTURE = """# DESIGN-SYSTEM

## 2. Token

### 2.1 Màu

| Token | Giá trị | Dùng cho |
|---|---|---|
| `--color-bg` | `#FFFFFF` | nền trang |
| `--color-text` | `#1A1A1A` | chữ chính |
| `--color-primary` | `#1E40AF` | hành động chính |
| `--color-on-primary` | `#FFFFFF` | chữ trên nền primary |

## 3. Tương phản
"""

with tempfile.TemporaryDirectory() as td:
    tmp = Path(td)
    (tmp / "scripts").mkdir()
    (tmp / "context").mkdir()
    (tmp / "prototype").mkdir()
    shutil.copy(SCRIPTS / "guard_ds.py", tmp / "scripts" / "guard_ds.py")
    (tmp / "context" / "DESIGN-SYSTEM.md").write_text(DS_FIXTURE, encoding="utf-8")
    guard_ds = tmp / "scripts" / "guard_ds.py"

    # Ca 2: mã màu thô ngoài :root → phải CHẶN.
    # Phép thử quan trọng nhất của cả file: bản dịch schema sai thì guard_ds đọc
    # content rỗng, exit 0, và mọi vi phạm design system lọt hết.
    raw_color_html = """<!doctype html>
<html><head><style>
:root { --color-primary: #1E40AF; }
.cta { background: #FF00AA; }
</style></head><body><button class="cta">Gửi</button></body></html>
"""
    code, msg = run(
        guard_ds,
        {"tool_input": to_claude_schema("write", {"filePath": "prototype/index.html", "content": raw_color_html})},
        tmp,
    )
    check("mã màu thô ngoài :root → chặn", code != 0, f"exit={code}, muốn ≠0. stderr={msg[:120]!r}")
    check("thông điệp chặn chỉ đích danh mã màu", "#ff00aa" in msg.lower(), f"stderr={msg[:120]!r}")

    # Ca 3: prototype lắp đúng từ token → phải CHO QUA.
    # Thiếu ca này thì một guard chặn-tất-cả cũng "xanh" ở ca 2.
    clean_html = """<!doctype html>
<html><head><style>
:root {
  --color-bg: #FFFFFF;
  --color-text: #1A1A1A;
  --color-primary: #1E40AF;
  --color-on-primary: #FFFFFF;
}
body { background: var(--color-bg); color: var(--color-text); }
.cta { background: var(--color-primary); color: var(--color-on-primary); }
</style></head><body><button class="cta">Gửi</button></body></html>
"""
    code, msg = run(
        guard_ds,
        {"tool_input": to_claude_schema("write", {"filePath": "prototype/index.html", "content": clean_html})},
        tmp,
    )
    check("prototype lắp đúng từ token → cho qua", code == 0, f"exit={code}, muốn 0. stderr={msg[:120]!r}")

    # Ca 4: dùng var(--…) chưa khai ở §2 → phải CHẶN
    ghost_token_html = clean_html.replace(
        ".cta { background: var(--color-primary);", ".cta { background: var(--color-accent-hot);"
    )
    code, msg = run(
        guard_ds,
        {"tool_input": to_claude_schema("write", {"filePath": "prototype/index.html", "content": ghost_token_html})},
        tmp,
    )
    check("token bịa (chưa khai ở §2) → chặn", code != 0, f"exit={code}, muốn ≠0. stderr={msg[:120]!r}")

# Ca 5: hợp đồng schema cho edit
schema = to_claude_schema(
    "edit",
    {"filePath": "prototype/index.html", "oldString": "a", "newString": "b", "replaceAll": True},
)
check(
    "edit: oldString/newString/replaceAll → old_string/new_string/replace_all",
    schema.get("old_string") == "a" and schema.get("new_string") == "b" and schema.get("replace_all") is True,
    f"dịch ra {schema!r}",
)

# ── 4. reanchor — nhồi luật khi compact ────────────────────────────────────────
print("\nreanchor.py — nhồi 8 luật vào prompt compaction")

proc = subprocess.run([sys.executable, str(SCRIPTS / "reanchor.py")], capture_output=True, text=True, cwd=str(ROOT))
ok_json, ctx = False, ""
try:
    ctx = json.loads(proc.stdout).get("hookSpecificOutput", {}).get("additionalContext", "")
    ok_json = isinstance(ctx, str) and bool(ctx.strip())
except (json.JSONDecodeError, AttributeError):
    pass
check("in ra JSON có hookSpecificOutput.additionalContext", ok_json, f"stdout={proc.stdout[:120]!r}")
check("nội dung nhồi có TÁM LUẬT", "TÁM LUẬT" in ctx, "không thấy chuỗi 'TÁM LUẬT'")
check("nội dung nhồi có pha hiện tại", "Pha hiện tại" in ctx, "không thấy 'Pha hiện tại'")

# ── Tổng kết ───────────────────────────────────────────────────────────────────
failed = [name for ok, name in results if not ok]
print(f"\n{'─' * 70}")
if failed:
    print(f"✗ {len(failed)}/{len(results)} phép thử ĐỎ — có hàng rào đang chết:")
    for name in failed:
        print(f"    · {name}")
    print("\nGuard chết âm thầm nguy hiểm hơn không có guard: tưởng được canh mà không.")
    sys.exit(1)

print(f"✓ {len(results)}/{len(results)} — ba hàng rào phản ứng đúng, reanchor nhồi được luật")
sys.exit(0)
