### Text log

`db_set` has near constant time insertion as it is just appending to end of file.

`db_get` on the other hand has linear performance as it has to scan every row in the file.
