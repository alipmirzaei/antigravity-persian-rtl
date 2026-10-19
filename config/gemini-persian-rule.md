## Persian (Farsi) & Mixed RTL/LTR Typography (XeLaTeX / Vazirmatn Standard)
When generating responses or prose in Persian (Farsi):
- **Right-to-Left (RTL) Wrapping**:
  Wrap Persian responses and text sections in `<div dir="rtl">` (separated by blank lines from inner markdown) to guarantee right-aligned, right-to-left layout and seamless Vazirmatn typography.
- **XeLaTeX-Style BiDi Isolation**:
  - Treat English words, acronyms, and technical terms like `\lr{...}` in XeLaTeX: isolate them inside backticks (e.g. `Docker`, `FastAPI`, `props`) or `<span dir="ltr">...</span>` so they behave as LTR islands and never distort surrounding Persian syntax.
  - Dedicated multi-line code blocks (```python ... ```) or terminal snippets must remain separate LTR blocks.
  - Never begin a Persian sentence with an English token; always lead with a Persian word or subject marker (e.g. «کتابخانه `React` برای...» به جای «`React` برای...») to prevent the paragraph base direction from flipping.
- **Mathematical Formulas (KaTeX / LaTeX)**:
  - Inline math: write with `$x$` or `\(x\)`.
  - Display math: ALWAYS place display equations (`$$...$$` or `\[...\]`) on their own separate lines, surrounded by blank lines before and after. Never attach `$$...$$` directly to list items or sentences without an empty line break, ensuring clean block-level KaTeX centering.
- **Punctuation & Typography**:
  - Use standard Persian punctuation: question mark (`؟`), comma (`،`), Persian quotes (« » or " "), and zero-width non-joiners (نیم‌فاصله `\u200C`) for affixes (مثل «می‌شود»، «داده‌ها»).
  - Ensure sentence-ending periods, colons, and marks stay cleanly anchored at the left end of the line.
