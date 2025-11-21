# Week 1: MLFQ Scheduler Design Document

**Project:** Multi-Level Feedback Queue Scheduler for xv6-RISC-V  
**Date:** November 15, 2025  
**Status:** Week 1 Complete - Foundation and Design Phase

---

## 1. Overview

This document describes the design and initial implementation of a Multi-Level Feedback Queue (MLFQ) scheduler for xv6. The MLFQ scheduler replaces xv6's default round-robin scheduler with a priority-based scheduler that dynamically adjusts process priorities based on their behavior.

## 2. MLFQ Design Specifications

### 2.1 Queue Architecture

**Number of Priority Queues:** 4 levels (Q0 through Q3)
- **Q0:** Highest priority (interactive/I/O-bound processes)
- **Q1:** High priority
- **Q2:** Medium priority  
- **Q3:** Lowest priority (CPU-bound processes)

### 2.2 Time Quantum Assignment

Each priority level has a different time quantum (measured in timer ticks):

| Queue | Time Quantum (ticks) | Real Time (~100ms/tick) | Description |
|-------|---------------------|------------------------|-------------|
| Q0    | 2                   | ~200ms                 | Shortest slice for interactive processes |
| Q1    | 4                   | ~400ms                 | Medium-short slice |
| Q2    | 8                   | ~800ms                 | Medium-long slice |
| Q3    | 16                  | ~1.6s                  | Longest slice for CPU-bound processes |

**Note:** Values adjusted for xv6's timer tick rate (~100ms per tick, 10 ticks/second).

**Rationale:** Higher priority queues get shorter time slices to enable quick response for I/O-bound processes, while lower priority queues get longer slices to reduce context-switching overhead for CPU-bound processes.

### 2.3 Scheduling Policy

#### Initial Placement
- New processes start at **Q0** (highest priority)
- This gives all processes an initial chance to demonstrate their behavior

#### Round-Robin Within Queue
- Within each queue, processes are scheduled in round-robin fashion
- Ensures fairness among processes at the same priority level

#### Queue Selection
- Scheduler always selects from the highest non-empty queue
- Only moves to lower queues when higher queues are empty

### 2.4 Demotion Policy

A process is **demoted** to the next lower queue if:
- It **uses its entire time quantum** without yielding
- Indicates CPU-bound behavior

**Demotion Rules:**
- Q0 → Q1 (after using 8 ticks)
- Q1 → Q2 (after using 16 ticks)
- Q2 → Q3 (after using 32 ticks)
- Q3 → Q3 (stays at lowest level)

### 2.5 Promotion Policy (Week 3)

To prevent **starvation** of lower-priority processes:
- **Priority Boost:** Periodically move all processes back to Q0
- **Boost Interval:** Every 100 timer ticks (to be tuned)
- Ensures even CPU-bound processes get occasional high-priority treatment

*Note: Priority boosting will be implemented in Week 3*

---

## 3. Implementation Details (Week 1)

### 3.1 Data Structure Modifications

#### Process Structure (`struct proc` in `kernel/proc.h`)

Added three new fields to track MLFQ state:

```c
// MLFQ scheduler fields
int priority;                // Current priority queue (0-3, 0 is highest)
int time_slices;             // Time slices used in current priority level
uint64 arrival_time;         // Time when process entered current queue
```

#### Global MLFQ State (`kernel/proc.c`)

```c
#define NMLFQ 4  // Number of priority queues
int mlfq_time_quanta[NMLFQ] = {8, 16, 32, 64};  // Time slices per queue
struct spinlock mlfq_lock;   // Lock for MLFQ operations
```

### 3.2 System Call: `getprocinfo`

**Purpose:** Retrieve process scheduling information for debugging and testing

**System Call Number:** 22

**User-Space Interface:**
```c
struct procinfo {
  int pid;           // Process ID
  int state;         // Process state (RUNNABLE, RUNNING, etc.)
  int priority;      // Current priority queue (0-3)
  int time_slices;   // Time slices used
};

int getprocinfo(struct procinfo* info);
```

**Implementation Files Modified:**
- `kernel/syscall.h` - Added `SYS_getprocinfo` definition
- `kernel/syscall.c` - Added syscall handler registration
- `kernel/sysproc.c` - Implemented `sys_getprocinfo()` function
- `user/usys.pl` - Added user-space syscall stub
- `user/user.h` - Added `procinfo` struct and function prototype

### 3.3 Process Initialization

Modified `allocproc()` in `kernel/proc.c`:
- All new processes initialized with `priority = 0` (highest queue)
- `time_slices = 0` (no time used yet)
- `arrival_time = 0` (will be set when added to scheduler)

