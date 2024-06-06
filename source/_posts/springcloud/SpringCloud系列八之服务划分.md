---
title: SpringCloud系列(八)---服务划分
date: 2024-02-19 15:40:06
tags:
- 其他
categories:
- SpringCloud
top: 8
cover: 0
---

<!-- toc -->

### 前言

前面我们将安全认证框架`SpringSecurity`添加为一个服务, 当我们添加认证服务后, 便实现的登录效果, 但是在资源服务中会有一下问题:

1. 资源服务无法获取到用户信息, 因为是在不同的服务应用中, 用户信息不能跨应用传递
2. 当用户已经退出登录, 或者登录失效后, 访问资源服务依然可以正常返回

上述问题是因为在资源服务中没有获取用户信息, 更没有进行用户信息的验证, 所以认证权限等的内容全是纸老虎, 没有起到任何作用

基于以上问题, 需要将`SpringSecurity`添加到资源服务中, `SpringSecurity`框架在资源服务中需要的内容主要有三个: 一. 获取用户信息; 二. 验证是否登录; 三. 验证用户权限

### 处理

上述的三项内容我们在前文中已经进行了处理, 只要将需要的内容拿来即可.

1. 用户信息: `securityContextRepository`配置会话上下文存储, ==一定要实现用户信息在不同应用服务之间的可访问性, 即`session`共享==
2. 验证是否登录结果处理: `exceptionHandling`配置未登录或者登录失效的处理
3. 验证用户权限: `AuthorizationFilter`处理

我们有多个资源服务, 每个资源服务都需要添加这个验证规则, 如果为每一个资源服务都添加一套验证使用的代码显然是不合理的, 所以我们将验证的代码添加到公共模块中, 然后区分认证服务和资源服务进行不同的配置即可

第一个目标要明确资源服务和认证服务各需要哪些内容

一: 资源服务:

1. 获取用户信息: 配置会话上下文存储
2. 是否登录的结果处理: 配置未登录或登录失效的处理
3. 验证用户权限: 开启权限验证过滤器
4. 路径匹配: 添加路径匹配规则, 每个资源服务都只处理自己匹配的路径, 其他路径不处理

二: 认证服务: 

1. 登录: 配置登录成功和失败处理
2. 注销: 配置注销处理和注销成功处理
3. 保存用户信息: 配置会话上下文存储
4. 是否登录的结果处理: 配置未登录和登录失效的处理
5. 路径匹配: 添加路径匹配规则, 只匹配登录路径和注销路径, 其他路径不处理

第二个目标我们需要明确何时开启`SpringSecurity`

当我们创建一个项目时, 我们是在该项目中添加`SpringSecurity`的, 只有将其标记为资源服务或者认证服务时, 我们才需要开启`SpringSecurity`, 比如我们要拆分出一个文件上传的服务, 该服务是不需要开启`SpringSecurity`的

### 实现

#### `Security`的开启与关闭

我们为了实现第二个目标, 我们需要默认将`SpringSecurity`的自动配置关闭, 然后在认证服务和资源服务两种类型的服务中开启

```java
// 默认关闭SpringSecurity服务
@Configuration
@EnableAutoConfiguration(exclude = {SecurityAutoConfiguration.class})
public class DefaultSecurityConfig {
}
```

```java
// 认证服务和资源服务开启SpringSecurity
@EnableWebSecurity
public abstract class ApplicationSecurityConfig { 
}
```

#### 资源服务和认证服务的区分配置

为了实现第二个目标, 我们需要开启`SpringSecurity`, 并且需要进行不同的配置, 资源服务之间的配置相似

首先, 所有服务的相似配置可以同时添加

```java
@Getter
@Setter
@EnableWebSecurity
public abstract class ApplicationSecurityConfig {

    public ApplicationSecurityConfig(
            ServerProperties serverProperties, AuthenticationSaveHandler authenticationSaveHandler,
            CustomerAuthenticationHandler customerAuthenticationHandler) {
        this.serverProperties = serverProperties;
        this.authenticationSaveHandler = authenticationSaveHandler;
        this.customerAuthenticationHandler = customerAuthenticationHandler;
    }

    public static final String SECURITY_FILTER_CHAIN_BEAN = "securityFilterChain";

    protected ServerProperties serverProperties;

    protected AuthenticationSaveHandler authenticationSaveHandler;

    protected CustomerAuthenticationHandler customerAuthenticationHandler;

    @Bean(name = SECURITY_FILTER_CHAIN_BEAN)
    public abstract SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception;

}
```

这个类做了以下几件事:

1. 开启`SpringSecurity`
2. 定义了一个类型为`SecurityFilterChain`, 名为`securityFilterChain`的`bean`, 但是没有实现
3. 定义并要求添加服务源配置, 会话上下文处理器, 未登录或登录失效后的处理器

