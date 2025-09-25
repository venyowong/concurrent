module main

import concurrent

fn test_string_map() {
	mut m := concurrent.SafeMap.new[string]()
	value := "value"
	m.set("key", value)
	println(m.keys())
	println(m.get("key"))
	println(m.get("key1"))
	println(m.get_or_create("key2", fn () string {return "value2"}))
	println(m)
}

fn test_struct_map() {
	mut m := concurrent.SafeStructMap.new[User]()
	mut user := User {
		id: 1
		name: "first"
	}
	m.set("1", &user)
	println(m)
	user.name = "second"
	println(m)
	u2 := m.get_or_create("2", fn () User {
		return User {
			id: 2
			name: "second"
		}
	})
	println(*u2)
	println(m)
}

struct User {
pub mut:
	id int
	name string
}