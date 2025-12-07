// src/types/keys.rs

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