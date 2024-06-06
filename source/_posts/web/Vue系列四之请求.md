---
title: Vue系列(四)---请求
date: 2024-02-01 08:47:48
tags:
- axios
categories:
- web
top: 4
cover: 1
---

<!-- toc -->

### 前言

为了实现前后端交互, 需要引入请求框架. 当前形势下, `Vue`项目通常使用`axios`作为项目的请求框架

### 引入

#### 安装

使用`pnmp`命令安装

```shell
pnpm add axios
```

#### 引入

`axios`的引入不需要像其它框架那样, 使用`app.use`引入, 只需要创建在使用的位置创建请求实例即可

```typescript
axios.create(config);
```

### 使用

#### 基本使用

```typescript
axios.create(config).request(config);
axios.create(config).get(url);
axios.create(config).post(url, data);
```

#### 封装使用

基本使用方式每次请求时都会创建一个`axios`实例, 并且每次都要添加创建配置, 可以在其基础上进行封装, 创建和使用一个`axios`实例即可, 并且可以进行统一的请求拦截和响应拦截

一. 请求拦截

```typescript
axios.create(config).interceptors.request.use(
    (req: InternalAxiosRequestConfig) => {
        console.log("请求拦截")
        return req;
    },
    (err: any) => {
    }
)
```

请求拦截就是请求在发送之前的前置处理

二. 响应拦截

```typescript
axios.create(config).interceptors.response.use(
    async (res: AxiosResponse) => {
        console.log("响应拦截")
        if (res.status === HttpStatusCode.Ok) {
            return res.data;
        } else {
            throw "请求异常";
        }
    },
    () => {
    }
)
```

响应拦截是对请求的结果进行拦截预处理, 请求的结果是`AxiosResponse`类型, 其中有`status`, `headers`, `config`, `data`等, 服务端返回的数据实际是`data`中的内容

三. 请求实例封装

1. 封装拦截器配置

   封装拦截器配置是将请求拦截和响应拦截按组封装, 方便按组添加

   ```typescript
   /**
    * 拦截器配置
    */
   export interface RequestInterceptorsConfig {
       // 请求拦截
       requestInterceptor?: (req: InternalAxiosRequestConfig) => InternalAxiosRequestConfig;
       requestInterceptorCatch?: (err: any) => any;
       // 响应拦截
       responseInterceptor?: <R = AxiosResponse>(config: R) => R;
       responseInterceptorCatch?: (err: any) => any
   }
   ```

2. 封装请求实例

   封装请求类, 并创建一个公用的请求实例用于项目使用. 提供请求构造, 支持请求的定制配置

   ```typescript
   /**
    * 请求实体
    */
   export class Request {
   
       config: AxiosRequestConfig;
       instance: AxiosInstance;
       interceptors?: RequestInterceptorsConfig[]
   
       constructor(config: AxiosRequestConfig, interceptors?: RequestInterceptorsConfig[]) {
           config.baseURL = import.meta.env.VITE_BASE_URL;
           config.headers = config.headers || new AxiosHeaders();
           config.withCredentials = false;
           this.config = config;
           this.instance = axios.create(config);
           this.interceptors = interceptors;
           // 全局请求拦截
           this.initGlobalRequestInterceptors();
           if (interceptors) {
               for (const interceptor of interceptors) {
                   // 实例请求拦截
                   this.instance.interceptors.request.use(
                       interceptor.requestInterceptor,
                       interceptor.requestInterceptorCatch
                   )
   
               }
               let reverseInterceptors = interceptors.reverse();
               for (const interceptor of reverseInterceptors) {
                   // 实例响应拦截
                   this.instance.interceptors.response.use(
                       interceptor.responseInterceptor,
                       interceptor.responseInterceptorCatch
                   )
               }
           }
           // 全局响应拦截
           this.initGlobalResponseInterceptors();
       }
   
       /**
        * 初始化请求的全局请求拦截
        */
       private initGlobalRequestInterceptors(): void {
           this.instance.interceptors.request.use(
               (req: InternalAxiosRequestConfig) => {
                   let userStore = useUserStore();
                   req.headers.set("TOKEN", userStore.getToken, true)
                   console.log("请求全局请求拦截")
                   return req;
               },
               (err: any) => {
               }
           )
       }
       /**
        * 初始化请求的全局响应拦截
        */
       private initGlobalResponseInterceptors(): void {
           this.instance.interceptors.response.use(
               async (res: AxiosResponse) => {
                   if (res.status === HttpStatusCode.Unauthorized || res.data.state === ApiStateEnum.NOT_LOGIN) {
                       let current = currentRoute();
                       await toLogin(current)
                       return res.data;
                   } else if (res.status >= HttpStatusCode.BadRequest) {
                       throw "请求异常";
                   }
                   return res.data;
               },
               () => {
               }
           )
       }
   }
   ```

   请求创建时获取一个请求配置项和一个拦截配置数组

   请求配置中设置基础路径

   创建时最先初始化全局请求拦截器, 最后初始化全局响应拦截器

   拦截配置数据中的请求拦截顺序添加, 响应拦截倒序添加

