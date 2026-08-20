/**
 * VIPER — bốn guard chạy TỰ ĐỘNG trên Kilo.
 *
 * VÌ SAO CÓ FILE NÀY
 *     Claude Code cưỡng chế luật VIPER bằng hook `PreToolUse`/`SessionStart` khai trong
 *     `.claude/settings.json`; Codex bằng `.codex/hooks.json`. Kilo không đọc hai thư mục
 *     đó và không có hai loại hook đó — nhưng nó có **plugin API**, và `tool.execute.before`
 *     chặn được một lời gọi tool bằng cách `throw`. File này bắc cầu: mỗi hook của Kilo gọi
 *     đúng script guard cũ trong `scripts/`, không viết lại logic (một nguồn sự thật).
 *
 *     Nhờ vậy bốn guard KHÔNG còn phải gọi tay:
 *       question       → guard_ask.py   (luật #2 — không hỏi Authority sau khi khoá scope)
 *       bash           → guard_bc.py    (không deploy khi legacy chưa rà, vòng ≥2)
 *       write / edit   → guard_ds.py    (không ghi prototype lệch design system)
 *       khi compact    → reanchor.py    (nhồi 8 luật vào CHÍNH prompt compaction)
 *
 * MỘT CHỖ TỐT HƠN BẢN CLAUDE CODE
 *     `reanchor` ở đây chạy tại `experimental.session.compacting`, tức luật được nhồi vào
 *     prompt compaction TRƯỚC khi model nén. Claude Code chạy nó SAU khi nén xong
 *     (`SessionStart matcher:compact`). Nhồi trước thì luật không bị nén mất.
 *
 * SCHEMA — chỗ dễ sai nhất
 *     Guard script viết cho schema tool của Claude Code (`file_path`, `old_string`,
 *     `new_string`, bọc trong `tool_input`). Tool của Kilo dùng camelCase (`filePath`,
 *     `oldString`, `newString`). `toClaudeSchema` dịch qua — sai chỗ này thì guard_ds
 *     nhận rỗng và im lặng cho qua mọi thứ. Hợp đồng này có test:
 *         python3 scripts/selftest_guards.py
 *
 * FAIL-OPEN có chủ ý, nhưng LÊN TIẾNG
 *     Không có python3, script mất, JSON hỏng → cho qua, vì chặn cả phiên do lỗi hạ tầng
 *     tệ hơn một lần lọt guard (đúng tinh thần fail-open của chính các script đó). Khác
 *     một điểm: mọi lần fail-open đều `log("error")` — guard chết âm thầm là kịch bản tệ
 *     nhất, vì tưởng có hàng rào mà thực ra không có. Xem log: `kilo` → /status, hoặc
 *     ~/.local/share/kilo/log/.
 *     Ngoại lệ: script exit ≠ 0 là PHÁN QUYẾT, không phải lỗi → chặn thật.
 */

/** Dịch args của Kilo sang `tool_input` mà guard script Claude-Code-era mong đợi. */
export function toClaudeSchema(tool: string, args: Record<string, any>): Record<string, any> {
  if (tool === "bash") {
    return { command: String(args?.command ?? "") }
  }
  if (tool === "write") {
    return {
      file_path: String(args?.filePath ?? ""),
      content: String(args?.content ?? ""),
    }
  }
  if (tool === "edit") {
    // guard_ds dựng lại nội dung sau-edit từ file trên đĩa + cặp old/new.
    return {
      file_path: String(args?.filePath ?? ""),
      old_string: String(args?.oldString ?? ""),
      new_string: String(args?.newString ?? ""),
      replace_all: Boolean(args?.replaceAll ?? false),
    }
  }
  return {}
}

/** File nào thuộc phạm vi guard_ds soi — lọc trước để không gọi python vô ích. */
export function inDesignSystemScope(filePath: string): boolean {
  return /(^|\/)prototype\//.test(filePath) || /DESIGN-SYSTEM\.md$/.test(filePath)
}

