#!/usr/bin/env python3
"""guard_ask.py — hook PreToolUse chặn tool hỏi có cấu trúc ngoài pha V.

VÌ SAO CÓ FILE NÀY
    Luật #2 (không hỏi Authority sau pha V) nếu chỉ cấm bằng văn xuôi trong các
    workflow skill. Sau compact, kỷ luật văn bản có thể trôi và agent lại hỏi. File
    này chặn lời gọi tool có cấu trúc ở pha ≠ V; `AGENTS.md` vẫn là lớp bắt buộc cho
    câu hỏi viết thẳng trong chat, vì hook không quan sát được loại đó.

CHẠY NHƯ THẾ NÀO
    Codex gọi qua matcher "request_user_input" (`.codex/hooks.json`); Claude Code
    gọi qua matcher "AskUserQuestion" (`.claude/settings.json`).
    Exit 0  → cho qua (pha V, hoặc không đọc được STATE.md — fail-open).
    Exit 2  → CHẶN tool; stderr được đưa lại cho model làm phản hồi.

    Fail-open là có chủ ý: chặn nhầm lúc STATE.md đang hỏng còn tệ hơn một câu hỏi thừa.
    Ngoại lệ số 2 của luật (hành động không đảo ngược được / hướng ra ngoài) KHÔNG đi qua
    tool này. Lớp approval + `.codex/rules/viper.rules` chặn các lệnh deploy/push
    tương ứng trước khi chúng tác động ra ngoài.

Đo vi phạm sau compact: python3 scripts/reanchor.py --audit
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


RULE_REMINDER = (
    "Mơ hồ → tự quyết theo PRD/ARCHITECTURE/TECHSTACK, ghi 1 dòng context/DECISIONS.md, đi tiếp.\n"
    "Ngoài scope → ghi context/ROADMAP.md Phase 2, làm tiếp phần còn lại.\n"
    "Chặn cứng sau khi đã tự thử hết cách → ghi STATE.md §Blocker, chuyển việc khác.\n"
    "Ngoại lệ duy nhất (hành động không đảo ngược được / hướng ra ngoài): "
    "hỏi bằng lời trong chat, không qua tool này.\n"
)


def main() -> int:
    try:
        text = (ROOT / "STATE.md").read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return 0  # không có STATE — fail-open, không biết gì để mà chặn

    # Luật thật của #2 là "sau KHOÁ SCOPE không hỏi" — pha chỉ là proxy. Thực chiến:
    # lỗi phổ biến nhất là agent quên đổi `Pha hiện tại : V → I`, hook đọc pha V và
    # cho hỏi suốt pha I. Ô Scope khoá của §Gate là chữ ký kết thúc pha V — nó đã
    # tick thì chặn, mặc kệ dòng pha ghi gì.
    if re.search(r"^- \[x\] \*\*Scope khoá\*\*", text, re.MULTILINE):
        sys.stderr.write(
            "LUẬT #2 — scope ĐÃ KHOÁ (STATE.md §Gate: Scope khoá ✓), không hỏi "
            "Authority qua tool hỏi có cấu trúc nữa, kể cả khi dòng pha còn ghi V.\n"
            "Nếu vừa rời pha V: cập nhật `Pha hiện tại : I` trong STATE.md cho đúng.\n"
            + RULE_REMINDER
        )
        return 2

    # Nhận cả P1/P2 (agent hay ghi tên gate vào ô pha). [VIPER] cũ không khớp "P1"
    # → fail-open ĐÚNG LÚC đang ở pha P — lỗ thủng của chính luật #2.
    m = re.search(r"Pha hiện tại\s*:\s*(V|I|P1|P2|P|E|R)\b", text)
    if m is None:
        if "Pha hiện tại" in text:
            # Có dòng pha nhưng giá trị không chuẩn ("Implement", "Đang I"…) —
            # fail-open ở đây là mở lỗ đúng chỗ luật #2 cần kín nhất. Chặn kèm
            # hướng dẫn: đang thật sự ở pha V thì sửa một dòng là hỏi lại được ngay.
            sys.stderr.write(
                "STATE.md có dòng `Pha hiện tại:` nhưng giá trị không phải một mã pha "
                "(V | I | P | P1 | P2 | E | R).\n"
                "Sửa dòng đó về đúng một mã (ví dụ `Pha hiện tại : I`) rồi thao tác "
                "tiếp — hook guard_ask và gate.py đều đọc đúng dòng này.\n"
            )
            return 2
        return 0  # STATE không theo khung VIPER — fail-open

    p = m.group(1)
    if p == "V":
        return 0
    sys.stderr.write(
        f"LUẬT #2 — đang ở pha {p}, không hỏi Authority qua tool hỏi có cấu trúc.\n"
        + RULE_REMINDER
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
