# Nix Attribute to Prime and Emoji Mapping

This document maps frequently occurring Nix attributes (or groups of attributes) to prime numbers and emojis, based on their frequency in `attrcount.txt`.

## Top 8 Attributes

1.  **`builder`, `name`, `system`** (Count: 5960)
    *   **Prime:** 2
    *   **Emoji:** 🚀 (Rocket - representing core build components)
2.  **`args`** (Count: 5112)
    *   **Prime:** 3
    *   **Emoji:** ⚙️ (Gear - representing arguments and configuration)
3.  **`buildInputs`, `configureFlags`, `depsBuildBuild`, `depsBuildBuildPropagated`, `depsBuildTarget`, `depsBuildTargetPropagated`, `depsHostHost`, `depsHostHostPropagated`, `depsTargetTarget`, `depsTargetTargetPropagated`, `doCheck`, `doInstallCheck`, `nativeBuildInputs`, `outputs`, `patches`, `propagatedBuildInputs`, `propagatedNativeBuildInputs`, `stdenv`, `strictDeps`, `userHook`** (Count: 5033)
    *   **Prime:** 5
    *   **Emoji:** 📦 (Package - representing dependencies and build setup)
4.  **`cmakeFlags`** (Count: 4003)
    *   **Prime:** 7
    *   **Emoji:** 🛠️ (Hammer and Wrench - representing CMake build system flags)
5.  **`mesonFlags`** (Count: 4002)
    *   **Prime:** 11
    *   **Emoji:** 🔧 (Wrench - representing Meson build system flags)
6.  **`__structuredAttrs`** (Count: 3994)
    *   **Prime:** 13
    *   **Emoji:** 🌳 (Tree - representing structured data and attributes)
7.  **`preferLocalBuild`** (Count: 3443)
    *   **Prime:** 17
    *   **Emoji:** 🏠 (House - representing local build preference)
8.  **`executable`** (Count: 3270)
    *   **Prime:** 19
    *   **Emoji:** 🏃 (Runner - representing executable output)

## Next 16 Attributes

9.  **`outputHashMode`, `outputHash`, `impureEnvVars`** (Count: 2824, 2824, 2823)
    *   **Prime:** 23
    *   **Emoji:** 🔒 (Locked - representing hashing and environment security)
10. **`urls`** (Count: 2807)
    *   **Prime:** 29
    *   **Emoji:** 🔗 (Link - representing external resource links)
11. **`postHook`** (Count: 1967)
    *   **Prime:** 31
    *   **Emoji:** 🎣 (Fishing Hook - representing post-build actions)
12. **`postFetch`** (Count: 1966)
    *   **Prime:** 37
    *   **Emoji:** 📥 (Inbox - representing actions after fetching)
13. **`curlOpts`, `downloadToTemp`, `mirrorsFile`, `nixpkgsVersion`, `preferHashedMirrors`, `showURLs`, `SSL_CERT_FILE`** (Count: 1959)
    *   **Prime:** 41
    *   **Emoji:** 🌐 (Globe - representing network and download options)
14. **`pname`, `src`, `version`** (Count: 1839)
    *   **Prime:** 43
    *   **Emoji:** 🏷️ (Label - representing package identification)
15. **`enableParallelBuilding`** (Count: 1629)
    *   **Prime:** 47
    *   **Emoji:** ⏩ (Fast-Forward - representing parallelization)
16. **`curlOptsList`** (Count: 1513)
    *   **Prime:** 53
    *   **Emoji:** 📜 (Scroll - representing a list of cURL options)
17. **`enableParallelChecking`** (Count: 1509)
    *   **Prime:** 59
    *   **Emoji:** ✅ (Check Mark - representing parallel checking)
18. **`enableParallelInstalling`** (Count: 1416)
    *   **Prime:** 61
    *   **Emoji:** ➕ (Plus Sign - representing parallel installation)
19. **`buildCommand`** (Count: 1101)
    *   **Prime:** 67
    *   **Emoji:** 🏗️ (Building Construction - representing the build command)
20. **`passAsFile`** (Count: 1088)
    *   **Prime:** 71
    *   **Emoji:** 📄 (Page - representing passing content as a file)
21. **`url`** (Count: 856)
    *   **Prime:** 73
    *   **Emoji:** 🌍 (Earth - representing a single URL)
22. **`unpack`** (Count: 848)
    *   **Prime:** 79
    *   **Emoji:** 🎁 (Gift - representing unpacking archives)
23. **`postPatch`** (Count: 772)
    *   **Prime:** 83
    *   **Emoji:** 🩹 (Adhesive Bandage - representing actions after patching)
24. **`checkPhase`** (Count: 739)
    *   **Prime:** 89
    *   **Emoji:** 🔍 (Magnifying Glass - representing the check phase)

## Next Interesting Attributes

25. **`installPhase`** (Count: 572)
    *   **Prime:** 97
    *   **Emoji:** 🏗️ (Construction - representing the installation step)
26. **`allowSubstitutes`** (Count: 544)
    *   **Prime:** 101
    *   **Emoji:** 🔄 (Recycle - representing binary caching/substitution)
27. **`postFixup`** (Count: 530)
    *   **Prime:** 103
    *   **Emoji:** 🩹 (Band-Aid - representing post-build adjustments)
28. **`LANG`** (Count: 501)
    *   **Prime:** 107
    *   **Emoji:** 🗣️ (Speaking Head - representing language/localization settings)
29. **`hardeningDisable`**, **`NIX_HARDENING_ENABLE`** (Count: 374, 359)
    *   **Prime:** 109
    *   **Emoji:** 🛡️ (Shield - representing security hardening)
30. **`configurePlatforms`** (Count: 338)
    *   **Prime:** 113
    *   **Emoji:** 🌐 (Globe - representing platform configuration)
31. **`disallowedReferences`** (Count: 335)
    *   **Prime:** 127
    *   **Emoji:** 🚫 (No Entry - representing forbidden dependencies)
32. **`configurePhase`** (Count: 243)
    *   **Prime:** 131
    *   **Emoji:** ⚙️ (Gear - representing the configuration step)
33. **`dontWrapPythonPrograms`** (Count: 179)
    *   **Prime:** 137
    *   **Emoji:** 🐍 (Snake - representing Python-specific behavior)
34. **`NIX_CFLAGS_COMPILE`** (Count: 132)
    *   **Prime:** 139
    *   **Emoji:** 📝 (Memo - representing C compiler flags)