export const ViperGuards = async ({ $, directory, worktree, client }: any) => {
  const root = worktree || directory

  const log = async (level: string, message: string, extra?: any) => {
    try {
      await client?.app?.log({ body: { service: "viper-guards", level, message, extra } })
    } catch {
      /* log lỗi không được làm chết guard */
    }
  }

  /**
   * Chạy một guard script với payload qua stdin. Trả { blocked, reason }.
   *
   * Dùng `Bun.spawn` khi có (API ổn định, stdin nhận thẳng bytes) và lùi về Bun shell
   * `$` khi không — plugin chạy trong Bun nên nhánh đầu gần như luôn trúng. KHÔNG dùng
   * `.timeout()` của ShellPromise: nó không có ở mọi phiên bản Bun, thiếu thì throw
   * TypeError và rơi vào fail-open — hàng rào chết âm thầm.
   */
  const runGuard = async (
    script: string,
    payload: Record<string, any>,
  ): Promise<{ blocked: boolean; reason: string }> => {
    const scriptPath = `${root}/scripts/${script}`
    const json = JSON.stringify(payload)

    try {
      const B: any = (globalThis as any).Bun
      if (B?.spawn) {
        const proc = B.spawn(["python3", scriptPath], {
          cwd: root,
          stdin: new TextEncoder().encode(json),
          stdout: "pipe",
          stderr: "pipe",
        })
        const [stdout, stderr] = await Promise.all([
          new Response(proc.stdout).text(),
          new Response(proc.stderr).text(),
        ])
        await proc.exited
        const code = typeof proc.exitCode === "number" ? proc.exitCode : 0
        if (code === 0) return { blocked: false, reason: "" }
        return {
          blocked: true,
          reason: stderr.trim() || stdout.trim() || `${script} exit ${code}`,
        }
      }

      // Lùi về Bun shell. printf '%s' an toàn với mọi ký tự trong JSON;
      // Bun tự escape giá trị nội suy nên không có chuyện chèn lệnh.
      const res = await $`printf '%s' ${json} | python3 ${scriptPath}`.cwd(root).quiet().nothrow()
      const code = typeof res?.exitCode === "number" ? res.exitCode : 0
      if (code === 0) return { blocked: false, reason: "" }
      const stderr = String(res?.stderr ?? "").trim()
      const stdout = String(res?.stdout ?? "").trim()
      return { blocked: true, reason: stderr || stdout || `${script} exit ${code}` }
    } catch (err: any) {
      // Hạ tầng lỗi — fail-open, nhưng LÊN TIẾNG ở mức error.
      await log("error", `GUARD KHÔNG CHẠY ĐƯỢC (${script}) — đang cho qua, hàng rào này hiện KHÔNG có tác dụng`, {
        error: String(err?.message ?? err),
        script: scriptPath,
      })
      return { blocked: false, reason: "" }
    }
  }

  await log("info", "VIPER guards đã nạp", { root })

  return {
    /**
     * Chặn TRƯỚC khi tool chạy. `throw` là huỷ lời gọi tool; thông điệp lỗi được đưa lại
     * cho model, nên stderr của guard script trở thành lời nhắc luật đúng lúc.
     */
    "tool.execute.before": async (input: any, output: any) => {
      const tool = String(input?.tool ?? "")
      const args = (output?.args ?? {}) as Record<string, any>

      // Luật #2 — không hỏi Authority sau khi khoá scope. guard_ask tự đọc STATE.md.
      if (tool === "question") {
        const { blocked, reason } = await runGuard("guard_ask.py", {})
        if (blocked) throw new Error(reason)
        return
      }

      // Legacy là hợp đồng — không deploy khi §3 chưa rà (vòng ≥2).
      if (tool === "bash") {
        const { blocked, reason } = await runGuard("guard_bc.py", {
          tool_input: toClaudeSchema("bash", args),
        })
        if (blocked) throw new Error(reason)
        return
      }

      // Design system là hợp đồng hình thức — prototype phải lắp từ token đã chốt.
      if (tool === "write" || tool === "edit") {
        const filePath = String(args?.filePath ?? "")
        if (!filePath || !inDesignSystemScope(filePath)) return
        const { blocked, reason } = await runGuard("guard_ds.py", {
          tool_input: toClaudeSchema(tool, args),
        })
        if (blocked) throw new Error(reason)
        return
      }
    },

    /** Nhồi lại 8 luật vào prompt compaction — luật đi VÀO bản nén, không bị nén mất. */
    "experimental.session.compacting": async (_input: any, output: any) => {
      try {
        const B: any = (globalThis as any).Bun
        let raw = ""
        if (B?.spawn) {
          const proc = B.spawn(["python3", `${root}/scripts/reanchor.py`], {
            cwd: root,
            stdout: "pipe",
            stderr: "pipe",
          })
          raw = (await new Response(proc.stdout).text()).trim()
          await proc.exited
        } else {
          const res = await $`python3 ${root}/scripts/reanchor.py`.cwd(root).quiet().nothrow()
          raw = String(res?.stdout ?? "").trim()
        }
        if (!raw) return

        // reanchor.py in ra schema hook của Claude Code; lấy phần additionalContext.
        const ctx = JSON.parse(raw)?.hookSpecificOutput?.additionalContext
        if (typeof ctx === "string" && ctx.trim() && Array.isArray(output?.context)) {
          output.context.push(ctx)
          await log("info", "đã nhồi lại luật VIPER vào prompt compaction")
        }
      } catch (err: any) {
        await log("error", "REANCHOR KHÔNG CHẠY ĐƯỢC khi compact — luật VIPER có thể bị nén mất", {
          error: String(err?.message ?? err),
        })
      }
    },
  }
}

export default { id: "viper-guards", server: ViperGuards }
