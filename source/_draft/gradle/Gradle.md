一.`Gradle`构建生命周期

1. 初始化阶段
   - 检测`settings.gradle`文件
   - 创建一个`Settings`实例
   - 评估设置文件以确定那些项目（和包含的构建）构成构建
   - 为每个项目创建一个`Project`实例
2. 配置阶段
   - 评估参与构建的每个项目的构建脚本`build.gradle`
   - 为请求的任务创建任务图
3. 执行阶段
   - 调度并执行选定的任务
   - 任务之间的依赖项决定执行顺序
   - 任务的执行可以并行执行

> 1. `settings.gradle`中的配置在初始化阶段使用
>
> 2. `build.gradle`中的配置在配置阶段使用
>
>    - 公共配置
>
>      ```groovy
>      repositories {
>          mavenCentral()
>      }
>      println '配置阶段执行'
>      ```
>
>    - 任务注册配置
>
>      ```groovy
>      task('myTask') {
>          println '配置阶段执行'
>          doFirest {
>              println '执行阶段执行'
>          }
>          doLast {
>              println '执行阶段执行'
>          }
>      }
>      ```
>
>    - `tasks.register`注册一个名为`myTask`的任务，这个任务在配置阶段就已经注册配置，但是直到执行阶段才会执行相关操作。执行操作通过`doFirst`和`doLast`添加

二.`settings.gradle`

1. `settings.gradle`是每个`Gradle`构建的入口，初始化阶段会在项目根目录中找到`settings.gradle`文件，并根据内容实例化一个`Settings`对象。由此，`settings.gradle`文件中可以做那些配置可以直接通过`Settings`类获得

2. 常用属性

   - `pluginManagement`: 定义插件位置

     > 管理构建的插件版本和仓库，提供了一种方式来定义项目应使用那些插件以及应从那些仓库解析它们。
     >
     > ```groovy
     > pluginManagement {  
     >     repositories {
     >         gradlePluginPortal()
     >     }
     > }
     > ```

   - `plugins`: 应用`settings`插件

     > 选择性的应用插件，这些插件对于配置项目的`settings`是必需品。
     >
     > ```groovy
     > plugins {   
     >     id("org.gradle.toolchains.foojay-resolver-convention") version "0.10.0"
     > }
     > ```

   - `rootProject.name`: 定义跟项目名称

     > ```groovy
     > rootProject.name = 'simple-project'     
     > ```

   - `dependencyResolutionManagement`: 定义依赖解析策略

     > 可以选择性的为项目定义依赖解析的规则和配置。提供了集中管理和自定义依赖解析的方式
     >
     > ```groovy
     > dependencyResolutionManagement {    
     >     repositories {
     >         mavenCentral()
     >     }
     > }
     > ```

   - `include`: 将子项目添加到构建中

     > ```groovy
     > include("sub-project-a")    
     > include("sub-project-b")
     > include("sub-project-c")
     > ```
     >
     > 如果是多级项目，通过`:`进行区分
     >
     > ```groovy
     > include("sub-project-a")
     > // sub-project-a项目下的level-three-a项目
     > include(":sub-project-a:level-three-a") 
     > ```
     >
     > 更优的可以使用迭代项目跟文件夹中的目录列表并自动包含
     >
     > ```groovy
     > def names(File file, String pN) {
     >     List ns = []
     >     Arrays.stream(file.listFiles()).filter { it.isDirectory() && it.name != "buildSrc" && (new File(it, "build.gradle").exists())}.forEach {
     >         String name = "${pN}:${it.name}"
     >         ns.add(name)
     >         ns.addAll(names(it, name))
     >     }
     >     return ns;
     > }
     > 
     > names(rootDir, '').forEach {
     >     include(it)
     > }
     > ```

三. `build.gradle`

1. `Gradel`为`settings.gradle`文件中包含的项目根项目和子项目创建一个`Project`实例，根据相应项目的`build.gradel`文件进行配置，`build.gradel`在配置阶段使用。由此，`build.gradle`文件中可以做那些配置可以直接通过`Project`类获得

2. 常用属性

   - `plugins`: 应用插件到构建

     > 用户扩展`Gradle`，也用于模块化和重用项目配置
     >
     > ```groovy
     > plugins {   
     >     id 'application' // application插件
     >     id 'groovy' // groovy插件
     > }
     > ```

   - `repositories`: 定义可以找到依赖的位置

     > 定义查找依赖项的二进制文件，可以提供多个位置，`maven`中定义仓库源的地方
     >
     > ```groovy
     > repositories {  
     >     mavenCentral() // 从中心仓库
     > }
     > ```

   - `dependencies`: 添加依赖

     > 添加项目使用的依赖项
     >
     > ```groovy
     > dependencies {  
     >     testImplementation 'org.junit.jupiter:junit-jupiter-engine:5.9.3'	// 测试时引入依赖
     >     testRuntimeOnly 'org.junit.platform:junit-platform-launcher'	// 仅测试运行时有依赖
     >     implementation 'com.google.guava:guava:32.1.1-jre'	// 引入外部依赖
     > }
     > ```
     >
     > 

   - `application`: 设置属性

     > 插件可以使用扩展向项目添加属性和方法。`Project`对象有一个关联的 `ExtensionContainer`对象，其中包含已应用于项目的所有插件的设置和属性。`build.gradle`可以对这些属性进行设置和修改
     >
     > ```groovy
     > plugins {   
     >     id 'application' // application插件
     >     id 'groovy' // groovy插件
     > }
     > // 对application插件进行属性修改
     > application {   
     >     mainClass = 'com.example.Main'
     > }
     > ```

   - `tasks.named()`、`tasks.register()`、`task()`: 注册和配置任务

     > 任务执行一些基本工作，例如编译类、运行单元测试或压缩 WAR 文件。
     >
     > 任务通常在插件中定义，也可以在构建脚本中注册或配置任务。
     >
     > ```groovy
     > // 注册任务
     > tasks.register('name') {
     >     
     > }
     > // 配置已有的任务
     > tasks.named('test', Test) { 
     >     useJUnitPlatform()
     > }
     > ```
     >
     > 

