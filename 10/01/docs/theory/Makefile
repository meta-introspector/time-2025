include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./10/01/docs/theory"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-unmath.owl

test-unmath.owl: unmath.owl.nix
	@echo "--- Testing unmath.owl.nix with nix eval ---"
	@nix eval --raw ./unmath.owl.nix > unmath.owl.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for unmath.owl.nix. Check unmath.owl.eval.log for details."
		cat unmath.owl.eval.log; 		exit 1; 	}
	@echo "--- unmath.owl.nix test complete. Output in unmath.owl.eval.log ---"



.PHONY: test-label_interpreter

test-label_interpreter: label_interpreter.nix
	@echo "--- Testing label_interpreter.nix with nix eval ---"
	@nix eval --raw ./label_interpreter.nix > label_interpreter.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for label_interpreter.nix. Check label_interpreter.eval.log for details."
		cat label_interpreter.eval.log; 		exit 1; 	}
	@echo "--- label_interpreter.nix test complete. Output in label_interpreter.eval.log ---"



.PHONY: test-emoji_grammar_graph

test-emoji_grammar_graph: emoji_grammar_graph.nix
	@echo "--- Testing emoji_grammar_graph.nix with nix eval ---"
	@nix eval --raw ./emoji_grammar_graph.nix > emoji_grammar_graph.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for emoji_grammar_graph.nix. Check emoji_grammar_graph.eval.log for details."
		cat emoji_grammar_graph.eval.log; 		exit 1; 	}
	@echo "--- emoji_grammar_graph.nix test complete. Output in emoji_grammar_graph.eval.log ---"



.PHONY: test-build_2gram_index

test-build_2gram_index: build_2gram_index.nix
	@echo "--- Testing build_2gram_index.nix with nix eval ---"
	@nix eval --raw ./build_2gram_index.nix > build_2gram_index.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for build_2gram_index.nix. Check build_2gram_index.eval.log for details."
		cat build_2gram_index.eval.log; 		exit 1; 	}
	@echo "--- build_2gram_index.nix test complete. Output in build_2gram_index.eval.log ---"



.PHONY: test-emoji.owl

test-emoji.owl: emoji.owl.nix
	@echo "--- Testing emoji.owl.nix with nix eval ---"
	@nix eval --raw ./emoji.owl.nix > emoji.owl.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for emoji.owl.nix. Check emoji.owl.eval.log for details."
		cat emoji.owl.eval.log; 		exit 1; 	}
	@echo "--- emoji.owl.nix test complete. Output in emoji.owl.eval.log ---"



.PHONY: test-emoji2nix

test-emoji2nix: emoji2nix.nix
	@echo "--- Testing emoji2nix.nix with nix eval ---"
	@nix eval --raw ./emoji2nix.nix > emoji2nix.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for emoji2nix.nix. Check emoji2nix.eval.log for details."
		cat emoji2nix.eval.log; 		exit 1; 	}
	@echo "--- emoji2nix.nix test complete. Output in emoji2nix.eval.log ---"



.PHONY: test-git_org_manager

test-git_org_manager: git_org_manager.nix
	@echo "--- Testing git_org_manager.nix with nix eval ---"
	@nix eval --raw ./git_org_manager.nix > git_org_manager.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for git_org_manager.nix. Check git_org_manager.eval.log for details."
		cat git_org_manager.eval.log; 		exit 1; 	}
	@echo "--- git_org_manager.nix test complete. Output in git_org_manager.eval.log ---"



.PHONY: test-github.graphql

test-github.graphql: github.graphql.nix
	@echo "--- Testing github.graphql.nix with nix eval ---"
	@nix eval --raw ./github.graphql.nix > github.graphql.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for github.graphql.nix. Check github.graphql.eval.log for details."
		cat github.graphql.eval.log; 		exit 1; 	}
	@echo "--- github.graphql.nix test complete. Output in github.graphql.eval.log ---"



.PHONY: test-jupyter

test-jupyter: jupyter.nix
	@echo "--- Testing jupyter.nix with nix eval ---"
	@nix eval --raw ./jupyter.nix > jupyter.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for jupyter.nix. Check jupyter.eval.log for details."
		cat jupyter.eval.log; 		exit 1; 	}
	@echo "--- jupyter.nix test complete. Output in jupyter.eval.log ---"



.PHONY: test-markdown_twin_generator

test-markdown_twin_generator: markdown_twin_generator.nix
	@echo "--- Testing markdown_twin_generator.nix with nix eval ---"
	@nix eval --raw ./markdown_twin_generator.nix > markdown_twin_generator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for markdown_twin_generator.nix. Check markdown_twin_generator.eval.log for details."
		cat markdown_twin_generator.eval.log; 		exit 1; 	}
	@echo "--- markdown_twin_generator.nix test complete. Output in markdown_twin_generator.eval.log ---"



