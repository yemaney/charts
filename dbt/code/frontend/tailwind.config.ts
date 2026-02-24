import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './index.html',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        surface: '#121212',
        panel: '#1E1E1E',
        accent: '#10B981'
      }
    },
  },
  plugins: [],
}
export default config
