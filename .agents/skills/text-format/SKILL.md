---
name: text-format
description: Format Chinese-dominant text in a target file according to references/rules.md, including mixed Chinese-English content. Use when the user provides one or more file paths and asks to check and fix spacing, punctuation, full-width/half-width usage, naming style, and related Chinese typography issues while preserving complete English clauses and paragraphs.
---

# Text Formatting Workflow

Use this skill to inspect and fix Chinese-dominant text layout in an existing file, including mixed Chinese-English content.

## Inputs

- Required: one target file path.
- Optional: multiple target file paths.

Treat each provided file as an in-place formatting task unless the user requests preview-only output.

## Reference

- Always read [references/rules.md](references/rules.md) before editing.
- Apply only the rules that are relevant to the target file content.

## Execution Steps

1. Open the target file and identify text regions that are natural language copy.
2. Apply spacing rules from `rules.md` in Chinese and mixed Chinese-English context:
   - Add spaces between Chinese and English.
   - Add spaces between Chinese and numbers.
   - Add spaces between numbers and units (except `%` and `°`).
   - Remove incorrect spaces around full-width punctuation.
3. Apply punctuation and width rules from `rules.md`:
   - Prefer full-width Chinese punctuation in Chinese-dominant sentences.
   - Keep half-width punctuation for complete English clauses/sentences and special English terms.
   - Collapse repeated punctuation to a single semantically correct form.
4. Apply terminology and casing rules from `rules.md`:
   - Normalize common proper nouns to correct casing.
   - Remove non-standard abbreviations when the intended term is clear from context.
5. Preserve meaning and structure:
   - Do not rewrite business logic or change file structure.
   - Do not force full English paragraphs into Chinese punctuation style.
   - Limit edits to typography and wording-format normalization.
6. Save changes in the same target file.

## Output Behavior

- If edits are made, report the file path and a concise summary of what categories were fixed.
- If no edits are needed, explicitly state that the file already complies with `rules.md`.
