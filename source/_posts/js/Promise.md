---
title: Promise
date: 2023-11-24 17:52:38
cover: 1
tags: 
- 技术分享
categories: 
- js
---

<!-- toc -->

## 前言

这是2021年11月份在`CSDN`上写的博客, 由于本人以后端为主, 前端对自己的要求是会用即可, 没有深入学习, 前几天面试时被问到`js`的异步问题, 有点懵, 所以翻出来再看一眼, 也补充点内容

## 介绍

`Promise`异步编程的一种解决方案.对异步操作进行封装,做链式编程
避免多重回调嵌套
## `Promise`的三种状态
##### `pending`:
等待状态,异步操作没有完成,如网络请求没有结束.
##### `fulfill`:
满足状态,运行到了主动回调`resolve`函数的位置,此时会回调`then()`.
##### `reject`:
拒绝状态,运行到了主动回调`reject`函数的位置,此时会回调`catch()`.
## 使用
##### 基本使用
> 1. 使用`new`关键字创建一个`Promise`
> 2. `Promise`创建时需要一个函数作为参数
> 3. 参数函数的参数为`resolve`函数和`reject`函数
```js
// 创建一个Promise
new Promise((resolve, reject) => {
		// 异步函数
		setTimeout(() =>{
			// 异步函数执行完的成功回调函数
			// 回调函数的操作改为调用resolve函数
			// 调用resolve函数后,Promise就会到then中
			// resolve函数中的参数可以从then的回调函数中取得
			resolve(data)
			// 一步函数执行完的失败回调函数
			reject(error)
		}, 1000)
	}
).then((data) => {
	// Promise中的异步函数的回调函数中的操作就可以写到then的对调函数中,可以获取resolve函数的参数
	console.log("then");
	// 如果还有异步操作,可以再次return一个Promise
	return new Promise((resolve, reject) => {
		// ...
		resolve(res)
	});
}).then(res).catch((error) => {
	// 异常情况的回调
});
```

##### `Promise`的链式调用
1.

```js
new Promise((resolve, reject) => {
	// 一步操作...
	resolve(data);
}).then((data) => {
	// ...
	// 结果处理
	return Promise.resolve(data + '111');
	// return Promise.reject(err) || throw "err message"
}).then((data) => {
	// ...
	// 结果处理
	return Promise.resolve(data + '222');
}).catch((err) => {
})
```
2. 
```js
new Promise((resolve, reject) => {
	// 一步操作...
	resolve(data);
}).then((data) => {
	// ...
	// throw "err message"
	// 结果处理
	return data + '111';
}).then((data) => {
	// ...
	// 结果处理
	return data + '222';
}).catch((err) =>{
})
```
> 1.`then`中期望一个函数作为参数,如果不是函数,则会发生`then`穿透,即本次`then`中的回调的参数直接给到下一个`then`中,不做任何处理.但是不会被`catch`获取
> 2.简单说,`then`中如果有`return`,则返回的内容是一个`Promise`,`return`的数据可以直接从下一个`then`中作为参数获取.如果抛出异常,则是返回一个`reject`的`Promise`,数据可以直接从`catch`中获取
```js
new Promise((resolve, reject) => {
	resolve('123');
}).then('abc').then(data => {
	// 此处的data的值是123
	console.log(data);
})
```
##### 同时处理多个异步操作
```js
Promise.all([
	new Promise((resolve, reject) => {resolve(data)}),
	new Promise((resolve, reject) => {resolve(data)}),
	...
]).then(results => {
	// ...
})

```
只有当所有的异步操作都完成时才会执行`then`函数,其回调的参数`results`时所有异步操作的返回结果集,是一个数组

<font color="#00FF00">日期：2021-11-18</font>

## 补充

##### `Promise`的任务类型

1. 在此之前是不了解`js`的, 通过这次才知道`js`是单线程的, 而所谓的异步实际指的是异步任务

2. `Promise`通过`new`的方式本身并没有变为异步任务, 在执行到`resolve`或者`reject`之后才会成为异步任务等待执行`then`或者`catch`回调, 所以`Promise`本身是同步代码块
3. 异步任务会放入任务队列中, 等待条件符合后执行(两个方面: 一是本身条件符合, 即已经放入了任务队列中; 二是线程条件符合, 即同步内容执行完成后, 被事件循环机制从队列中取出)

## 推荐

<a href="https://blog.csdn.net/qfc_128220/category_11294044.html">Promise系列</a>

这位老哥关于`Promise`的博文写的很棒, 这两天比较忙, 只看了(三), 后续补上

