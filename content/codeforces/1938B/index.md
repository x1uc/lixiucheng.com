---
title: "CF 1938B"
date: 2025-11-17
---

```go
package main

import (
    "bufio"
    "fmt"
    "os"
)

func solve() {
    var n, k int
    fmt.Fscan(reader, &n, &k)

    arr := make([]int, k)
    for i := 0; i < k; i++ {
        fmt.Fscan(reader, &arr[i])
    }

    min_num := 0
    positions_needed := n - k + 1

    if arr[0]%positions_needed == 0 {
        min_num = arr[0] / positions_needed
    } else {
        min_num = arr[0] / positions_needed
        if arr[0] > 0 {
            min_num++
        }
    }

    is_valid := true
    for i := 1; i < k; i++ {
        increase := arr[i] - arr[i-1]
        if increase < min_num {
            is_valid = false
            break
        }
        min_num = increase
    }

    if is_valid {
        fmt.Fprintln(writer, "YES")
    } else {
        fmt.Fprintln(writer, "NO")
    }
}

var reader = bufio.NewReader(os.Stdin)
var writer = bufio.NewWriter(os.Stdout)

func main() {
    defer writer.Flush()
    var t int
    fmt.Fscan(reader, &t)
    for i := 0; i < t; i++ {
        solve()
    }
}

```