.PHONY: test-matplotlib

test-matplotlib: matplotlib.nix
	@echo "--- Testing matplotlib.nix with nix eval ---"
	@nix eval --raw ./matplotlib.nix > matplotlib.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for matplotlib.nix. Check matplotlib.eval.log for details."
		cat matplotlib.eval.log; 		exit 1; 	}
	@echo "--- matplotlib.nix test complete. Output in matplotlib.eval.log ---"



.PHONY: test-n_gram_generator

test-n_gram_generator: n_gram_generator.nix
	@echo "--- Testing n_gram_generator.nix with nix eval ---"
	@nix eval --raw ./n_gram_generator.nix > n_gram_generator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for n_gram_generator.nix. Check n_gram_generator.eval.log for details."
		cat n_gram_generator.eval.log; 		exit 1; 	}
	@echo "--- n_gram_generator.nix test complete. Output in n_gram_generator.eval.log ---"



.PHONY: test-nix2emoji

test-nix2emoji: nix2emoji.nix
	@echo "--- Testing nix2emoji.nix with nix eval ---"
	@nix eval --raw ./nix2emoji.nix > nix2emoji.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix2emoji.nix. Check nix2emoji.eval.log for details."
		cat nix2emoji.eval.log; 		exit 1; 	}
	@echo "--- nix2emoji.nix test complete. Output in nix2emoji.eval.log ---"



.PHONY: test-nix_code_indexer

test-nix_code_indexer: nix_code_indexer.nix
	@echo "--- Testing nix_code_indexer.nix with nix eval ---"
	@nix eval --raw ./nix_code_indexer.nix > nix_code_indexer.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_code_indexer.nix. Check nix_code_indexer.eval.log for details."
		cat nix_code_indexer.eval.log; 		exit 1; 	}
	@echo "--- nix_code_indexer.nix test complete. Output in nix_code_indexer.eval.log ---"



.PHONY: test-nix_2gram_indexer

test-nix_2gram_indexer: nix_2gram_indexer.nix
	@echo "--- Testing nix_2gram_indexer.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer.nix > nix_2gram_indexer.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer.nix. Check nix_2gram_indexer.eval.log for details."
		cat nix_2gram_indexer.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer.nix test complete. Output in nix_2gram_indexer.eval.log ---"



.PHONY: test-nix_data_science_platform

test-nix_data_science_platform: nix_data_science_platform.nix
	@echo "--- Testing nix_data_science_platform.nix with nix eval ---"
	@nix eval --raw ./nix_data_science_platform.nix > nix_data_science_platform.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_data_science_platform.nix. Check nix_data_science_platform.eval.log for details."
		cat nix_data_science_platform.eval.log; 		exit 1; 	}
	@echo "--- nix_data_science_platform.nix test complete. Output in nix_data_science_platform.eval.log ---"



.PHONY: test-pandas

test-pandas: pandas.nix
	@echo "--- Testing pandas.nix with nix eval ---"
	@nix eval --raw ./pandas.nix > pandas.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for pandas.nix. Check pandas.eval.log for details."
		cat pandas.eval.log; 		exit 1; 	}
	@echo "--- pandas.nix test complete. Output in pandas.eval.log ---"



.PHONY: test-nix_to_owl_ontology

test-nix_to_owl_ontology: nix_to_owl_ontology.nix
	@echo "--- Testing nix_to_owl_ontology.nix with nix eval ---"
	@nix eval --raw ./nix_to_owl_ontology.nix > nix_to_owl_ontology.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_to_owl_ontology.nix. Check nix_to_owl_ontology.eval.log for details."
		cat nix_to_owl_ontology.eval.log; 		exit 1; 	}
	@echo "--- nix_to_owl_ontology.nix test complete. Output in nix_to_owl_ontology.eval.log ---"



.PHONY: test-project_nix_path_ngrams

test-project_nix_path_ngrams: project_nix_path_ngrams.nix
	@echo "--- Testing project_nix_path_ngrams.nix with nix eval ---"
	@nix eval --raw ./project_nix_path_ngrams.nix > project_nix_path_ngrams.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for project_nix_path_ngrams.nix. Check project_nix_path_ngrams.eval.log for details."
		cat project_nix_path_ngrams.eval.log; 		exit 1; 	}
	@echo "--- project_nix_path_ngrams.nix test complete. Output in project_nix_path_ngrams.eval.log ---"



.PHONY: test-secret_scanner

test-secret_scanner: secret_scanner.nix
	@echo "--- Testing secret_scanner.nix with nix eval ---"
	@nix eval --raw ./secret_scanner.nix > secret_scanner.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for secret_scanner.nix. Check secret_scanner.eval.log for details."
		cat secret_scanner.eval.log; 		exit 1; 	}
	@echo "--- secret_scanner.nix test complete. Output in secret_scanner.eval.log ---"



