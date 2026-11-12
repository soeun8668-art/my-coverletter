import { cp, mkdir, rm, writeFile } from "node:fs/promises";

await rm("dist", { recursive: true, force: true });
await mkdir("dist", { recursive: true });
await cp("index.html", "dist/index.html");
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
if (supabaseUrl && supabaseAnonKey) {
  const config = `window.CAREERLY_SUPABASE = ${JSON.stringify({ url: supabaseUrl, anonKey: supabaseAnonKey })};\n`;
  await writeFile("dist/supabase-config.js", config);
} else {
  await cp("supabase-config.js", "dist/supabase-config.js").catch(() => cp("supabase-config.example.js", "dist/supabase-config.js"));
}
console.log("Built static Cloudflare Pages site in dist/");
