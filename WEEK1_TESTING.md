# Week 1 Testing Guide

## Build and Run Instructions

### 1. Clean and Build xv6
```bash
cd ~/Operation-Nixor-Whale
make clean
make
```

### 2. Run xv6 in QEMU
```bash
make qemu
```

### 3. Test getprocinfo System Call
Once xv6 boots, run:
```bash
procinfo
```

**Expected Output:**
```
Process Information:
  PID: 3
  State: 4
  Priority Queue: 0 (0=highest, 3=lowest)
  Time Slices Used: 0

MLFQ Scheduler Test - Week 1
Successfully retrieved process info via getprocinfo syscall!
```

### 4. Verify Multiple Processes
Run multiple instances to see different PIDs:
```bash
procinfo &
procinfo &
procinfo
```

## Verification Checklist

- [ ] xv6 compiles without errors
- [ ] xv6 boots successfully (single-core mode)
- [ ] `procinfo` command exists and runs
- [ ] System call returns correct PID
- [ ] Priority is initialized to 0 (highest queue)
- [ ] Time slices start at 0
- [ ] Multiple processes can call `getprocinfo` simultaneously

## Common Issues and Solutions

### Issue: "procinfo: not found"
**Solution:** Make sure `user/_procinfo` is in the Makefile's UPROGS list and rebuild with `make clean && make`

### Issue: Compilation errors about `priority` or `time_slices`
**Solution:** Ensure `kernel/proc.h` has the MLFQ fields added to `struct proc`

### Issue: "unknown sys call 22"
**Solution:** 
- Check `kernel/syscall.h` has `#define SYS_getprocinfo 22`
- Check `kernel/syscall.c` has `sys_getprocinfo` in the syscalls array
- Check `kernel/sysproc.c` has the `sys_getprocinfo()` implementation

### Issue: QEMU shows multiple CPUs
**Solution:** Verify Makefile has `CPUS := 1` in the configuration section

## Debug Tips

1. **Add debug prints** in `sys_getprocinfo()`:
   ```c
   printf("getprocinfo: pid=%d priority=%d\n", p->pid, p->priority);
   ```

2. **Check process table** with Ctrl+P in xv6 (shows all processes)

3. **Verify initialization** by adding print in `allocproc()`:
   ```c
   printf("allocproc: new process priority=%d\n", p->priority);
   ```

## Week 1 Success Criteria

✅ Code compiles cleanly  
✅ xv6 boots in single-core mode  
✅ `procinfo` test program runs successfully  
✅ `getprocinfo()` returns valid process information  
✅ All new processes start with priority=0  
✅ Design document completed (WEEK1_DESIGN.md)  

## What's NOT Expected in Week 1

- ❌ MLFQ scheduling (still using round-robin)
- ❌ Time slice tracking/counting
- ❌ Process demotion between queues
- ❌ Priority boosting
- ❌ Different time quanta per queue

These features will be implemented in Week 2 and Week 3!

## Next Steps After Week 1

Once Week 1 testing is complete:
1. Review the design document
2. Understand the current round-robin scheduler in `scheduler()`
3. Study timer interrupts in `kernel/trap.c`
4. Plan Week 2 implementation: actual MLFQ scheduling logic
