# T3 — Extend

T3 changes shell behavior after the underlying operation is manually
understood and stable.

Adopt roughly in increasing order of interaction scope:

1. typed custom environment values;
2. callable aliases;
3. macros where source-expression access matters;
4. command or output decorators;
5. events and hooks;
6. completers, keybindings, or prompt-toolkit integration;
7. a narrowly justified xontrib.

## Extension contract

Each extension must state:

- the repeated manual operation it replaces;
- the semantic input, output, and failures;
- whether it changes composition notation or shell behavior;
- which interactive state it owns;
- how the underlying operation remains directly accessible;
- what evidence would cause removal.

A normal function is preferred when raw expression access, event integration,
or command-shaped invocation adds no information.

## Authority boundary

Do not move project authority into aliases, prompt state, environment values,
terminal user variables, or history. Extensions are disposable projections of
operations whose durable semantics remain in repository files and tests.
