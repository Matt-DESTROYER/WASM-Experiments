(module
	;; MEMORY
	(;
	 ; Format:
	 ; <i32 blocksize><blocksize * bytes>
	 ; The first byte is reserved as a null pointer.
	 ;)

	;; when the ability to use multiple memory blocks is added to the standard, this will improve this implementation of malloc
	;; (memory $memory_metadata_table) 1 64)
	(memory $memory_pool (; start with 1 page ;) 1 (; _can_ expand to 64 pages ;) 64) ;; 65,536 bytes (64 KiB) per a maximum of 65,536 pages
	(global $memory_pool_size   (mut i32) (i32.const 65536))
	(global $memory_pool_in_use (mut i32) (i32.const 0))

	(global $NULL      i32 (i32.const 0))
	(global $I8_SIZE   i32 (i32.const 1))
	(global $I32_SIZE  i32 (i32.const 4))
	(global $PAGE_SIZE i32 (i32.const 65536))

	(;
	(func $NOT (param $x i32) (result i32)
		local.get $x
		i32.const -1
		i32.xor
		return
	)
	;)

	(;
	 ; should_grow_memory(i32 bytes_needed) => i32
	 ;
	 ; Indicates whether (1) or not (0) the memory pool should be grow
	 ; in order to add make an allocation of the specified number of bytes.
	 ;)
	(func $should_grow_memory (param $bytes_needed i32) (result i32)
		;; $memory_pool_in_use + $bytes_needed < $memory_pool_size
		global.get $memory_pool_in_use
		local.get $bytes_needed
		i32.add
		global.get $memory_pool_size
		i32.gt_u
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

	(;
	 ; auto_grow_memory(i32 bytes_needed) => void
	 ;
	 ; Automatically handles resizing the memory pool if needed to
	 ; make an allocation of the specified number of bytes.
	 ;)
	(func $auto_grow_memory (param $bytes_needed i32)
		;; TODO:
		;; consider calculating the pages needed to grow by using rem_u
		loop $while
			;; continue while more memory is needed
			local.get $bytes_needed
			call $should_grow_memory
			if
				;; grow memory by 1 page
				i32.const 1
				memory.grow

				;; update the memory pool size
				global.get $memory_pool_size
				global.get $PAGE_SIZE
				i32.add
				global.set $memory_pool_size
				br $while
			end
		end
	)

	(;
	 ; locate_next_non_null(i32 start_pointer, i32 max) => i32
	 ;
	 ; 
	 ;)
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
			i32.load
			i32.const 0
			i32.ne
			if
				local.get $pointer
				i32.load
				local.get $pointer
				i32.add
				global.get $I32_SIZE
				i32.add
				local.set $pointer ;; $pointer += *($pointer) + $I32_SIZE
				br $find_space
			end

			;; check how much space is available here
			local.get $pointer
			local.get $bytes
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

	(func $free (param $pointer i32)
		;; to mark memory as free, we need to re-zero it
		;; todo: zero memory when it's malloced
	)
)

