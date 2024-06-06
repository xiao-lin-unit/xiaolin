---
title: Typescript系列(二)---高级
date: 2024-01-04 20:01:46
tags: Typescript
categories: Typescript
cover: 1
top: 2
---

<!-- toc -->

### 前言

前面介绍了`typescript`基本的数据类型和使用, 本篇介绍其高级类型和使用, 本篇结束后, 由于学习内容基本满足项目使用, 所以本系列将暂停一段时间, 着手去搞前端项目

### 交叉类型

交叉类型是将多个类型合并为一个类型

使用`&`符号将多个类型合并, 合并之后表示这个类型的对象同时拥有多种类型的成员

```typescript
function extend<T, U>(first: T, second: U): T & U {
    let result = <T & U>{};
    for (let id in first) {
        (<any>result)[id] = (<any>first)[id];
    }
    for (let id in second) {
        if (!result.hasOwnProperty(id)) {
            (<any>result)[id] = (<any>second)[id];
        }
    }
    return result;
}

class Person {
    constructor(public name: string) { }
}
interface Loggable {
    log(): void;
}
class ConsoleLogger implements Loggable {
    log() {
        // ...
    }
}
var jim = extend(new Person("Jim"), new ConsoleLogger());
var n = jim.name;
jim.log();
```

### 联合类型

联合类型是将多个类型联合起来, 表示一个值可以是联合的多种类型中的一种类型的实例

使用`|`符号将多个类型联合, 如果一个值时联合类型, 则只能访问此联合类型的多有类型里的共有成员

```typescript
interface Bird {
    fly();
    layEggs();
}

interface Fish {
    swim();
    layEggs();
}

function getSmallPet(): Fish | Bird {
    // ...
}

let pet = getSmallPet();
pet.layEggs(); // okay
pet.swim();    // errors
```

### 类型保护与区分类型

#### 类型保护

当想要确切的知道某个实例时何种类型时, 通常是通过检查成员是否存在进行区分

基于以上, 可以使用类型断言来实现

```typescript
let pet = getSmallPet();

if ((<Fish>pet).swim) {
    (<Fish>pet).swim();
}
else {
    (<Bird>pet).fly();
}
```

#### 自定义类型保护

要定义一个类型保护, 只要定义一个函数, 它的返回值是一个*类型谓词*

```typescript
function isFish(pet: Fish | Bird): pet is Fish {
    return (<Fish>pet).swim !== undefined;
}
```

如上, `pet is Fish`就是类型谓词, 形式为: `paramName is Type`, `paramName`必须是来自于当前函数签名的一个参数名, `Type`是某个联合类型的一种类型

每当使用一些变量调用类型谓词的函数时, 就会将变量缩减为那个具体的类型, 只要这个类型与变量的原始类型兼容

```typescript
// 'swim' 和 'fly' 调用都没有问题了

if (isFish(pet)) {
    pet.swim();
}
else {
    pet.fly();
}
```

上面的例子中, `typescript`不仅知道`if`分支里`pet`是`Fish`类型, 还知道在`else`里一定不是`Fish`类型

#### `typeof`类型保护

`typescript`可以将`typeof x === 'number'`这样的表达式识别为一个类型保护, 即是说可以直接在代码里检查类型

```typescript
function padLeft(value: string, padding: string | number) {
    if (typeof padding === "number") {
        return Array(padding + 1).join(" ") + value;
    }
    if (typeof padding === "string") {
        return padding + value;
    }
    throw new Error(`Expected string or number, got '${padding}'.`);
}
```

需要注意的是, 这些`typeof`类型保护只有两种形式能别识别:

`typeof v === 'typename'`和`typeof v !=== 'typename'`; `typename`必须是`number`, `string`, `boolean`, `symbol`; 当`typename`为其它类型时, `typescript`不会阻止与其比较, 但不会将其识别为类型保护

#### `instanceof`类型保护

`instanceof`类型保护是通过构造函数来细化类型的一种方式

