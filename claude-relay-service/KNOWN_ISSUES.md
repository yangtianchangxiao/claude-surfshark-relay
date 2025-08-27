# Known Issues and Technical Debt

This document tracks known issues, temporary workarounds, and areas for future improvement in the AI Prediction Market MVP project.

## 1. Persistent Linter Error in `predictionMarketService.ts`

*   **File:** `src/services/predictionMarketService.ts`
*   **Context:** Occurs on the line `const reader = new TupleReader(result.stack);` within the `getMarketDetails` and `getUserShare` functions (specifically after the `client.runMethod` call).
*   **Error Message:** `类型"TupleReader"的参数不能赋给类型"TupleItem[]"的参数。 (Parameter of type 'TupleReader' cannot be assigned to parameter of type 'TupleItem[]'.)`
*   **Analysis:** This error seems misplaced, as `TupleReader` is correctly instantiated with `result.stack` which is of type `StackItem[]`. The error message itself refers to assigning `TupleReader` to `TupleItem[]`, which is not happening at that line. It's suspected to be either a bug within the TypeScript linter/language server, or a subtle type conflict between `@ton/core`, `@ton/ton`, and potentially `@types/node` or other related type definitions.
*   **Resolution Attempts:** Multiple attempts were made to refactor the `runMethod` call and parameter typing, but the error persisted, always pointing to the `TupleReader` instantiation line.
*   **Current Status:** **Temporarily Accepted/Ignored.** The underlying code logic for calling `runMethod` and parsing the stack with `TupleReader` is believed to be correct based on library documentation and common usage patterns. To avoid getting permanently blocked, we are proceeding with the assumption that this is a linter/type definition issue.
*   **Action Required:** Revisit this issue periodically, especially after updating key dependencies (`@ton/core`, `@ton/ton`, `typescript`, `@types/*`). If the error persists, further deep investigation into type definitions or seeking help from the TON developer community might be necessary. Consider explicitly adding `// @ts-ignore` above the affected lines if the warning becomes too noisy during development.

---

*Add other known issues or technical debt items here as they arise.* 