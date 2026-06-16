import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";

export default defineConfig({
  site: process.env.SITE_URL ?? "https://siliward.github.io",
  base: process.env.BASE_PATH ?? "/",
  integrations: [tailwind()],
  trailingSlash: "never"
});
