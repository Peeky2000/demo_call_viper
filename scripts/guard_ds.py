#!/usr/bin/env python3
"""guard_ds.py — hook PreToolUse: design system đã chốt thì phải theo.

VÌ SAO CÓ FILE NÀY
    Pha V chốt `context/DESIGN-SYSTEM.md` TRƯỚC rồi mới dựng prototype, để prototype
    chỉ còn là lắp ráp từ token + kho component (VIPER.md §1.1). Nhưng lúc dựng HTML,
    cám dỗ lớn nhất là gõ thẳng `#3B82F6` hoặc `font-size: 15px` cho nhanh — nhanh hơn
    thật, và giết sạch tác dụng của design system: phản hồi "chữ nhỏ quá" của Authority
    lẽ ra sửa MỘT token rồi lan ra mọi màn, nay thành đi sửa tay từng chỗ.
    Ở đường intake còn nặng hơn: gói `intake/design-systems/<ds>/tokens.json` là hợp
    đồng Authority đưa sẵn — bịa thêm token hay đổi giá trị của nó là sửa hợp đồng.

    gate.py bắt được cả hai lỗi này, nhưng gate chỉ BÁO và chỉ chạy khi có người gọi.
    Thực chiến cho thấy cấm bằng văn xuôi không giữ được luật, nhất là sau compact —
    nên chỗ này chặn cứng ngay lúc ghi file, cùng triết lý với guard_ask / guard_bc.

CHẶN ĐÚNG BA LỖI
    1. BỊA MÀU    — mã màu thô (#hex, rgb(), hsl()) trong prototype, ngoài khối :root
    2. BỊA TOKEN  — prototype dùng var(--x) mà DESIGN-SYSTEM.md §2 không khai
    3. PHÁ HỢP ĐỒNG — DESIGN-SYSTEM.md §2 thêm/sửa token lệch tokens.json của intake

    Chỉ chặn lỗi MỚI so với bản đang nằm trên đĩa. File bẩn từ trước (viết lúc hook
    chưa có hiệu lực) là việc của gate V; edit không thêm lỗi — kể cả edit sửa dần
    từng lỗi một — phải đi qua, không thì hook bắt đền lỗi cũ và Edit không sửa nổi.

CHẠY NHƯ THẾ NÀO
    Codex gọi qua hook PreToolUse matcher "Write|Edit" cho apply_patch:
    `tool_input.command` chứa toàn bộ patch. Hook dựng nội dung prospective của mọi
    Add/Update/Delete block rồi mới kiểm, nên một patch sửa nhiều file không lọt.

    Schema editor cũ (`file_path` + `content` / `new_string` / `edits[]`) vẫn được
    nhận để dự án sinh từ phiên bản template trước không gãy trong lúc chuyển đổi.
    exit 0: cho qua · exit 2: CHẶN, stderr được đưa lại cho model

    Fail-open có chủ đích: JSON hỏng · file ngoài phạm vi · DESIGN-SYSTEM.md chưa
    điền hoặc mang marker KHÔNG CÓ UI · §2 chưa khai token nào → cho qua. Chưa chốt
    design system thì chưa có gì để mà theo; hook an toàn không chặn nhầm phiên.

Exit codes: 0 cho qua · 2 chặn
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DS = "context/DESIGN-SYSTEM.md"
UNFILLED = "_CHƯA ĐIỀN_"  # giống scripts/gate.py — còn dấu này là DS chưa chốt

# Màu thô. Cố tình KHÔNG bắt độ dài/khoảng cách (px, rem): nhịp trong prototype có
# chỗ chính đáng phải viết thẳng (ví dụ chiều rộng khung demo), bắt hết thành nhiễu
# rồi bị tắt hook. Màu thì không có ngoại lệ nào chính đáng — nó luôn thuộc về token.
RAW_COLOR = re.compile(r"#[0-9a-fA-F]{3,8}\b|\b(?:rgba?|hsla?)\s*\(", re.IGNORECASE)

# Từ khoá CSS không phải token — tránh báo nhầm khi HTML dùng biến của thư viện.
COMMENT_HTML = re.compile(r"<!--.*?-->", re.DOTALL)
COMMENT_CSS = re.compile(r"/\*.*?\*/", re.DOTALL)
PATCH_HEADER = re.compile(r"^\*\*\* (Add|Update|Delete) File: (.+)$")


class FileChange:
    """Một file trước/sau tool call; ``after=None`` nghĩa là bị xoá."""

    def __init__(self, rel: str, before: str | None, after: str | None):
        self.rel = rel
        self.before = before
        self.after = after


def read(rel: str) -> str:
    try:
        return (ROOT / rel).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return ""


def table_cells(text: str) -> list[tuple[list[str], list[str]]]:
    """Mọi dòng dữ liệu của mọi bảng markdown trong text → (ô tiêu đề, ô dữ liệu).

    Đọc cột theo TÊN chứ không theo VỊ TRÍ — bảng §2 và bảng experience đều được nối
    thêm cột `DS` ở cuối để đỡ nhiều design system. Giữ ĐỒNG BỘ với gate.py.
    """
    out: list[tuple[list[str], list[str]]] = []
    header: list[str] | None = None
    prev: list[str] | None = None
    for line in text.splitlines():
        s = line.strip()
        if not s.startswith("|"):
            header, prev = None, None
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        if cells and all(re.fullmatch(r":?-{2,}:?", c) for c in cells):
            header, prev = prev, None
            continue
        if header is None:
            prev = cells
            continue
        out.append((header, cells))
    return out


def cell_of(header: list[str], cells: list[str], *names: str) -> str:
    """Ô thuộc cột mang một trong các tên `names`. Bảng không có cột đó → chuỗi rỗng."""
    low = [h.strip().lower() for h in header]
    for n in names:
        if n in low:
            i = low.index(n)
            return cells[i].strip() if i < len(cells) else ""
    return ""


def ds_token_rows(text: str) -> list[tuple[str, str, str]]:
    """(ds, token, giá trị) cho mỗi dòng token. Giữ ĐỒNG BỘ với gate.py.

    Dễ tính hơn table_cells(): dòng token không có tiêu đề phía trên vẫn nhận (ds
    rỗng) — hook soi mảnh nội dung sắp ghi, mảnh đó thường là một dòng bảng rời.
    """
    out: list[tuple[str, str, str]] = []
    header: list[str] = []
    prev: list[str] | None = None
    for line in text.splitlines():
        s = line.strip()
        if not s.startswith("|"):
            header, prev = [], None
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        if cells and all(re.fullmatch(r":?-{2,}:?", c) for c in cells):
            header, prev = (prev or []), None
            continue
        m = re.fullmatch(r"`(--[a-z0-9-]+)`", cells[0]) if cells else None
        if m and len(cells) >= 2:
            out.append((cell_of(header, cells, "ds", "design system").strip("`"),
                        m.group(1), cells[1]))
        else:
            prev = cells
    return out


def intake_packages() -> list[Path]:
    """Gói design system thật — bỏ `_*` và `{{…}}` của template. Giữ ĐỒNG BỘ với gate.py."""
    return [p for p in sorted((ROOT / "intake" / "design-systems").glob("*/tokens.json"))
            if not p.parent.name.startswith(("_", "{{"))]


def sole_ds() -> str | None:
    """Tên gói khi dự án chỉ có ĐÚNG MỘT design system — bản lề giữ tương thích ngược."""
    pkgs = intake_packages()
    return pkgs[0].parent.name if len(pkgs) == 1 else None


def ds_map(architecture_text: str | None = None) -> dict[str, str]:
    """experience → tên gói design system, từ cột `Design system` của ARCHITECTURE §2–§3.

    Nguồn ánh xạ DUY NHẤT của cả hệ; tên experience đồng thời là thư mục
    `prototype/<tên>/` nên hook tra được gói của file đang ghi. Giữ ĐỒNG BỘ với gate.py.
    """
    live = COMMENT_HTML.sub(
        "", read("context/ARCHITECTURE.md") if architecture_text is None else architecture_text)

    def sect(header: str) -> str:
        i = live.find(header)
        if i < 0:
            return ""
        j = live.find("\n## ", i + len(header))
        return live[i: j if j > 0 else len(live)]

    text = sect("\n## 2.") + "\n\n" + sect("\n## 3.")
    out: dict[str, str] = {}
    for header, cells in table_cells(text):
        exp = cells[0].strip().strip("`") if cells else ""
        ds = cell_of(header, cells, "design system", "ds").strip("`")
        if (exp and ds and UNFILLED not in exp and UNFILLED not in ds
                and exp not in {"—", "-"} and ds not in {"—", "-"}):
            out[exp] = ds
    return out


def declared_tokens(design_system_text: str | None = None) -> dict[tuple[str, str], str]:
    """Token khai ở DESIGN-SYSTEM.md §2 → {(ds, token): giá trị}.

    Một gói thì ô `DS` để trống cũng được — sole_ds() quy nó về gói duy nhất, nên
    dự án đang chạy không phải sửa bảng.
    """
    text = COMMENT_HTML.sub(
        "", read(DS) if design_system_text is None else design_system_text)
    i = text.find("\n## 2.")
    if i < 0:
        return {}
    j = text.find("\n## ", i + 6)
    sole = sole_ds()
    return {(ds or sole or "", tok): val
            for ds, tok, val in ds_token_rows(text[i: j if j > 0 else len(text)])}


def tokens_for(tokens: dict[tuple[str, str], str], ds: str | None) -> dict[str, str]:
    """Lát token của một design system → {token: giá trị}. ds rỗng → cả bảng."""
    if not ds:
        return {t: v for (_d, t), v in tokens.items()}
    return {t: v for (d, t), v in tokens.items() if d in ("", ds)}


def ds_for_prototype(rel: str, architecture_text: str | None = None) -> str | None:
    """Gói design system của file prototype đang ghi, suy từ `prototype/<experience>/…`.

    `prototype/index.html` (đường phỏng vấn) và experience chưa có trong ánh xạ →
    None, tức là đối chiếu với cả bảng token. Fail-open có chủ đích: hook không đoán
    mò gói cho một thư mục lạ, gate V mới là chỗ đòi khai đủ ánh xạ.
    """
    parts = rel.split("/")
    return ds_map(architecture_text).get(parts[1]) if len(parts) >= 3 else None


def intake_tokens() -> tuple[dict[tuple[str, str], set[str]], str | None]:
    """Gói token Authority đưa sẵn: intake/design-systems/<ds>/tokens.json.

    Đọc `$value` (Design Token Format), `value` thuần, và chuỗi trần; bỏ qua khoá bắt
    đầu bằng `$`/`_` (metadata). Đặc tả: intake/design-systems/{{ds-name}}/
    _TOKENS-TEMPLATE.json.

    KHOÁ THEO GÓI (ds, token), KHÔNG hợp nhất: gộp phẳng thì hai gói cùng khai
    `color.primary` khác giá trị sẽ che nhau, một gói biến mất mà không ai báo.
    Gói hỏng bị bỏ qua (fail-open; gate.py mới là chỗ báo đỏ). Giữ ĐỒNG BỘ với
    intake_tokens() trong gate.py — hai chỗ phải hiểu gói giống hệt nhau, lệch nhau
    thì hook chặn cái mà gate cho qua (hoặc ngược lại) và không ai tin nữa.
    """
    real = intake_packages()
    if not real:
        return {}, None

    flat: dict[tuple[str, str], set[str]] = {}

    def walk(node: object, trail: list[str], ds: str) -> None:
        if isinstance(node, dict):
            for key in ("$value", "value"):
                if key in node and not isinstance(node[key], (dict, list)):
                    flat.setdefault((ds, "--" + "-".join(trail)), set()).add(
                        str(node[key]).strip())
                    return
            for k, v in node.items():
                if str(k).startswith(("$", "_")):
                    continue
                walk(v, trail + [str(k).strip().lower().replace(" ", "-")], ds)
        elif isinstance(node, (str, int, float)) and trail:
            flat.setdefault((ds, "--" + "-".join(trail)), set()).add(str(node).strip())

    for path in real:
        try:
            walk(json.loads(path.read_text(encoding="utf-8")), [], path.parent.name)
        except (OSError, ValueError):
            continue  # gói hỏng → fail-open, gate.py sẽ báo đỏ
    return flat, ", ".join(str(p.relative_to(ROOT)) for p in real)


def norm(v: str) -> str:
    v = v.strip().strip("`").lower()
    m = re.fullmatch(r"#([0-9a-f]{3})", v)
    return "#" + "".join(c * 2 for c in m.group(1)) if m else v


def written_text(tool_input: dict, rel: str) -> str | None:
    """Nội dung file SAU khi tool ghi xong.

    Write: `content` đã là cả file. Edit/MultiEdit: dựng lại nội dung sau-edit từ
    file trên đĩa — soi mỗi fragment `new_string` rời thì thiếu ngữ cảnh, sửa giá
    trị token NGAY TRONG :root cũng bị bắt oan là "mã màu thô ngoài :root", trong
    khi đó chính là thao tác spec khuyến khích (phản hồi của Authority → sửa MỘT
    token). Không dựng lại được (file chưa tồn tại, old_string không khớp) → None:
    chính lệnh Edit cũng sẽ lỗi ở tầng tool, không có gì sắp được ghi — fail-open.
    """
    if "content" in tool_input:
        return str(tool_input.get("content") or "")
    edits = tool_input.get("edits")
    if not isinstance(edits, list):
        edits = [tool_input]
    try:
        text = (ROOT / rel).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return None
    for e in edits:
        if not isinstance(e, dict):
            continue
        old = str(e.get("old_string") or "")
        if not old:
            continue
        if old not in text:
            return None
        new = str(e.get("new_string") or "")
        text = text.replace(old, new) if e.get("replace_all") else text.replace(old, new, 1)
    return text


def relative_path(raw_path: str) -> str | None:
    """Chuẩn hoá path từ hook/patch và chặn path thoát khỏi project root."""
    if not raw_path.strip():
        return None
    path = Path(raw_path.strip())
    if not path.is_absolute():
        path = ROOT / path
    try:
        return path.resolve().relative_to(ROOT.resolve()).as_posix()
    except (OSError, ValueError):
        return None


def disk_text(rel: str) -> str | None:
    """Đọc file UTF-8; None phân biệt file không tồn tại với file rỗng."""
    try:
        path = ROOT / rel
        if not path.is_file():
            return None
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return None


def find_lines(haystack: list[str], needle: list[str], start: int,
               *, require_eof: bool = False) -> int | None:
    """Tìm context của một hunk, exact trước rồi mới tolerant như apply_patch.

    Nhánh tolerant chỉ bỏ khoảng trắng hai đầu để nhận patch có indentation context
    hơi khác. Khi thay, dòng context thật từ file vẫn được giữ nguyên, nên tolerance
    không âm thầm reformat nội dung.
    """
    if not needle:
        return len(haystack) if require_eof else min(start, len(haystack))
    last = len(haystack) - len(needle)
    candidates = range(max(0, start), last + 1)
    for i in candidates:
        if haystack[i:i + len(needle)] == needle and (not require_eof or i + len(needle) == len(haystack)):
            return i
    for i in range(max(0, start), last + 1):
        if ([line.strip() for line in haystack[i:i + len(needle)]]
                == [line.strip() for line in needle]
                and (not require_eof or i + len(needle) == len(haystack))):
            return i
    return None


def apply_update_patch(text: str, body: list[str]) -> str | None:
    """Áp một Update block lên text mà không ghi đĩa; không chắc thì fail-open.

    Đây là subset đầy đủ cho format apply_patch của Codex: nhiều hunk, header `@@`
    có hoặc không có anchor, context/add/delete line, và `*** End of File`.
    `*** Move to:` cố tình chưa nhận vì delta của move cần baseline ở path nguồn;
    đoán sai sẽ chặn oan một rename hợp lệ.
    """
    if any(line.startswith("*** Move to:") for line in body):
        return None

    source = text.splitlines()
    trailing_newline = text.endswith(("\n", "\r"))
    cursor = 0
    i = 0
    saw_hunk = False

    while i < len(body):
        header = body[i]
        if not header.startswith("@@"):
            return None
        saw_hunk = True
        hint = header[2:].strip()
        i += 1

        ops: list[tuple[str, str]] = []
        require_eof = False
        while i < len(body) and not body[i].startswith("@@"):
            line = body[i]
            i += 1
            if line == "*** End of File":
                require_eof = True
                if i < len(body) and not body[i].startswith("@@"):
                    return None
                break
            if not line or line[0] not in " +-":
                return None
            ops.append((line[0], line[1:]))

        old = [line for tag, line in ops if tag in " -"]
        search_from = cursor
        # `@@ def foo():` là skip-ahead anchor của apply_patch, không phải unified
        # diff range. Nếu không tìm thấy anchor, vẫn thử context từ cursor.
        if hint and not re.fullmatch(r"-?\d+(?:,\d+)?(?:\s+\+\d+(?:,\d+)?)?\s*@@?", hint):
            anchor = find_lines(source, [hint], cursor)
            if anchor is not None:
                search_from = anchor + 1

        pos = find_lines(source, old, search_from, require_eof=require_eof)
        if pos is None and search_from != cursor:
            pos = find_lines(source, old, cursor, require_eof=require_eof)
        if pos is None:
            return None

        replacement: list[str] = []
        src_i = pos
        for tag, line in ops:
            if tag == "+":
                replacement.append(line)
                continue
            if src_i >= len(source):
                return None
            actual = source[src_i]
            if actual != line and actual.strip() != line.strip():
                return None
            if tag == " ":
                replacement.append(actual)
            src_i += 1

        source[pos:src_i] = replacement
        cursor = pos + len(replacement)

    if not saw_hunk:
        return None
    result = "\n".join(source)
    return result + ("\n" if trailing_newline else "")


def parse_apply_patch(command: str) -> list[FileChange] | None:
    """Dựng final state cho mọi file trong một Codex apply_patch command.

    Nhiều block chạm cùng file được áp tuần tự. Kết quả chỉ giữ một change/file,
    với ``before`` từ trước tool call và ``after`` sau block cuối cùng.
    """
    lines = command.splitlines()
    try:
        begin = lines.index("*** Begin Patch")
        end = len(lines) - 1 - lines[::-1].index("*** End Patch")
    except ValueError:
        return None
    if begin >= end or any(line.strip() for line in lines[:begin] + lines[end + 1:]):
        return None

    states: dict[str, str | None] = {}
    befores: dict[str, str | None] = {}
    order: list[str] = []

    def current(rel: str) -> str | None:
        if rel not in states:
            states[rel] = disk_text(rel)
            befores[rel] = states[rel]
            order.append(rel)
        return states[rel]

    i = begin + 1
    while i < end:
        match = PATCH_HEADER.match(lines[i])
        if match is None:
            return None
        kind, raw_path = match.groups()
        rel = relative_path(raw_path)
        if rel is None:
            return None
        i += 1
        body: list[str] = []
        while i < end and PATCH_HEADER.match(lines[i]) is None:
            body.append(lines[i])
            i += 1

        before_block = current(rel)
        if kind == "Add":
            if before_block is not None or any(not line.startswith("+") for line in body):
                return None
            states[rel] = "\n".join(line[1:] for line in body) + ("\n" if body else "")
        elif kind == "Delete":
            if before_block is None or body:
                return None
            states[rel] = None
        else:
            if before_block is None:
                return None
            updated = apply_update_patch(before_block, body)
            if updated is None:
                return None
            states[rel] = updated

    return [FileChange(rel, befores[rel], states[rel]) for rel in order]


def legacy_change(tool_input: dict) -> FileChange | None:
    """Adapter schema Write/Edit/MultiEdit cũ."""
    rel = relative_path(str(tool_input.get("file_path") or ""))
    if rel is None:
        return None
    after = written_text(tool_input, rel)
    if after is None:
        return None
    return FileChange(rel, disk_text(rel), after)


def strip_root_blocks(css: str) -> str:
    """Bỏ nội dung mọi khối :root{…} — đó là chỗ DUY NHẤT được viết mã màu thô.

    Token phải quy về giá trị thật ở đâu đó; :root là nơi đó. Mọi chỗ khác dùng var().
    """
    return re.sub(r":root\s*\{[^}]*\}", ":root{}", css, flags=re.IGNORECASE)


def proto_violations(text: str, tokens: dict[str, str]) -> tuple[set[str], set[str]]:
    """(mã màu thô ngoài :root, token dùng mà §2 chưa khai) của một bản nội dung."""
    body = COMMENT_CSS.sub("", COMMENT_HTML.sub("", text))
    outside = strip_root_blocks(body)
    raw = {m.group(0).rstrip("(").strip().lower() for m in RAW_COLOR.finditer(outside)}
    used = set(re.findall(r"var\(\s*(--[A-Za-z0-9_-]+)", body))
    used |= set(re.findall(r"^\s*(--[A-Za-z0-9_-]+)\s*:", body, re.MULTILINE))
    return raw, {t for t in used if t not in tokens}


def check_prototype(text: str, before: str, tokens: dict[str, str],
                    all_tokens: dict[tuple[str, str], str], ds: str | None) -> list[str]:
    raw_now, undeclared_now = proto_violations(text, tokens)
    raw_before, undeclared_before = proto_violations(before, tokens)
    errors: list[str] = []

    raw = sorted(raw_now - raw_before)
    if raw:
        errors.append(
            f"MÃ MÀU THÔ ngoài :root — {', '.join(raw[:8])}"
            + (" …" if len(raw) > 8 else "")
            + f"\n    Dùng var(--…) từ bảng token DESIGN-SYSTEM.md §2 "
              f"({len(tokens)} token đang khai). Màu viết thẳng vào màn hình thì "
              "phản hồi của Authority không lan ra được — đó là lý do design system "
              "phải chốt TRƯỚC prototype."
        )

    undeclared = sorted(undeclared_now - undeclared_before)
    # Token CÓ THẬT nhưng thuộc gói khác là bệnh khác hẳn "chưa khai" — gọi đúng tên
    # thì người sửa biết phải đổi sang token cùng gói, chứ không đi khai thêm một dòng
    # §2 và vô tình bê nửa gói kia sang.
    foreign = sorted({f"{t} (của design system `{od}`)" for t in undeclared
                      for (od, ot) in all_tokens if ot == t and od != ds})
    rest = [t for t in undeclared if not any(ot == t for (_o, ot) in all_tokens)]
    if foreign:
        errors.append(
            f"TRỘN DESIGN SYSTEM — {', '.join(foreign)}"
            f"\n    File này thuộc experience mặc gói `{ds}` (cột `Design system` ở "
            "context/ARCHITECTURE.md §2–§3). Mỗi gói là một hợp đồng hình thức riêng; "
            "mượn token của gói khác là phá cả hai. Dùng token cùng gói."
        )
    if rest:
        errors.append(
            f"TOKEN CHƯA KHAI — {', '.join(rest)}"
            "\n    Khai vào DESIGN-SYSTEM.md §2 TRƯỚC (kèm cặp tương phản ở §3 nếu là "
            "màu), rồi mới dùng. Khai biến mới thẳng trong prototype là dựng design "
            "system thứ hai mà không ai biết."
        )
    return errors


def ds_rows(text: str) -> dict[tuple[str, str], str]:
    """Dòng token của cả file → {(ds, token): giá trị}, ds rỗng quy về gói duy nhất."""
    sole = sole_ds()
    return {(ds or sole or "", tok): val
            for ds, tok, val in ds_token_rows(COMMENT_HTML.sub("", text))}


def check_design_system(text: str, before: str) -> list[str]:
    src, path = intake_tokens()
    if not src:
        return []  # không có gói intake → token do pha V tự quyết, không có gì để đối chiếu

    rows = ds_rows(text)
    if not rows:
        return []  # sửa mục khác của file, không đụng bảng token

    # Nhiều gói mà bảng chưa có cột `DS` thì mọi phép đối chiếu đều sai địa chỉ —
    # fail-open, gate V là chỗ đòi khai cột đó. Hook không chặn cái nó không hiểu.
    if len({d for d, _ in src}) > 1 and any(not d for d, _ in rows):
        return []

    def viols(r: dict[tuple[str, str], str]) -> tuple[set, set]:
        invented = {(d, t) for (d, t) in r if (d, t) not in src}
        drifted = {(d, t, norm(r[(d, t)])) for (d, t) in r
                   if (d, t) in src and norm(r[(d, t)]) not in {norm(v) for v in src[(d, t)]}}
        return invented, drifted

    def label(d: str, t: str) -> str:
        return f"{t} [{d}]" if len({x for x, _ in src}) > 1 else t

    invented_now, drifted_now = viols(rows)
    invented_prev, drifted_prev = viols(ds_rows(before))
    errors: list[str] = []
    invented = sorted(label(d, t) for d, t in invented_now - invented_prev)
    drifted = sorted(
        f"{label(d, t)} = {rows[(d, t)].strip()} (gói: {' | '.join(sorted(src[(d, t)]))})"
        for d, t, _ in drifted_now - drifted_prev)
    if invented:
        errors.append(
            f"TOKEN BỊA THÊM, không có trong {path} — {', '.join(invented)}"
            "\n    Gói design system của intake là HỢP ĐỒNG (VIPER.md §1.3): dịch "
            "trung thành, không 'cải tiến'. Thiếu token thật sự cần → hỏi Authority "
            "(đang pha V) rồi ghi 1 dòng context/DECISIONS.md."
        )
    if drifted:
        errors.append(
            f"TOKEN LỆCH GIÁ TRỊ so với {path} — {' · '.join(drifted)}"
            "\n    Trả về đúng giá trị gốc. Muốn đổi thật thì Authority chốt + 1 dòng "
            "context/DECISIONS.md nói rõ đổi gì, vì sao."
        )
    return errors


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0  # fail-open

    tool_input = payload.get("tool_input") or {}
    command = tool_input.get("command")
    if isinstance(command, str) and "*** Begin Patch" in command:
        changes = parse_apply_patch(command)
        if changes is None:
            return 0  # patch không dựng chắc được; chính apply_patch sẽ báo nếu invalid
    else:
        change = legacy_change(tool_input)
        if change is None:
            return 0
        changes = [change]

    prospective = {change.rel: change.after for change in changes}
    ds_after = prospective.get(DS, read(DS))
    if ds_after is None:
        ds_after = ""
    arch_after = prospective.get("context/ARCHITECTURE.md", read("context/ARCHITECTURE.md"))
    if arch_after is None:
        arch_after = ""

    # Chưa chốt design system (rỗng HOẶC còn dấu _CHƯA ĐIỀN_ — template khai sẵn TÊN
    # token nên chỉ kiểm rỗng là hook đã chặn ngay trên dự án vừa bootstrap) /
    # backend-only → chưa có gì để theo. Cùng chuẩn filled() của gate.py.
    if (not ds_after.strip() or UNFILLED in ds_after
            or "KHÔNG CÓ UI" in COMMENT_HTML.sub("", ds_after)):
        return 0

    all_tokens = declared_tokens(ds_after)
    violations: list[tuple[str, str, list[str]]] = []
    for change in changes:
        rel = change.rel
        text = change.after
        if text is None or not text.strip():
            continue  # delete/empty không thể thêm một vi phạm mới
        is_proto = rel.startswith("prototype/") and rel.endswith((".html", ".htm", ".css"))
        if not is_proto and rel != DS:
            continue
        before = change.before or ""  # file mới toanh — mọi lỗi trong nó đều là lỗi mới
        if is_proto:
            if not all_tokens:
                continue  # §2 chưa khai token — gate V sẽ bắt, hook không có căn cứ chặn
            ds = ds_for_prototype(rel, arch_after)
            errors = check_prototype(text, before, tokens_for(all_tokens, ds),
                                     all_tokens, ds)
            what = "prototype"
        else:
            errors, what = check_design_system(text, before), "bảng token"
        if errors:
            violations.append((rel, what, errors))

    if not violations:
        return 0

    details = []
    for rel, what, errors in violations:
        details.append(
            f"{rel} — {what} không theo design system đã chốt:\n"
            + "\n\n".join(f"  {i}. {m}" for i, m in enumerate(errors, 1)))
    label = violations[0][0] if len(violations) == 1 else f"{len(violations)} file"
    print(f"[VIPER guard_ds] CHẶN ghi {label}:\n\n"
          + "\n\n".join(details)
          + f"\n\nNguồn sự thật của hình thức là {DS}. Sửa cho khớp rồi ghi lại — "
            "đừng vòng qua hook bằng cách ghi kiểu khác.", file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:  # hook KHÔNG BAO GIỜ được làm hỏng phiên
        print(f"guard_ds.py: {e}", file=sys.stderr)
        sys.exit(0)
