(module
	;; MATH CONSTANTS
	;; (FROM GNU C <math.h>)
	(global $E        f64 (f64.const 2.7182818284590452354))  ;; e
	(global $LOG2E    f64 (f64.const 1.4426950408889634074))  ;; log_2 e
	(global $LOG10E   f64 (f64.const 0.43429448190325182765)) ;; log_10 e
	(global $LN2      f64 (f64.const 0.69314718055994530942)) ;; log_e 2
	(global $LN10     f64 (f64.const 2.30258509299404568402)) ;; log_e 10
	(global $PI       f64 (f64.const 3.14159265358979323846)) ;; pi
	(global $PI_2     f64 (f64.const 1.57079632679489661923)) ;; pi/2
	(global $PI_4     f64 (f64.const 0.78539816339744830962)) ;; pi/4
	(global $1_PI     f64 (f64.const 0.31830988618379067154)) ;; 1/pi
	(global $2_PI     f64 (f64.const 0.63661977236758134308)) ;; 2/pi
	(global $2_SQRTPI f64 (f64.const 1.12837916709551257390)) ;; 2/sqrt(pi)
	(global $SQRT1_2  f64 (f64.const 0.70710678118654752440)) ;; sqrt(1/2)
	(global $SQRT2    f64 (f64.const 1.41421356237309504880)) ;; sqrt(2)

	(func $abs (export "abs") (param $x f64) (result f64)
		;; return abs($x)
		local.get $x
		f64.abs
		return
	)
	;; acos
	;; acosh
	;; asin
	;; asinh
	;; atan
	;; atan2
	;; atanh
	;; cbrt
	(func $ceil (export "ceil") (param $x f64) (result f64)
		local.get $x
		f64.ceil
		return
	)
	;; clz32
	;; cos
	;; cosh
	;; exp
	;; expm1
	(func $factorial (export "factorial") (param $x i64) (result i64)
		
	)
	(func $floor (export "floor") (param $x f64) (result f64)
		local.get $x
		f64.floor
		return
	)
	(func $fround (export "fround") (param $x f64) (result f32)
		local.get $x
		f32.demote_f64
		f32.nearest
	)
	;; hypot
	(func $imul (export "imul") (param $x f64) (param $y f64) (result i32)
		local.get $x
		i32.trunc_f64_s
		local.get $y
		i32.trunc_f64_s
		i32.mul
		return
	)
	;; log
	;; log10
	;; log1p
	;; log2
	(func $max (export "max") (param $x f64) (param $y f64) (result f64)
		local.get $x
		local.get $y
		f64.max
		return
	)
	(func $min (export "min") (param $x f64) (param $y f64) (result f64)
		local.get $x
		local.get $y
		f64.min
		return
	)
	;; pow
	;; random
	(func $round (export "round") (param $x f64) (result f64)
		local.get $x
		f64.nearest
		return
	)
	(func $sign (export "sign") (param $x f64) (result i32)
		;; if $x < 0
		local.get $x
		f64.const 0
		f64.lt
		if
			;; return -1
			i32.const -1
			return
		end
		;; if $x > 0
		local.get $x
		f64.const 0
		f64.gt
		if
			;; return 1
			i32.const 1
			return
		end
		;; return 0
		i32.const 0
		return
	)
	;; sin
	;; sinh
	(func (export "sqrt") (param $x f64) (result f64)
		local.get $x
		f64.sqrt
		return
	)
	;; sumPrecise
	;; tan
	;; tanh
	(func (export "trunc") (param $x f64) (result f64)
		local.get $x
		f64.trunc
		return
	)
)

