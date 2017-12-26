### Log with in memory index

`db_set` has near constant time insertion as it is just appending to end of file.
`db_get` highly scalable performance (a single disk seek) as it has direct lookup to get the specific byte offset.

Will have issues scaling in size:

* This will only work as long as the index fits in memory.
* The file must fit on a single machine. (ie. No way to partition.)

The index would need a recovery mechanism.
(Be able to build an index for an existing file.)
