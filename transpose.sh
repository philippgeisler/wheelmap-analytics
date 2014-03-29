#!/usr/bin/awk -f
# transposes a sorted(!) recordset with three values per record
# given that $1 is a category, $2 a key (here: status), $3 the value for said key
# e.g.
# cat1 status1 1 becomes [category status1 status2]
# cat1 status2 2          cat1     1       2
# cat2 status2 3          cat2     0       3...
# ... ...
BEGIN {
    current=0
    status["limited"] = 0
    status["no"] = 1
    status["unknown"] = 2
    status["yes"] = 3
    last = 3

    print "category" FS "limited" FS "no" FS "unknown" FS "yes"
}
{
    if (!category[$1]++) {
        if (NR > 1) {
            while (current++ <= last) { printf FS 0 }
            printf RS $1
        } else {
            # no newline at the beginning
            printf $1
        }
        current = 0
    }
    {
        number_missing_values = status[$2] - current
        n = 0
        while (n++ < number_missing_values) { printf FS 0 }
        printf FS $3
        current = ++current + number_missing_values
        }
    }
END {
    while (current++ <= last) { printf FS 0 }
}