When storing data to a database it may depend somewhat on the use case but generally you want it to be performant for both insertions and retrieves even as it grows in size. Another consideration is how it scales in its memory and disk usage. There are many different databases that have many different pros and cons depending on what they're optimized for, this repo will look at and build a log based systems similar to what is used internally for many NoSQL databases.

Log based systems are generally very efficient at inserting and retrieving individual records and with the right system can also work well with retrieving ranges of data. On the other hand if you want a system that is easy to perform many different dynamic queries it can have its shortcomings.

This starts from a plain text [log file](/log_file/readme.md) with no indexing. We than add [indexing](/log_with_in_memory_index/readme.md) for efficient lookups. The next issue we address is horizontal scalability by adding [segmentation](/segmented_log/readme.md) and [compaction](/segmented_log_with_compaction/readme.md).
