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
