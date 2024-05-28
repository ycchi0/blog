+++
title = 'Art Template'
date = 2024-05-23T16:59:54Z
draft = false
+++

## art-template

art-template 是一个简约、超快的模板引擎。采用作用域预声明的技术来优化模板渲染速度，从而获得接近 JavaScript 极限的运行性能，并且同时支持 NodeJS 和浏览器。

在一些动态渲染场景，使用 art-template 可以将 JS 代码与 Html 代码分开管理，便于项目维护。

比如说后端获取到一个 students 对象数组，现在要在界面上以列表的形式展示，我们可能会这样编写代码

student 对象数组为：
```javascript
const students = [
  {
    name: "xxx",
    age: 18,
  },
  {
    name: "yyy",
    age: 28,
  },
  {
    name: "zzz",
    age: 20,
  },
];


```

使用模板字符串
```javascript

const list = document.getElementById('list');

let html = '';

for (const student of students) {
    html += `<li>${student.name} ${student.age}</li>`;
}
list.innerHTML = html;

```

使用 art-template：

```javascript

 <script id="tpl-students" type="text/html">
    {{each students}}
        <li>{{$value.name}} {{$value.age}} {{$value.sex}}</li>
    {{/each}}
</script>

const list = document.getElementById('list');

 // 模板引擎输出的是字符串，是填充了数据的字符串
list.innerHTML = template('tpl-students', {students});
```

可以发现，代码变得更整洁也更容易维护。

更多 art-template 用法，可以查看[官方文档](https://aui.github.io/art-template/docs/api.html)。

