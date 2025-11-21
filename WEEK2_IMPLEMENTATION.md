# Week 2: MLFQ Scheduler Core - Implementation Complete

**Date:** November 15, 2025  
**Status:** Week 2 Implementation Complete - Ready for Testing

---

## Week 2 Objectives (All Complete)

✅ Implement MLFQ scheduling in proc.c with 4 priority queues  
✅ Enforce time-slice quanta and round-robin within each level  
✅ Implement demotion policy based on time quantum usage  
✅ Create test programs for CPU-bound and I/O-bound processes  

---

## Implementation Summary

### 1. MLFQ Scheduler (kernel/proc.c)

**Modified `scheduler()` function:**
- Replaced simple round-robin with priority-based selection
- Scans priority queues from Q0 (highest) to Q3 (lowest)
- Picks first RUNNABLE process from highest non-empty queue
- Implements round-robin within each priority level
- Restarts from Q0 after each process runs

**Key Algorithm:**
```c
for(int priority = 0; priority < NMLFQ && !found; priority++) {
  for(p = proc; p < &proc[NPROC]; p++) {
    if(p->state == RUNNABLE && p->priority == priority) {
      // Run this process
      // After it yields/blocks, restart from Q0
    }
  }
}
```

### 2. Time Slice Tracking (kernel/trap.c)

**Modified `usertrap()` function:**
- Increments `time_slices` counter on each timer interrupt (tick)
- Runs for EVERY process while it's RUNNING
- Accurate tracking of CPU time usage

**Code:**
```c
if(which_dev == 2) {  // Timer interrupt
  p->time_slices++;
  // ... check for demotion ...
  yield();
}
```

### 3. Demotion Policy (kernel/trap.c)

**Automatic demotion on quantum exhaustion:**
- Q0: Demote after 8 ticks
- Q1: Demote after 16 ticks  
- Q2: Demote after 32 ticks
- Q3: Stay at Q3 (lowest level)

**Logic:**
```c
if(p->time_slices >= mlfq_time_quanta[p->priority]) {
  if(p->priority < NMLFQ - 1) {
    p->priority++;  // Demote to lower queue
  }
  p->time_slices = 0;  // Reset counter for new queue
}
```

### 4. Voluntary Yield Handling

**Implicit implementation:**
- Process that yields BEFORE using full quantum keeps `time_slices` value
- Stays in current priority queue
- Only resets `time_slices` after full quantum is used
- Favors I/O-bound processes that yield frequently

---

## Test Programs Created

### 1. cpubound.c
**Purpose:** Test CPU-intensive workload  
**Expected Behavior:**
- Starts at Q0
- Demotes through Q0 → Q1 → Q2 → Q3
- Stays at Q3 (lowest priority)

**Test:**
- Runs 10 iterations of 1M loop iterations
- Prints priority after each iteration
- Reports success if reaches Q3

### 2. iobound.c
**Purpose:** Test I/O-intensive workload  
**Expected Behavior:**
- Starts at Q0
- Stays in Q0 or Q1 (high priority)
- Never demotes to Q2/Q3

**Test:**
- Runs 10 iterations with sleep between each
- Does minimal computation, yields frequently
- Reports success if stays in Q0/Q1

### 3. mlfqtest.c
**Purpose:** Mixed workload test  
**Expected Behavior:**
- Forks both CPU-bound and I/O-bound processes
- I/O-bound gets more CPU time despite doing less work
- CPU-bound demotes to Q3, I/O-bound stays in Q0/Q1

**Test:**
- Runs both processes concurrently
- Demonstrates scheduler prioritizes I/O-bound work
- Shows fairness and responsiveness

---

## Files Modified (Week 2)

### Kernel Files
- **kernel/proc.c** - Implemented MLFQ scheduler in `scheduler()`
- **kernel/trap.c** - Added time tracking and demotion in `usertrap()`

### User Test Programs
- **user/cpubound.c** - CPU-intensive test
- **user/iobound.c** - I/O-intensive test
- **user/mlfqtest.c** - Mixed workload test

### Build System
- **Makefile** - Added new test programs to UPROGS

---

## Testing Instructions

### Build and Run
```bash
make clean && make
make qemu
```

### Test 1: CPU-Bound Process
```bash
cpubound
```

**Expected Output:**
```
CPU-bound test starting...
Initial priority: Q0
After iteration 0: PID=3 Priority=Q0 TimeSlices=7
After iteration 1: PID=3 Priority=Q1 TimeSlices=15
After iteration 2: PID=3 Priority=Q2 TimeSlices=31
After iteration 3: PID=3 Priority=Q3 TimeSlices=63
...
Final priority: Q3
SUCCESS: Process reached lowest priority queue!
```

### Test 2: I/O-Bound Process
```bash
iobound
```

