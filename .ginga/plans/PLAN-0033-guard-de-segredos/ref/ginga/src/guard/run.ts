import { appendFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { homedir } from "node:os";
import { checkCall, redact, type Deny, type Verdict } from "./core";
import denyDefault from "./deny.json";

export type Env = Record<string, string | undefined>;
export type Mode = "enforce" | "shadow" | "off";
type Opts = { env?: Env; cwd?: string; home?: string; deny?: Deny };

// Escopo: só vale em sessão de lane. Sem GINGA_GUARD_LANE o guard é inerte (sessão interativa do dono).
export function mode(env: Env): Mode {
  if (!env.GINGA_GUARD_LANE) return "off";
  const m = env.GINGA_GUARD ?? "enforce";
  return m === "shadow" || m === "off" ? m : "enforce";
}

const sha = (x: unknown) => createHash("sha256").update(JSON.stringify(x) ?? "").digest("hex").slice(0, 12);

function log(env: Env, rec: Record<string, unknown>): void {
  if (!env.GINGA_GUARD_LOG) return;
  try {
    appendFileSync(env.GINGA_GUARD_LOG, JSON.stringify({ ts: new Date().toISOString(), lane: env.GINGA_GUARD_LANE, ...rec }) + "\n");
  } catch {}
}

export function guardCall(tool: string, input: Record<string, unknown>, o: Opts = {}): Verdict {
  const env = o.env ?? process.env;
  const m = mode(env);
  if (m === "off") return { block: false };
  try {
    const v = checkCall({ tool, input, cwd: o.cwd ?? process.cwd(), home: o.home ?? env.HOME ?? homedir() }, o.deny === undefined ? (denyDefault as Deny) : o.deny);
    if (v.block) {
      log(env, { event: "guard.block", tool, rule: v.rule, mode: m, call: sha(input) });
      if (m === "shadow") return { block: false };
    }
    return v;
  } catch (e) {
    log(env, { event: "guard.error", tool, error: String(e).slice(0, 120) });
    return m === "shadow" ? { block: false } : { block: true, rule: "guard_error", reason: "falha interna do guard (fail-closed)" };
  }
}

const SECRET_NAME = /(KEY|TOKEN|SECRET|PASSW(OR)?D|CREDENTIAL)/i;
export const secretEnvValues = (env: Env): string[] =>
  Object.entries(env).filter(([k, v]) => SECRET_NAME.test(k) && (v ?? "").length >= 12).map(([, v]) => v as string);

export function guardResult(text: string, o: Opts = {}): string {
  const env = o.env ?? process.env;
  const m = mode(env);
  if (m === "off") return text;
  try {
    const r = redact(text, o.deny === undefined ? (denyDefault as Deny) : o.deny, secretEnvValues(env));
    if (r.hits.length) log(env, { event: "guard.redact", rules: [...new Set(r.hits)], mode: m });
    return m === "shadow" ? text : r.text;
  } catch (e) {
    log(env, { event: "guard.error", error: String(e).slice(0, 120) });
    return m === "shadow" ? text : "[REDACTED:guard_error]";
  }
}
