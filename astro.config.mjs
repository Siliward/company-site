import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";

export default defineConfig({
  site: process.env.SITE_URL ?? "https://siliward.github.io",
  base: process.env.BASE_PATH ?? "/",
  integrations: [tailwind()],
  // Internal links and canonical URLs mix both slash forms (e.g. "/products/wordex/"
  // vs "/privacy"), and the production Nginx docroot serves both. "ignore" makes
  // the dev server match that behavior instead of 404ing the trailing-slash form.
  trailingSlash: "ignore"
});
