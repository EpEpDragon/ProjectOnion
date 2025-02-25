extends Node
class_name Math

func bit_interleave(x : int, y : int) -> int:
	return bit_interleave_zero(x) | bit_interleave_zero(y) << 1


func bit_interleave_zero(x : int) -> int:
	x = (x ^ (x << 16)) & 0x0000ffff0000ffff
	x = (x ^ (x << 8 )) & 0x00ff00ff00ff00ff
	x = (x ^ (x << 4 )) & 0x0f0f0f0f0f0f0f0f
	x = (x ^ (x << 2 )) & 0x3333333333333333
	x = (x ^ (x << 1 )) & 0x5555555555555555
	return x


func bit_count(x) -> int:
	# log in base 2
	return int((log(x) / log(2)) + 1);


func bit_reverse(x : int, bit_count : int) -> int:
	var reverse : int = 0
	while(bit_count > 0):
		reverse = (reverse << 1) | (x & 1)
		x >>= 1
		bit_count -= 1
	return reverse
