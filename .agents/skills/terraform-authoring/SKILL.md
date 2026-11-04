---
name: terraform-authoring
description: Use when writing or modifying Terraform configurations or modules.
metadata:
  author: Zach Callahan
  version: "1.0"
---

# Terraform authoring

- For providers with strong communities, prefer widely used community modules
  over custom modules.
- Identify and prefer the latest versions of providers and modules. Pin exact
  versions, except provider requirements in reusable custom modules: constrain
  those to a single major version.
- In custom modules, add outputs only when another module is known to need them,
  and variables only when variability is confirmed to be necessary.

## Gruntwork Terraform style

Apply these conventions unless they conflict with the rules above:

- Run `terraform fmt`; use two-space indentation and snake_case for block
  labels, variables, and outputs.
- Put configuration in `main.tf`, inputs in `variables.tf`, and outputs in
  `outputs.tf`. Explain nonstandard file layouts in the README.
- Give every variable a `description` and explicit `type`, in that order.
  Separate required variables from optional variables with defaults; clearly
  identify required environment variables. If using `any`, comment the supported
  attributes.
- Give every output a `description` before its `value`.
- Use `#` for comments rather than `//` or `/* */`.
- Use indented heredocs (`<<-EOF`, not `<<EOF`) so their contents can follow the
  surrounding indentation.
- Break ternary expressions across multiple lines and wrap them in parentheses
  for readability.
- Put usage examples in `examples/`. Test each example at least once; tests for
  modules in `modules/` should exercise them through examples rather than
  calling them directly.
