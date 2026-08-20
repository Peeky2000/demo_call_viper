# CORE-VIPER — hợp đồng lệnh VIPER
#
# Sáu lệnh dưới đây là giao diện chung của MỌI stack. Quy trình VIPER và scripts/gate.py
# chỉ gọi các lệnh này, không cần biết bên dưới là Next.js hay Spring Boot.
#
# Pha I: mở .claude/skills/stack-<tên>/SKILL.md §4 và điền phần thân cho từng target.
# Giữ nguyên TÊN target — đổi tên là phá hợp đồng, gate.py sẽ không chạy được.
#
# Artifact để CHẠY nằm ở deployment/, không rải ra gốc repo (deployment/README.md):
#   make dev  → docker compose -f deployment/local/docker-compose.yml up -d db
#   biến env  → deployment/.env.example (danh sách) · deployment/local/.env (giá trị)
# Đa target (đường intake): thân lệnh điều phối xuống `make -C srcroot/<nhóm>/<tên> …`;
# deploy LUÔN đi qua `make deploy` ở gốc — đó là chỗ hook guard_bc đứng.

.PHONY: help dev check test migrate deploy doctor gate

STACK_SKILL ?= custom — Flutter (viper-mobile §2)
PYTHON ?= python3

help:
	@echo "CORE-VIPER — VIPER"
	@echo ""
	@echo "  make dev      chạy local (app + db)"
	@echo "  make check    lint + typecheck + build"
	@echo "  make test     smoke + luồng quan trọng"
	@echo "  make migrate  DB migration có version"
	@echo "  make deploy   đẩy lên PaaS"
	@echo "  make doctor   kiểm env + kết nối, in cái gì thiếu"
	@echo ""
	@echo "  make gate     kiểm gate của pha hiện tại (hoặc: make gate P=I)"
	@echo ""
	@echo "Stack skill: $(STACK_SKILL)"

define NOT_IMPLEMENTED
	@echo ""
	@echo "  ✗ 'make $@' chưa được hiện thực."
	@echo ""
	@echo "  Pha I chưa xong. Mở .claude/skills/stack-<tên>/SKILL.md §4"
	@echo "  rồi điền phần thân cho target '$@' trong Makefile này."
	@echo ""
	@echo "  Stack đã chốt ở context/TECHSTACK.md: $(STACK_SKILL)"
	@echo ""
	@exit 1
endef

# Flutter ghim ở .fvmrc — KHÔNG dùng ~/fvm/default. Chạy sai bản thì test đỏ
# vì lệch shader (ink_sparkle.frag "Expected 2, got 1"), không phải vì code sai.
FLUTTER ?= $(HOME)/fvm/versions/3.41.9/bin/flutter

# Giá trị thật nằm ở deployment/local/.env — .gitignore đã chặn. Ở Flutter biến
# đi vào app qua --dart-define chứ không đọc file lúc chạy (TECHSTACK.md §6).
ENV_FILE ?= deployment/local/.env
DEFINES = $(shell [ -f $(ENV_FILE) ] && sed -e '/^\#/d' -e '/^$$/d' $(ENV_FILE) | sed 's/^/--dart-define=/' | tr '\n' ' ')

dev:
	@[ -f $(ENV_FILE) ] || { echo "✗ thiếu $(ENV_FILE) — chép từ deployment/.env.example rồi điền"; exit 1; }
	$(FLUTTER) run $(DEFINES)

check:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

migrate:
	@echo ""
	@echo "  KaiCall KHÔNG có database — không có gì để migrate."
	@echo ""
	@echo "  Đây là quyết định, không phải thiếu sót: danh bạ là 2 hằng số trong"
	@echo "  source, không có gì cần sống qua lần chạy."
	@echo "  Xem context/DECISIONS.md 2026-08-20 và ARCHITECTURE.md §6."
	@echo ""

# "Deploy" của vòng này = APK debug cài thẳng vào máy, không có PaaS nào
# (PRD.md §7). Debug chứ không release: bản release mang theo API secret là
# thứ tuyệt đối không được phát hành (DECISIONS.md).
deploy:
	@[ -f $(ENV_FILE) ] || { echo "✗ thiếu $(ENV_FILE)"; exit 1; }
	$(FLUTTER) build apk --debug $(DEFINES)
	@echo ""
	@echo "  APK: build/app/outputs/flutter-apk/app-debug.apk"
	@echo "  Cài: adb install -r build/app/outputs/flutter-apk/app-debug.apk"
	@echo ""

doctor:
	@echo "── Flutter ─────────────────────────────────────────────"
	@$(FLUTTER) --version | head -1
	@echo ""
	@echo "── Bốn biến bắt buộc ($(ENV_FILE)) ─────────────────────"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "  ✗ chưa có $(ENV_FILE) — chép từ deployment/.env.example"; \
	else \
		for v in KAICALL_LIVEKIT_URL KAICALL_LIVEKIT_API_KEY KAICALL_LIVEKIT_API_SECRET KAICALL_ALLOW_INSECURE_LOCAL_TOKEN; do \
			if grep -q "^$$v=." $(ENV_FILE); then echo "  ✓ $$v"; else echo "  ✗ $$v thiếu"; fi; \
		done; \
	fi
	@echo ""
	@echo "── Thiết bị ────────────────────────────────────────────"
	@$(FLUTTER) devices 2>/dev/null | tail -n +2 || echo "  (không có thiết bị nào)"
	@echo ""
	@echo "  Cần HAI đầu để thử gọi: 1 máy Android thật + 1 emulator."
	@echo "  Emulator mic là giả — ca 'nghe rõ không' phải kiểm bằng tai trên máy thật."
	@echo 

# --- không đổi ---

gate:
	@$(PYTHON) scripts/gate.py $(P)
