## Coding Style

- **Python Standards:** Follow PEP 8 for all Python code. Use established language-specific style guides and conventions for other languages.
- **Documentation:** All non-trivial functions, methods, and complex components must have concise documentation describing their purpose, important behavior, and non-obvious parameters or return values. Avoid documenting trivial or self-explanatory code.
- **Comments:** Keep comments to an absolute minimum. Code should be self-explanatory through good naming and straightforward structure. Add comments only when necessary to explain non-obvious behavior, magic numbers, important design decisions, unusual workarounds, or logic that cannot reasonably be understood from the code alone. Never add comments that simply restate what the code does.
- **Abstraction:** Avoid unnecessary abstractions, layers, wrappers, helpers, and indirection. Don't introduce design patterns, generic utilities, or reusable frameworks without a clear practical need. Prefer straightforward implementations, especially in smaller projects.
- **Simplicity:** Prioritize clean, readable, and easily interpretable code over cleverness or unnecessary sophistication. Favor the simplest implementation that adequately solves the problem.
- **Optimization:** Avoid premature optimization and unnecessary performance tuning. Prioritize correctness, maintainability, and readability unless optimization is explicitly requested or a demonstrated performance issue requires it.
- **Scope:** Keep implementations appropriately sized for the project. Don't build infrastructure for hypothetical future requirements or solve problems beyond the requested scope.
- **Overall Principle:** Prefer concise, straightforward, self-documenting code. Optimize for human readability and maintainability, not abstraction, theoretical scalability, or cleverness. Deviate from these guidelines when explicitly requested or when the problem genuinely warrants it.
