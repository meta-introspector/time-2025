# SOP: Emacs Configurable Items and Online Help Implementation

## Purpose:
This Standard Operating Procedure (SOP) outlines the guidelines and best practices for implementing configurable items and comprehensive online help within Emacs Lisp integrations, specifically for the `gemini-cli` tool.

## Scope:
This SOP applies to all Emacs Lisp files related to the `gemini-cli` integration, including `solfunmeme-gemini.el` and `solfunmeme-mode.el`.

## Procedure:

### 1. Implementing Configurable Items (`defcustom`):

1.  **Identify Configuration Variables**: Review the Emacs Lisp code and identify variables that users might want to customize. These typically include paths, commands, intervals, and boolean flags.

2.  **Use `defcustom`**: Replace `defvar` with `defcustom` for all identified configurable variables. `defcustom` automatically creates a customization interface accessible via `M-x customize`.

    **Syntax:**
    ```elisp
    (defcustom variable-name initial-value
      "Documentation string for the variable."
      :type 'type-specifier
      :group 'customization-group-name)
    ```

    -   `initial-value`: The default value for the variable.
    -   `Documentation string`: A clear and concise description of what the variable controls.
    -   `:type`: Specifies the data type (e.g., `string`, `integer`, `boolean`, `file`, `directory`, `(choice ...)`). This helps Emacs provide appropriate input widgets in the customization interface.
    -   `:group`: Assigns the variable to a customization group. For the `gemini-cli` integration, a group like `solfunmeme` or `gemini-cli` should be used. This allows users to find all related customizations easily via `M-x customize-group group-name`.

3.  **Example (`solfunmeme-auto-run-interval`):**
    ```elisp
    (defcustom solfunmeme-auto-run-interval 300
      "Interval in seconds for automatically running all Gemini tasks."
      :type 'integer
      :group 'solfunmeme)
    ```

### 2. Implementing Online Help:

1.  **Docstrings for Functions (`defun`)**: Every function should have a clear and informative docstring immediately after its argument list. This docstring is displayed when `C-h f` (describe-function) is used.

    **Syntax:**
    ```elisp
    (defun function-name (args)
      "Documentation string for the function."
      ;; Function body
      )
    ```

    -   The first line of the docstring should be a concise summary.
    -   Subsequent lines can provide more details, examples, and explanations of arguments and return values.

2.  **Docstrings for Variables (`defvar`, `defcustom`)**: As shown above, `defcustom` requires a docstring. For `defvar` (for non-customizable variables), a docstring is also highly recommended.

3.  **`help-echo` for Interactive Commands**: For interactive commands, `help-echo` can provide a brief description that appears in the echo area when the command is highlighted (e.g., in `M-x` completion).

    **Syntax (within `interactive` form):**
    ```elisp
    (defun my-command ()
      "My command does something useful."
      (interactive (list (read-string "Prompt: ")))
      (message "Hello, %s" arg))
    ```
    *(Note: `help-echo` is typically used with `key-binding` definitions or in more complex interactive forms, but ensuring good docstrings is the primary step for online help.)*

4.  **Customization Groups Documentation**: Ensure the customization group itself has a docstring, which is displayed when `M-x customize-group group-name` is used.

    **Syntax:**
    ```elisp
    (defgroup solfunmeme nil
      "Customization group for Solfunmeme Emacs integrations."
      :group 'solfunmeme)
    ```

### 3. Testing and Verification:
- After implementing configurable items, verify they appear correctly in `M-x customize-group group-name`.
- Test docstrings by using `C-h f` on functions and `C-h v` on variables.
- Ensure all new `defcustom` variables are properly typed and have sensible default values.

## Related Documents:
- [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
- [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
- `docs/crqs/CRQ_Emacs_Configurable_Items_and_Online_Help.md`
- `solfunmeme-gemini.el`
- `solfunmeme-mode.el`

## Revision History:
- [Date]: Initial Draft
