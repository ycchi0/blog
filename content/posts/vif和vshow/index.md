+++
title = 'Vif和vshow'
date = 2024-05-24T13:13:11Z
draft = false
+++

## v-if 与 v-show 的共同点

v-if v-show 都是 Vue 中用来控制元素显示与否的。

## v-if 与 v-show 的区别

1. v-show隐藏则是为该元素添加css--display:none，dom元素依旧还在。v-if显示隐藏是将dom元素整个添加或删除

2. v-show 由false变为true的时候不会触发组件的生命周期
3. v-if由false变为true的时候，触发组件的beforeCreate、create、beforeMount、mounted钩子，由true变为false的时候触发组件的beforeDestory、destoryed方法

##  v-if 与 v-show 的使用场景

需要非常频繁地切换，则使用 v-show 较好

运行时条件很少改变时，则使用 v-if 较好
