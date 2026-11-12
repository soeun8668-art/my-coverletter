# Careerly

Static Careerly prototype prepared for Cloudflare Pages with Supabase Auth and Postgres.

## Supabase setup

1. Create a Supabase project and run `supabase/schema.sql` in its SQL Editor.
2. In **Authentication → Providers**, enable Google and enter the OAuth client credentials from Google Cloud. Add the Supabase callback URL shown on that page (usually `https://<project-ref>.supabase.co/auth/v1/callback`) to Google Cloud's authorized redirect URIs.
3. Add the local and production site URLs to Supabase **Authentication → URL Configuration**. Use `http://localhost:8788` locally and your Cloudflare Pages domain in production.
4. Copy `supabase-config.example.js` to `supabase-config.js`, then fill in the project URL and anon/publishable key. This key is intended for browser use; never use a `service_role` key in the page.

## Cloudflare Pages

Install dependencies with `npm install`, then run `npm run build` to produce the deployable `dist/` directory. For a Cloudflare Pages Git build, define `SUPABASE_URL` and `SUPABASE_ANON_KEY` as build environment variables. For a local deploy, `supabase-config.js` can supply the same public client values. Deploy with `npm run deploy` after authenticating Wrangler and creating the Pages project. The configured project name is `careerly-coverletter`.

For local preview, run `npx wrangler pages dev dist` after building. Set the Supabase OAuth redirect URL to the same local or production origin used in the browser.

The current app remains a UI prototype: Google OAuth is wired, while projects, essays, uploads, credits, and AI responses still use mock data. In the workspace chat, type `@` to select the current essay or a project file as a prompt reference. The SQL schema is the starting point for connecting those screens to Supabase.