3. 封装请求操作

   在封装的请求实例中添加请求操作, 直接使用请求实例中的`AxiosInstance`实例操作

   ```typescript
   /**
    * 有配置请求
    * @param config
    * @param interceptors
    */
   async request(config: AxiosRequestConfig, interceptors?: RequestInterceptorsConfig[]): Promise<void | ApiResult<any>> {
       let instance: AxiosInstance = interceptors && interceptors.length > 0 ? new Request(config, interceptors).instance : this.instance;
       // let instance: AxiosInstance = this.instance;
       return instance
           .request<any, ApiResult<any>>(config)
           .catch((err: any) => {
                   console.log(err);
               })
   }
   
   /**
    * get 请求
    * @param url       请求路径
    * @param params    请求参数数据
    * @param config    请求配置
    */
   get(url: string, params?: any, config?: AxiosRequestConfig): Promise<void | ApiResult<any>> {
       if (!config) {
           config = defaultRequestConfig();
       }
       config.method = "GET";
       config.url = url;
       config.params = params;
       return this.request(config);
   }
   
   /**
    * delete 请求
    * @param url       请求路径
    * @param params    请求参数数据
    * @param config    请求配置
    */
   delete(url: string, params?: any, config?: AxiosRequestConfig): Promise<void | ApiResult<any>> {
       if (!config) {
           config = defaultRequestConfig();
       }
       config.method = "DELETE";
       config.url = url;
       config.params = params;
       return this.request(config);
   }
   
   /**
    * download 请求
    * 请求类型为get
    * @param url       请求路径
    * @param params    请求参数数据
    * @param name      文件名
    */
   download(url: string, name: string, params?: {[key: string]: string}): void {
       if (params) {
           let pre: string = '';
           let [uri, param]: string[] = url.split("?");
           for (let key in params) {
               let item: string = key + "=" + params[key];
               pre += item + '&'
           }
           pre += param;
           window.open(uri + '?' + pre, name);
       } else {
           window.open(url, name);
       }
   }
   
   /**
    * post 请求
    * @param url       请求路径
    * @param data      请求参数数据
    * @param config    请求配置
    */
   post(url: string, data?: any, config?: AxiosRequestConfig): Promise<void | ApiResult<any>> {
       if (!config) {
           config = defaultRequestConfig();
       }
       config.method = "POST";
       config.url = url;
       config.data = data;
       return this.request(config);
   }
   
   /**
    * form表单格式的post请求
    * @param url       请求路径
    * @param data      请求参数数据
    * @param config    请求配置
    */
   postForm(url: string, data?: any, config?: AxiosRequestConfig): Promise<void | ApiResult<any>> {
       if (!config) {
           config = defaultRequestConfig();
       }
       config.headers = config.headers || new AxiosHeaders();
       config.headers['Content-Type'] = "application/x-www-form-urlencoded;charset=UTF-8";
       return this.post(url, data, config);
   }
   
   /**
    * json格式的post请求
    * @param url       请求路径
    * @param data      请求参数数据
    * @param config    请求配置
    */
   postJson(url: string, data?: any, config?: AxiosRequestConfig): Promise<void | ApiResult<any>> {
       if (!config) {
           config = defaultRequestConfig();
       }
       config.headers = config.headers || new AxiosHeaders();
       config.headers['Content-Type'] = "application/json;charset=UTF-8";
       return this.post(url, data, config);
   }
   
   /**
    * 文件格式的post请求
    * @param url       请求路径
    * @param data      请求参数数据
    * @param config    请求配置
    */
   postFile(url: string, data?: any, config?: AxiosRequestConfig): Promise<void | ApiResult<any>>  {
       if (!config) {
           config = defaultRequestConfig();
       }
       config.headers = config.headers || new AxiosHeaders();
       config.headers['Content-Type'] = "multipart/form-data;charset=UTF-8";
       return this.post(url, data, config);
   }
   
   /**
    * 文件格式的post请求
    * @param url       请求路径
    * @param data      请求参数数据
    * @param config    请求配置
    */
   put(url: string, data?: any, config?: AxiosRequestConfig): Promise<void | ApiResult<any>>  {
       if (!config) {
           config = defaultRequestConfig();
       }
       config.method = "put";
       config.url = url;
       config.data = data;
       config.headers = config.headers || new AxiosHeaders();
       config.headers['Content-Type'] = "multipart/form-data;charset=UTF-8";
       return this.request(config);
   }
   ```

   封装操作中最终要的封装就是`request`的封装, 当某个请求需要额外的请求拦截时, 可以创建一个新的实例完成, 保持原请求实例不变

   返回结果中的`ApiResult`是个人封装的请求结果

   ```typescript
   export interface ApiResult<T> {
       state: ApiStateEnum | number,
       message: string,
       data: T
   }
   ```

4. 默认的请求

   ```typescript
   /**
    * 默认请求配置
    */
   export function defaultRequestConfig(): AxiosRequestConfig {
       return {}
   }
   
   /**
    * 实例化一个请求
    */
   const request: Request = new Request(
       defaultRequestConfig()
   )
   
   /**
    * 返回一个实例化请求
    */
   export default request;
   ```

到目前, 项目的前端使用组件添加的差不多了, 在整理了项目的架子和布局之后, 前端暂停一段, 开始做服务端的登录认证等内容

<a href="pure-project-web.7z">前端项目</a>