#gi programming language

The gi programming language is simple language that runs on the gvm.

gi syntax:
```
func transform = (i32 val1, i32 val2): i32 {
	return 2 * val1 + val2;
}

func main = () {
	i32 var1 = 3;
	i32 var2 = 5;
	i32 result = transform(var1, var2);

	i32 new_result = 2;
	if result > 10 {
		new_result = 12;
	}

	put new_result;
	return;
}
```
