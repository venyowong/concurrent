module main

import concurrent
import json

fn test_struct_map() {
	mut m := concurrent.AsyncMap.new[User]()
	mut user := User {
		id: 1
		name: "first"
	}
	m.set("1", user)
	println(json.encode(m))
	user.name = "second"
	println(json.encode(m))
	u2 := m.get_or_create("2", fn () User {
		return User {
			id: 2
			name: "second"
		}
	})
	println(u2)
	println(json.encode(m))
}

fn test_struct_map_json() {
	str := '{"data":{"1":{"id":1,"name":"second"},"2":{"id":2,"name":"second"}},"mu":{"mx":{}}}'
	println(json.decode(concurrent.AsyncMap[User], str) or {panic(err)})
}

struct User {
pub mut:
	id int
	name string
}