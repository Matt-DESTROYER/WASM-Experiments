(module
	;; MEMORY
	(;
	 ; Format:
	 ; <i64 blocksize><blocksize * bytes>
	 ; The first byte is reserved as a null pointer.
	 ;)

	;; when the ability to use multiple memory blocks is added to the standard, this will improve this implementation of malloc
	;; (memory $memory_metadata_table) 1 64)
	(memory $memory_pool (; start with 1 page ;) 1 (; _can_ expand to 64 pages ;) 64) ;; 65,536 bytes (64 KiB) per a maximum of 65,536 pages
	(global $memory_pool_size   (mut i32) (i32.const 1))
	(global $memory_pool_in_use (mut i32) (i32.const 0))

	(global $NULL     i32 (i32.const 0))
	(global $I8_SIZE  i32 (i32.const 1))
	(global $I32_SIZE i32 (i32.const 4))

	(;
	(func $NOT (param $x i32) (result i32)
		local.get $x
		i32.const -1
		i32.xor
		return
	)
	;)

	(func $should_grow_memory (param $bytes_needed i32) (result i32)
		;; $memory_pool_in_use + $bytes_needed < $memory_pool_size
		global.get $memory_pool_in_use
		local.get $bytes_needed
		i32.add
		global.get $memory_pool_size
		i32.lt_u
		if
			;; we should grow the memory
			i32.const 1
			return
		end

		;; $memory_pool_in_use + $bytes_needed < $memory_pool_in_use
		global.get $memory_pool_in_use
		local.get $bytes_needed
		i32.add
		global.get $memory_pool_in_use
		i32.lt_u
		if
			;; we should grow the memory
			i32.const 1
			return
		end
		;; we shouldn't grow the memory
		i32.const 0
	)

	(func $auto_grow_memory (param $bytes_needed i32)
		;; TODO:
		;; consider calculating the pages needed to grow by using rem_u
		loop $while
			;; grow memory by 1 page
			i32.const 1
			memory.grow
			
			;; continue while more memory is needed
			local.get $bytes_needed
			call $should_grow_memory
			br_if $while
		end
	)

	(func $locate_next_non_null (param $start_pointer i32) (param $max i32) (result i32)
		(local $pointer i32)
		local.get $start_pointer
		local.set $pointer

		loop $while
			;; increment the pointer
			local.get $pointer
			global.get $I8_SIZE
			i32.add
			local.tee $pointer

			;; if we pass $max, early return
			local.get $start_pointer
			local.get $max
			i32.add
			local.get $pointer
			i32.ge_u
			if
				local.get $pointer
				return
			end

			;; continue if the byte at this pointer is still empty
			i32.load8_u
			i32.eqz
			br_if $while
		end

		local.get $pointer
		return
	)

	(func $malloc (param $bytes i32) (result i32)
		(local $pointer i32)
		;; auto grow memory if needed
		local.get $bytes
		global.get $I32_SIZE
		i32.add
		local.tee $bytes
		call $auto_grow_memory

		;; find the next available 
		global.get $I8_SIZE
		local.set $pointer

		loop $find_space
			;; continue until we find an empty space
			local.get $pointer
			i32.load32_u
			i32.const 0
			i32.ne
			if
				local.get $pointer
				i32.load32_u
				local.get $pointer
				i32.add
				global.get $I32_SIZE
				i32.add
				local.set $pointer ;; $pointer += *(pointer) + $I32_SIZE
				br $find_space
			end

			;; check how much space is available here
			local.get $pointer
			local.get $byte
			call $locate_next_non_null
			
			;; if we don't have enough space, continue
			local.get $pointer
			i32.sub
			local.get $bytes
			i32.lt_u
			br_if $find_space
		end

		;; at this point we're gonna ignore the possibility of
		;; exhausting all possible 4 GiB of memory
		
		;; by this point we've located a valid location for the allocation
		;; store the size of the allocation and return the pointer to the data
		local.get $pointer
		local.get $bytes
		i32.store

		global.get $memory_pool_in_use
		local.get $bytes
		i32.add
		global.set $memory_pool_in_use

		local.get $pointer
		return
	)

	;; load an entire allocated buffer onto the stack
	;; (in reverse order, with the first element at the top)
	(func $load_buffer (param $buffer_start i32)
		(local $pointer i32)
		;; set pointer to the end of the allocated buffer
		local.get $buffer_start
		global.get $I32_SIZE
		i32.sub
		i32.load32_u
		local.get $buffer_start
		i32.add
		local.set $pointer
		
		;; while $pointer > $buffer_start
		loop $while
			;; push the next value to the stack
			local.get $pointer
			i32.load8_u

			;; decrement the pointer
			local.get $pointer
			global.get $I8_SIZE
			i32.sub
			local.tee $pointer

			;; continue while $pointer > buffer_start
			local.get $buffer_start
			i32.gt_u
			br_if
		end
	)
)

