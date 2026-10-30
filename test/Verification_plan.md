
# TCPU-16 Verification Plan

## Steps

### 1. Features
Identify the main CPU features, such as ALU, instruction decoder, program loader, program memory, program counter, accumulator, and output multiplexer.

### 2. Sub-Features
Break each feature into smaller functions, such as ADD/SUB operations, JMP/JZ conditions, reset, synchronization, and byte selection.

### 3. Test Intent and Test Names
Define the purpose of each test and assign a unique test name.

### 4. Test Scenario Description
Specify the input stimulus, execution steps, and expected output for every test.

### 5. Functional Coverage Points
Identify the instructions, operands, branch conditions, memory addresses, and output selections that must be exercised.

### 6. Configuration Details
Define the test configurations for Mode H and Mode O, including reset timing, program-loading timing, and synchronization requirements.

### 7. Positive and Negative Tests
Create tests for valid operations and tests that check detection or handling of invalid or prohibited sequences.

### 8. Cross-Feature Verification
Verify interactions between features, such as decoder + ALU, loader + run control, and accumulator + output multiplexer.

### 9. Checkers and Assertions
Define checks for accumulator results, program-counter updates, instruction execution, loading protocols, synchronization, and HALT behavior.

### 10. Detailed Functional Coverage
Track covered and missing scenarios, instruction coverage, branch outcomes, configuration coverage, and cross-feature combinations.

## Verification Completion

- Run all directed tests.
- Verify both operating modes where required.
- Compare DUT behavior against a cycle-exact reference model.
- Run at least 1,000 randomized fully loaded programs for 64 clock edges each, with randomized `run` toggles.
- Analyze failures and close coverage gaps.
- Document final test results and unresolved issues.
