---
title: "CF 2133D"
date: 2025-11-07
---

```go
package main

import (
    "bufio"
    . "fmt"
    "io"
    "os"
)

func main() {
    in := bufio.NewReader(os.Stdin)
    out := os.Stdout
    var T int
    Fscan(in, &T)

    for T != 0 {
        solve(in, out)
        T--
    }
}

func solve(in io.Reader, out io.Writer) {
    var n int
    var k int
    var cnt_1 int
    var str string
    Fscan(in, &n, &k, &str)
    for i := 0; i < n; i++ {
        if str[i] == '1' {
            cnt_1++
        }
    }

    if n >= 2*k {
        if cnt_1 <= k {
            Fprintln(out, "Alice")
        } else {
            Fprintln(out, "Bob")
        }
    } else {
        Fprintln(out, "Alice")
    }
}
```
