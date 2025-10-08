module concurrent

import time

pub fn spin_wait(min_interval i64, max_interval i64, steps int, timeout u64, condition fn () bool) ! {
	if min_interval <= 0 {
		return error("min_interval must be bigger than zero")
	}

	mut interval := min_interval
	start := time.now()
	for {
		if condition() {return}

		time.sleep(interval * time.nanosecond)
		if max_interval > min_interval && interval < max_interval {
			interval += (max_interval - min_interval) / steps
		}
		if interval > max_interval {
			interval = max_interval
		}
		used := time.now() - start
		if timeout > 0 && used >= timeout {
			return error("spin_wait timeout, used $used")
		}
	}
}