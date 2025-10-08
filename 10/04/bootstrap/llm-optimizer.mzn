include "globals.mzn";

% --- Parameters ---

% Number of LLM providers
int: num_llm_providers;

% Number of tasks
int: num_tasks;

% LLM provider capacities (e.g., total requests, total tokens per minute/hour/day/week)
array[1..num_llm_providers] of int: total_requests;
array[1..num_llm_providers] of int: remaining_requests;
array[1..num_llm_providers] of int: requests_per_minute;
array[1..num_llm_providers] of int: requests_per_hour;
array[1..num_llm_providers] of int: requests_per_day;
array[1..num_llm_providers] of int: requests_per_week;

array[1..num_llm_providers] of int: total_tokens;
array[1..num_llm_providers] of int: remaining_tokens;
array[1..num_llm_providers] of int: tokens_per_minute;
array[1..num_llm_providers] of int: tokens_per_hour;
array[1..num_llm_providers] of int: tokens_per_day;
array[1..num_llm_providers] of int: tokens_per_week;

% Estimated usage for each task (requests, tokens)
array[1..num_tasks] of int: estimated_task_requests;
array[1..num_tasks] of int: estimated_task_tokens;

% Task priorities (higher value = higher priority)
array[1..num_tasks] of int: task_priority;

% --- Decision Variables ---

% Which LLM provider to use for each task (0 if not assigned, 1..num_llm_providers if assigned)
array[1..num_tasks] of var 0..num_llm_providers: assign_llm;

% --- Constraints ---

% 1. Each task can be assigned to at most one LLM provider
constraint forall i in 1..num_tasks (
  sum j in 1..num_llm_providers (bool2int(assign_llm[i] == j)) <= 1
);

% 2. Respect total request quotas
constraint forall j in 1..num_llm_providers (
  sum i in 1..num_tasks (bool2int(assign_llm[i] == j) * estimated_task_requests[i]) <= remaining_requests[j]
);

% 3. Respect total token quotas
constraint forall j in 1..num_llm_providers (
  sum i in 1..num_tasks (bool2int(assign_llm[i] == j) * estimated_task_tokens[i]) <= remaining_tokens[j]
);

% 4. Respect requests per minute rate limits (simplified for now, assumes all tasks run concurrently)
%    FIXME: This needs a more sophisticated time-aware model for accurate rate limiting
constraint forall j in 1..num_llm_providers (
  sum i in 1..num_tasks (bool2int(assign_llm[i] == j) * estimated_task_requests[i]) <= requests_per_minute[j]
);

% 5. Respect tokens per minute rate limits (simplified for now)
constraint forall j in 1..num_llm_providers (
  sum i in 1..num_tasks (bool2int(assign_llm[i] == j) * estimated_task_tokens[i]) <= tokens_per_minute[j]
);

% --- Objective Function ---

% Maximize the total priority of assigned tasks
solve maximize sum i in 1..num_tasks (bool2int(assign_llm[i] != 0) * task_priority[i]);

% --- Output ---

output [
  "assign_llm = ", show(assign_llm), ";\n",
  "total_priority = ", show(sum i in 1..num_tasks (bool2int(assign_llm[i] != 0) * task_priority[i])), ";\n"
];
