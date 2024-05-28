+++
title = 'Golang异常处理'
date = 2024-05-28T11:02:44Z
draft = false
+++


从error的定义说起
-----------

```go
type error interface {
	Error() string
}
```

Go 的error类型是一个接口。在Go中，只要实现了接口约定的方法，就等同于实现了这个接口。在日常的业务代码编写中，我们经常使用 errors 包下的New 方法来生成一个error对象。

```go
func main() {
	err := errors.New("a error")
	fmt.Println(reflect.TypeOf(err))//*errors.errorString
}

```

可以发现，err 是一个指针类型，为什么这里的 err 需要是一个指针呢？

```go
// Each call to New returns a distinct error value even if the text is identical.
func New(text string) error {
	return &errorString{text}
}

```

查看errors包的代码，我们知道返回指针是为了确保err的唯一性。

以下的代码是返回一个变量会引起的问题。

```go
type ValueError string

func (ve ValueError) Error() string {
	return string(ve)
}
func New(text string) error {
	return ValueError(text)
}

func main() {
	simpleError := New("error")
	complexError := New("error")

	if simpleError == complexError {
		fmt.Println("true")//true
	}
}

```

Panic 机制
--------

Go 没有像其它语言一样提供 try...catch机制。在Java代码中，我们常见的就是写了一大段的逻辑，然后在外层进行try...catch 异常处理。在Go中，我们只有 error 和 panic 函数，这里主要介绍一下panic函数，通常我们是在程序碰见无法处理问题时才会考虑panic，比如除数为0了，这时候程序是会直接奔溃的。所以Go提供了 recover 函数，用来回复程序抛出的panic,我们可以在 recover 里进行日志、堆栈信息的记录，便于后续问题的排查。

通常是在 defer 里进行 recover 的。

```go
package main

import "fmt"

func main() {
	f()
	fmt.Println("Returned normally from f.")
}
func f() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Recovered in f", r)
		}
	}()
	panic("panic")
}

```

web 服务一般会在最外层使用 recover 来避免因为异常导致程序奔溃的情况。比如 gin.Default() 这个方法中就默认使用了 recovery() 中间件。

以下代码片段来自 gin 的recovery 方法

```go
return func(c *Context) {
		defer func() {
			if err := recover(); err != nil {
				// Check for a broken connection, as it is not really a
				// condition that warrants a panic stack trace.
				var brokenPipe bool
				if ne, ok := err.(*net.OpError); ok {
					if se, ok := ne.Err.(*os.SyscallError); ok {
						if strings.Contains(strings.ToLower(se.Error()), "broken pipe") || strings.Contains(strings.ToLower(se.Error()), "connection reset by peer") {
							brokenPipe = true
						}
					}
				}
				....
		}()
		c.Next()
	}

```

这里要注意的是，很多人利用defer-recover这样的套路，实现了Go语言的'try-catch'，这其实是不太优雅的。个人觉得这有点违背 Go 异常处理的设计理念。

错误类型（error types）
-----------------

### 预定义错误

io 包中就定义了很多预定义的错误。最常见的可能就是EOF了。

```go
var ErrShortBuffer = errors.New("short buffer")
var EOF = errors.New("EOF")
var ErrUnexpectedEOF = errors.New("unexpected EOF")

```

使用这种方式一个缺点就是不够灵活，当我们需要使用预定错误的时候，我们通常需要通过判断错误的类型是否相匹配

而在业务层中，我们通常返回错误的时候需要带上一些上下文信息，方便后续问题的排查。如果我们使用fmt.Errorf()，就会破坏调用者的类型判断。同时如果在业务层使用了预定义的错误，这时这个错误也必须是公共的，这将增加API的对外暴露的信息。同时调用方需要引用定义错误的这个包，增加了源代码层面的依赖关系。所以这个类型的错误一般是在标准库或者基础库中进行使用。

### 自定义错误

```go
type MyError struct {
	When time.Time
	What string
}

func (e *MyError) Error() string {
	return fmt.Sprintf("%v : %v\n", e.When, e.What)
}

func test() error {
	return &MyError{When: time.Now(), What: "test error"}
}

func main() {
	err := test()
	switch err.(type) {
	case nil:
		fmt.Println("nil")
	case *MyError:
		fmt.Println("MyError")
	default:
		fmt.Println("unKnow")
	}
}

```

代码中通过断言转换这个类型。与特定错误相比，自定义的错误可以携带更多的上下文信息，但是本质上仍需要error类型为public。同样和调用者有强耦合。

因此，使用我们要尽量避免在公共API中使用 error types。

### Assert errors for behaviour, not type

