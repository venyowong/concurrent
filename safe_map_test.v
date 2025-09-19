module main

import concurrent
import os

fn main() {
	mut m := concurrent.SafeMap.new[string]()
	m.set("key", "value")
	println(m.keys())
	println(m.get("key"))
	println(m.get("key1"))
	println(m.get_or_create("key2", fn () string {return "value2"}))
	println(m)
}