/* 
 * Dynamic sync control driver definitions (V2)
 * 
 * by andip71 (alias Lord Boeffla)
 * 
 */

#define DYN_FSYNC_ACTIVE_DEFAULT false
#define DYN_FSYNC_VERSION_MAJOR 3
#define DYN_FSYNC_VERSION_MINOR 0
#define SYNC_WORK_DELAY_MSEC 3000

extern bool suspend_active;
extern void sync_filesystems(struct work_struct *work);