`instanceof`的左侧要求是一个实例, 右侧要求是一个构造函数, 注意右侧要求是一个构造函数, 所以`instanceof`只能判断是否是某个类的类型, 不能判断是否是某个接口类型, 因为接口没有构造函数

> `typescript`在进行`instanceof`判断时会细化构造函数为:
>
> - 此构造函数的`prototype`属性的类型, 如果它的类型不为`any`的话
> - 构造签名所返回的类型的联合

#### `null`和`undefined`

由于`null`和`undefined`是所有类型的有效值, 所以无法阻止其赋值给其他类型的变量

`--strictNullChecks`标记可以解决: 当声明一个变量时, 不会自动包含`null`和`undefined`, 但可以使用联合类型包含它们, 以此来讲`null`和`undefined`区别对待

> `null`和`undefined`的类型保护:
>
> 1. 可以直接使用`==`判断, 或者使用逻辑运算判断
> 2. 可以使用类型断言手动去除, 语法是变量后添加`!`后缀

### 类型别名

#### 基本使用

类型别名会给一个类型起一个新名字, 此类型可以是原始值, 联合类型, 元组以及自定义类型等

```typescript
type Name = string;
type NameResolver = () => string;
type NameOrResolver = Name | NameResolver;
function getName(n: NameOrResolver): Name {
    if (typeof n === 'string') {
        return n;
    }
    else {
        return n();
    }
}
```

类型别名不会新建一个类型, 只是创建了一个新名字来引用那个类型

类型别名也可以使用泛型

```typescript
type Tree<T> = {
    value: T;
    left: Tree<T>;
    right: Tree<T>;
}
```

类型别名不能出现在声明右侧的任何地方

```typescript
type Yikes = Array<Yikes>; // error
```

> 接口与类型别名的区别:
>
> 1. 接口创建一个新名字, 类型别名并不创建新名字
> 2. 接口可以被继承实现, 类型别名不可以
> 3. 如果无法通过接口来描述一个类型, 并且需要使用联合类型或元组类型, 通常会使用类型别名

#### 特殊使用

字符串字面量类型允许指定字符串必须得固定值. 字符串字面量类型可以与联合类型, 类型保护和类型别名配合

```typescript
type Easing = "ease-in" | "ease-out" | "ease-in-out";
```

当使用上述类型别名作为参数或属性的类型时, 则值必须是允许的三个字符串之一, 否则会产生错误

同字符串字面量类型一样, 数字字面量类型和枚举成员类型也可以如此使用. 这是因为类型别名本身可以用作类型定义, 而字面量类型方式不过是将字面量值本身定义为了一种自定义类型

### 可辨识联合

#### 基本使用

合并单例类型, 联合类型, 类型保护和类型别名来创建可辨识联合的高级模式, 也称作标签联合或代数数据类型

> 三要素:
>
> 1. 具有普通的单例类型属性-可辨识的特征
> 2. 一个类型别名包含了那些类型的联合-联合
> 3. 此属性上的类型保护

```typescript
// 要联合的接口, kind作为可辨识特征
interface Square {
    kind: "square";
    size: number;
}
interface Rectangle {
    kind: "rectangle";
    width: number;
    height: number;
}
interface Circle {
    kind: "circle";
    radius: number;
}
// 联合
type Shape = Square | Rectangle | Circle;
// 可辨识联合
function area(s: Shape) {
    switch (s.kind) {
        case "square": return s.size * s.size;
        case "rectangle": return s.height * s.width;
        case "circle": return Math.PI * s.radius ** 2;
    }
}
```

上述中首先声明了要联合的接口, 每个接口都有`kind`属性但有不同的字符串字面量类型. `kind`属性称作*可辨识的特征*或标签. 其他属性则特定于各个接口

#### 完整性检查

当没有涵盖所有可辨识联合的变化时, 希望编译器可以通知

1. 启用`--strictNullChecks`并指定一个返回值类型

   ```typescript
   function area(s: Shape): number { // error: returns number | undefined
       switch (s.kind) {
           case "square": return s.size * s.size;
           case "rectangle": return s.height * s.width;
           case "circle": return Math.PI * s.radius ** 2;
       }
   }
   ```

