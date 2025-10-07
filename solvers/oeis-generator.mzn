int: n; % Length of the sequence to generate

array[1..n] of var int: F; % The OEIS sequence

% Initial terms (to be provided in .dzn)
% constraint F[1] = ...;
% constraint F[2] = ...;

% Recurrence relation (to be provided in .dzn)
% constraint forall(i in 3..n) (F[i] = F[i-1] + F[i-2]);

% Convergence criteria (to be provided in .dzn)
% constraint F[n] > 0;

% Community contributions (to be provided in .dzn)
% array[COMMUNITY_CONTRIBUTIONS_INDICES] of int: community_results;

solve maximize F[n]; % Maximize the last term (or some other objective related to convergence)

output ["F = ", show(F)];