我们应该断言错误的特定行为，而不是它的类型。这个建议来自于 [Dave](https://link.zhihu.com/?target=https%3A//dave.cheney.net/2014/12/24/inspecting-errors) 。

调用方关注更多的地方是这个错误的行为，而不是这个错误的类型，所以提供方可以封装出特定错误类型的方法，只对外暴露这个方法而不暴露错误的类型。

```go
func isTimeout(err error) bool {
        type timeout interface {
                Timeout() bool
        }
        te, ok := err.(timeout)
        return ok && te.Timeout()
}
```

错误处理
----

在Go中，我们经常写出这样的代码

```go
if err != nil {
   //do someting
   //return 
}

```

从程序的严谨性来讲，有错误的地方都是需要处理的。错误仅需要处理一次，如果认为需要交给调用者处理，则仅需要将错误信息返回。

### pkg/errors

[GitHub地址](https://link.zhihu.com/?target=https%3A//github.com/pkg/errors)

pkg/errors 是一个好用的第三方error包，兼容Go标准库，提供了一些非常有用的操作用于封装和处理错误。

```go
type RawError struct {
	msg string
}

func (e *RawError) Error() string {
	return e.msg
}

func main() {
	rawError := &RawError{msg: "no such file or directory"}
	fmt.Println("rawError:", rawError)
	wrapError := errors.Wrap(rawError, "a error occurred in xxxx,xxxxx")
	fmt.Println("wrapError:", wrapError)

	wrapwrapError := errors.Wrap(rawError, "double wrap")

	switch errors.Cause(wrapError).(type) {
	case *RawError:
		fmt.Println("the error type is *RawError ")
	default:
		fmt.Println("unknown")
	}

	switch errors.Cause(wrapwrapError).(type) {
	case *RawError:
		fmt.Println("the error type is *RawError ")
	default:
		fmt.Println("unknown")
	}
}

// rawError: no such file or directory
// wrapError: a error occurred in xxxx,xxxxx: no such file or directory
// the error type is *RawError
// the error type is *RawError

```

### Go标准库

Go1.13为 errors 和 fmt 标准库包引入了新特性。

```go
// Unwrap returns the result of calling the Unwrap method on err, if err's
// type contains an Unwrap method returning error.
// Otherwise, Unwrap returns nil.
func Unwrap(err error) error {
	u, ok := err.(interface {
		Unwrap() error
	})
	if !ok {
		return nil
	}
	return u.Unwrap()
}

// Is reports whether any error in err's chain matches target.
//
// The chain consists of err itself followed by the sequence of errors obtained by
// repeatedly calling Unwrap.
func Is(err, target error) bool {
	if target == nil {
		return err == target
	}

	isComparable := reflectlite.TypeOf(target).Comparable()
	for {
		if isComparable && err == target {
			return true
		}
		if x, ok := err.(interface{ Is(error) bool }); ok && x.Is(target) {
			return true
		}
		// TODO: consider supporting target.Is(err). This would allow
		// user-definable predicates, but also may allow for coping with sloppy
		// APIs, thereby making it easier to get away with them.
		if err = Unwrap(err); err == nil {
			return false
		}
	}
}

// As finds the first error in err's chain that matches target, and if so, sets
// target to that error value and returns true. Otherwise, it returns false.
func As(err error, target interface{}) bool {
	if target == nil {
		panic("errors: target cannot be nil")
	}
	val := reflectlite.ValueOf(target)
	typ := val.Type()
	if typ.Kind() != reflectlite.Ptr || val.IsNil() {
		panic("errors: target must be a non-nil pointer")
	}
	targetType := typ.Elem()
	if targetType.Kind() != reflectlite.Interface && !targetType.Implements(errorType) {
		panic("errors: *target must be interface or implement error")
	}
	for err != nil {
		if reflectlite.TypeOf(err).AssignableTo(targetType) {
			val.Elem().Set(reflectlite.ValueOf(err))
			return true
		}
		if x, ok := err.(interface{ As(interface{}) bool }); ok && x.As(target) {
			return true
		}
		err = Unwrap(err)
	}
	return false
}

//示例
var rawError = errors.New("simple error")
func SimpleError() error {
	return rawError
}
func main() {
	simpleError := SimpleError()

	wrapE := fmt.Errorf("wrap error:%w", simpleError)
	wrapWrapE := fmt.Errorf("wrapWrapE error:%w", wrapE)

	fmt.Printf("err:%+v\n", wrapWrapE)
	fmt.Printf("errors.Unwrap(wrapWrapE):%+v\n", errors.Unwrap(wrapWrapE))
	fmt.Printf("errors.Unwrap(errors.Unwrap(wrapWrapE)):%+v\n", errors.Unwrap(errors.Unwrap(wrapWrapE)))

	fmt.Println("errors.Is(err, rawError):", errors.Is(wrapWrapE, rawError))

	var errorValue error
	fmt.Println("errors.As(err, &rawError):", errors.As(wrapWrapE, &errorValue))
	fmt.Println("errorValue:", errorValue)

}

```