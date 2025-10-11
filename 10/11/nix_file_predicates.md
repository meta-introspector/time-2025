# 🏷️ Nix File Predicates for nix2make2nix Classification

This document outlines 42 predicates for classifying Nix files within the `nix2make2nix` content-addressable build system. These predicates serve as a structured way to categorize and understand the purpose and characteristics of each Nix expression.

## Predicate List

1.  **IsFlakeDefinition:** (Boolean) ❄️🚫❄️ Is this file a `flake.nix`?
2.  **IsNixModule:** (Boolean) 📦🚫📦 Is this file a Nix module (e.g., `default.nix` in a module directory, or a file defining options/config)?
3.  **IsNixPackage:** (Boolean) 🎁🚫🎁 Does this file define a Nix package?
4.  **IsNixLibrary:** (Boolean) 📚📖 Is this file contain reusable Nix functions or utilities?
5.  **IsNixTest:** (Boolean) 🧪❌🧪 Is this file a Nix test expression?
6.  **IsNixScript:** (Boolean) 📜🚫📜 Is this file a shell script embedded in Nix or a Nix expression that generates a script?
7.  **IsNixConfiguration:** (Boolean) ⚙️🚫⚙️ Does this file define configuration options?
8.  **IsNixDocumentation:** (Boolean) 📝📄 Is this file a Nix expression related to documentation generation or processing?
9.  **IsNixTheory:** (Boolean) 💡💭 Is this file a Nix expression related to theoretical concepts or experiments?
10. **IsVendorizedNix:** (Boolean) 🤝💔 Is this file part of a vendorized external Nix expression?
11. **IsQAComponent:** (Boolean) ✅❌ Is this file part of the Quality Assurance system?
12. **IsBuildSystemComponent:** (Boolean) 🏗️🚧 Is this file part of the core build system logic?
13. **IsLLMIntegration:** (Boolean) 🤖🧑‍💻 Is this file related to Large Language Model integration?
14. **IsSymbolicRepresentation:** (Boolean) 🔣🔡 Is this file related to symbolic representations (emojis, primes)?
15. **IsContentAddressable:** (Boolean) 🔗👻 Is this file part of the content-addressable mechanism?
16. **IsFlakeInput:** (Boolean) 📥📤 Is this file intended to be a flake input?
17. **IsFlakeOutput:** (Boolean) 📤📥 Is this file defining a flake output?
18. **IsDerivation:** (Boolean) 🏭🗑️ Is this file define a derivation?
19. **IsFunction:** (Boolean) ➡️↩️ Does this file define a Nix function?
20. **IsAttributeSet:** (Boolean) 🧩⬜ Does this file define an attribute set?
21. **IsList:** (Boolean) 📜📄 Does this file define a list?
22. **HasExternalDependencies:** (Boolean) 🌐🏠 Does this file depend on external resources (e.g., `fetchurl`, `fetchGit`)?
23. **IsImpure:** (Boolean) 🌪️✨ Does this file use impure Nix features?
24. **IsPure:** (Boolean) ✨🌪️ Is this file a pure Nix expression?
25. **IsExperimental:** (Boolean) 🧪✅ Is this file marked as experimental or work-in-progress?
26. **IsStable:** (Boolean) 🔒🔓 Is this file considered stable?
27. **IsDeprecated:** (Boolean) 🗑️✨ Is this file deprecated?
28. **RelatesToCRQ:** (Boolean) 🎫🚫🎫 Is this file related to a Change Request (CRQ)?
29. **RelatesToSOP:** (Boolean) 📜📄 Is this file related to a Standard Operating Procedure (SOP)?
30. **RelatesToMeme:** (Boolean) 😂😐 Is this file related to a "meme" (as in the project's context)?
31. **RelatesToPrimeNumbers:** (Boolean) 🔢🔠 Is this file specifically dealing with prime numbers?
32. **RelatesToEmojiEncoding:** (Boolean) 😄😐 Is this file related to emoji encoding/decoding?
33. **RelatesToGraphTheory:** (Boolean) 📊📈 Is this file related to graph theory concepts?
34. **RelatesToOntology:** (Boolean) 🧠💭 Is this file related to ontology definitions or processing?
35. **RelatesToGitHubAPI:** (Boolean) 🐙👻 Is this file interacting with the GitHub API?
36. **RelatesToLogAnalysis:** (Boolean) 🔍📄 Is this file related to log analysis?
37. **RelatesToSynapseSystem:** (Boolean) 🧠⚙️ Is this file part of the "synapse-system"?
38. **RelatesToDream2Nix:** (Boolean) 💭😴 Is this file part of the `dream2nix` vendorization?
39. **RelatesToMachNix:** (Boolean) ⚙️🛠️ Is this file part of the `mach-nix` vendorization?
40. **RelatesToPip2Nix:** (Boolean) 🐍🐭 Is this file part of the `pip2nix` vendorization?
41. **RelatesToPynixify:** (Boolean) 🐍🐭 Is this file part of the `pynixify` vendorization?
42. **RelatesToUv2Nix:** (Boolean) ☀️☔ Is this file part of the `uv2nix` vendorization?

## Conceptual Ordering based on Prime Factorization

In the `nix2make2nix` system, the ordering and significance of these predicates can be further refined based on the prime factorization of their position in the list. Predicates at prime-numbered indexes (e.g., 2nd, 3rd, 5th, 7th, etc.) could be assigned "special meaning," indicating their fundamental or axiomatic nature within the classification scheme. For instance:

*   **Prime-indexed predicates:** Represent core, irreducible properties.
*   **Composite-indexed predicates:** Represent derived or composite properties, potentially factorable into their prime-indexed components.

This conceptual ordering aligns with the project's vision of using primes and symbolic representations for deep structural encoding.