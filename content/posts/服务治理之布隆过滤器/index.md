+++
title = '服务治理之布隆过滤器'
date = 2024-05-28T11:01:20Z
draft = false
+++

# 布隆过滤器 
布隆过滤器（英语：Bloom Filter）是1970年由布隆提出的。它实际上是一个很长的二进制向量和一系列随机映射函数。元素可以添加到集合中，但不能删除(计数布鲁姆过滤器变体支持删除);

## 作用 
布隆过滤器可以用于判断一个元素可能存在或者一定不存在。

### 参考文章
* [Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter)
* https://segmentfault.com/a/1190000021136424



## go-zero 中的实现 
### go-zero 中基于 redis 实现了布隆过滤器 

通过 lua 脚本 setbit 和 getbit 
```lub
	setScript = `
for _, offset in ipairs(ARGV) do
	redis.call("setbit", KEYS[1], offset, 1)
end
`
	testScript = `
for _, offset in ipairs(ARGV) do
	if tonumber(redis.call("getbit", KEYS[1], offset)) == 0 then
		return false
	end
end

```
### 使用
```go
package main

import (
	"fmt"

	"github.com/zeromicro/go-zero/core/bloom"
	"github.com/zeromicro/go-zero/core/stores/redis"
)

func main() {
	store := redis.New("localhost:6379")
	filter := bloom.New(store, "testbloom", 64)
	filter.Add([]byte("kevin"))
	filter.Add([]byte("wan"))
	fmt.Println(filter.Exists([]byte("kevin")))
	fmt.Println(filter.Exists([]byte("wan")))
	fmt.Println(filter.Exists([]byte("nothing")))
}

```

## 应用场景 
* 网页爬虫对 URL 去重，避免爬取相同的 URL 地址
* 反垃圾邮件，从数十亿个垃圾邮件列表中判断某邮箱是否垃圾邮箱
* Google Chrome 使用布隆过滤器识别恶意 URL
* Medium 使用布隆过滤器避免推荐给用户已经读过的文章
* Google BigTable，Apache HBbase 和 Apache Cassandra 使用布隆过滤器减少对不存在的行和列的查找
* **解决缓存穿透**

### 解决缓存穿透问题 
1. 预先把数据查询的主键，比如用户 ID 或文章 ID 缓存到过滤器中。
2. 当根据 ID 进行数据查询的时候，先通过布隆过滤器判断数据是否存在，如果不存在，则直接返回，这样就减少触发后续的数据库查询。由于布隆过滤器只能判断数据可能存在或者一定不存在，所以无法完全解决缓存穿透的问题，但可以将其控制在一个可容忍的范围内。

