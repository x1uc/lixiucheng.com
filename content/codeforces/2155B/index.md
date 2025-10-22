---
title: "CF 2155B"
date: 2025-10-20
---

[CF 2155B](https://codeforces.com/problemset/problem/2155/B)

**收获**

- go如何输入
- fmt.Println('a') 输出的是字符的ascii码，而非字符

```go
package main

import "fmt"

func main() {
	var t int
	fmt.Scan(&t)
	for i := 0; i < t; i++ {
		var n, kf int
		fmt.Scan(&n, &kf)
		if n*n-kf == 1 {
			fmt.Println("NO")
			continue
		}
		fmt.Println("YES")
		count := 0
		for j := 0; j < n; j++ {
			control := false
			for k := 0; k < n; k++ {
				count++
				if count <= kf {
					fmt.Print("L")
					continue
				}
				if k == n-1 && j != n-1 {
					fmt.Print("D")
					continue
				}
				if !control {
					control = !control
					fmt.Print("R")
					continue
				} else {
					fmt.Print("L")
					continue
				}
			}
			fmt.Println()
		}
	}
}
```
