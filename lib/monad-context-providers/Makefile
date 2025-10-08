include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./lib/monad-context-providers"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-gemini

test-gemini: gemini.nix
	@echo "--- Testing gemini.nix with nix eval ---"
	@nix eval --raw ./gemini.nix > gemini.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for gemini.nix. Check gemini.eval.log for details."
		cat gemini.eval.log; 		exit 1; 	}
	@echo "--- gemini.nix test complete. Output in gemini.eval.log ---"



.PHONY: test-groq

test-groq: groq.nix
	@echo "--- Testing groq.nix with nix eval ---"
	@nix eval --raw ./groq.nix > groq.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for groq.nix. Check groq.eval.log for details."
		cat groq.eval.log; 		exit 1; 	}
	@echo "--- groq.nix test complete. Output in groq.eval.log ---"



.PHONY: test-amazonq

test-amazonq: amazonq.nix
	@echo "--- Testing amazonq.nix with nix eval ---"
	@nix eval --raw ./amazonq.nix > amazonq.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for amazonq.nix. Check amazonq.eval.log for details."
		cat amazonq.eval.log; 		exit 1; 	}
	@echo "--- amazonq.nix test complete. Output in amazonq.eval.log ---"



.PHONY: test-github-copilot

test-github-copilot: github-copilot.nix
	@echo "--- Testing github-copilot.nix with nix eval ---"
	@nix eval --raw ./github-copilot.nix > github-copilot.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github-copilot.nix. Check github-copilot.eval.log for details."
		cat github-copilot.eval.log; 		exit 1; 	}
	@echo "--- github-copilot.nix test complete. Output in github-copilot.eval.log ---"



.PHONY: test-openai-codex

test-openai-codex: openai-codex.nix
	@echo "--- Testing openai-codex.nix with nix eval ---"
	@nix eval --raw ./openai-codex.nix > openai-codex.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for openai-codex.nix. Check openai-codex.eval.log for details."
		cat openai-codex.eval.log; 		exit 1; 	}
	@echo "--- openai-codex.nix test complete. Output in openai-codex.eval.log ---"


