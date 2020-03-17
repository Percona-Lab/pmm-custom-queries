#!/bin/bash
# "-----------------------------------------------------------"
# " This is a simple script for creating a query              "
# " that collects data from the table pg_stat_user_tables     "
# " for list of databases                                     "
# "-----------------------------------------------------------"

if [ "$#" -eq 0 ] ;  
then
    echo -e "\n\tYou must enter at least one database name as an argument."
    echo -e "\tArguments should be separated by spaces.\n"
    exit 
fi

TOPPART="\npg_stat_user_tables:\n  query: \"SELECT datname, "
MIDDLEPART="FROM pg_database"
BOTTOMPART="WHERE datname NOT LIKE 'template_' AND datname NOT LIKE 'postgres'\""
PROMPART="  metrics:
    - datname:
        usage: \"LABEL\"
        description: \"Name of the database that this table is in\"
    - schemaname:
        usage: \"LABEL\"
        description: \"Name of the schema that this table is in\"
    - relname:
        usage: \"LABEL\"
        description: \"Name of this table\"
    - seq_scan:
        usage: \"COUNTER\"
        description: \"Number of sequential scans initiated on this table\"
    - seq_tup_read:
        usage: \"COUNTER\"
        description: \"Number of live rows fetched by sequential scans\"
    - idx_scan:
        usage: \"COUNTER\"
        description: \"Number of index scans initiated on this table\"
    - idx_tup_fetch:
        usage: \"COUNTER\"
        description: \"Number of live rows fetched by index scans\"
    - n_tup_ins:
        usage: \"COUNTER\"
        description: \"Number of rows inserted\"
    - n_tup_upd:
        usage: \"COUNTER\"
        description: \"Number of rows updated\"
    - n_tup_del:
        usage: \"COUNTER\"
        description: \"Number of rows deleted\"
    - n_tup_hot_upd:
        usage: \"COUNTER\"
        description: \"Number of rows HOT updated (i.e., with no separate index update required)\"
    - n_live_tup:
        usage: \"GAUGE\"
        description: \"Estimated number of live rows\"
    - n_dead_tup:
        usage: \"GAUGE\"
        description: \"Estimated number of dead rows\"
    - n_mod_since_analyze:
        usage: \"GAUGE\"
        description: \"Estimated number of rows changed since last analyze\"
    - last_vacuum:
        usage: \"GAUGE\"
        description: \"Last time at which this table was manually vacuumed (not counting VACUUM FULL)\"
    - last_autovacuum:
        usage: \"GAUGE\"
        description: \"Last time at which this table was vacuumed by the autovacuum daemon\"
    - last_analyze:
        usage: \"GAUGE\"
        description: \"Last time at which this table was manually analyzed\"
    - last_autoanalyze:
        usage: \"GAUGE\"
        description: \"Last time at which this table was analyzed by the autovacuum daemon\"
    - vacuum_count:
        usage: \"COUNTER\"
        description: \"Number of times this table has been manually vacuumed (not counting VACUUM FULL)\"
    - autovacuum_count:
        usage: \"COUNTER\"
        description: \"Number of times this table has been vacuumed by the autovacuum daemon\"
    - analyze_count:
        usage: \"COUNTER\"
        description: \"Number of times this table has been manually analyzed\"
    - autoanalyze_count:
        usage: \"COUNTER\"
        description: \"Number of times this table has been analyzed by the autovacuum daemon\"
"

