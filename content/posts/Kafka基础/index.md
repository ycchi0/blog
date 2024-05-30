+++
title = 'Kafka 基础'
date = 2024-05-30T12:45:04Z
draft = true
+++

## Kafka 基本概念

kafka 是一个分布式的，分区的消息(官方称之为 commit log )服务。

**Kafka 相关术语**
|名称|解释|
| ---- | ---- |
|Broker|消息中间件处理节点，一个 Kafka 节点就是一个 broker，一个或者多个 Broker 可以组成一个 Kafka 集群|
|Topic|Kafka 根据 topic 对消息进行归类，发布到 Kafka 集群的每条消息都需要指定一个 topic|
|Producer|消息生产者，向 Broker 发送消息的客户端|
|Consumer|消息消费者，从 Broker 读取消息的客户端|
|ConsumerGroup|每个 Consumer 属于一个特定的 Consumer Group，一条消息可以被多个不同的 Consumer Group 消费，但是一个 Consumer Group 中只能有一个 Consumer 能够消费该消息|
|Partition|物理上的概念，一个 topic 可以分为多个 partition，每个 partition 内部消息是有序的|


### 单播消息

一条消息只能被某一个消费者消费的模式，类似queue模式，只需让所有消费者在同一个消费组里即可
分别在两个客户端执行如下消费命令，然后往主题里发送消息，结果只有一个客户端能收到消息。

### 多播消息
一条消息能被多个消费者消费的模式，类似publish-subscribe模式费，针对Kafka同一条消息只能被同一个消费组下的某一个消费者消费的特性，要实现多播只要保证这些消费者属于不同的消费组即可


