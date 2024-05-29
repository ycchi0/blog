+++
title = '在 VUE 中 ，如何正确使用 Compute、Watch 和 Methods '
date = 2024-05-24T12:49:58Z
draft = false
+++
## Vue 中 computed, watch 和 methods 区别

在Vue 中，我们有几种处理数据和逻辑的方式。

本文将重点探讨computed, watch 和 methods 的区别和使用场景。

### computed
在Vue中，computed用于处理依赖其他属性的计算结果。它是由缓存的，只有当依赖项发生更改时，才会重新计算其结果。
```javascript
setup() {
    const count = ref(0);
    const doubled = computed(() => count.value * 2);

    return {
        count,
        doubled
    }
}
```

我们创建了一个计算属性doubled，将count进行了两倍的计算。每当 count 更新时，doubled 也会自动更新。

### watch

watch用于观察和响应Vue组件中的数据更改。当被观察的数据源发生改变时，会触发一个回调函数。

在Vue中，computed和watch是两种常见的监听数据变化和执行逻辑的手段。它们在用法和应用场景上存在一些区别：
* computed: 它用于处理依赖其他变量的计算结果。比如，你有两个变量 a 和 b，你想创建第三个变量 c，它是 a 和 b 的和。在这种情况下，你应该使用 computed。computed 属性有一个缓存机制，当依赖项没有发生改变时，它会直接返回上一次的计算结果，而不会再次执行函数。
  
* watch: 它用来观察vue实例上的数据变动。需要注意的是，watch 是非缓存的，即只要观察的目标发生变化 watch 就会执行，无论是否真的需要（依赖的数据是否真正发生了改变）。watch 更适合于例如：当数据变化时需要执行异步或者较长时间的操作的场景。

另外 watch 还有跟多高阶用法和特性，本文不做讨论，具体可查询[VUE 文档](https://cn.vuejs.org/guide/introduction.html)

下面的例子中，我们观察count的变化，并在每次count变化时打印出变化后和变化前的值。
```javascript
setup() {
    const count = ref(0);

    watch(count, (newValue, oldValue) => {
        console.log(`Count changed from ${oldValue} to ${newValue}`);
    });

    return {
        count,
        increment: () => count.value++ 
    }
}

```

在这个例子中，当increment函数被调用，count的值会增加，然后watch回调函数将在控制台中打印出count的新旧值。

### methods
methods 是我们在Vue组件中定义的函数。它们不依赖于任何数据属性，并且不会在数据发生变化时自动触发。

下面的例子中，我们定义了一个increment的方法，将count增加1。

```javascript
setup() {
    const count = ref(0);

    const increment = () => {
        count.value++;
    };

    return {
        count,
        increment
    }
}

```

以下是一个可运行的示例代码：
```javascript
<!DOCTYPE html>
<html>
  <head>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <title>Vue 3</title>
  </head>
  <body>
    <div id="app">
      <p>当前值是：{{ count }}</p>
      <p>两倍的值是：{{ doubleCount }}</p>
      <button @click="increment">增加值</button>
    </div>

    <script>
      const { ref, computed, watch } = Vue;
      const app = Vue.createApp({
        setup() {
          const count = ref(0);
          const doubleCount = computed(() => count.value * 2);

          const increment = () => {
            count.value++;
          };


          watch(count, (newValue, oldValue) => {
            console.log(`Count changed from ${oldValue} to ${newValue}`);
          });

          return {
            count,
            doubleCount,
            increment,
          };
        },
      });

      app.mount("#app");
    </script>
  </body>
</html>

```

## 总结

computed, watch 和 methods 在Vue中有它们各自的适用场景。

computed是计算属性，适用于需要根据其他数据变化计算得到新数据的场景。

watch是观察者，适用于关注某个值的变化，并执行一些逻辑操作。

而methods则适用于处理更加复杂的逻辑操作，如用户交互等。你应当根据自己的实际需求选择最适合的处理方式。