其次我们要实现资源服务和认证服务的不同配置

我们分别实现上面的配置类, 分别添加不同的配置

认证服务配置

```java
public class AuthenticationApplicationSecurityConfig extends ApplicationSecurityConfig {

    private final UserLogoutHandler userLogoutHandler;

    private final UserLogoutSuccessHandler userLogoutSuccessHandler;

    private final LoginSuccessHandler loginSuccessHandler;

    private final LoginFailureHandler loginFailureHandler;

    public AuthenticationApplicationSecurityConfig(ServerProperties serverProperties,
                                                   AuthenticationSaveHandler authenticationSaveHandler,
                                                   UserLogoutHandler userLogoutHandler,
                                                   UserLogoutSuccessHandler userLogoutSuccessHandler,
                                                   LoginSuccessHandler loginSuccessHandler,
                                                   LoginFailureHandler loginFailureHandler,
                                                   CustomerAuthenticationHandler customerAuthenticationHandler) {
        super(serverProperties, authenticationSaveHandler, customerAuthenticationHandler);
        this.loginSuccessHandler = loginSuccessHandler;
        this.loginFailureHandler = loginFailureHandler;
        this.userLogoutHandler = userLogoutHandler;
        this.userLogoutSuccessHandler = userLogoutSuccessHandler;
    }

    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable);
        http.securityMatcher("/login", "/logout");
        http.formLogin((config) ->
                        config
                                .usernameParameter("username")
                                .passwordParameter("password")
                                .loginProcessingUrl("/login")
                                .failureHandler(loginFailureHandler)
                                .successHandler(loginSuccessHandler)
        );
        http.logout(
                (config) -> config
                        .logoutUrl("/logout")
                        .addLogoutHandler(userLogoutHandler)
                        .logoutSuccessHandler(userLogoutSuccessHandler)
        );
        http.exceptionHandling(config ->
                config.authenticationEntryPoint(customerAuthenticationHandler)
        );
        http.securityContext(config ->
             	config.securityContextRepository(authenticationSaveHandler)
        );

        return http.build();
    }

}
```

认证服务配置中我们做了`SecurityFilterChain`的实现, 配置了公共配置之外登录和注销操作, 以及路径匹配规则

资源服务配置

```java
public class ResourceApplicationSecurityConfig extends ApplicationSecurityConfig {

    public ResourceApplicationSecurityConfig(ServerProperties serverProperties, AuthenticationSaveHandler authenticationSaveHandler, CustomerAuthenticationHandler customerAuthenticationHandler) {
        super(serverProperties, authenticationSaveHandler, customerAuthenticationHandler);
    }

    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        String contextPath = serverProperties.getServlet().getContextPath();
        if (StringUtils.isBlank(contextPath)) {
            contextPath = "/**";
        } else {
            contextPath = (!contextPath.startsWith("/") ? "/" : "") + contextPath + "/**";
        }
        final String path = contextPath;
        http.csrf(AbstractHttpConfigurer::disable);

        http.securityMatcher(path);
        http.authorizeHttpRequests(
                (auth) -> auth
                        .requestMatchers(HttpMethod.OPTIONS)
                        .permitAll()
                        .anyRequest()
                        .authenticated()
        );
        http.exceptionHandling(config ->
                config.authenticationEntryPoint(customerAuthenticationHandler)
        );
        http.securityContext(config ->
                config.securityContextRepository(authenticationSaveHandler)
        );
        return http.build();
    }

}
```

资源服务配置中我们添加了除了公共配置外的路径匹配规则, 权限验证规则

==在公共配置文件中我们并没有进行`SecurityFilterChain`的`bean`配置, 只是在该类中要求必须添加公共配置需要的内容, 具体配置应当在具体配置中添加==

#### 资源服务和认证服务的区分导入

上面我们完成了资源服务和认证服务的区分配置, 但是我们并没有添加`@Configuration`注解使用

现在我们通过不同的注解, 将服务划分为资源服务和认证服务, 然后区别引入配置

认证服务注解

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import({AuthenticationApplicationSecurityConfig.class})
public @interface AuthenticationApplication {
}
```

认证服务注解的作用是通过`Import`的方式导入认证服务配置

资源服务注解

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import({ResourceApplicationSecurityConfig.class})
public @interface ResourceApplication {
}
```

资源服务注解的作用是通过`Import`的方式导入资源服务配置

认证服务的启动类

```java
@AuthenticationApplication
@SpringBootApplication
public class SecurityApplication {
    public static void main(String[] args) {
		SpringApplication.run(SecurityApplication.class, args);
    }
}
```

资源服务的启动类

```java
@ResourceApplication
@SpringBootApplication
public class DictServiceApplication {
    public static void main(String[] args) {
		SpringApplication.run(DictServiceApplication.class, args);
    }
}
```

