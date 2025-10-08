module concurrent

import time

fn test_spin() {
	mut m := 0
	mut r := unsafe{&m}
	spawn fn (r2 &int) {
		time.sleep(60 * time.second)
		unsafe{*r2 = 1}
	}(r)
	spin_wait(10 * time.millisecond, time.second, 10, 0, fn [r]() bool {
		return *r > 0
	}) or {
		println(err)
	}
	println("finished to spin wait")
}