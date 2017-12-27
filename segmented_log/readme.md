### Segmented log with in memory index

`db_set` has near constant time insertion as it is just appending to end of file.

`db_get` checks the hash of each segment in reverse order for the key, than performs a single disk seek on the first found key.

Can split the segments to each use their own file, which we can use as a base for scaling this db horizontally.

Performance: O(n + k) where n is the number of segments and k is the seek time. Though you could search across the segments concurrently (especially if across separate machines).

But we are always appending to the files, which means if reusing the same keys there will be a lot of wasted space and in turn extra segments. This will effect performance as well as using a lot of extra db space.

### Difference:

The values are stored across multiple files (segments) each of which has its own index hash.