while [ "$1" != "" ]; do
   OBJECTS=$OBJECTS" "$1
   SCHEMANAME=$SCHEMANAME$1".schemaname"
   RELNAME=$RELNAME$1".relname"
   SEQSCAN=$SEQSCAN$1".seq_scan"
   SEQTUPREAD=$SEQTUPREAD$1".seq_tup_read"
   IDXSCAN=$IDXSCAN$1".idx_scan"
   IDXTUPFETCH=$IDXTUPFETCH$1".idx_tup_fetch"
   NTUPINS=$NTUPINS$1".n_tup_ins"
   NTUPUPD=$NTUPUPD$1".n_tup_upd"
   NTUPDEL=$NTUPDEL$1".n_tup_del"
   NTUPHOTUPD=$NTUPHOTUPD$1".n_tup_hot_upd"
   NLIVETUP=$NLIVETUP$1".n_live_tup"
   NDEADTUP=$NDEADTUP$1".n_dead_tup"
   NMODSINCEANALYZE=$NMODSINCEANALYZE$1".n_mod_since_analyze"
   LASTVACUUM=$LASTVACUUM$1".last_vacuum"
   LASTAUTOVACUUM=$LASTAUTOVACUUM$1".last_autovacuum"
   LASTANALYZE=$LASTANALYZE$1".last_analyze"
   LASTAUTOANALYZE=$LASTAUTOANALYZE$1".last_autoanalyze"
   VACUUMCOUNT=$VACUUMCOUNT$1".vacuum_count"
   AUTOVACUUMCOUNT=$AUTOVACUUMCOUNT$1".autovacuum_count"
   ANALYZECOUNT=$ANALYZECOUNT$1".analyze_count"
   AUTOANALYZECOUNT=$AUTOANALYZECOUNT$1".autoanalyze_count"
   if [ $# -ne 1 ] ;
   then
       SCHEMANAME=$SCHEMANAME", "
       RELNAME=$RELNAME", "
       SEQSCAN=$SEQSCAN", "
       SEQTUPREAD=$SEQTUPREAD", "
       IDXSCAN=$IDXSCAN", "
       IDXTUPFETCH=$IDXTUPFETCH", "
       NTUPINS=$NTUPINS", "
       NTUPUPD=$NTUPUPD", "
       NTUPDEL=$NTUPDEL", "
       NTUPHOTUPD=$NTUPHOTUPD", "
       NLIVETUP=$NLIVETUP", "
       NDEADTUP=$NDEADTUP", "
       NMODSINCEANALYZE=$NMODSINCEANALYZE", "
       LASTVACUUM=$LASTVACUUM", "
       LASTAUTOVACUUM=$LASTAUTOVACUUM", "
       LASTANALYZE=$LASTANALYZE", "
       LASTAUTOANALYZE=$LASTAUTOANALYZE", "
       VACUUMCOUNT=$VACUUMCOUNT", "
       AUTOVACUUMCOUNT=$AUTOVACUUMCOUNT", "
       ANALYZECOUNT=$ANALYZECOUNT", "
       AUTOANALYZECOUNT=$AUTOANALYZECOUNT", "
   else
       SCHEMANAME="COALESCE("$SCHEMANAME") as ${SCHEMANAME//*./}"
       RELNAME="COALESCE("$RELNAME") as ${RELNAME//*./}"
       SEQSCAN="COALESCE("$SEQSCAN") as ${SEQSCAN//*./}"
       SEQTUPREAD="COALESCE("$SEQTUPREAD") as ${SEQTUPREAD//*./}"
       IDXSCAN="COALESCE("$IDXSCAN") as ${IDXSCAN//*./}"
       IDXTUPFETCH="COALESCE("$IDXTUPFETCH") as ${IDXTUPFETCH//*./}"
       NTUPINS="COALESCE("$NTUPINS") as ${NTUPINS//*./}"
       NTUPUPD="COALESCE("$NTUPUPD") as ${NTUPUPD//*./}"
       NTUPDEL="COALESCE("$NTUPDEL") as ${NTUPDEL//*./}"
       NTUPHOTUPD="COALESCE("$NTUPHOTUPD") as ${NTUPHOTUPD//*./}"
       NLIVETUP="COALESCE("$NLIVETUP") as ${NLIVETUP//*./}"
       NDEADTUP="COALESCE("$NDEADTUP") as ${NDEADTUP//*./}"
       NMODSINCEANALYZE="COALESCE("$NMODSINCEANALYZE") as ${NMODSINCEANALYZE//*./}"
       LASTVACUUM="COALESCE("$LASTVACUUM") as ${LASTVACUUM//*./}"
       LASTAUTOVACUUM="COALESCE("$LASTAUTOVACUUM") as ${LASTAUTOVACUUM//*./}"
       LASTANALYZE="COALESCE("$LASTANALYZE") as ${LASTANALYZE//*./}"
       LASTAUTOANALYZE="COALESCE("$LASTAUTOANALYZE") as ${LASTAUTOANALYZE//*./}"
       VACUUMCOUNT="COALESCE("$VACUUMCOUNT") as ${VACUUMCOUNT//*./}"
       AUTOVACUUMCOUNT="COALESCE("$AUTOVACUUMCOUNT") as ${AUTOVACUUMCOUNT//*./}"
       ANALYZECOUNT="COALESCE("$ANALYZECOUNT") as ${ANALYZECOUNT//*./}"
       AUTOANALYZECOUNT="COALESCE("$AUTOANALYZECOUNT") as ${AUTOANALYZECOUNT//*./}"
   fi
   shift
done

echo -ne "$TOPPART"
echo -n "$SCHEMANAME, $RELNAME, $SEQSCAN, $SEQTUPREAD, $IDXSCAN, $IDXTUPFETCH, $NTUPINS, $NTUPUPD, $NTUPDEL, $NTUPHOTUPD, $NLIVETUP, $NDEADTUP, $NMODSINCEANALYZE, "
echo -n "$LASTVACUUM, $LASTAUTOVACUUM, $LASTANALYZE, $LASTAUTOANALYZE, $VACUUMCOUNT, $AUTOVACUUMCOUNT, $ANALYZECOUNT, $AUTOANALYZECOUNT "
echo -n "$MIDDLEPART"

for t in $OBJECTS; do
   DB=$DB" LEFT OUTER JOIN dblink('dbname=$t','SELECT current_database(), schemaname, relname, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd, n_live_tup, n_dead_tup, n_mod_since_analyze, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze, vacuum_count, autovacuum_count, analyze_count, autoanalyze_count FROM pg_stat_user_tables') as $t(datname name, schemaname name, relname name, seq_scan bigint, seq_tup_read bigint, idx_scan bigint, idx_tup_fetch bigint, n_tup_ins bigint, n_tup_upd bigint, n_tup_del bigint, n_tup_hot_upd bigint, n_live_tup bigint, n_dead_tup bigint, n_mod_since_analyze bigint, last_vacuum timestamp, last_autovacuum timestamp, last_analyze timestamp, last_autoanalyze timestamp, vacuum_count bigint, autovacuum_count bigint, analyze_count bigint, autoanalyze_count bigint) USING (datname)"
done

echo -n "$DB "
echo "$BOTTOMPART"
echo -e "$PROMPART"
