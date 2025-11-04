---
title: "CF 1736B"
date: 2025-10-24
math: true
---

## 题目大意

给定一个长度为 $n$ 的整数数组 $a$。

是否存在一个由 $n+1$ 个正整数构成的数组 $b$，使得对于所有 $i$（$1 \leq i \leq n$）都满足 $a_i=\gcd (b_i,b_{i+1})$ ？

请注意，$\gcd(x, y)$ 表示整数 $x$ 和 $y$ 的[最大公约数](https://en.wikipedia.org/wiki/Greatest_common_divisor)。

## 题目思路

$$
a_i, a_{i+1}, a_{i+2}, a_{i+3}
$$

$$
b_i, b_{i+1}, b_{i+2}, b_{i+3}, b_{i+4}
$$

有关系：

$$
a_i = \gcd(b_i, b_{i+1})
$$

$$
a_{i+1} = \gcd(b_{i+1}, b_{i+2})
$$

我们可以知道 $b_{i+1}$ 是 $a_i$ 和 $a_{i+1}$ 的倍数，也就是：

$$
b_{i+1} = k \cdot \mathrm{lcm}(a_i, a_{i+1})
$$

那么这个 $k$ 应该如何确定呢？

注意到：

$$
b_{i+1} = k \cdot \mathrm{lcm}(a_i, a_{i+1}), \quad
b_{i+2} = k \cdot \mathrm{lcm}(a_{i+1}, a_{i+2})
$$

也可以写成：

$$
b_{i+1} = x \cdot a_{i+1}, \quad
b_{i+2} = y \cdot a_{i+1}
$$

此时可以确定的是，$a_{i+1}$ 必然是 $b_{i+1}$ 和 $b_{i+2}$ 的公约数(⚠️这里是公约数而不是最大公约数)。

由于 $x$ 和 $y$ 越大，会降低 $a_{i+1}$ 作为 $\gcd(b_{i+1}, b_{i+2})$ 的最大性，因此选择 $k=1$ 是最优的。
