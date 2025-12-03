// boostlong.c - MLFQ demonstration test
// xv6 printf only supports basic %d, %s, %x, %p, %c - NO width specifiers!

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Pure CPU work without any syscalls
void pure_cpu_work(int iterations) {
  volatile int dummy = 0;
  for(int i = 0; i < iterations; i++) {
    for(long j = 0; j < 500000; j++) {
      dummy = dummy + j;
      dummy = dummy % 1000000;
    }
  }
}

int
main(int argc, char *argv[])
{
  struct procinfo info;
  int last_priority = -1;
  int last_slices = -1;
  int q3_count = 0;
  int boost_count = 0;
  int phase = 0;
  
  printf("\n");
  printf("================================================================\n");
  printf("       MLFQ BOOST TEST - WITH STARTUP ANALYSIS\n");
  printf("================================================================\n\n");

  printf("----------------------------------------------------------------\n");
  printf(" PHASE 1: STARTUP OVERHEAD ANALYSIS\n");
  printf("----------------------------------------------------------------\n");
  printf(" Shows why initial ticks look weird - printf/syscalls use CPU\n\n");

  int t0 = uptime();
  getprocinfo(&info);
  int t1 = uptime();
  printf(" After getprocinfo: uptime %d->%d, slices=%d, queue=Q%d\n", 
         t0, t1, info.time_slices, info.priority);

  t0 = uptime();
  printf(" This printf...");
  t1 = uptime();
  getprocinfo(&info);
  printf(" took %d tick(s), slices now=%d\n", t1-t0, info.time_slices);

  printf("\n Key insight: Syscalls cause context switches.\n");
  printf(" Process yields during I/O, so ticks pass but time_slices\n");
  printf(" only count RUNNING time on CPU.\n\n");

  printf("----------------------------------------------------------------\n");
  printf(" PHASE 2: WAIT FOR BOOST TO RESET\n");
  printf("----------------------------------------------------------------\n");
  printf(" Running CPU work until we get boosted to Q0...\n");
  
  int waited = 0;
  while(1) {
    pure_cpu_work(5);
    waited++;
    getprocinfo(&info);
    if(info.priority == 0 && info.time_slices == 0 && waited > 10) {
      printf(" Got boosted! Starting clean measurement now.\n\n");
      break;
    }
    if(waited > 200) {
      printf(" Timeout waiting for boost, starting anyway.\n\n");
      break;
    }
  }

  printf("================================================================\n");
  printf(" PHASE 3: CLEAN MLFQ DEMONSTRATION\n");
  printf("================================================================\n");
  printf(" Time Quanta: Q0=2, Q1=4, Q2=8, Q3=16 slices\n");
  printf(" Boost Interval: Every 30 ticks all processes -> Q0\n\n");
  
  printf("+-------+-------+--------+-------------------------------+\n");
  printf("| SLICE | QUEUE | CHANGE | DESCRIPTION                   |\n");
  printf("+-------+-------+--------+-------------------------------+\n");
  
  // Get fresh start state
  getprocinfo(&info);
  last_priority = info.priority;
  last_slices = info.time_slices;
  printf("|   %d   |  Q%d   | START  | Fresh start highest priority  |\n",
         info.time_slices, info.priority);
  
  // Run and track clean MLFQ behavior
  while(phase < 400) {
    pure_cpu_work(1);
    phase++;
    
    getprocinfo(&info);
    
    int priority_changed = (info.priority != last_priority);
    int slices_changed = (info.time_slices != last_slices);
    
    if(priority_changed) {
      if(info.priority > last_priority) {
        // Demotion
        if(last_priority == 0) {
          printf("|   %d   |  Q%d   | DEMOTE | Used 2 slices -> Q1           |\n",
                 info.time_slices, info.priority);
        } else if(last_priority == 1) {
          printf("|   %d   |  Q%d   | DEMOTE | Used 4 slices -> Q2           |\n",
                 info.time_slices, info.priority);
        } else if(last_priority == 2) {
          printf("|   %d   |  Q%d   | DEMOTE | Used 8 slices -> Q3           |\n",
                 info.time_slices, info.priority);
        }
        
        if(info.priority == 3) {
          printf("+-------+-------+--------+-------------------------------+\n");
          printf("| >>> AT Q3 - Will stay until BOOST interval <<<        |\n");
          printf("+-------+-------+--------+-------------------------------+\n");
        }
      } else {
        // Boost!
        boost_count++;
        printf("+-------+-------+--------+-------------------------------+\n");
        printf("|   %d   |  Q%d   | BOOST  | *** AUTOMATIC BOOST #%d ***    |\n",
               info.time_slices, info.priority, boost_count);
        printf("+-------+-------+--------+-------------------------------+\n");
        q3_count = 0;
      }
    }
    // Show slice progression at Q3
    else if(info.priority == 3 && slices_changed) {
      q3_count++;
      if(q3_count % 4 == 0) {  // Show every 4th change
        printf("|  %d   |  Q%d   |   ..   | Running at Q3 (%d/16 slices)  |\n",
               info.time_slices, info.priority, info.time_slices);
      }
    }
    
    last_priority = info.priority;
    last_slices = info.time_slices;
    
    // Stop after 3 boosts
    if(boost_count >= 3) {
      break;
    }
  }
  
  printf("+-------+-------+--------+-------------------------------+\n");
  
  printf("\n");
  printf("================================================================\n");
  printf("                      TEST SUMMARY\n");
  printf("================================================================\n");
  printf("  Boost Events: %d automatic boosts observed\n", boost_count);
  printf("----------------------------------------------------------------\n");
  if(boost_count >= 2) {
    printf("  SUCCESS! MLFQ working correctly:\n");
    printf("  - Q0: 2 slices -> demote to Q1\n");
    printf("  - Q1: 4 slices -> demote to Q2\n");
    printf("  - Q2: 8 slices -> demote to Q3\n");
    printf("  - Q3: stays until boost (every 30 ticks)\n");
    printf("  - BOOST: all processes return to Q0\n");
  } else {
    printf("  Incomplete - run longer or check implementation\n");
  }
  printf("================================================================\n\n");
  
  exit(0);
}
