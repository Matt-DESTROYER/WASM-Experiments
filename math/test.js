const fs = require("fs").promises;

fs.readFile("./math.wasm")
	.then((res) => WebAssembly.instantiate(res))
	.then((obj) => obj.instance.exports)
	.then((math) => {
		console.log("[Testing `js_math.wasm`]");
		for (let i = 0; i < 10; i++) {
			console.log(`math.sqrt(${i}) => ${math.sqrt(i)}`);
		}
	});

