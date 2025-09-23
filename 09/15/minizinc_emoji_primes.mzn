% minizinc_emoji_primes.mzn
% A MiniZinc model to assign prime numbers to emojis based on conceptual resonance.

% Define the set of emojis
set of int: EMOJIS = 1..14; % Representing 14 emojis
array[EMOJIS] of string: emoji_names = [
    "🧠", "🔄", "💡", "✨", "📜", "🔗", "🤔", "🚀", "💥", "🌌", "🔢", "🧬", "⚙️", "☕"
];

% Define the set of prime numbers to choose from
set of int: PRIMES = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29};

% Decision variable: assign a prime to each emoji
array[EMOJIS] of var PRIMES: assigned_prime;

% Constraint: Each emoji gets a unique prime (optional, but makes sense for "best set")
constraint all_different(assigned_prime);

% Define "resonance" scores (hypothetical, for demonstration)
% Higher score means better resonance.
% This would be the subjective part, translated into quantifiable values.
% For simplicity, let's create a dummy resonance matrix.
% In a real scenario, these scores would be carefully defined based on expert knowledge.
array[EMOJIS, PRIMES] of int: resonance_scores = [
    % 🧠 (Self-reflection)
    10, 5, 8, 7, 9, 6, 7, 8, 9, 5, 10, 8, 7, 6 |
    % 🔄 (Recursive loop)
    6, 9, 7, 8, 5, 7, 6, 7, 8, 5, 9, 7, 6, 5 |
    % 💡 (Insight)
    9, 7, 10, 8, 7, 6, 8, 9, 7, 6, 8, 7, 6, 5 |
    % ✨ (Transformation)
    7, 8, 9, 10, 6, 7, 8, 9, 7, 6, 8, 7, 6, 5 |
    % 📜 (Knowledge base)
    8, 6, 7, 7, 10, 8, 9, 7, 6, 8, 9, 7, 6, 5 |
    % 🔗 (Connection)
    7, 7, 6, 7, 8, 10, 7, 6, 7, 8, 7, 9, 6, 5 |
    % 🤔 (Deep thought)
    8, 6, 7, 7, 9, 7, 10, 8, 9, 7, 8, 7, 6, 5 |
    % 🚀 (New space)
    6, 5, 7, 8, 7, 6, 7, 10, 9, 8, 7, 6, 5, 5 |
    % 💥 (Singularity)
    9, 7, 8, 9, 6, 7, 8, 9, 10, 7, 8, 7, 6, 5 |
    % 🌌 (Multiverse)
    7, 6, 7, 8, 8, 7, 8, 9, 7, 10, 8, 7, 6, 5 |
    % 🔢 (Gödel number)
    10, 8, 9, 8, 9, 7, 8, 7, 8, 7, 10, 9, 7, 6 |
    % 🧬 (DNA)
    8, 7, 8, 9, 7, 8, 7, 8, 7, 8, 9, 10, 7, 6 |
    % ⚙️ (Opcode)
    7, 8, 6, 7, 5, 6, 5, 6, 5, 5, 7, 6, 10, 5 |
    % ☕ (Coffee break)
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10 |
 
];

% Objective: Maximize total resonance
var int: total_resonance = sum(i in EMOJIS)(resonance_scores[i, assigned_prime[i]]);

solve maximize total_resonance;

output [
    "Emoji: \(emoji_names[i]), Assigned Prime: \(assigned_prime[i]), Resonance Score: \(resonance_scores[i, assigned_prime[i]])\n"
    | i in EMOJIS
] ++ ["\nTotal Resonance: \(total_resonance)\n"];
