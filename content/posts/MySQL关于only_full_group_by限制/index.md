+++
title = 'MySQL关于only_full_group_by限制'
date = 2024-05-28T10:56:23Z
draft = false
+++

先上结论

如果 only_full_group_by 被启用，那么在查询时，如果某个列不在group by 列表中，此时如果不对该列进行聚合处理，则该列不能出现在 select 列表，having 条件中及order by 列表中

MySQL 8.0 默认启用了sql_mode，我们可以通过 select @@session.sql_mode 查看会话中的 sql_mode 配置。

```sql
mysql> SELECT @@session.sql_mode;
+-----------------------------------------------------------------------------------------------------------------------+
| @@session.sql_mode
|
+-----------------------------------------------------------------------------------------------------------------------+
| ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION |
+-----------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

有这么一张表

```sql
CREATE TABLE `mytable`
(
    `id` int unsigned NOT NULL,
    `a`  varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `b`  int                                    DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

INSERT INTO mytable
VALUES (1, 'abc', 1000),
       (2, 'abc', 2000),
       (3, 'def', 4000);
```

当我们执行的 SQL 语句包含聚合函数时，MYSQL 提示需要使用 GROUP BY 进行分组。

```sql
mysql> SELECT a,SUM(b) FROM mytable;
ERROR 1140 (42000): In aggregated query without GROUP BY, 
expression #1 of SELECT list contains nonaggregated column 'study.mytable.a'; 
this is incompatible with sql_mode=only_full_group_by
如果我们关掉 only_full_group_by 限制，SQL 语句就正常执行了，但又没有完全正常执行。

mysql> SET sql_mode = '';
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT a,SUM(b) FROM mytable;
+------+--------+
| a    | SUM(b) |
+------+--------+
| abc  |   7000 |
+------+--------+
1 row in set (0.00 sec)
```

可以看到，虽然我们得到了 SUM(b) 的值为 7000 是期望的，但是 a 的值为 abc 不是我们期望的。

MySQL 8.0 里的文档提到这么一句话

the query is processed by treating all rows as a single group, but the value selected for each named column is nondeterministic
在这个例子中，a 的值就是不确定的

当 WHERE 过滤条件中包含了 SELECT 列表中全部非聚合列的字段，则在开启 only_full_group_by 下也可以正常工作

```sql
In this case, every such column must be limited to a single value in theWHEREclause, and all such limiting conditions must be joined by logicalAND
mysql> SET SESSION sql_mode = sys.list_add(@@session.sql_mode, 'ONLY_FULL_GROUP_BY');
Query OK, 0 rows affected (0.01 sec)


mysql> SELECT a,SUM(b) FROM mytable;
ERROR 1140 (42000): In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'study.mytable.a'; this is incompatible with sql_mode=only_full_group_by
mysql> SELECT a, SUM(b) FROM mytable WHERE a = 'abc';
+------+--------+
| a    | SUM(b) |
+------+--------+
| abc  |   3000 |
+------+--------+
1 row in set (0.00 sec)

mysql> SELECT * FROM mytable1;
+----+------+------+-------+
| id | a    | b    | c     |
+----+------+------+-------+
|  1 | abc  | qrs  |  1000 |
|  2 | abc  | tuv  |  2000 |
|  3 | def  | qrs  |  4000 |
|  4 | def  | tuv  |  8000 |
|  5 | abc  | qrs  | 16000 |
|  6 | def  | tuv  | 32000 |
+----+------+------+-------+
6 rows in set (0.00 sec)

mysql> SELECT a, b, SUM(c) FROM mytable1 WHERE a = 'abc' OR b = 'qrs';
ERROR 1140 (42000): In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'study.mytable1.a'; this is incompatible with sql_mode=only_full_group_by
mysql> SELECT a, b, SUM(c) FROM mytable1 WHERE a = 'abc' AND b = 'qrs';
+------+------+--------+
| a    | b    | SUM(c) |
+------+------+--------+
| abc  | qrs  |  17000 |
+------+------+--------+
1 row in set (0.00 sec)
```

这种方式可以理解为通过条件限制确定了分组条件。因为没有指名分组时，MySQL 将所有字段视为一个组处理。

在开启 only_full_group_by 限制时，也可以通过 ANY_VALUE 函数，使MySQL 正常执行语句，显而易见的是，我们得到的值是不确切的。

```sql
mysql> SELECT a,SUM(b) FROM mytable;
ERROR 1140 (42000): In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'study.mytable.a'; this is incompatible with sql_mode=only_full_group_by
mysql> SELECT ANY_VALUE(a),SUM(b) FROM mytable;
+--------------+--------+
| ANY_VALUE(a) | SUM(b) |
+--------------+--------+
| abc          |   7000 |
+--------------+--------+
1 row in set (0.00 sec)
```

综上，在使用聚合函数的场景中，使用 GROUP BY 进行分组可以确保逻辑严谨性。

推荐阅读：
https://dev.mysql.com/doc/refman/8.0/en/counting-rows.html
https://dev.mysql.com/doc/refman/8.0/en/group-by-handling.html
