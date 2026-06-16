/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        // 语义令牌（随 data-theme 切换）
        bg: "var(--bg)",
        elev: "var(--bg-elev)",
        surface: "var(--surface)",
        "surface-strong": "var(--surface-strong)",
        content: "var(--content)",
        muted: "var(--content-muted)",
        faint: "var(--content-faint)",
        accent: "var(--accent)",
        "accent-2": "var(--accent-2)",
        "accent-soft": "var(--accent-soft)",
        "accent-contrast": "var(--accent-contrast)",
        line: "var(--line)",
        "line-strong": "var(--line-strong)",
        // 旧色名保留为静态默认，避免改造期样式断裂
        ink: "#17211d",
        moss: "#5aa982",
        leaf: "#237a52",
        mint: "#e8f6ee",
        cloud: "#f7fbf8",
        ember: "#f0a64a"
      },
      borderRadius: {
        theme: "var(--radius)",
        "theme-lg": "var(--radius-lg)"
      },
      boxShadow: {
        soft: "var(--shadow)"
      },
      fontFamily: {
        display: ["var(--font-display)"],
        body: ["var(--font-body)"],
        mono: ["var(--font-mono)", "Consolas", "monospace"],
        sans: ["var(--font-body)", "ui-sans-serif", "system-ui", "sans-serif"]
      }
    }
  },
  plugins: []
};
