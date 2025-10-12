{
  # Define the top 8 principles as an attribute set
  # Each principle will have a 'flag' (a 42-bit integer) and its associated 'emoji'
  bottPrinciples = {
    # 1. builder, name, system
    coreBuildComponents = {
      flag = 1; # 2^0 = 1
      emoji = "🚀";
      description = "Core build components: builder, name, system";
    };

    # 2. args
    argumentsAndConfig = {
      flag = 2; # 2^1 = 2
      emoji = "⚙️";
      description = "Arguments and configuration: args";
    };

    # 3. buildInputs, configureFlags, ...
    dependenciesAndBuildSetup = {
      flag = 4; # 2^2 = 4
      emoji = "📦";
      description = "Dependencies and build setup: buildInputs, configureFlags, etc.";
    };

    # 4. cmakeFlags
    cmakeBuildFlags = {
      flag = 8; # 2^3 = 8
      emoji = "🛠️";
      description = "CMake build system flags: cmakeFlags";
    };

    # 5. mesonFlags
    mesonBuildFlags = {
      flag = 16; # 2^4 = 16
      emoji = "🔧";
      description = "Meson build system flags: mesonFlags";
    };

    # 6. __structuredAttrs
    structuredAttributes = {
      flag = 32; # 2^5 = 32
      emoji = "🌳";
      description = "Structured data and attributes: __structuredAttrs";
    };

    # 7. preferLocalBuild
    localBuildPreference = {
      flag = 64; # 2^6 = 64
      emoji = "🏠";
      description = "Local build preference: preferLocalBuild";
    };

    # 8. executable
    executableOutput = {
      flag = 128; # 2^7 = 128
      emoji = "🏃";
      description = "Executable output: executable";
    };
  };

  # A combined flag for all bott principles (for demonstration)
  # This would be the sum of all individual flags
  allBottPrinciplesFlag = 255;
}
