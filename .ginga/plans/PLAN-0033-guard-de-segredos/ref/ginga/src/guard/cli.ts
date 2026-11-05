#!/usr/bin/env bun
import { guardCall, guardResult } from "./run";
import { sweep } from "./sweep";

const [verb, arg] = process.argv.slice(2);
const stdin = async () => await new Response(Bun.stdin.stream()).text();

try {
  if (verb === "check") {
    const j = JSON.parse(await stdin());
    const v = guardCall(String(j.tool ?? ""), j.input ?? {}, { cwd: j.cwd, home: j.home });
    if (v.block) { console.log(JSON.stringify({ block: true, rule: v.rule, reason: v.reason })); process.exit(2); }
  } else if (verb === "redact") {
    process.stdout.write(guardResult(await stdin()));
  } else if (verb === "sweep" && arg) {
    const r = sweep(arg);
    for (const h of r.hits) console.log(`${h.file}:${h.line} ${h.rule}`);
    console.log(`varridos ${r.files} arquivos, ${r.hits.length} ocorrência(s)`);
    process.exit(r.hits.length ? 3 : 0);
  } else { console.error("uso: cli.ts check|redact (stdin) | sweep <dir>"); process.exit(64); }
} catch (e) { console.error(`guard: erro interno: ${String(e).slice(0, 120)}`); process.exit(1); }