**Expected Output:**
```
I/O-bound test starting...
Initial priority: Q0
After sleep 0: PID=4 Priority=Q0 TimeSlices=1
After sleep 1: PID=4 Priority=Q0 TimeSlices=2
...
Final priority: Q0
SUCCESS: Process maintained high priority!
```

### Test 3: Mixed Workload
```bash
mlfqtest
```

**Expected Output:**
```
=== MLFQ Mixed Workload Test ===

[CPU-BOUND] Starting...
[I/O-BOUND] Starting...
[I/O-BOUND] Wake 0: Q0 (slices=1)
[CPU-BOUND] Iteration 0: Q0 (slices=8)
[CPU-BOUND] Iteration 1: Q1 (slices=16)
[I/O-BOUND] Wake 1: Q0 (slices=2)
...
Expected: I/O-bound stayed in Q0/Q1, CPU-bound demoted to Q3
```

### Test 4: Verify with procinfo
```bash
cpubound &
procinfo
```

Should show the cpubound process at a lower priority.

---

## How MLFQ Works Now

### Scenario 1: CPU-Bound Process
1. Process starts at Q0, gets 8 ticks
2. Uses all 8 ticks → demoted to Q1
3. Gets 16 ticks in Q1, uses all → demoted to Q2
4. Gets 32 ticks in Q2, uses all → demoted to Q3
5. Stays at Q3 with 64-tick quantum

### Scenario 2: I/O-Bound Process
1. Process starts at Q0, gets 8 ticks
2. Sleeps after 2 ticks (yields voluntarily)
3. Wakes up, still in Q0 with 2 ticks used
4. Sleeps again after 1 tick
5. Never uses full quantum → stays in Q0

### Scenario 3: Interactive Process
1. Starts at Q0
2. Does small bursts of work, yields to wait for input
3. Never exhausts quantum
4. Maintains high priority for responsiveness

---

## Validation Checklist

After testing, verify:

- [ ] Code compiles without errors
- [ ] xv6 boots successfully
- [ ] `cpubound` demotes from Q0 to Q3
- [ ] `iobound` stays in Q0 or Q1
- [ ] `mlfqtest` shows I/O-bound gets priority
- [ ] `procinfo` correctly shows priority and time_slices
- [ ] Multiple processes can run concurrently
- [ ] Timer interrupts are working (time_slices increments)
- [ ] Scheduler picks highest priority RUNNABLE process

---

## Week 2 vs Week 1 Changes

| Aspect | Week 1 | Week 2 |
|--------|--------|--------|
| Scheduler | Round-robin | MLFQ priority-based |
| Time Tracking | None | Per-tick tracking |
| Demotion | Not implemented | Automatic on quantum exhaustion |
| Priority | Static (always 0) | Dynamic (0-3) |
| Fairness | All equal | Favors I/O-bound |

---

## Known Limitations (to address in Week 3)

1. **No Priority Boosting** - Low priority processes can starve
2. **No Aging** - Long-running processes may never get high priority again
3. **Simple Demotion** - No gaming protection (process can't reset timer)
4. **Fixed Quanta** - Time slices are not tunable at runtime

**Week 3 will add:**
- Priority boosting every N ticks (prevent starvation)
- Optional `boostproc()` syscall for testing
- More sophisticated fairness mechanisms

---

## Troubleshooting

### Issue: time_slices not incrementing
**Solution:** Verify timer interrupts are firing - check `clockintr()` is being called

### Issue: Processes not demoting
**Solution:** 
- Check `mlfq_time_quanta` array is correct
- Verify comparison `p->time_slices >= mlfq_time_quanta[p->priority]`
- Add debug prints in trap.c

### Issue: All processes stuck in one queue
**Solution:** Verify scheduler is checking `p->priority == priority` correctly

### Issue: Scheduler not running any process
**Solution:** Check that `p->state == RUNNABLE` and priority is in range 0-3

---

## Debug Tips

Add these prints for debugging:

**In scheduler():**
```c
printf("Scheduler: checking priority %d\n", priority);
if(found) printf("  Found process %d at Q%d\n", p->pid, p->priority);
```

**In usertrap():**
```c
if(which_dev == 2) {
  printf("Timer: PID %d, Q%d, slices=%d/%d\n", 
         p->pid, p->priority, p->time_slices, 
         mlfq_time_quanta[p->priority]);
}
```

---

## Success Metrics

Week 2 is successful if:

✅ CPU-bound processes demote to lower priorities  
✅ I/O-bound processes maintain high priorities  
✅ System remains responsive to interactive processes  
✅ Time slices are tracked accurately  
✅ Demotion happens at correct thresholds  
✅ All test programs run without errors  

---

## Next Steps (Week 3)

1. Implement priority boosting (every 100 ticks, move all to Q0)
2. Add `boostproc()` syscall for manual testing
3. Test starvation prevention with long-running processes
4. Fine-tune time quanta if needed
5. Create comprehensive test suite
6. Write final project report

**Week 2 Complete! 🎉**
