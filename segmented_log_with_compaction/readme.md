### Segmented log with in memory index

`db_set` has near constant time insertion as it is just appending to end of file (with the addition of creating a new file if not enough room in the current segment).

`db_get` checks the hash of each segment in reverse order for the key, than performs a single disk seek on the first found key.

`compact!` compacts the existing files, by creating new files and only persisting the most recent value of each key. It then deletes the old files. The current implementation first reduces all the segments hash_indexes to produce an array of unique keys, it then does a `db_get` on each value and writes it to the new segment. This is pretty brute force though is memory efficient.

Performance: O(n + k) where n is the number of segments and k is the seek time.

We are now able to split the segments to each use their own file, which we can use as a base for scaling this db horizontally.

But we are always appending to the files, which means if reusing the same keys there will be a lot of wasted space and in turn extra segments. This will effect performance as well as using a lot of extra db space.

### Difference:

Compacts segments by combining them into new files, while removing duplicate keys.

### Limitations

* Deleting records - can place a special char or something (tombstone) on the key to indicate it has been deleted.
* Crash recovery - if it crashes will lose the in memory indexes.
* Partially written records - if crashes while writing how will it recover.
* The hash table must fit in memory.
* No quick way of doing range queries other than looking for every key in the range.
* Assuming the compaction can run on a background thread how would you handle writes while compacting. - As a first step to compaction we could create a new segment which will be used for writes and both the old and new segments array will use as the most recent segment.
