+++
title = '重新学习JAVA(一)'
date = 2024-05-28T10:37:29Z
draft = true
+++

本文记录重拾 JAVA 过程的一些知识点。

## 仪式感要有，你好，世界。
```java
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello world!");
    }
}
```

## 基础数据类型
```java
public class DataTypesExampleAndRange {
    public static void main(String[] args) {
        // 声明并初始化基础数据类型的变量
        int intVar = 100;
        short shortVar = 200;
        long longVar = 300L;
        byte byteVar = 40;
        float floatVar = 5.5f;
        double doubleVar = 6.6;
        char charVar = 'C';
        boolean boolVar = false;

        // 输出变量值
        System.out.println("intVar: " + intVar);
        System.out.println("shortVar: " + shortVar);
        System.out.println("longVar: " + longVar);
        System.out.println("byteVar: " + byteVar);
        System.out.println("floatVar: " + floatVar);
        System.out.println("doubleVar: " + doubleVar);
        System.out.println("charVar: " + charVar);
        System.out.println("boolVar: " + boolVar);

        // 打印基础数据类型的位数和范围
        System.out.println("\n数据类型位数和范围:");
        System.out.println("int: 32位, 最小值: " + Integer.MIN_VALUE + ", 最大值: " + Integer.MAX_VALUE);
        System.out.println("short: 16位, 最小值: " + Short.MIN_VALUE + ", 最大值: " + Short.MAX_VALUE);
        System.out.println("long: 64位, 最小值: " + Long.MIN_VALUE + ", 最大值: " + Long.MAX_VALUE);
        System.out.println("byte: 8位, 最小值: " + Byte.MIN_VALUE + ", 最大值: " + Byte.MAX_VALUE);
        System.out.println("float: 32位, 最小值: " + Float.MIN_VALUE + ", 最大值: " + Float.MAX_VALUE);
        System.out.println("double: 64位, 最小值: " + Double.MIN_VALUE + ", 最大值: " + Double.MAX_VALUE);
        System.out.println("char: 16位, Unicode字符集");
        System.out.println("boolean: 位数不定, 值: true 或 false");
    }
}

```
输出结果：
```java
intVar: 100
shortVar: 200
longVar: 300
byteVar: 40
floatVar: 5.5
doubleVar: 6.6
charVar: C
boolVar: false

数据类型位数和范围:
int: 32位, 最小值: -2147483648, 最大值: 2147483647
short: 16位, 最小值: -32768, 最大值: 32767
long: 64位, 最小值: -9223372036854775808, 最大值: 9223372036854775807
byte: 8位, 最小值: -128, 最大值: 127
float: 32位, 最小值: 1.4E-45, 最大值: 3.4028235E38
double: 64位, 最小值: 4.9E-324, 最大值: 1.7976931348623157E308
char: 16位, Unicode字符集
boolean: 位数不定, 值: true 或 false

```
## 基本算术运算

```java
public class Calc {
    public static void main(String[] args) {
        double a = 5.0;
        double b = 3.0;

        double sum = a + b; // 加法
        double difference = a - b; // 减法
        double product = a * b; // 乘法
        double quotient = a / b; // 除法

        System.out.println("Sum: " + sum);
        System.out.println("Difference: " + difference);
        System.out.println("Product: " + product);
        System.out.println("Quotient: " + quotient);
    }
}

```
结果：
```java
Sum: 8.0
Difference: 2.0
Product: 15.0
Quotient: 1.6666666666666667

```

### 浮点数
由于浮点数的精度问题，直接使用 == 运算符比较两个浮点数是否相等可能会导致意外的结果。

通常建议使用一个小的误差范围来比较两个浮点数是否足够接近。

```java
double value1 = 1.0 / 3.0;
double value2 = 0.333333333;

boolean areEqual = Math.abs(value1 - value2) < 0.00001; // 使用误差范围比较

```
**注意事项**
* 浮点数运算可能会有舍入误差，因为计算机使用二进制浮点数近似表示十进制小数。
* 在进行浮点数运算时，要注意数值的溢出和下溢问题。
* 在比较浮点数时，应考虑使用误差范围而不是直接相等比较


## 数组

原始类型数组的声明和使用如下：
```java
int[] intArray; // 声明一个整型数组
intArray = new int[10]; // 创建一个长度为10的整型数组，默认初始化为0

double[] doubleArray = new double[5]; // 创建一个长度为5的双精度浮点型数组，默认初始化为0.0

char[] charArray = {'a', 'b', 'c', 'd'}; // 创建并初始化一个字符型数组

```

对象数组:
```java
// 创建一个对象数组，存储自定义类的对象
MyClass[] myObjectArray = new MyClass[5];
myObjectArray[0] = new MyClass(); // 创建并初始化第一个对象

```

数组对象有一些内置的属性和方法：

* length：数组的长度，即数组中元素的数量。
* clone()：返回数组的副本。

```java
for (int i = 0; i < intArray.length; i++) {
    System.out.println(intArray[i]);
}

```

### 多维数组
Java支持多维数组，实际上它们是数组的数组。

例如，二维数组可以看作是数组的数组：
```java
int[][] twoDimArray = new int[3][4]; // 创建一个3x4的二维整型数组
twoDimArray[0] = new int[4]; // 也可以逐行初始化

String[][] stringTwoDimArray = {
    {"hello", "world"},
    {"java", "is", "fun"}
};

```

### 动态集合
在Java中，当你需要一个动态大小的数据集合时，通常会使用Java集合框架中的类。

#### ArrayList
```java
import java.util.ArrayList;

public class ArrayListExample {
    public static void main(String[] args) {
        ArrayList<String> fruits = new ArrayList<>();
        fruits.add("Apple");
        fruits.add("Banana");
        fruits.add("Cherry");

        System.out.println("Original list: " + fruits);

        // Accessing elements by index
        System.out.println("Second fruit: " + fruits.get(1));

        // Removing an element
        fruits.remove("Banana");
        System.out.println("List after removal: " + fruits);

        // Adding an element at specific index
        fruits.add(1, "Mango");
        System.out.println("List after adding 'Mango': " + fruits);
    }
}

输出结果：
Original list: [Apple, Banana, Cherry]
Second fruit: Banana
List after removal: [Apple, Cherry]
List after adding 'Mango': [Apple, Mango, Cherry]
```

#### LinkedList
```java
import java.util.LinkedList;

public class LinkedListExample {
    public static void main(String[] args) {
        LinkedList<String> fruits = new LinkedList<>();
        fruits.add("Apple");
        fruits.addLast("Banana");
        fruits.addFirst("Cherry");

        System.out.println("Original list: " + fruits);

        // Removing first occurrence of an element
        fruits.remove("Banana");
        System.out.println("List after removal: " + fruits);

        // Accessing the first element
        System.out.println("First fruit: " + fruits.getFirst());
    }
}

输出结果：
Original list: [Cherry, Apple, Banana]
List after removal: [Cherry, Apple]
First fruit: Cherry

```
## 对象