.PHONY: test-sparql

test-sparql: sparql.nix
	@echo "--- Testing sparql.nix with nix eval ---"
	@nix eval --raw ./sparql.nix > sparql.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for sparql.nix. Check sparql.eval.log for details."
		cat sparql.eval.log; 		exit 1; 	}
	@echo "--- sparql.nix test complete. Output in sparql.eval.log ---"



.PHONY: test-url_provenance_mapper

test-url_provenance_mapper: url_provenance_mapper.nix
	@echo "--- Testing url_provenance_mapper.nix with nix eval ---"
	@nix eval --raw ./url_provenance_mapper.nix > url_provenance_mapper.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for url_provenance_mapper.nix. Check url_provenance_mapper.eval.log for details."
		cat url_provenance_mapper.eval.log; 		exit 1; 	}
	@echo "--- url_provenance_mapper.nix test complete. Output in url_provenance_mapper.eval.log ---"



.PHONY: test-plot_schema

test-plot_schema: plot_schema.nix
	@echo "--- Testing plot_schema.nix with nix eval ---"
	@nix eval --raw ./plot_schema.nix > plot_schema.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for plot_schema.nix. Check plot_schema.eval.log for details."
		cat plot_schema.eval.log; 		exit 1; 	}
	@echo "--- plot_schema.nix test complete. Output in plot_schema.eval.log ---"



.PHONY: test-2gram_report_generator

test-2gram_report_generator: 2gram_report_generator.nix
	@echo "--- Testing 2gram_report_generator.nix with nix eval ---"
	@nix eval --raw ./2gram_report_generator.nix > 2gram_report_generator.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 2gram_report_generator.nix. Check 2gram_report_generator.eval.log for details."
		cat 2gram_report_generator.eval.log; 		exit 1; 	}
	@echo "--- 2gram_report_generator.nix test complete. Output in 2gram_report_generator.eval.log ---"



.PHONY: test-verifiable_file_topology

test-verifiable_file_topology: verifiable_file_topology.nix
	@echo "--- Testing verifiable_file_topology.nix with nix eval ---"
	@nix eval --raw ./verifiable_file_topology.nix > verifiable_file_topology.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for verifiable_file_topology.nix. Check verifiable_file_topology.eval.log for details."
		cat verifiable_file_topology.eval.log; 		exit 1; 	}
	@echo "--- verifiable_file_topology.nix test complete. Output in verifiable_file_topology.eval.log ---"



.PHONY: test-w3c_ontology_importer

test-w3c_ontology_importer: w3c_ontology_importer.nix
	@echo "--- Testing w3c_ontology_importer.nix with nix eval ---"
	@nix eval --raw ./w3c_ontology_importer.nix > w3c_ontology_importer.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for w3c_ontology_importer.nix. Check w3c_ontology_importer.eval.log for details."
		cat w3c_ontology_importer.eval.log; 		exit 1; 	}
	@echo "--- w3c_ontology_importer.nix test complete. Output in w3c_ontology_importer.eval.log ---"



.PHONY: test-create_plot

test-create_plot: create_plot.nix
	@echo "--- Testing create_plot.nix with nix eval ---"
	@nix eval --raw ./create_plot.nix > create_plot.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for create_plot.nix. Check create_plot.eval.log for details."
		cat create_plot.eval.log; 		exit 1; 	}
	@echo "--- create_plot.nix test complete. Output in create_plot.eval.log ---"



.PHONY: test-content_transformer_and_organizer

test-content_transformer_and_organizer: content_transformer_and_organizer.nix
	@echo "--- Testing content_transformer_and_organizer.nix with nix eval ---"
	@nix eval --raw ./content_transformer_and_organizer.nix > content_transformer_and_organizer.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for content_transformer_and_organizer.nix. Check content_transformer_and_organizer.eval.log for details."
		cat content_transformer_and_organizer.eval.log; 		exit 1; 	}
	@echo "--- content_transformer_and_organizer.nix test complete. Output in content_transformer_and_organizer.eval.log ---"



.PHONY: test-w3c_spec_vendorizer

test-w3c_spec_vendorizer: w3c_spec_vendorizer.nix
	@echo "--- Testing w3c_spec_vendorizer.nix with nix eval ---"
	@nix eval --raw ./w3c_spec_vendorizer.nix > w3c_spec_vendorizer.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for w3c_spec_vendorizer.nix. Check w3c_spec_vendorizer.eval.log for details."
		cat w3c_spec_vendorizer.eval.log; 		exit 1; 	}
	@echo "--- w3c_spec_vendorizer.nix test complete. Output in w3c_spec_vendorizer.eval.log ---"



