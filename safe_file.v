module concurrent

import sync
import os

pub struct SafeFile {
mut:
	mutex_map SafeStructMap[sync.RwMutex] = SafeStructMap.new[sync.RwMutex]()
}

pub fn (mut safe_file SafeFile) append(path string, lines ...string) ! {
	mut mutex := safe_file.mutex_map.get_or_create(path, fn () sync.RwMutex { return sync.RwMutex{} })
	mutex.lock()
	defer { mutex.unlock() }
	
	mut file := os.open_file(path, 'a')!
	defer {file.close()}
	for line in lines {
		file.writeln(line)!
	}
}

pub fn (mut safe_file SafeFile) read_by_line[T](path string, process fn(string) ?T) ![]T {
	mut mutex := safe_file.mutex_map.get_or_create(path, fn () sync.RwMutex { return sync.RwMutex{} })
	mutex.rlock()
	defer { mutex.runlock() }

	mut file := os.open_file(path, "r")!
	defer {
        file.close()
    }

	mut result := []T{}
	buff_size := 4096  // 缓冲区大小
	mut buffer := []u8{len: buff_size}
    mut data := []u8{}
	for {
		// 读取数据到缓冲区
        n := file.read(mut buffer)!

		index := data.len // 开始遍历的下标
        mut start := 0
		// 合并上次剩余的数据和新读取的数据
		data << buffer[0..n]
		// 分割行（处理 \n 和 \r\n 两种换行符）
        for i := index; i < data.len; i++ {
            if data[i] == `\n` {
                // 提取一行（去除换行符）
                end := if i > 0 && data[i-1] == `\r` { i - 1 } else { i }
                line := data[start..end].bytestr()
				r := process(line)
				if r != none {
					result << r
				}
                start = i + 1
            }
        }

		// 保存未完成的行
        if start < data.len {
            data = unsafe{ data[start..] }
        } else {
			data = []u8{}
		}

		if n < buff_size {
			break
		}
	}

	if data.len > 0 {
		line := data.bytestr()
		r := process(line)
		if r != none {
			result << r
		}
    }
	return result
}

pub fn (mut safe_file SafeFile) rm(path string) ! {
	mut mutex := safe_file.mutex_map.get_or_create(path, fn () sync.RwMutex { return sync.RwMutex{} })
	mutex.lock()
	defer { mutex.unlock() }

	os.rm(path)!
}

pub fn (mut safe_file SafeFile) remove_by_line(path string, need_remove fn(string) bool) ! {
	mut mutex := safe_file.mutex_map.get_or_create(path, fn () sync.RwMutex { return sync.RwMutex{} })
	mutex.rlock()
	defer { mutex.runlock() }

	temp_path := path + ".tmp" // 临时文件路径
	mut temp_file := os.open_file(temp_path, 'w')!
	defer {
		temp_file.close()
        if os.exists(temp_path) {
            os.rm(temp_path) or {}
        }
    }

	lines := safe_file.read_by_line[string](path, fn [need_remove] (line string) ?string {
		if !need_remove(line) {
			return line
		} else {
			return none
		}
	})!
	for line in lines {
		temp_file.writeln(line)!
	}

	temp_file.flush()
	temp_file.close()
	os.rm(path)!
	os.mv(temp_path, path)!
}

pub fn (mut safe_file SafeFile) write_file(path string, content string) ! {
	mut mutex := safe_file.mutex_map.get_or_create(path, fn () sync.RwMutex { return sync.RwMutex{} })
	mutex.lock()
	defer { mutex.unlock() }

	os.write_file(path, content)!
}