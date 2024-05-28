+++
title = 'SQL基础'
date = 2024-05-28T10:51:29Z
draft = false
+++

前言
--

在平时的工作中，大家可能是 ORM 战士。但是 ORM 之下，还是原生的 SQL。这是整理 SQL 基础时的一些记录。

### DDL

数据定义语言,用来定义数据库对象，包括数据库、数据表和列。

### DML

数据操作语言，用来操作和数据库相关的记录，比如增加、删除、修改数据表中的记录。

### DCL

数据控制语言，用来定义访问权限和安全级别。

### DQL

数据查询语言，用来查询想要的记录。

SQL语句书写规范
---------

参考：

表名、表别名、字段名、字段别名等都小写

SQL 保留字、函数名、绑定变量等都大写

SQL 排序
------

### ORDER BY

1.  ORDER BY 后面可以有一个或多个列名，如果是多个列名进行排序，会按照后面第一个列先进行排序，当第一列的值相同的时候，再按照第二列进行排序，以此类推。
2.  ORDER BY 后面可以注明排序规则，ASC 代表递增排序，DESC 代表递减排序。默认情况下是按照 ASC 递增排序。
3.  ORDER BY 可以使用非选择列进行排序，即使在 SELECT 后面没有这个列名，同样可以放到 ORDER BY 后面进行排序。

SELECT 的执行顺序
------------

### 1.关键字语法顺序

```sql
SELECT ... FROM ... WHERE ... GROUP BY ... HAVING ... ORDER BY ...
```

其中 WHERE 和 HAVING 的区别在于，WHERE 是对数据行进行过滤，而 HAVING 是对分组数据进行过滤。

### 2.语句的执行顺序(以MySQL为例)

```sql
FROM > WHERE > GROUP BY > HAVING > SELECT 的字段 > DISTINCT > ORDER BY > LIMIT

(5)SELECT DISTINCT <select_list>                     
(1)FROM <left_table> <join_type> JOIN <right_table> ON <on_predicate>
(2)WHERE <where_predicate>
(3)GROUP BY <group_by_specification>
(4)HAVING <having_predicate>
(6)ORDER BY <order_by_list>
(7)LIMIT n, m
```

这些步骤执行时，每个步骤都会产生一个虚拟表，该虚拟表被用作下一个步骤的输入。这些虚拟表对调用者（客户端应用程序或者外部查询）无感知的。只有最后一步生成的表才会返回给调用者。如果没有在查询中指定某一子句，将跳过相应的步骤。

SQL 函数
------

SQL 提供了许多常用的内置函数，分别有算数函数、字符串函数、日期函数、转换函数等。

比如说：

```sql
SELECT CONCAT('abc', 123)
SELECT DATE('2022-03-21 12:00:05');
SELECT CURRENT_TIMESTAMP()
```

使用内置函数的一个好处是可以简化我们的SQL语句，但同样的，可能会使索引不生效而走全表扫描。这块内容将在索引部分进行分析。

子查询
---

子查询又分为关联子查询和非关联子查询。

### 关联子查询

子查询从数据表中查询了数据结果。如果这个子查询只执行一次，然后得到的数据结果作为主查询的条件进行执行，那么这样的子查询叫做非关联子查询

### 非关联子查询

如果子查询需要执行多次，即采用循环的方式，先从外部查询开始，每次都传入子查询进行查询，然后再将结果反馈给外部，这种嵌套的执行方式就称为关联子查询。

### 原则

使用子查询时需要遵循一个原则，小表驱动大表，即小的数据集驱动大的数据集。

```sql
select * from A where A.id in （select B.id from B）
```

in 后的括号的表达式结果要求先输出一列字段。与之前的搜索字段匹配，匹配到相同则返回对应行。mysql的执行顺序是先执行子查询，然后执行主查询，用子查询的结果按条匹配主查询。

```sql
select * from A where exists（select * from B where B.id= A.id）
```

exist后的括号无输出要求，exist判断后面的结果集中有没有行，有行则返回外层查询对应的行。mysql的执行顺序是先执行主查询，将主查询的数据放在子查询中做条件验证。

通常来讲，不管 Oracle 还是 MySQL，优化的目标都是尽可能的减少关联的循环次数，保证小表驱动大表

主要原因有：

1.小表驱动大表，相当于在一次连接中做多次操作，减少连接请求时的消耗

2.不论是大表驱动小表还是小表驱动大表，对同一情况的查询语句而言，扫描行数都是一样的，两者的差距在于大表上如果有索引，走可以走索引，其次是大表做全表扫描时，读取磁盘一次性可以读出多条数据。相当于作了批量操作。

### 视图

视图（view）本身是不具有数据的，是一种虚拟存在的表，是一个逻辑表。虚拟表可以连接一个或多个数据表，不同的查询应用都可以建立在虚拟表之上。

视图的这一特点，可以帮我们简化复杂的 SQL 查询。比如在编写视图后，我们就可以直接重用它，不需要再考虑视图中包含的基础查询细节。

比如说：我们创建一个 view\_heros 的视图，数据来源于 heros

```sql
CREATE VIEW view_heros AS
SELECT * FROM heros                         
```

之后对 heros 的查询操作都可以从视图查询，当heros 数据有变化时，视图上的数据也会跟着修改。

存储过程
----

视图是虚拟表，通常不对底层数据表直接操作。存储过程是程序化的 SQL，可以直接操作底层数据表，可以满足一些复杂的数据处理需求。

存储过程是 SQL 语句的封装。一旦存储过程被创建出来，使用它就像使用函数一样，直接通过调用存储过程名即可。

定义一个存储过程

```sql
CREATE PROCEDURE 存储过程名称 ([参数列表])
BEGIN
    需要执行的语句
END    
```

比如：

```sql
DELIMITER //    MySQL 中默认情况下 SQL 采用（；）做为结束符，临时定义新的 DELIMITER，新的结束符可以用（//）
CREATE PROCEDURE `add_num`(IN n INT)
BEGIN
       DECLARE i INT;
       DECLARE sum INT;
       
       SET i = 1;
       SET sum = 0;
       WHILE i <= n DO
              SET sum = sum + i;
              SET i = i +1;
       END WHILE;
       SELECT sum;
END //
DELIMITER ; 将结束符还原

call add_num(10);  调用存储过程， 查询结果为 55 
```

更多关于存储过程，可以查看 [mysql存储过程 变量和参数类型](https://link.zhihu.com/?target=https%3A//blog.csdn.net/jxpxlinkui/article/details/79709037)