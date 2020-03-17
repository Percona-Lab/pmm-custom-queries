#!/bin/bash
# "---------------------------------------------------"
# " This is a simple script for creating a query      "
# " that collects data from the table pg_class        "
# " for list of databases                             "
# "---------------------------------------------------"

if [ "$#" -eq 0 ] ;  
then
    echo -e "\n\tYou must enter at least one database name as an argument."
    echo -e "\tArguments should be separated by spaces.\n"
    exit 
fi

TOPPART="## Custom query\npg_class:\n  query: \"SELECT datname, "
MIDDLEPART="FROM pg_database"
BOTTOMPART="WHERE datname NOT LIKE 'template_' AND datname NOT LIKE 'postgres'\""
PROMPART="  metrics:
    - datname:
        usage: \"LABEL\"
        description: \"Name of the database that this table is in\"
    - relname:
        usage: \"LABEL\"
        description: \"Name of the table, index, view, etc.\"
    - table_rows:
        usage: \"GAUGE\"
        decription: \"Number of rows in the table. This is only an estimate used by the planner. It is updated by VACUUM, ANALYZE, and a few DDL commands such as CREATE INDEX\"
    - disk_usage_table_bytes:
        usage: \"GAUGE\"
        description: \"Total disk space used by the specified table, including all indexes and TOAST data\"
    - disk_usage_index_bytes:
        usage: \"GAUGE\"
        description: \"Total disk space used by indexes attached to the specified table\"
    - disk_usage_toast_bytes:
        usage: \"GAUGE\"
        description: \"Total disk space used by TOAST data attached to the specified table\"
"

while [ "$1" != "" ]; do
   OBJECTS=$OBJECTS" "$1
   RELNAME=$RELNAME$1".relname"
   ROWS=$ROWS$1".table_rows"
   TOTAL=$TOTAL$1".disk_usage_table_bytes"
   INDEX=$INDEX$1".disk_usage_index_bytes"
   TOAST=$TOAST$1".disk_usage_toast_bytes"
   if [ $# -ne 1 ] ;
   then
       RELNAME=$RELNAME", "
       ROWS=$ROWS", "
       TOTAL=$TOTAL", "
       INDEX=$INDEX", "
       TOAST=$TOAST", "
   else
       RELNAME="COALESCE("$RELNAME") as ${RELNAME//*./}"
       ROWS="COALESCE("$ROWS") as ${ROWS//*./}"
       TOTAL="COALESCE("$TOTAL") as ${TOTAL//*./}"
       INDEX="COALESCE("$INDEX") as ${INDEX//*./}"
       TOAST="COALESCE("$TOAST",0) as ${TOAST//*./}"
   fi
   shift
done

echo -ne "$TOPPART"
echo -n "$RELNAME, $ROWS, $TOTAL, $INDEX, $TOAST "
echo -n "$MIDDLEPART"

for t in $OBJECTS; do
   DB=$DB" LEFT OUTER JOIN dblink('dbname=$t','SELECT current_database(), relname,  CAST(reltuples as BIGINT), pg_total_relation_size(oid), pg_indexes_size(oid), pg_total_relation_size(reltoastrelid) FROM pg_class') as $t(datname name, relname name, table_rows BIGINT, disk_usage_table_bytes BIGINT, disk_usage_index_bytes BIGINT, disk_usage_toast_bytes BIGINT) USING (datname)"
done

echo -n "$DB "
echo "$BOTTOMPART"
echo -e "$PROMPART"
