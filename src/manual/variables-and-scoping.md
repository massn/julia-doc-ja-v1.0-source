`[](# [Scope of Variables](@id scope-of-variables))
# [変数のスコープ](@id scope-of-variables)

```@raw html
<!--
The *scope* of a variable is the region of code within which a variable is visible. Variable scoping
helps avoid variable naming conflicts. The concept is intuitive: two functions can both have arguments
called `x` without the two `x`'s referring to the same thing. Similarly there are many other cases
where different blocks of code can use the same name without referring to the same thing. The
rules for when the same variable name does or doesn't refer to the same thing are called scope
rules; this section spells them out in detail.
-->
```

変数の **スコープ** とは、変数から参照できるコードの領域のことです。
変数のスコープを使うと変数名の競合を避けることができます。
この概念は直感的です。
２つの関数が引数に同じ名前の`x`を使っていても、２つの`x`が同一のものを参照することなく利用できる、というものです。
同様に、コード内の別のブロックで、同じ名前を使っていても、それぞれが同一のものを参照することなく利用できる場合が数多くあります。
同じ名前の変数がいつ同じものを参照し、いつ参照しないのかという規則を、スコープ規則といいます。
このセクションで詳しく説明します。




```@raw html
<!--
Certain constructs in the language introduce *scope blocks*, which are regions of code that are
eligible to be the scope of some set of variables. The scope of a variable cannot be an arbitrary
set of source lines; instead, it will always line up with one of these blocks. There are two
main types of scopes in Julia, *global scope* and *local scope*, the latter can be nested. The
constructs introducing scope blocks are:
-->
```

言語の構文の中には **スコープブロック**　、つまり変数に対するスコープとして適切なコード領域が決まっているものがあります。
変数のスコープはソースの任意の行を割当てることはできません。以下のいずれかを割り当てます。
Juliaには主に２種類のスコープがあります。 **グローバルスコープ** と **ローカルスコープ** です。
後者はネストすることができます。
各構文の導入しているスコープは、


# [](@id man-scope-table)

```@raw html
<!--
  * Scope blocks that may nest only in other global scope blocks:

    - global scope

      + module, baremodule

      + at interactive prompt (REPL)

    - local scope (don't allow nesting)

      + (mutable) struct, macro

  * Scope blocks which may nest anywhere (in global or local scope):

    - local scope

      + for, while, try-catch-finally, let

      + functions (either syntax, anonymous & do-blocks)

      + comprehensions, broadcast-fusing

-->
```

  * 他のグローバルスコープ内でのみネストが可能なスコープブロック

    - グローバルスコープ

      + モジュール、ベアモジュール

      + 対話プロンプト(REPL)

    - ローカルスコープ (ネスト禁止)

      + (可変な) struct, マクロ

  * どこでもネストが可能なスコープブロック（グローバルでもローカルでも）
  
    - ローカルスコープ

      + for, while, try-catch-finally, let

      + 関数 (構文、無名関数 、ブロック)

      + 内包表記, ブロードキャスト-融合

```@raw html
<!--
Notably missing from this table are
[begin blocks](@ref man-compound-expressions) and [if blocks](@ref man-conditional-evaluation)
which do *not* introduce new scope blocks.
Both types of scopes follow somewhat different rules which will be explained below.
-->
```
この表に記載のない注目すべきものは、
[begin ブロック](@ref man-compound-expressions)と[if ブロック](@ref man-conditional-evaluation)です。
これらは、新たなスコープブロックを **導入しません**。
どちらのスコープも後述のような少し違った規則に従います。


```@raw html
<!--
Julia uses [lexical scoping](https://en.wikipedia.org/wiki/Scope_%28computer_science%29#Lexical_scoping_vs._dynamic_scoping),
meaning that a function's scope does not inherit from its caller's scope, but from the scope in
which the function was defined. For example, in the following code the `x` inside `foo` refers
to the `x` in the global scope of its module `Bar`:
-->
```

Juliaは[レキシカルスコープ](https://en.wikipedia.org/wiki/Scope_%28computer_science%29#Lexical_scoping_vs._dynamic_scoping)を
使用しています。これは、呼び出し側のスコープを引き継がず、定義されたスコープを引き継ぐという意味です。
例えば、以下のコードでは、`foo`の中の`x`は、モジュール`Bar`のグローバルスコープにある`x`を参照しています。

```jldoctest moduleBar
julia> module Bar
           x = 1
           foo() = x
       end;
```

```@raw html
<!--
and not a `x` in the scope where `foo` is used:
-->
```

そして、`foo`が使われる場所のスコープにある `x`は参照しません。

```jldoctest moduleBar
julia> import .Bar

julia> x = -1;

julia> Bar.foo()
1
```

```@raw html
<!--
Thus *lexical scope* means that the scope of variables can be inferred from the source code alone.
-->
```

このように、**レキシカルスコープ** は変数のスコープは、ソースコードのみから推論できることを意味します。

`[](## Global Scope)
## グローバルスコープ

```@raw html
<!--
Each module introduces a new global scope, separate from the global scope of all other modules;
there is no all-encompassing global scope. Modules can introduce variables of other modules into
their scope through the [using or import](@ref modules) statements or through qualified access using the
dot-notation, i.e. each module is a so-called *namespace*. Note that variable bindings can only
be changed within their global scope and not from an outside module.
-->
```
各モジュールは新しいグローバルスコープを導入するので、他のすべてのモジュールと分離しています。
すべてを包括するグローバルスコープは存在しません。
モジュールには他のモジュールの変数を自身のスコープに導入することができます。
これは[using または import](@ref modules)文を通じて、あるいはドット表記を使った限定的なアクセスを通じて導入できます。
つまり各モジュールはいわゆる **名前空間** です。
変数の束縛を変更できるのは、グローバルスコープ内のみで、モジュール外では、できない点に注意してください。


```jldoctest
julia> module A
           a = 1 # a global in A's scope
       end;

julia> module B
           module C
               c = 2
           end
           b = C.c    # can access the namespace of a nested global scope
                      # through a qualified access
           import ..A # makes module A available
           d = A.a
       end;

julia> module D
           b = a # errors as D's global scope is separate from A's
       end;
ERROR: UndefVarError: a not defined

julia> module E
           import ..A # make module A available
           A.a = 2    # throws below error
       end;
ERROR: cannot assign variables in other modules
```

```@raw html
<!--
Note that the interactive prompt (aka REPL) is in the global scope of the module `Main`.
-->
```
対話プロンプト(別名 REPL)はモジュール`Main`のグローバルスコープである点に注意してください。

`[](## Local Scope)
## ローカルスコープ

```@raw html
<!--
A new local scope is introduced by most code blocks (see above
[table](@ref man-scope-table) for a complete list).
A local scope inherits all the variables from a parent local scope,
both for reading and writing.
Additionally, the local scope inherits all globals that are assigned
to in its parent global scope block (if it is surrounded by a global `if` or `begin` scope).
Unlike global scopes, local scopes are not namespaces,
thus variables in an inner scope cannot be retrieved from the parent scope through some sort of
qualified access.
-->
```
ほとんどのコードブロックで新しいローカルスコープが導入されます。（完全なリストは上の[表](@ref man-scope-table)を参照）
ローカルスコープは親のローカルスコープにあるすべての変数を、読み書きともに引き継ぎます。
さらに、親のグローバルスコープブロック（グローバルな`if`や`begin`に囲まれたブロック）に割り当てられたグローバル変数を引き継ぎます。
また、内側のスコープにある変数は親のスコープからなんらかの限定的なアクセスによって取り出すことはできません。

```@raw html
<!--
The following rules and examples pertain to local scopes.
A newly introduced variable in a local scope does not
back-propagate to its parent scope.
For example, here the ``z`` is not introduced into the top-level scope:
-->
```
以下の規則と例はローカルスコープに関するものです。
ローカルスコープに新しく導入される変数は、親のスコープに逆伝播しません。
例えば、ここにある``z``はトップレベルのスコープに導入されません。


```jldoctest
julia> for i = 1:10
           z = i
       end

julia> z
ERROR: UndefVarError: z not defined
```

```@raw html
<!--
(Note, in this and all following examples it is assumed that their top-level is a global scope
with a clean workspace, for instance a newly started REPL.)

Inside a local scope a variable can be forced to be a new local variable using the `local` keyword:
-->
```
（これ以降の例では、トップレベルが、新規に起動されたREPLなどの潔白な作業領域をもつ、グローバルスコープであることを想定している点に、
注意してください。）

ローカルスコープ内で、`local`キーワードを使って、変数を強制的に新しいローカル変数にすることができます。


```jldoctest
julia> x = 0;

julia> for i = 1:10
           local x # this is also the default
           x = i + 1
       end

julia> x
0
```

```@raw html
<!--
Inside a local scope a global variable can be assigned to by using the keyword `global`:
-->
```

ローカルスコープ内で`global`変数を使ってグローバル変数に代入することができます。

```jldoctest
julia> for i = 1:10
           global z
           z = i
       end

julia> z
10
```

```@raw html
<!--
The location of both the `local` and `global` keywords within the scope block is irrelevant.
The following is equivalent to the last example (although stylistically worse):
-->
```
スコープブロック内の`local`と`global`のキーワードの位置は共に無関係です。
下記のものは、直前の例と同等です（表記としては良くないですが）


```jldoctest
julia> for i = 1:10
           z = i
           global z
       end

julia> z
10
```

```@raw html
<!--
The `local` and `global` keywords can also be applied to destructuring assignments, e.g.
`local x, y = 1, 2`. In this case the keyword affects all listed variables.

Local scopes are introduced by most block keywords,
with notable exceptions of `begin` and `if`.
-->
```
`local`と`global`のキーワードは、例えば`local x, y = 1, 2`のように、分割代入にも適用されます。
この場合、キーワードはすべての列挙した変数に影響します。

ローカルスコープは大抵のブロックキーワードで導入されますが、注目すべき例外は`begin`と`if`です。



```@raw html
<!--
In a local scope, all variables are inherited from its parent
global scope block unless:

  * an assignment would result in a modified *global* variable, or
  * a variable is specifically marked with the keyword `local`.
-->
```
ローカルスコープでは、すべての変数を親のグローバルスコープブロックから、以下の場合を除き引き継ぎます。

  * 代入によって **グローバル** 変数が変更されている
  * 変数にキーワード`local`をわざわざつけている。


```@raw html
<!--
Thus global variables are only inherited for reading but not for writing:
-->
```
このように、グローバル変数が引き継ぐのは、読取りだけで、書込みは引き継ぎません。


```jldoctest
julia> x, y = 1, 2;

julia> function foo()
           x = 2        # assignment introduces a new local
           return x + y # y refers to the global
       end;

julia> foo()
4

julia> x
1
```

```@raw html
<!--
An explicit `global` is needed to assign to a global variable:
-->
```

グローバル変数に代入するには、わざわざ`global`を付ける必要があります。

```@raw html
<!--
!!! sidebar "Avoiding globals"
    Avoiding changing the value of global variables is considered by many
    to be a programming best-practice.
    One reason for this is that remotely changing the state of global variables in other
    modules should be done with care as it makes the local behavior of the program hard to reason about.
    This is why the scope blocks that introduce local scope require the ``global``
    keyword to declare the intent to modify a global variable.
-->
```

!!! sidebar "グローバル変数を避ける"
    グローバル変数の値の変更を避けることは、多くの人がベストプラクティスだと考えています。
    他のモジュールのグローバル変数の状態を遠隔で変更すると、プログラムのローカルな挙動を推論するのが困難になるので
    注意を払うべきだ、というのが理由の一つです。
    ローカルスコープを導入したブロックで グローバル変数を変更する旨を宣言するには、``global``キーワードが必要なのは、
    このためです。

```jldoctest    
julia> x = 1;

julia> function foobar()
           global x = 2
       end;

julia> foobar();

julia> x
2
```

```@raw html
<!--
Note that *nested functions* can modify their parent scope's *local* variables:
-->
```

**ネストした関数** は親のスコープの **local** 変数を変更できる点に注意してください。

```jldoctest
julia> x, y = 1, 2;

julia> function baz()
           x = 2 # introduces a new local
           function bar()
               x = 10       # modifies the parent's x
               ret
               urn x + y # y is global
           end
           return bar() + x # 12 + 10 (x is modified in call of bar())
       end;

julia> baz()
22

julia> x, y # verify that global x and y are unchanged
(1, 2)
```

```@raw html
<!--
The reason to allow *modifying local* variables of parent scopes in
nested functions is to allow constructing [`closures`](https://en.wikipedia.org/wiki/Closure_%28computer_programming%29)
which have a private state, for instance the ``state`` variable in the
following example:
-->
```

ネストした関数で親のスコープの **ローカル変数を変更できる**　理由は、
プライベートな状態を保持する [`クロージャ`](https://en.wikipedia.org/wiki/Closure_%28computer_programming%29)
を構成できるようにするためです。
以下の例の ``state`` 変数が具体例です。

```jldoctest
julia> let state = 0
           global counter() = (state += 1)
       end;

julia> counter()
1

julia> counter()
2
```

```@raw html
<!--
See also the closures in the examples in the next two sections. A variable
such as `x` in the first example and `state` in the second that is inherited
from the enclosing scope by the inner function is sometimes called a
*captured* variable. Captured variables can present performance challenges
discussed in [performance tips](@ref man-performance-tips).
-->
```

クロージャの例としては、次の２セクションも参照してください。
最初の例の`x`や二番目の例の`state`などは、周囲のスコープから内部の関数に引き継がれており、
**捕捉された** 変数と呼ばれます。
捕捉された変数がパフォーマンスの困難となりうる問題についての議論が[パフォーマンスティップス](@ref man-performance-tips)
にあります。


```@raw html
<!--
The distinction between inheriting global scope and nesting local scope
can lead to some slight differences between functions
defined in local vs. global scopes for variable assignments.
Consider the modification of the last example by moving `bar` to the global scope:
-->
```

グローバルスコープの引き継ぎとローカルスコープのネストの違いから、
ローカルスコープとグローバルスコープで定義された、変数の代入をおこなう関数が少しちがってきます。
最後の例の`bar`をグローバルスコープに移して少し変えることを考えてみましょう。


```jldoctest
julia> x, y = 1, 2;

julia> function bar()
           x = 10 # local, no longer a closure variable
           return x + y
       end;

julia> function quz()
           x = 2 # local
           return bar() + x # 12 + 2 (x is not modified)
       end;

julia> quz()
14

julia> x, y # verify that global x and y are unchanged
(1, 2)
```

```@raw html
<!--
Note that the above nesting rules do not pertain to type and macro definitions as they can only appear
at the global scope. There are special scoping rules concerning the evaluation of default and
keyword function arguments which are described in the [Function section](@ref man-functions).

An assignment introducing a variable used inside a function, type or macro definition need not
come before its inner usage:
-->
```

上記のネストの規則は、型やマクロの定義には関係ありません。
これは、グローバルスコープのみに表れるからです。
関数の引数のデフォルトとキーワードの評価に関連する特殊なスコープ規則については[関数のセクション](@ref man-functions)
に記述があります。


関数、型、マクロの定義の内部で使われる変数を導入して行う代入は、必ずしも内部の定義での前に行う必要はありません。



```jldoctest
julia> f = y -> y + a;

julia> f(3)
ERROR: UndefVarError: a not defined
Stacktrace:
[...]

julia> a = 1
1

julia> f(3)
4
```

```@raw html
<!--
This behavior may seem slightly odd for a normal variable, but allows for named functions -- which
are just normal variables holding function objects -- to be used before they are defined. This
allows functions to be defined in whatever order is intuitive and convenient, rather than forcing
bottom up ordering or requiring forward declarations, as long as they are defined by the time
they are actually called. As an example, here is an inefficient, mutually recursive way to test
if positive integers are even or odd:
-->
```

この挙動は、通常の変数としては少し変に思えるかもしれませんが、名前付き関数では、可能なことです。
名前付き関数は、関数オブジェクトを保持する単なる通常の変数で、定義を行う前に利用します。
これによって、実際に関数が呼ばれる前に定義されている限り、関数の定義をどんな順番でも、直感的で便利に行うことができ、
ボトムアップの順序や事前の宣言にこだわる必要はありません。
ここであげるのは、非効率で相互再帰な方法でおこなう、正の整数が偶数か奇数かを検査する例です。


```jldoctest
julia> even(n) = (n == 0) ? true : odd(n - 1);

julia> odd(n) = (n == 0) ? false : even(n - 1);

julia> even(3)
false

julia> odd(3)
true
```

```@raw html
<!--
Julia provides built-in, efficient functions to test for oddness and evenness called [`iseven`](@ref)
and [`isodd`](@ref) so the above definitions should only be considered to be examples of scope,
not efficient design.
-->
```
Juliaには、組込みの効率的な偶数性や奇数性を確認する[`iseven`](@ref)や[`isodd`](@ref)といった関数があるので、
上記の例は、効率的な設計ではなくスコープの例としてだけ考えるべきでしょう。


`[](### Let Blocks)
### Let ブロック

```@raw html
<!--
Unlike assignments to local variables, `let` statements allocate new variable bindings each time
they run. An assignment modifies an existing value location, and `let` creates new locations.
This difference is usually not important, and is only detectable in the case of variables that
outlive their scope via closures. The `let` syntax accepts a comma-separated series of assignments
and variable names:
-->
```

ローカル変数の代入とは違い、`let`文は毎回実行時に新しく変数の束縛しメモリを割り当てます。
代入は既存の場所の値を変更し、`let`では新しい場所に生成します。
この違いは、通常それほど重要ではなく、検出できるのもスコープ外のクロージャに変数があるときのみです。
`let`構文はコンマで区切った一連の代入と変数名を受け取ります。


```jldoctest
julia> x, y, z = -1, -1, -1;

julia> let x = 1, z
           println("x: $x, y: $y") # x is local variable, y the global
           println("z: $z") # errors as z has not been assigned yet but is local
       end
x: 1, y: -1
ERROR: UndefVarError: z not defined
```

```@raw html
<!--
The assignments are evaluated in order, with each right-hand side evaluated in the scope before
the new variable on the left-hand side has been introduced. Therefore it makes sense to write
something like `let x = x` since the two `x` variables are distinct and have separate storage.
Here is an example where the behavior of `let` is needed:
-->
```
代入は順番に評価されます。
それぞれ右辺は左辺の新しい変数が導入される前に評価されます。
そのため、`let x = x`のような式も意味があり、２つの変数`x`は異なり、別々に格納されています。
こういう`let`の挙動が必要な例を挙げます。




```jldoctest
julia> Fs = Vector{Any}(undef, 2); i = 1;

julia> while i <= 2
           Fs[i] = ()->i
           global i += 1
       end

julia> Fs[1]()
3

julia> Fs[2]()
3
```

```@raw html
<!--
Here we create and store two closures that return variable `i`. However, it is always the same
variable `i`, so the two closures behave identically. We can use `let` to create a new binding
for `i`:
-->
```
ここでは、変数`i`を返すクロージャを生成し。格納します。
しかし、`i`は常に同じ変数で、２つのクロージャは全く同等の挙動をします。
`let`を新しい束縛の`i`を生成するために利用することができます。



```jldoctest
julia> Fs = Vector{Any}(undef, 2); i = 1;

julia> while i <= 2
           let i = i
               Fs[i] = ()->i
           end
           global i += 1
       end

julia> Fs[1]()
1

julia> Fs[2]()
2
```

```@raw html
<!--
Since the `begin` construct does not introduce a new scope, it can be useful to use a zero-argument
`let` to just introduce a new scope block without creating any new bindings:
-->
```

`begin`構文は新しいスコープを導入しないので、引数のない`let`を使って単に新しいスコープブロックを導入するだけで、
新しい束縛を生成しないのも、役に立つこともあります。



```jldoctest
julia> let
           local x = 1
           let
               local x = 2
           end
           x
       end
1
```

```@raw html
<!--
Since `let` introduces a new scope block, the inner local `x` is a different variable than the
outer local `x`.
-->
```
`let`は新しいスコープブロックを導入するので、内側のローカル変数 `x`は外側のローカル変数 `x`と異なります。

`[](### For Loops and Comprehensions)
### For ループと内包表記

```@raw html
<!--
`for` loops, `while` loops, and [Comprehensions](@ref) have the following behavior: any new variables
introduced in their body scopes are freshly allocated for each loop iteration, as if the loop body
were surrounded by a `let` block:
-->
```

`for`ループ、`while`ループ、[内包表記](@ref)は以下のような挙動を取ります。
ループ本体のスコープの導入されるすべての新しい変数はループの反復ごとに新しくメモリに割当てられて、
ループの本体が`let`ブロックに囲まれているかのようにふるまう。



```jldoctest
julia> Fs = Vector{Any}(undef, 2);

julia> for j = 1:2
           Fs[j] = ()->j
       end

julia> Fs[1]()
1

julia> Fs[2]()
2
```

```@raw html
<!--
A `for` loop or comprehension iteration variable is always a new variable:
-->
```

`for`ループや内包表記の反復で、変数は常に新しい変数です。

```julia-repl enable_doctest_when_deprecation_warning_is_removed
julia> function f()
           i = 0
           for i = 1:3
           end
           return i
       end;

julia> f()
0
```

```@raw html
<!--
However, it is occasionally useful to reuse an existing variable as the iteration variable.
This can be done conveniently by adding the keyword `outer`:
-->
```
しかし、既存の変数を反復の変数として再利用するのも、役に立つときがあります。
これを行うには、`outer`キーワードを使うと便利です。



```jldoctest
julia> function f()
           i = 0
           for outer i = 1:3
           end
           return i
       end;

julia> f()
3
```

`[](## Constants)
## 定数

```@raw html
<!--
A common use of variables is giving names to specific, unchanging values. Such variables are only
assigned once. This intent can be conveyed to the compiler using the `const` keyword:
-->
```

変数のよくある使い方として、特定の変化しない値に名前をつけることがあります。
こういった変数はたった一度代入されるだけです。
こうした意図は`const`キーワードを使ってコンパイラに伝えることができます。



```jldoctest
julia> const e  = 2.71828182845904523536;

julia> const pi = 3.14159265358979323846;
```

Multiple variables can be declared in a single `const` statement:
```jldoctest
julia> const a, b = 1, 2
(1, 2)
```

```@raw html
<!--
The `const` declaration should only be used in global scope on globals.
It is difficult for the compiler to optimize code involving global variables, since
their values (or even their types) might change at almost any time. If a global variable will
not change, adding a `const` declaration solves this performance problem.
-->
```

`const`宣言はグローバルスコープにあるグローバル変数に対してだけ行うべきです。
コンパイラがグローバル変数を含むコードを最適化するのは、困難です。
というのもその値（や型でさえも）ほとんどいつでも変わりうるからです。
グローバル変数が変化しない時には、`const`宣言によってこのパフォーマンスの問題が解決します。


```@raw html
<!--
Local constants are quite different. The compiler is able to determine automatically when a local
variable is constant, so local constant declarations are not necessary, and in fact are currently
not supported.

Special top-level assignments, such as those performed by the `function` and `struct` keywords,
are constant by default.
-->
```
ローカル変数は全く異なります。
ローカル変数が一定の時は、自動的に決定可能です。
そのため、定数の宣言は必要なく、実のところ対応していません。

 `function`や`struct`キーワードで実行されるような、特殊なトップレベルの代入は、デフォルトでは定数です。



```@raw html
<!--
Note that `const` only affects the variable binding; the variable may be bound to a mutable
object (such as an array), and that object may still be modified. Additionally when one tries
to assign a value a variable that is declared constant the following scenarios are possible:
-->
```
`const`は変数束縛だけに影響する点に注意してください。
変数は（配列のような）可変オブジェクトを束縛してもいいので、変更可能かもしれません。
さらに、定数だと宣言した変数に値を代入しようとする、以下のようなシナリオもありえます。


```@raw html
<!--
* if a new value has a different type than the type of the constant then an error is thrown:
-->
```

* 新しい値が定数の型と異なる型の時、エラーが投げられます。


```jldoctest
julia> const x = 1.0
1.0

julia> x = 1
ERROR: invalid redefinition of constant x
```
```@raw html

<!--
* if a new value has the same type as the constant then a warning is printed:
-->
```
* 新しい値が定数と同じ型の時、警告が表示される。

```jldoctest
julia> const y = 1.0
1.0

julia> y = 2.0
WARNING: redefining constant y
2.0
```

```@raw html
<!--
* if an assignment would not result in the change of variable value no message is given:
-->
```
代入が結果として変数の値を変えない時、メッセージを出さない。

```jldoctest
julia> const z = 100
100

julia> z = 100
100
```
```@raw html
<!--
The last rule applies for immutable objects even if the vairable binding would change, e.g.:
-->
```

最後の規則は変数の束縛が変わりうる時も、不変オブジェクトに適用されます。

```julia-repl
julia> const s1 = "1"
"1"

julia> s2 = "1"
"1"

julia> pointer.([s1, s2], 1)
2-element Array{Ptr{UInt8},1}:
 Ptr{UInt8} @0x00000000132c9638
 Ptr{UInt8} @0x0000000013dd3d18

julia> s1 = s2
"1"

julia> pointer.([s1, s2], 1)
2-element Array{Ptr{UInt8},1}:
 Ptr{UInt8} @0x0000000013dd3d18
 Ptr{UInt8} @0x0000000013dd3d18
```
```@raw html
<!--
However, for mutable objects the warning is printed as expected:
-->
```
しかし、可変オブジェクトには想定通り警告が表示されます。

```jldoctest
julia> const a = [1]
1-element Array{Int64,1}:
 1

julia> a = [1]
WARNING: redefining constant a
1-element Array{Int64,1}:
 1
```

```@raw html
<!--
Note that although possible, changing the value of a variable that is declared as constant
is strongly discouraged. For instance, if a method references a constant and is already
compiled before the constant is changed then it might keep using the old value:
-->
```
定数だと宣言した変数の値を変更することは、もし可能であっても、強く反対します。
例えば、定数を参照するメソッドは、定数の変更される前にすでにコンパイルされて、古い値のまま使われ続けます。


```jldoctest
julia> const x = 1
1

julia> f() = x
f (generic function with 1 method)

julia> f()
1

julia> x = 2
WARNING: redefining constant x
2

julia> f()
1
```