### 3.4 Configuration Changes

**Makefile:**
- Set `CPUS := 1` for single-core simplicity
- Added `user/_procinfo` to `UPROGS` for testing

---

## 4. Testing Strategy

### 4.1 Week 1 Test Program: `procinfo`

**Purpose:** Validate the `getprocinfo` system call

**Test Program:** `user/procinfo.c`

**Expected Output:**
```
Process Information:
  PID: <process_id>
  State: 4 (RUNNING)
  Priority Queue: 0 (0=highest, 3=lowest)
  Time Slices Used: 0

MLFQ Scheduler Test - Week 1
Successfully retrieved process info via getprocinfo syscall!
```

### 4.2 Validation Checklist

- [x] Code compiles without errors
- [ ] `procinfo` program runs successfully
- [ ] System call returns correct process information
- [ ] New process fields are properly initialized
- [ ] MLFQ data structures are initialized in `procinit()`

---

## 5. Week 2 Preview: Scheduler Implementation

### 5.1 Planned Modifications

**Scheduler Function (`scheduler()` in `kernel/proc.c`):**
- Replace simple round-robin with priority-based selection
- Implement queue traversal (Q0 → Q1 → Q2 → Q3)
- Track time slice usage per process

**Timer Interrupt Handler (`kernel/trap.c`):**
- Increment time slice counter for running process
- Check if process has exceeded its time quantum
- Trigger demotion if quantum is exhausted

**Yield Behavior:**
- Process that yields voluntarily stays in current queue
- Process that uses full quantum is demoted

### 5.2 Week 2 Test Programs

1. **CPU-bound test:** Long computation loop (should demote to Q3)
2. **I/O-bound test:** Frequent sleep/wakeup cycles (should stay in Q0/Q1)
3. **Mixed workload:** Multiple processes with different behaviors

---

## 6. Design Decisions and Rationale

### 6.1 Why 4 Priority Levels?

- **Balance:** Enough granularity without excessive complexity
- **Standard:** Common in MLFQ implementations (e.g., BSD scheduler)
- **Performance:** Minimal overhead for queue management

### 6.2 Why Exponential Time Quanta?

- **Theory:** Matches MLFQ literature (Ousterhout's rule of thumb)
- **Practice:** Short slices for interactive, long slices for throughput
- **Adaptability:** Naturally separates I/O vs CPU-bound processes

### 6.3 Why Single-Core Mode?

- **Simplicity:** Avoids multiprocessor synchronization complexity
- **Focus:** Concentrates on scheduling algorithm, not concurrency
- **Debugging:** Easier to trace scheduler behavior

### 6.4 Why Priority Boosting? (Week 3)

- **Starvation Prevention:** Lower queues get periodic high-priority access
- **Adaptability:** Processes that change behavior get re-evaluated
- **Fairness:** Prevents indefinite waiting for CPU-bound processes

---

## 7. Known Limitations (Week 1)

1. **Scheduler Not Yet MLFQ:** Still using default round-robin
2. **No Time Tracking:** Timer interrupts not yet counting time slices
3. **No Queue Management:** Processes not actually placed in queues
4. **No Demotion/Promotion:** Rules defined but not implemented

**These will be addressed in Week 2 and Week 3.**

---

## 8. Files Modified (Week 1)

### Kernel Files
- `kernel/proc.h` - Added MLFQ fields to `struct proc`
- `kernel/proc.c` - Added MLFQ globals, initialized in `procinit()`, initialized in `allocproc()`
- `kernel/syscall.h` - Added `SYS_getprocinfo`
- `kernel/syscall.c` - Registered `sys_getprocinfo` handler
- `kernel/sysproc.c` - Implemented `sys_getprocinfo()` function

### User Files
- `user/user.h` - Added `struct procinfo` and `getprocinfo()` declaration
- `user/usys.pl` - Added `getprocinfo` stub generator
- `user/procinfo.c` - Created test program

### Build System
- `Makefile` - Set `CPUS := 1`, added `user/_procinfo` to `UPROGS`

---

## 9. Summary

Week 1 successfully established the foundation for the MLFQ scheduler:

✅ **Design completed:** 4-level queue system with exponential time quanta  
✅ **Data structures added:** Process fields for priority tracking  
✅ **System call implemented:** `getprocinfo` for debugging  
✅ **Test program created:** Validates syscall functionality  
✅ **Configuration set:** Single-core mode enabled  

**Next Steps (Week 2):**
- Implement actual MLFQ scheduling logic in `scheduler()`
- Add time slice tracking in timer interrupt handler
- Implement demotion policy
- Create comprehensive test programs for CPU-bound and I/O-bound processes
