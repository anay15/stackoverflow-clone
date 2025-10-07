/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'so-orange': '#f48024',
        'so-blue': '#0074cc',
        'so-dark-blue': '#0a95ff',
        'so-gray': '#6a737c',
        'so-light-gray': '#f1f2f3',
        'so-dark-gray': '#232629',
      }
    },
  },
  plugins: [],
}
