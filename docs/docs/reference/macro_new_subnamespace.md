# Macro - New subnamespace

```r
macro_new_subnamespace(class_pattern, subclass_env = NULL, remove_f = TRUE)
```

## Arguments

- `class_pattern`: regex to select functions
- `subclass_env`: optional subclass of
- `remove_f`: drop sourced functions from package ns after bundling into sub ns

## Returns

A function which returns a subclass environment of bundled class functions.

Bundle class methods into an environment (subname space)

## Details

This function is used to emulate py-polars subnamespace-methods All R functions coined 'macro_'-functions use eval(parse()) but only at package build time to solve some tricky self-referential problem. If possible to deprecate a macro in a clean way , go ahead.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#macro_new_subnamespace() is not exported, export for this toy example</span></span></span>
<span class='r-in'><span><span class='co'>#macro_new_subnamespace = polars:::macro_new_subnamespace</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>##define some new methods prefixed 'MyClass_'</span></span></span>
<span class='r-in'><span><span class='co'>#MyClass_add2 = function() self + 2</span></span></span>
<span class='r-in'><span><span class='co'>#MyClass_mul2 = function() self * 2</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>##grab any sourced function prefixed 'MyClass_'</span></span></span>
<span class='r-in'><span><span class='co'>#my_class_sub_ns = macro_new_subnamespace("^MyClass_", "myclass_sub_ns")</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#here adding sub-namespace as a expr-class property/method during session-time,</span></span></span>
<span class='r-in'><span><span class='co'>#which only is for this demo.</span></span></span>
<span class='r-in'><span><span class='co'>#instead sourced method like Expr_arr() at package build time instead</span></span></span>
<span class='r-in'><span><span class='co'>#env = polars:::Expr #get env of the Expr Class</span></span></span>
<span class='r-in'><span><span class='co'>#env$my_sub_ns = method_as_property(function() { #add a property/method</span></span></span>
<span class='r-in'><span><span class='co'># my_class_sub_ns(self)</span></span></span>
<span class='r-in'><span><span class='co'>#})</span></span></span>
<span class='r-in'><span><span class='co'>#rm(env) #optional clean up</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#add user defined S3 method the subclass 'myclass_sub_ns'</span></span></span>
<span class='r-in'><span><span class='co'>#print.myclass_sub_ns = function(x, ...) { #add ... even if not used</span></span></span>
<span class='r-in'><span><span class='co'>#   print("hello world, I'm myclass_sub_ns")</span></span></span>
<span class='r-in'><span><span class='co'>#   print("methods in sub namespace are:")</span></span></span>
<span class='r-in'><span><span class='co'>#  print(ls(x))</span></span></span>
<span class='r-in'><span><span class='co'>#  }</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#test</span></span></span>
<span class='r-in'><span><span class='co'># e = pl$lit(1:5)  #make an Expr</span></span></span>
<span class='r-in'><span><span class='co'>#print(e$my_sub_ns) #inspect</span></span></span>
<span class='r-in'><span><span class='co'>#e$my_sub_ns$add2() #use the sub namespace</span></span></span>
<span class='r-in'><span><span class='co'>#e$my_sub_ns$mul2()</span></span></span>
<span class='r-in'></span>
 </code></pre>