四. 依赖管理

软件项目通常依赖于其他库才能正常工作，`gradle`在`build.gradle`文件通过`dependencies`声明项目引入的依赖。它允许指定各种类型的依赖，如外部库，本地`JAR`或多项目构建中的其他项目

1. 依赖类型

   - 模块依赖：指代仓库中的一个模块

     > ```groovy
     > dependencies {
     >     implementation 'org.codehaus.groovy:groovy:3.0.5'
     >     implementation 'org.codehaus.groovy:groovy-json:3.0.5'
     >     implementation 'org.codehaus.groovy:groovy-nio:3.0.5'
     > }
     > ```

   - 项目依赖：允许生命贵同一构建中的其他项目的依赖

     > ```groovy
     > dependencies {
     >     implementation project(':utils')
     >     implementation project(':api')
     > }
     > ```

   - 文件依赖：托管在共享驱动器上或者与项目源代码一起检入版本控制系统大的文件

     > ```groovy
     > dependencies {
     >     runtimeOnly files('libs/a.jar', 'libs/b.jar')
     >     runtimeOnly fileTree('libs') { include '*.jar' }
     > }
     > ```

2. 依赖配置

   - `api`:编译和运行时都需要，并包含在发布的`API`中

   - `implementation`:编译和运行时都需要

   - `compileOnly`:仅编译时需要

   - `compileOnlyApi`:仅编译时需要，但包含在发布的`API`中

   - `runtimeOnly`:仅运行时需要，不包含在编译类滤镜中

   - `testImplementation`:编译和运行测试选哟

   - `testCompileOnly`:仅测试编译需要

   - `testRuntimeOnly`:仅运行测试需要

   - `customConfig`:自定义配置

     > ```groovy
     > configurations {
     >     customConfig
     > }
     > 
     > dependencies {
     >     customConfig("org.example:example-lib:1.0")
     > }
     > ```

   - 其它类型配置: 不用于声明依赖项

3. 声明仓库

   通过`build.gradle`中的`repositories`块来为依赖台添加任意数量的仓库

   ```groovy
   repositories {
       mavenCentral()  // 公共仓库
       maven {         
           url = uri("https://company/com/maven2")	// 自定义仓库
       }
       maven {
           url = 'https://your.secure.repo/url'	// 自定义仓库
           credentials {							// 验证方式
               username = 'your-username'
               password = 'your-password'
           }
       }
       mavenLocal()    // 本地仓库
       flatDir {       
           dirs "libs" // 文件位置
       }
   }
   ```

4. 使用平台

   > ```groovy
   > // platform/build.gradle
   > plugins {
   >     id("java-platform")
   > }
   > 
   > dependencies {
   >     constraints { // 用户解决依赖冲突时选择依赖项的特定版本
   >         api("org.apache.commons:commons-lang3:3.12.0")
   >         api("com.google.guava:guava:30.1.1-jre")
   >         api("org.slf4j:slf4j-api:1.7.30")
   >     }
   > }
   > 
   > // app/build.gradle
   > plugins {
   >     id("java-library")
   > }
   > 
   > dependencies {
   >     implementation(platform(":platform"))
   >     implementation platform('org.springframework.boot:spring-boot-dependencies:1.5.8.RELEASE')
   > }
   > ```
   >
   > 

5. 集中依赖管理

   > ```toml
   > // gradle/libs.versions.toml
   > 
   > [versions]
   > groovy = "3.0.5"
   > checkstyle = "8.37"
   > 
   > [libraries]
   > groovy-core = { module = "org.codehaus.groovy:groovy", version.ref = "groovy" }
   > groovy-json = { module = "org.codehaus.groovy:groovy-json", version.ref = "groovy" }
   > groovy-nio = { module = "org.codehaus.groovy:groovy-nio", version.ref = "groovy" }
   > commons-lang3 = { group = "org.apache.commons", name = "commons-lang3", version = { strictly = "[3.8, 4.0[", prefer="3.9" } }
   > 
   > [bundles]
   > groovy = ["groovy-core", "groovy-json", "groovy-nio"]
   > 
   > [plugins]
   > versions = { id = "com.github.ben-manes.versions", version = "0.45.0" }
   > ```
   >
   > ```groovy
   > // build.gradle
   > plugins {
   >     id 'java-library'
   >     alias(libs.plugins.versions)
   > }
   > 
   > dependencies {
   >     api libs.groovy.core
   >     api libs.bundles.groovy
   > }
   > ```
   >
   > 