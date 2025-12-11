// src/types/keys.rs

pub const MONSTER_GROUP_ORDER_STR: &str = "808017424794512875886459904961710757005754368000000000";

// Predicate Constants for symbolic embedding
pub const PREDICATE_IS_PUBLIC: &str = "predicate::is_public";
pub const PREDICATE_IS_FUNCTION: &str = "predicate::is_function";
pub const PREDICATE_IS_STRUCT: &str = "predicate::is_struct";
pub const PREDICATE_IS_ENUM: &str = "predicate::is_enum";
pub const PREDICATE_IS_CONST: &str = "predicate::is_const";
pub const PREDICATE_HAS_DOC_COMMENT: &str = "predicate::has_doc_comment";
pub const PREDICATE_PARAM_COUNT: &str = "predicate::param_count";
pub const PREDICATE_FIELD_COUNT: &str = "predicate::field_count";
pub const PREDICATE_VARIANT_COUNT: &str = "predicate::variant_count";
pub const PREDICATE_LITERAL_LENGTH: &str = "predicate::literal_length";
pub const PREDICATE_NUMERIC_LITERAL_VALUE: &str = "predicate::numeric_literal_value";
pub const PREDICATE_PRIME_RESONANCE: &str = "predicate::prime_resonance"; // For general prime matches

// New project-level/repository-level predicates
pub const PREDICATE_IS_CRATE: &str = "predicate::is_crate";
pub const PREDICATE_IS_EXE: &str = "predicate::is_exe";
pub const PREDICATE_IS_NIX_FLAKE: &str = "predicate::is_nix_flake";
pub const PREDICATE_IS_GIT_REPOSITORY: &str = "predicate::is_git_repository";
pub const PREDICATE_IS_GIT_BRANCH_ACTIVE: &str = "predicate::is_git_branch_active"; // E.g., not detached HEAD

// Old Constants (kept for backward compatibility with analysis where used)
pub const GENERAL_TYPE: &str = "general.type"; // length 12, ASCII sum 1230 = 2 * 3 * 5 * 41
pub const GENERAL_ARCHITECTURE: &str = "general.architecture"; // length 20, ASCII sum 2036 = 2^2 * 509
pub const FEATURE_TOGGLE_71: &str = "feature_toggle_seventy_one_is_an_important_number_in_this_system"; // length 71
pub const RESOURCE_IDENTIFIER: &str = "resource_identifier_for_the_monster_group_context_number_71"; // length 65
pub const API_VERSION: &str = "v1.71"; // length 5, numeric literal 71
pub const MONSTER_PRIME_29: &str = "a_key_related_to_the_prime_number_29_from_monster_group"; // length 55
pub const MONSTER_PRIME_71_STRING: &str = "a_string_of_exactly_seventy_one_characters_for_testing_the_analyzer"; // length 71
// Let's create a string whose ASCII sum is a multiple of 71 or includes 71.
// 'G' is ASCII 71.
pub const MONSTER_KEY_ASCII_SUM_WITH_71: &str = "This string's ASCII sum should contain 71 as a prime factor. G"; // length 63
                                                                                                                   // Sum of 'G' is 71.

// SVG Predicate Constants
pub const PREDICATE_IS_SVG: &str = "predicate::is_svg";
pub const PREDICATE_IS_GROUP: &str = "predicate::is_group";
pub const PREDICATE_IS_RECT: &str = "predicate::is_rect";
pub const PREDICATE_IS_CIRCLE: &str = "predicate::is_circle";
pub const PREDICATE_IS_ELLIPSE: &str = "predicate::is_ellipse";
pub const PREDICATE_IS_TEXT: &str = "predicate::is_text";
pub const PREDICATE_IS_PATH: &str = "predicate::is_path";
pub const PREDICATE_HAS_ID: &str = "predicate::has_id";
pub const PREDICATE_HAS_FILL: &str = "predicate::has_fill";
pub const PREDICATE_HAS_STROKE: &str = "predicate::has_stroke";
pub const PREDICATE_HAS_TRANSFORM: &str = "predicate::has_transform";
pub const PREDICATE_CHILD_COUNT: &str = "predicate::child_count";
pub const PREDICATE_WIDTH: &str = "predicate::width";
pub const PREDICATE_HEIGHT: &str = "predicate::height";
pub const PREDICATE_AREA: &str = "predicate::area";
pub const PREDICATE_VIEW_BOX: &str = "predicate::view_box";
pub const PREDICATE_TEXT_CONTENT_LENGTH: &str = "predicate::text_content_length";
pub const PREDICATE_TEXT_WORD_COUNT: &str = "predicate::text_word_count";
pub const PREDICATE_PATH_DATA_LENGTH: &str = "predicate::path_data_length";