2. 使用`never`类型, 编译器用它进行完整性检查

   ```typescript
   function assertNever(x: never): never {
       throw new Error("Unexpected object: " + x);
   }
   function area(s: Shape) {
       switch (s.kind) {
           case "square": return s.size * s.size;
           case "rectangle": return s.height * s.width;
           case "circle": return Math.PI * s.radius ** 2;
           default: return assertNever(s); // error here if there are missing cases
       }
   }
   ```

### 多态的`this`类型

多态的`this`类型表示的是某个包含类或接口的子类型, 这杯称作`F-bounded`多态性. 它很容易的表现连贯接口间的继承

在使用表现上即是在函数定义中, 最终将当前实例(`this`)返回, 并将函数的返回值类型定义为`this`(称为`this`类型)

```typescript
class BasicCalculator {
    public constructor(protected value: number = 0) { }
    public currentValue(): number {
        return this.value;
    }
    public add(operand: number): this {
        this.value += operand;
        return this;
    }
    public multiply(operand: number): this {
        this.value *= operand;
        return this;
    }
    // ... other operations go here ...
}

let v = new BasicCalculator(2)
            .multiply(5)
            .add(1)
            .currentValue();
```

由于这个类使用了`this`类型，你可以继承它，新的类可以直接使用之前的方法，不需要做任何的改变。

```typescript
class ScientificCalculator extends BasicCalculator {
    public constructor(value = 0) {
        super(value);
    }
    public sin() {
        this.value = Math.sin(this.value);
        return this;
    }
    // ... other operations go here ...
}

let v = new ScientificCalculator(2)
        .multiply(5)
        .sin()
        .add(1)
        .currentValue();
```

需要注意的是, 与`java`不同, 在实例调用返回`this`类型的函数时, 其结果是`this`表示的实例类型, 即实例为哪种类型, 则`this`类型即为哪种类型

### 索引类型

使用索引类型, 编译器就能够检查使用了动态属性名的代码

通过*索引类型查询操作符*和*索引访问操作符*:

```typescript
function pluck<T, K extends keyof T>(o: T, names: K[]): T[K][] {
  return names.map(n => o[n]);
}

interface Person {
    name: string;
    age: number;
}
let person: Person = {
    name: 'Jarid',
    age: 35
};
let strings: string[] = pluck(person, ['name']); // ok, string[]
```

编译器会检查`name`是否真的是`Person`的一个属性

`keyof T`，**索引类型查询操作符**. 对于任何类型`T`，`keyof T`的结果为`T`上已知的公共属性名的联合

`T[K]`，**索引访问操作符**. 类型语法反应表达式语法, 类似与一种泛型, 但在获取到实际值时, 返回实际值的真实类型

### 映射类型

从旧类型中创建新类型的一种方式-映射类型. 新类型以相同的形式去转换旧类型里的每个属性

```typescript
type Readonly<T> = {
    readonly [P in keyof T]: T[P];
}
type Partial<T> = {
    [P in keyof T]?: T[P];
}

type PersonPartial = Partial<Person>;
type ReadonlyPerson = Readonly<Person>;
```

通用版本

```typescript
type Nullable<T> = { [P in keyof T]: T[P] | null }
type Partial<T> = { [P in keyof T]?: T[P] }
```

有代理

```typescript
type Proxy<T> = {
    get(): T;
    set(value: T): void;
}
type Proxify<T> = {
    [P in keyof T]: Proxy<T[P]>;
}
function proxify<T>(o: T): Proxify<T> {
   // ... wrap proxies ...
}
let proxyProps = proxify(props);
```

`ts`标准库

```typescript
type Pick<T, K extends keyof T> = {
    [P in K]: T[P];
}
type Record<K extends string, T> = {
    [P in K]: T;
}
```

由映射类型进行推断

拆包

```typescript
function unproxify<T>(t: Proxify<T>): T {
    let result = {} as T;
    for (const k in t) {
        result[k] = t[k].get();
    }
    return result;
}
```



















