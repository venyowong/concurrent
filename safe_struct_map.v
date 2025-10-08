module concurrent

import sync

pub struct SafeStructMap[T] {
mut:
    data map[string]&T
    mu   sync.RwMutex  // 读写锁
}

pub fn SafeStructMap.new[T]() SafeStructMap[T] {
    return SafeStructMap[T]{
        data: map[string]&T{}
        mu: sync.RwMutex{}
    }
}

// 读操作（共享锁）
pub fn (mut m SafeStructMap[T]) get(key string) &T {
    m.mu.rlock()       // 读锁
    defer { m.mu.runlock() }  // 释放读锁
    return unsafe {m.data[key]}
}

pub fn (mut m SafeStructMap[T]) get_or_create(key string, creator fn() T) &T {
    m.mu.lock()
    defer { m.mu.unlock() }
    return m.data[key] or {
        value := creator();
        m.data[key] = &value
        return &value
    }
}

// 读操作示例：获取所有键
pub fn (mut m SafeStructMap[T]) keys() []string {
    m.mu.rlock()
    defer { m.mu.runlock() }
    return m.data.keys()
}

pub fn (mut m SafeStructMap[T]) remove(key string) ?&T {
    m.mu.lock()
    defer { m.mu.unlock() }
    if key in m.data {
        value := m.data[key]
        m.data.delete(key)
        return value
    } else {
        return none
    }
}

// 写操作（独占锁）
pub fn (mut m SafeStructMap[T]) set(key string, value &T) {
    m.mu.lock()
    defer { m.mu.unlock() }
    m.data[key] = unsafe{value}
}

pub fn (mut m SafeStructMap[T]) values() []&T {
    m.mu.lock()
    defer { m.mu.unlock() }
    return m.data.values()
}