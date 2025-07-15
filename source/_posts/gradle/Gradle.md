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

