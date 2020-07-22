// 引入 express 框架
const express = require("express");
// 引入 path 路径模块
const path = require("path");
// 开启express app服务
const app = express();

app.use(express.static(path.resolve(__dirname, "public")));

app.use((req, res, next) => {
  // 获取请求代理
  const Proxy = req.query.Proxy;
  // 如果有代理
  if (Proxy) {
    req.headers.cookie = req.headers.cookie + `__proxy__${Proxy}`;
  }
  next();
});
// 获取数据 路由到不同的数据接口
app.use("/getTestData", require("./router/test"));
app.use("/getHomePageContent", require("./router/homePageContent"));
// 指定端口
const port = process.env.PORT || 3300;
app.listen(port, () => {
  console.log(`server running @http://127.0.0.1:${port}`);
});
// 导入 app服务
module.exports = app;
