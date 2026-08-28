---
name: explain-diff
description: Use when the user asks for a rich explanation of a code change, diff, branch, or PR. Produces HTML output.
---

# Explain Diff

Please make me a rich, interactive explanation of the specified code change.

It should have these sections:

- Background: Explain the existing system relevant to this change. (You should
  broadly explore surrounding code for this.) We don't know how much the reader
  already knows, so include a deep background for beginners (note that it can be
  skipped if the reader is already familiar), and then a more narrow background
  directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is
  to explain the essence, not the full details. Use concrete examples with toy
  data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changes to the code. Group/order the
  changes in an understandable way.
- Quiz: Come up with five questions that test the reader's knowledge of this PR.
  This should be medium difficulty, difficult enough that you actually need to
  understand the substance of the PR to answer them, but not gotchas. The goal
  is to help the reader make sure that they've actually understood. These should
  be presented as interactive multiple-choice questions, and when the user
  clicks, it tells them whether they were correct and gives feedback.

Format:

- Output a single self-contained HTML file which includes CSS and JavaScript.
  Make the whole thing one long page with section headers and a table of
  contents. Don't use tabs for the top-level structure. Basic responsive styling
  so you can view it on a phone is nice too. Put the file in a global place on
  my computer outside of the code repo, and make sure the filename always starts
  with today's date in `YYYY-MM-DD-` format, because it helps keep the files
  time-sorted and out of version control. For example:
  /tmp/2026-01-12-explanation-<slug>.html
- Please write with the clarity and flow of Martin Kleppmann, making it engaging
  and written in classic style. Transitions between sections should be smooth.
- Make the HTML structure, CSS, and visual styling deterministic. Use the same
  restrained visual system for every explanation: a warm off-white page
  background, a dark charcoal text color, one muted blue accent, a readable
  system sans-serif body font, a monospace code font, a centered content column
  no wider than 72rem, and a simple one-column responsive layout. Use the same
  named CSS classes and fixed design tokens each time; do not randomly select
  colors, fonts, layouts, decorative motifs, or animations.
- Some tips on diagrams. Ideally, you should pick a small number of diagram
  families that can be reused throughout the explanation to explain various
  cases. Some useful kinds of diagrams:
  - A very simplified version of the UI that the user sees in the app, to
    explain UI changes.
  - A system diagram showing data flow or communication between components. Make
    sure to include example data here!
- Don't use ASCII diagrams. Always use simple HTML designs for your diagrams,
  HTML lists for lists of things, etc.
  - For code blocks, always use `<pre>` tags. If you use a custom styled div
    instead, it **must** have `white-space: pre-wrap` in its CSS, or the browser
    will collapse all newlines into a single line. Before saving the file, scan
    each code block in the HTML source and confirm its CSS includes
    `white-space: pre` or `pre-wrap`.
- Use callouts for key concepts or definitions, important edge cases, etc.

Quiz requirements:

- Give every question exactly four plausible answer choices. Store the correct
  answer with the question data rather than relying on its displayed position.
- Randomize the displayed answer order independently for every question in
  JavaScript with an unbiased Fisher-Yates shuffle when the page loads. The
  correct answer must therefore not consistently appear in any lettered or
  ordinal position. Preserve the correct-answer mapping after shuffling so
  selection feedback remains accurate.
- Keep answer choices comparable in length and detail: aim for each choice to
  be within roughly 20% of the longest choice's word count, and rewrite rather
  than pad with filler. Do not make the correct answer uniquely qualified,
  specific, or much longer than its distractors.
