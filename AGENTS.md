# AGENTS.md

## Deployment

- The production website for `www.siliward.com` is hosted on the SSH target `siliward`.
- The server-side Nginx document root for the main site is `/var/www/siliward.com`.
- Deployments for this repo are full replacements of `/var/www/siliward.com`, not incremental edits.
- The site directory `/var/www/siliward.com` is owned by `zjwei:zjwei`. The deployment script connects as `root` via `ssh siliward`, uploads to `/root/deploy-staging/...`, then replaces the live directory.
- Local deploy entrypoint: `./scripts/deploy-sili.ps1`
- Default flow:
  1. Run `npm run build`
  2. Upload local `dist/` to `/root/deploy-staging/siliward.com/<timestamp>/`
  3. Create a backup at `/root/deploy-backups/siliward.com/<timestamp>/`
  4. Replace `/var/www/siliward.com` with the uploaded build output
- This replacement is destructive for any server-only files under `/var/www/siliward.com`. Keep anything that must survive deploys in the repo or outside that directory.

## Command

- Standard deploy command from the repo root:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\deploy-sili.ps1
  ```
- The script must run with Windows-native `tar`/`ssh` (plain PowerShell). From Git Bash, prefix `PATH="/c/Windows/System32:/c/Windows/System32/OpenSSH:$PATH"` — Git's MSYS tar misreads drive-letter archive paths and Git's ssh reads `D:\Home\.ssh\config` (which carries the `siliward` alias for this machine).

## Server-Side Redirects (Nginx)

- The production Nginx config `/etc/nginx/sites-available/siliward.com` carries durable product-entry redirects that bypass the static docroot: `/wordex` and `/products/wordex` (both slash forms) return `302 https://wordex.siliward.com/` immediately.
- These rules are maintained on the server, not generated from this repo. The repo still builds static meta-refresh pages at the same paths as a fallback if the Nginx rules are ever removed.
- Nginx config backups live in `/root/nginx-backups/` on the server (first redirect change: `siliward.com.before-wordex-302-20260926-223234`).
- After deploys that change public pages, the Aliyun ESA edge cache for `www.siliward.com` must be purged manually (ESA console → 站点管理 → siliward.com → 刷新缓存), or the edge keeps serving the old pages for weeks.
