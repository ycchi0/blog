+++
title = 'ETCD应用场景'
date = 2024-05-30T17:37:32Z
draft = false
+++

## 前置知识

* ETCD的租约机制
  
租约是ETCD中的一种抽象，它可以关联到一个或多个键值对，当租约过期时，与其关联的所有键值对都会被自动删除。

以下是ETCD租约机制的主要特性和使用方式：

**创建租约**：客户端可以通过调用ETCD的API创建一个新的租约。创建租约时需要指定一个TTL（Time To Live），表示租约的有效期。创建成功后，ETCD会返回一个唯一的租约ID。

**关联键值对**：客户端在创建或修改键值对时，可以指定一个租约ID，将键值对关联到这个租约。这样，当租约过期时，这个键值对会被自动删除。


**续租**：客户端可以通过调用ETCD的API来续租一个租约，即重新设置租约的TTL。这样可以防止租约过期，与其关联的键值对被删除。

**撤销租约**：客户端可以通过调用ETCD的API来撤销一个租约。撤销租约会导致与其关联的所有键值对被立即删除。

**租约超时**：如果客户端在租约的TTL时间内没有进行续租操作，那么租约会自动过期，与其关联的所有键值对都会被ETCD自动删除。

 一个租约可以挂多个key，一个key只能挂一个租约


## 应用场景 

### 服务发现

服务注册与发现(Service Discovery)是ETCD最常见的使用场景，解决的是如何在同一个分布式集群中的进程或服务找到目标服务的IP地址并建立连接。

在分布式系统中，服务提供者都是以集群的方式对外提供服务，集群中服务的IP随时都可能发生变化，因此服务提供者需要将自己的服务注册到ETCD中去。这样，服务使用者通过ETCD可以获取到实际服务提供者的ip信息，连接到服务提供者，进行后续操作。

### 消息发布与订阅

使用ETCD进行消息发布与订阅，实际上就是构建一个配置共享中心

消息发布方在将消息存储到对应的key上，消息订阅者在ETCD节点上注册一个Watcher并等待，以后每次配置有更新的适合，ETCD都会实时通知订阅者，以此达到获取最新配置信息的目的。


### 分布式锁

ETCD实现分布式锁的关键在于其Compare-and-Swap（CAS）操作和TTL（Time To Live）特性。

以下是ETCD实现分布式锁的详细步骤：

1. **获取锁**：客户端尝试获取锁，通过调用ETCD的CAS操作。在这个操作中，客户端会尝试创建一个键值对，键是锁的名称，值是一个唯一标识（例如，客户端的ID或者UUID）。同时，这个键值对会设置一个TTL，表示锁的过期时间。如果这个键值对创建成功，那么就表示客户端成功获取到了锁。如果键值对创建失败（通常是因为键已经存在，即锁已经被其他客户端持有），那么客户端就没有获取到锁。

2. **持有锁**：一旦客户端获取到锁，就可以执行需要同步的操作。在这个过程中，其他客户端无法获取到锁，也就无法执行相同的操作。

3. **释放锁**：客户端在完成需要同步的操作后，需要释放锁，让其他客户端有机会获取锁。释放锁是通过调用ETCD的Delete操作，删除对应的键值对来实现的。

4. **锁的过期**：如果客户端在持有锁的过程中崩溃，可能无法正常释放锁。这时，ETCD的TTL特性就会发挥作用。ETCD会在键值对的TTL时间到达后，自动删除这个键值对，从而释放锁。这样可以防止因为客户端崩溃导致的锁无法释放，阻塞其他客户端的问题。

5. **等待锁**：如果客户端尝试获取锁失败（即锁已经被其他客户端持有），那么客户端可以选择等待锁被释放。这通常是通过轮询的方式实现的，客户端会定期尝试获取锁，直到成功为止。

通过这种方式，ETCD可以在分布式环境下实现锁的同步，保证在同一时刻，只有一个客户端能够执行需要同步的操作。这对于保证分布式系统的数据一致性非常重要。






