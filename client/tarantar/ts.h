#ifndef TS_H_INCLUDED
#define TS_H_INCLUDED

struct ts {
	struct ts_options opts;
	struct ts_spaces s;
	struct ts_reftable rt;
	uint64_t last_snap_lsn;
	uint64_t last_xlog_lsn;
	int to_lsn_set;
	uint64_t alloc;
	uint64_t to_lsn;
	struct slab_cache sc;
	struct region ra;
	const char* snap_dir;
	const char* wal_dir;
};

void ts_oomcheck(void);

#endif
