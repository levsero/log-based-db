### Segmented log with in memory index

`db_set` has near constant time insertion as it is just appending to end of file.
`db_get` performance is pretty scalable, has to check the hash of every segment for the key, as well as single disk seek.
Performance: O(n + k) where n is the number of segments and k is the seek time.

We are now able to split the segments to each use their own file, which we can use as a base for scaling this db horizontally.

But we are always appending to the files, which means if reusing the same keys there will be a lot of wasted space and in turn extra segments. This will effect performance as well as using a lot of extra db space.
