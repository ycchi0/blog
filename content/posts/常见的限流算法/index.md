+++
title = '常见的限流算法'
date = 2024-05-28T11:11:22Z
draft = false
+++

限流
--

通过限制并发访问数或者限制一个时间窗口内允许处理的请求数量来保护系统，例如，通过限流，你可以过滤掉产生流量峰值的客户和服务。

令牌桶算法
-----

令牌桶算法是常见的一种限流算法。假设有一个桶，以固定速度（rate）往桶里加入令牌（token）。当桶满了时停止加入。服务收到请求时尝试从桶里取出令牌。如果成功取出，则可以响应本次请求。如果没有取到，可以进行有限时间的等待或者返回超时错误。

### 特点

遇到流量洪峰时可以应对部分突发流量，但由于桶有容量上限，当消耗完桶里堆积的令牌之后只能根据令牌的生成速率提供服务，从而起到限流的作用。

### Golang 实现

Golang rate包提供了 token limiter 的实现,具体可以点击链接查看[rate package](https://pkg.go.dev/golang.org/x/time/rate)

漏桶算法
----

一个固定容量的漏桶，按照常量固定速率流出水滴，这里的水滴指的就是能进行响应的请求。当漏桶满了时，请求就会被丢弃，返回一个限流标志。

### 特点

流量均匀，一般作为计量工具，可以用于流量整形和流量控制。比方说对数据库的操作。经过一层漏桶控制，可以有效控制对数据库的请求，避免数据库被打挂。流量稳定，但是无法应对突发流量。

### Golang 实现

uber 开源了一个基于漏桶的限流器[ratelimit](https://pkg.go.dev/go.uber.org/ratelimit#section-readme)

```go
func main() {
	rl := ratelimit.New(1) // per second
	for i := 0; i < 10; i++ {
		now := rl.Take()
		if i > 0 {
			fmt.Println(i, now)
		}
	}
}

1 2022-03-24 02:24:51.57952663 
2 2022-03-24 02:24:52.579526624 
3 2022-03-24 02:24:53.579526623 
4 2022-03-24 02:24:54.579526617 
5 2022-03-24 02:24:55.579526616 
6 2022-03-24 02:24:56.579526617 
7 2022-03-24 02:24:57.579526616 
8 2022-03-24 02:24:58.579526615 
9 2022-03-24 02:24:59.579526629 

```

可以看到，通过“漏桶”这层的过滤，可以有效保护我们的服务。

```go
// WithoutSlack configures the limiter to be strict and not to accumulate
// previously "unspent" requests for future bursts of traffic.
var WithoutSlack Option = slackOption(0)

// WithSlack configures custom slack.
// Slack allows the limiter to accumulate "unspent" requests
// for future bursts of traffic.
func WithSlack(slack int) Option {
	return slackOption(slack)
}

```

可以简单对比一下

```go
rl := ratelimit.New(1, ratelimit.WithoutSlack) // per second
for i := 0; i < 10; i++ {
	now := rl.Take()
	if i == 2 {
		time.Sleep(2 * time.Second)
	}
	if i > 0 {
		fmt.Println(i, now)
	}
}
1 2022-03-24 02:34:22.547745401 
2 2022-03-24 02:34:23.54774539   //sleep 2 秒，后面 rps 还是很平稳
3 2022-03-24 02:34:25.549647721 
4 2022-03-24 02:34:26.549647738 
5 2022-03-24 02:34:27.549647312 
6 2022-03-24 02:34:28.549647722 
7 2022-03-24 02:34:29.549647716 
8 2022-03-24 02:34:30.549647722 
9 2022-03-24 02:34:31.549647599 

rl := ratelimit.New(1, ratelimit.WithSlack(5)) // per second
for i := 0; i < 10; i++ {
	now := rl.Take()
	if i == 2 {
		time.Sleep(5 * time.Second)
	}
	if i > 0 {
		fmt.Println(i, now)
	}
}
1 2022-03-24 02:39:58.860218897 
2 2022-03-24 02:39:59.860218892  //sleep 5 秒，这里的例子比较夸张，不过可看到我们可以一次性处理 5 个
3 2022-03-24 02:40:04.865851924 
4 2022-03-24 02:40:04.865855167 
5 2022-03-24 02:40:04.86585706 
6 2022-03-24 02:40:04.865858894 
7 2022-03-24 02:40:04.865860533 
8 2022-03-24 02:40:05.860218893 
9 2022-03-24 02:40:06.860218883 

```

我们取得可以处理的请求后还应该结合 context 上下午中的上下文时间，避免拿到请求后处理请求超时。

滑动窗口算法
------

滑动窗口算法是对普通时间窗口计数的优化，我们知道普通时间窗口计数存在精度的不足，比如说我们服务1秒可以处理1000个请求，所以这里我们限制1s处理的请求数为1000。前1秒后500ms 来了600个请求，后一秒前400ms 来了600个请求，那么在这 900ms的间隔里就来了1200 个请求。主要的原因就在于普通时间窗口计数每间隔 1 s 会刷新，所以滑动窗口将间隔时间划分为多个区间，从设计上优化了精度问题。

### Golang 实现

```go
type slot struct {
	startTime time.Time //slot 的起始时间
	count     int       //数量
}

type slots []*slot

type window slots //窗口

func sumReq(win window) int { //计数
	count := 0
	for _, slot := range win {
		count += slot.count
	}
	return count
}

type RollingWindow struct {
	slotLength time.Duration //slot 的长度
	slotNum    int           //slot 个数
	winLenght  time.Duration //窗口长度
	maxReqNum  int           //rolling window 内允许的最大请求书
	win        window        //窗口
	lock       sync.Mutex    //锁
}

func NewRollingWindow(slotLength time.Duration, slotNum int, maxReqNum int) *RollingWindow {
	return &RollingWindow{
		slotLength: slotLength,
		slotNum:    slotNum,
		winLenght:  slotLength * time.Duration(slotNum),
		maxReqNum:  maxReqNum,
		win:        make(window, 0, slotNum),
		lock:       sync.Mutex{},
	}
}

func (rw *RollingWindow) IsLimit() bool {
	return !rw.validate()
}


func (rw *RollingWindow) validate() bool {
	now := time.Now()
	rw.lock.Lock()
	defer rw.lock.Unlock()
	//滑动窗口
	rw = rw.slideRight(now)
	//是否超限
	can := rw.accept()
	if can {
		//记录请求数
		rw.update(now)
	}

	return can
}

//向右移动窗口 [0,1,2,3,4,5] -> [1,2,3,4,5]
func (rw *RollingWindow) slideRight(now time.Time) *RollingWindow {
	offset := -1
	for i, slot := range rw.win {
		if slot.startTime.Add(rw.winLenght).After(now) {
			break //不需要滑动
		}
		offset = i
	}
	if offset > -1 {
		rw.win = rw.win[offset+1:]
	}
	return rw
}

//判断请求是否超限 没有超限返回 true
func (rw *RollingWindow) accept() bool {
	return sumReq(rw.win) < rw.maxReqNum
}

func (rw *RollingWindow) update(now time.Time) *RollingWindow {

	if len(rw.win) > 0 {
		lastOffset := len(rw.win) - 1
		lastSlot := rw.win[lastOffset]
		if lastSlot.startTime.Add(rw.slotLength).Before(now) {
			//填入新的 slot
			newSlot := &slot{startTime: now, count: 1}
			rw.win = append(rw.win, newSlot)
		} else {
			rw.win[lastOffset].count++
		}
	} else {
		newSlot := &slot{startTime: now, count: 1}
		rw.win = append(rw.win, newSlot)
	}

	return rw
}

func main() {
	l := NewRollingWindow(100*time.Millisecond, 10, 10)
	fakeDealReq(l, 3)
	printRollingWindow(l)
	time.Sleep(200 * time.Millisecond)

	fakeDealReq(l, 3)
	printRollingWindow(l)

	time.Sleep(200 * time.Millisecond)
	fakeDealReq(l, 5)
	printRollingWindow(l)

	time.Sleep(1 * time.Second)
	fakeDealReq(l, 1)
	printRollingWindow(l)
}

func fakeDealReq(l *RollingWindow, num int) {
	for i := 0; i < num; i++ {
		fmt.Println(l.IsLimit())
	}
}

func printRollingWindow(l *RollingWindow) {
	for _, v := range l.win {
		fmt.Println(v.startTime, v.count)
	}
}

//输出
false
false
false
2022-03-24 05:06:04.616315628 +0000 UTC m=+0.000036182 3
false
false
false
2022-03-24 05:06:04.616315628 +0000 UTC m=+0.000036182 3
2022-03-24 05:06:04.817533239 +0000 UTC m=+0.201253793 3
false
false
false
false
true
2022-03-24 05:06:04.616315628 +0000 UTC m=+0.000036182 3
2022-03-24 05:06:04.817533239 +0000 UTC m=+0.201253793 3
2022-03-24 05:06:05.018547679 +0000 UTC m=+0.402268233 4
false
2022-03-24 05:06:06.020410484 +0000 UTC m=+1.404131050 1

```

