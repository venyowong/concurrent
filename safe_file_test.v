module main

import concurrent
import os

fn test_safe_file() {
	mut file := concurrent.SafeFile{}
	path := "test.txt"
	file.append(path, "line1", "line2")!
	file.read_by_line[string](path, fn (line string) ?string { return line })!
	file.remove_by_line(path, fn (line string) bool { return line.len == 0 || line[line.len - 1] == `1` })!
	println(os.read_file(path)!)
}