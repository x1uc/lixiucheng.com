---
title: "CF 2149D"
date: 2025-10-21
---

[CF 2155B](https://codeforces.com/problemset/problem/2149/D)

**收获**

- 写题目的时候分配数组要在栈上，使用make分配会很浪费时间
- 默认初始化返回参数 func() (ans int) {}

```go
package main

import (
	"fmt"
)

const N = 200005

var (
	sum_l   [N]int
	sum_r   [N]int
	sum_2_l [N]int
	sum_2_r [N]int
)

func solve() {
	var n int
	var s string
	ans := 99999999999
	fmt.Scan(&n)
	fmt.Scan(&s)
	for i := 0; i < n; i++ {
		sum_l[i], sum_r[i], sum_2_l[i], sum_2_r[i] = 0, 0, 0, 0
	}
	if len(s) == 1 {
		fmt.Println(0)
		return
	}
	count := 0
	if s[0] == 'a' {
		count = 1
	}
	for i := 1; i < n; i++ {
		if s[i] == 'a' {
			sum_l[i] = sum_l[i-1] + i - count
			count++
		} else {
			sum_l[i] = sum_l[i-1]
		}
	}
	count = 0
	if s[n-1] == 'a' {
		count = 1
	}
	for i := n - 2; i >= 0; i-- {
		if s[i] == 'a' {
			sum_r[i] = sum_r[i+1] + n - (i + 1) - count
			count++
		} else {
			sum_r[i] = sum_r[i+1]
		}
	}
	for i := 0; i < n-1; i++ {
		now := sum_l[i] + sum_r[i+1]
		if now < ans {
			ans = now
		}
	}

	count = 0
	if s[0] == 'a' {
		count++
	}
	for i := 1; i < n; i++ {
		if s[i] == 'a' {
			sum_2_l[i] = sum_2_l[i-1]
			count++
		} else {
			sum_2_l[i] = sum_2_l[i-1] + count
		}
	}

	count = 0
	if s[n-1] == 'a' {
		count++
	}
	for i := n - 2; i >= 0; i-- {
		if s[i] == 'a' {
			sum_2_r[i] = sum_2_r[i+1]
			count++
		} else {
			sum_2_r[i] = sum_2_r[i+1] + count
		}
	}

	for i := 0; i <= n-1; i++ {
		now := sum_2_l[i] + sum_2_r[i]
		if now < ans {
			ans = now
		}
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

```go
package main

import (
	"fmt"
)

func AbsInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func calc(vector []int) int {
	if len(vector) == 0 || len(vector) == 1 {
		return 0
	}
	ans := 0
	pos := len(vector) / 2
	for i := 0; i < len(vector); i++ {
		ans += AbsInt(vector[pos]-vector[i]) - AbsInt(pos-i)
	}
	return ans
}

func solve() {
	var n int
	var str string
	var pos_a []int
	var pos_b []int
	fmt.Scan(&n, &str)
	for i := 0; i < n; i++ {
		if str[i] == 'a' {
			pos_a = append(pos_a, i)
		} else {
			pos_b = append(pos_b, i)
		}
	}
	l_ans := calc(pos_a)
	r_ans := calc(pos_b)
	var ans int
	if l_ans > r_ans {
		ans = r_ans
	} else {
		ans = l_ans
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
