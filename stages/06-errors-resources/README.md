# 06 — Exceptions and resource boundaries

## Exit conditions

- Raise domain-specific failures at contract boundaries.
- Handle only errors a layer can resolve.
- Use context managers for deterministic cleanup.

## Ordered work

124. **raising-and-handling-errors** — concept · core  
   `stages/06-errors-resources/concepts/raising-and-handling-errors`
125. **user-defined-errors** — concept · core  
   `stages/06-errors-resources/concepts/user-defined-errors`
126. **with-statement** — concept · core  
   `stages/06-errors-resources/concepts/with-statement`
127. **hamming** — practice · core · difficulty 1  
   `stages/06-errors-resources/exercises/practice/hamming`
128. **error-handling** — practice · core · difficulty 3  
   `stages/06-errors-resources/exercises/practice/error-handling`

## Stage commands

```bash
python tools/path.py list --stage 06 --all
python tools/path.py next
python tools/path.py test <exercise-slug>
python tools/path.py mark <item-slug>
```
