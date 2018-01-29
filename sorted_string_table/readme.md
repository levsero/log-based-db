### Sorted string table (SST)

`db_set` adds the value to an in memory string. When the in memory hash reaches a certain size it is persist to a file.

`db_get` checks the hash of each segment in reverse order for the key, starting with the in-memory segment.

`compact!` compacts the existing persisted segments. Opens all the files reading only the first key-value pair of each into memory sorts them, and merges in the most recent one. For each file that had that key it moves to the second key-value pair. Since it always takes the first one in a sorted order this maintains sorting in every segment even after compaction.

Currently storing the in memory index in a hash so duplicates don't exist, but usually this would be a tree of some sort.

Used by RocksDB which is used by kafka streams

### Difference:

Every file is now alphabetically sorted on persistence. This is achieved by keeping the segment in memory and only persisting to a given file once and doing so in a sorted order. Additionally the merge has also been rewritten so it will maintain the sort ordering on merge.

The advantage of this is it will allow for querying by range as well as being able to maintain sparse collection of key indexes because you can easily scan from the closest key. For example if we have the key `honduras: 256, japan: 512`, and need to look up 'india' we can quickly scan from byte 256 until 512 to see if it exists without having to store every key in memory.
