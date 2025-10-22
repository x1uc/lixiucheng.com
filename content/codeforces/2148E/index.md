---
title: "CF 2148E"
date: 2025-10-21
---

[CF 2148E](https://codeforces.com/problemset/problem/2148/E)

**收获**

- go 中如何写while循环

```go
package main

import "fmt"

func solve() {
    var n, k int
    var arr [200005]int
    var cnt [200005]int
    var cnt_now [200005]int
    fmt.Scan(&n, &k)
    for i := 0; i < n; i++ {
        fmt.Scan(&arr[i])
        cnt[arr[i]]++
    }

    for i := 0; i < n; i++ {
        if cnt[arr[i]]%k != 0 {
            fmt.Println(0)
            return
        }
    }

    var l, r int
    cnt_now[arr[0]]++
    ans := 1
    for r < n-1 {
        r++
        cnt_now[arr[r]]++
        if cnt_now[arr[r]] > cnt[arr[r]]/k {
            for cnt_now[arr[r]] > cnt[arr[r]]/k {
                cnt_now[arr[l]]--
                l++
            }
        }
        ans += r - l + 1
    }
    fmt.Println(ans)
}

func main() {
    var t int
    fmt.Scan(&t)
    for i := 0; i < t; i++ {
        solve()
    }
}
```
