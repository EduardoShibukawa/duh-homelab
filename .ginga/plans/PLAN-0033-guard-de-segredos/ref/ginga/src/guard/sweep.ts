import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import denyDefault from "./deny.json";
import type { Deny } from "./core";

export type Hit = { file: string; line: number; rule: string };

// Só caminho, linha e regra: o trecho que casou nunca sai daqui.
export function sweep(root: string, deny: Deny = denyDefault as Deny): { files: number; hits: Hit[] } {
  const res = deny.content.map((c) => ({ id: c.id, re: new RegExp(c.re) }));
  const hits: Hit[] = []; let files = 0;
  const walk = (d: string) => {
    for (const e of readdirSync(d, { withFileTypes: true })) {
      const p = join(d, e.name);
      if (e.isDirectory()) { if (e.name !== "node_modules" && e.name !== ".git") walk(p); continue; }
      if (!/\.(log|md|out|events|tsv|json|txt|jsonl)$/.test(e.name) || statSync(p).size > 20e6) continue;
      files++;
      readFileSync(p, "utf8").split("\n").forEach((line, i) => { for (const r of res) if (r.re.test(line)) hits.push({ file: relative(root, p), line: i + 1, rule: r.id }); });
    }
  };
  walk(root);
  return { files, hits };
}
