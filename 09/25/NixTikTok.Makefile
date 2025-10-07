# NixTikTok.Makefile
# Learning Nix, one TikTok at a time! 🚀
# Each target is a short, engaging video for n00bs.

.PHONY: all help encode_simple_expr translate_lambda_to_emojis make_make_prompt_prompt generate_simple_prompt

all: help

help:
	@echo "Welcome to Nix TikTok! Learn Nix the fun way. ✨"
	@echo ""
	@echo "Available 'TikToks' (make targets):"
	@echo "  encode_simple_expr - See how we turn Lean4 expressions into prime emojis! 🔢💡"
	@echo "  translate_lambda_to_emojis - Imagine: Turning that <LAMBDA> into a vibrant emoji sequence! 🤩"
	@echo "  make_make_prompt_prompt - 🤖 Make a prompt that makes prompts! (via Gemini in Nix)"
	@echo "  generate_simple_prompt - 📝 Generate a simple prompt for Gemini."
	@echo "  # Add more targets here as we go!"

encode_simple_expr: ## See how we turn Lean4 expressions into prime emojis! 🔢💡
	@echo "🎬 TikTok: Encoding Lean4 SimpleExpr to Prime Emojis!"
	@echo "🎵 Sound: 'Mind Blown' by Epic Beats"
	@echo "✨ Effect: Sparkle filter on the output!"
	@echo "👇 Watch this magic happen:"
	nix-build -E 'with import <nixpkgs> {}; callPackage ./09/25/test_prime_encoder.nix {}' --no-out-link
	@echo "👆 Boom! That's your Lean4 expression, now a sequence of prime emojis! 🤯"

translate_lambda_to_emojis: ## Imagine: Turning that <LAMBDA> into a vibrant emoji sequence! 🤩"
	@echo "🎬 TikTok: From <LAMBDA> to Emoji Magic! ✨"
	@echo "🎵 Sound: 'Transformation' by Synthwave Dreams"
	@echo "✨ Effect: Rainbow glow on the <LAMBDA>!"
	@echo "👇 The dream: Take the encoded prime sequence (currently hidden behind <LAMBDA>)..."
	@echo "   ...and transform it into a beautiful, readable string of emojis!"
	@echo "   This will involve calling the Nix function and then mapping the resulting prime list to emojis."
	@echo "   Stay tuned for the next episode! 🔜"

make_make_prompt_prompt: ## 🤖 Make a prompt that makes prompts! (via Gemini in Nix)
	echo "🎬 TikTok: Prompting the Prompt-Maker! 🤯" ; \
	echo "🎵 Sound: 'Inception' by Hans Zimmer" ; \
	echo "✨ Effect: Glitch filter on the screen!" ; \
	echo "👇 Watch Gemini generate a new prompt within a Nix derivation:" ; \
	PROMPT="Write a short, creative haiku about Nix flakes and their purity." ; \
	nix build \
	  --impure \
	  --extra-experimental-features "nix-command flakes impure-derivations" \
	  --arg pkgs '(import <nixpkgs> {})' \
	  --arg lib '(import <nixpkgs> {}).lib' \
	  --argstr system "aarch64-linux" \
	  -f /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/25/gemini-prompt-derivation.nix \
	  --argstr prompt "$PROMPT" \
	  --arg gemini-cli '(builtins.getFlake "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06").packages.aarch64-linux.default' ; \
	echo "👆 Gemini just made a prompt for you! Check the 'result' symlink for the output. 📝"