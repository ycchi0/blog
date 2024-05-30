+++
title = '跨域问题处理方案'
date = 2024-05-30T16:27:47Z
draft = false
+++



## 使用 Nginx 反向代理处理跨域问题

在 Nginx 配置文件中设置一个代理服务器，并添加一些额外的头信息。

```javascript
location /api/ {
    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
    add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
    proxy_pass http://target.com;
}
```

然后重启 Nginx 以应用这些更改：

## 在 Vue.js 项目中处理跨域问题

在`vue.config.js`文件中，配置 devServer.proxy 选项来设置代理规则。例如：

```javascript
module.exports = {
  devServer: {
    host: "127.0.0.1",
    port: 8084,
    open: true, 
    proxy: {
      "/api": {
        // '/api'是代理标识，用于告诉node，url前面是/api的就是使用代理的
        target: "http://xxx.xxx.xx.xx:8080", //目标地址，一般是指后台服务器地址
        changeOrigin: true, //是否跨域
        pathRewrite: {
          // pathRewrite 的作用是把实际Request Url中的'/api'用""代替
          "^/api": "",
        },
      },
    },
  },
};
```

保存并重启 Vue 开发服务器，新的代理设置应该就生效了。
注意：这种方法只在开发环境中有效，因为它依赖于 Vue CLI 的开发服务器。在生产环境中，你可能需要在你的后端服务器上设置 CORS 或使用其他方法来处理跨域问题。
