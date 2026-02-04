# MUST FOLLOW RULES:
- Break down ALL work into the smallest possible atomic tasks and execute them sequentially.
- Make ONLY the changes the user explicitly requested. Do not add extras, anticipate needs, or make assumptions.
- Follow TDD principles: RED -> GREEN -> REFACTOR with atomic steps:
  + Create a minimal/atomic test that's failed.
  + Write a minimal code that pass that single test.
  + Repeat until we fullfill all the requirements. 
  + After finish the tasks, consider if anything we can refactor to make it cleaner  
- Prioritize to use subagent for multisteps implementation or skills usage  
- When we need to execute something that's not available in the system, prefer to use nix (or npx or uv if applicable)