#### 实现描述

我们通过`@ResourceApplication`和`@AuthenticationApplication`分别导入资源配置类`ResourceApplicationSecurityConfig`和认证配置类`AuthenticationApplicationSecurityConfig`, 在资源配置类和认证配置类中进行不同的配置, 实现服务的不同应用

如果不太理解, 可以了解一下`@Import`注解的作用和使用: https://juejin.cn/post/7217994625343635514

#### `Bean`注册优化

到上述阶段, 我们只需要将配置过程中需要的`bean`注册到容器中即可实现正常运行, 但是普通的`bean`注册不会区分服务类型, 直接将其注册为`bean`, 为了优雅些, 我们粗略实现下只有认证服务和资源服务时才注册所需的`bean`的功能

方案一: 理解比较复杂

```java
@Configuration
@Conditional(SecurityBeans.SecurityBeansCondition.class)
public class SecurityBeans {

    @Autowired
    private RedisUtil redisUtil;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    @Bean
    public AuthenticationSaveHandler authenticationSaveHandler() {
        return new RedisAuthenticationSaveHandler(redisUtil);
    }

    @Bean
    public UserLogoutHandler userLogoutHandler() {
        return new UserLogoutHandler(authenticationSaveHandler());
    }

    @Bean
    public UserLogoutSuccessHandler userLogoutSuccessHandler() {
        return new UserLogoutSuccessHandler();
    }

    @Bean
    public LoginSuccessHandler loginSuccessHandler() {
        return new LoginSuccessHandler();
    }

    @Bean
    public LoginFailureHandler loginFailureHandler() {
        return new LoginFailureHandler();
    }

    @Bean
    public CustomerAuthenticationHandler customerAuthenticationHandler() {
        return new CustomerAuthenticationHandler();
    }

    public static class SecurityBeansCondition extends AnyNestedCondition {

        public SecurityBeansCondition() {
            super(ConfigurationPhase.REGISTER_BEAN);
        }

        @ConditionalOnBean(annotation = ResourceApplication.class)
        static class OnResourceApplication {
        }

        @ConditionalOnBean(annotation = AuthenticationApplication.class)
        static class OnAuthenticationApplication {
        }

    }

}
```

我们创建一个类, 在其中进行`bean`注册, 并将该类使用`@Configuration`和
`@Conditional`修饰, 表示满足条件时, 注册该配置类, 这样类中配置的`bean`也会注册到容器中, 不满足时则不会注册该配置类, 类中的`bean`也不会注册

创建一个"或"条件加载类, 条件是容器中有`bean`被`@ResourceApplication`或者被`@AuthenticationApplication`修饰时, 执行`bean`注册

```java
public static class SecurityBeansCondition extends AnyNestedCondition {

    public SecurityBeansCondition() {
        super(ConfigurationPhase.REGISTER_BEAN);
    }

    @ConditionalOnBean(annotation = ResourceApplication.class)
    static class OnResourceApplication {
    }

    @ConditionalOnBean(annotation = AuthenticationApplication.class)
    static class OnAuthenticationApplication {
    }

}
```

此处使用的是静态内部类的方式, 这样在一个类中比较方便

简述:

在`SecurityBeansCondition`中实现两种注解的"或"操作, 这样在`SecurityBeans`加载时, 如果满足则进行注册处理

https://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/autoconfigure/condition/AnyNestedCondition.html

https://www.cnblogs.com/hellxz/p/16253857.html

方案二: 

```java
public class SecurityBeans {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    @Bean
    public AuthenticationSaveHandler authenticationSaveHandler(RedisUtil redisUtil) {
        return new RedisAuthenticationSaveHandler(redisUtil);
    }

    @Bean
    public UserLogoutHandler userLogoutHandler(AuthenticationSaveHandler authenticationSaveHandler) {
        return new UserLogoutHandler(authenticationSaveHandler);
    }

    @Bean
    public UserLogoutSuccessHandler userLogoutSuccessHandler() {
        return new UserLogoutSuccessHandler();
    }

    @Bean
    public LoginSuccessHandler loginSuccessHandler() {
        return new LoginSuccessHandler();
    }

    @Bean
    public LoginFailureHandler loginFailureHandler() {
        return new LoginFailureHandler();
    }

    @Bean
    public CustomerAuthenticationHandler customerAuthenticationHandler() {
        return new CustomerAuthenticationHandler();
    }

}
```

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import({AuthenticationApplicationSecurityConfig.class, SecurityBeans.class})
public @interface AuthenticationApplication {
}
```

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import({ResourceApplicationSecurityConfig.class, SecurityBeans.class})
public @interface ResourceApplication {
}
```

应用`@Import`的导入原理

