.PHONY: test-nix_2gram_indexer_step1

test-nix_2gram_indexer_step1: nix_2gram_indexer_step1.nix
	@echo "--- Testing nix_2gram_indexer_step1.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step1.nix > nix_2gram_indexer_step1.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step1.nix. Check nix_2gram_indexer_step1.eval.log for details."
		cat nix_2gram_indexer_step1.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step1.nix test complete. Output in nix_2gram_indexer_step1.eval.log ---"



.PHONY: test-nix_2gram_indexer_step2

test-nix_2gram_indexer_step2: nix_2gram_indexer_step2.nix
	@echo "--- Testing nix_2gram_indexer_step2.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step2.nix > nix_2gram_indexer_step2.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step2.nix. Check nix_2gram_indexer_step2.eval.log for details."
		cat nix_2gram_indexer_step2.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step2.nix test complete. Output in nix_2gram_indexer_step2.eval.log ---"



.PHONY: test-nix_2gram_indexer_step3

test-nix_2gram_indexer_step3: nix_2gram_indexer_step3.nix
	@echo "--- Testing nix_2gram_indexer_step3.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step3.nix > nix_2gram_indexer_step3.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step3.nix. Check nix_2gram_indexer_step3.eval.log for details."
		cat nix_2gram_indexer_step3.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step3.nix test complete. Output in nix_2gram_indexer_step3.eval.log ---"



.PHONY: test-nix_2gram_indexer_step4

test-nix_2gram_indexer_step4: nix_2gram_indexer_step4.nix
	@echo "--- Testing nix_2gram_indexer_step4.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step4.nix > nix_2gram_indexer_step4.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step4.nix. Check nix_2gram_indexer_step4.eval.log for details."
		cat nix_2gram_indexer_step4.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step4.nix test complete. Output in nix_2gram_indexer_step4.eval.log ---"



.PHONY: test-nix_2gram_indexer_step5

test-nix_2gram_indexer_step5: nix_2gram_indexer_step5.nix
	@echo "--- Testing nix_2gram_indexer_step5.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step5.nix > nix_2gram_indexer_step5.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step5.nix. Check nix_2gram_indexer_step5.eval.log for details."
		cat nix_2gram_indexer_step5.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step5.nix test complete. Output in nix_2gram_indexer_step5.eval.log ---"



.PHONY: test-nix_2gram_indexer_step6

test-nix_2gram_indexer_step6: nix_2gram_indexer_step6.nix
	@echo "--- Testing nix_2gram_indexer_step6.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step6.nix > nix_2gram_indexer_step6.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step6.nix. Check nix_2gram_indexer_step6.eval.log for details."
		cat nix_2gram_indexer_step6.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step6.nix test complete. Output in nix_2gram_indexer_step6.eval.log ---"



.PHONY: test-nix_2gram_indexer_step7

test-nix_2gram_indexer_step7: nix_2gram_indexer_step7.nix
	@echo "--- Testing nix_2gram_indexer_step7.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step7.nix > nix_2gram_indexer_step7.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step7.nix. Check nix_2gram_indexer_step7.eval.log for details."
		cat nix_2gram_indexer_step7.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step7.nix test complete. Output in nix_2gram_indexer_step7.eval.log ---"



.PHONY: test-nix_2gram_indexer_step8

test-nix_2gram_indexer_step8: nix_2gram_indexer_step8.nix
	@echo "--- Testing nix_2gram_indexer_step8.nix with nix eval ---"
	@nix eval --raw ./nix_2gram_indexer_step8.nix > nix_2gram_indexer_step8.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for nix_2gram_indexer_step8.nix. Check nix_2gram_indexer_step8.eval.log for details."
		cat nix_2gram_indexer_step8.eval.log; 		exit 1; 	}
	@echo "--- nix_2gram_indexer_step8.nix test complete. Output in nix_2gram_indexer_step8.eval.log ---"



.PHONY: test-render_plot

test-render_plot: render_plot.nix
	@echo "--- Testing render_plot.nix with nix eval ---"
	@nix eval --raw ./render_plot.nix > render_plot.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for render_plot.nix. Check render_plot.eval.log for details."
		cat render_plot.eval.log; 		exit 1; 	}
	@echo "--- render_plot.nix test complete. Output in render_plot.eval.log ---"



.PHONY: test-example_plot

test-example_plot: example_plot.nix
	@echo "--- Testing example_plot.nix with nix eval ---"
	@nix eval --raw ./example_plot.nix > example_plot.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for example_plot.nix. Check example_plot.eval.log for details."
		cat example_plot.eval.log; 		exit 1; 	}
	@echo "--- example_plot.nix test complete. Output in example_plot.eval.log ---"


