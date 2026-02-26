#import "@preview/touying:0.6.1": *
#import "theme/dresdenrb.typ": *
#import "theme/code.typ": init-code
#import "@preview/codly:1.3.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, shapes.ellipse, shapes.cylinder, shapes.rect

#set figure(numbering: none)

#show: init-code.with()
#show: dresdenrb-theme.with(
  show-notes-on-second-screen: bottom,
  config-info(
    title: [
      #set text(size: 28pt)
      Generating Type Signatures at Runtime with Racer
    ],
    short-title: [Racer: Generating Types at Runtime],
    author: [Richard Böhme],
    date: datetime(year: 2026, month: 2, day: 26),
    institution: [Dresden.rb - Ruby User Group],
    email: [richard.boehme@webit.de],
  ),
)

#title-slide()

== The Idea

- static typing is useful, because it...
  - avoids a whole category of errors
  - documents interfaces
  - supports newcomers in your projects
- but static typing is also...
  - hard to do in existing untyped projects
  - annoying?!

#v(1.5em)

#text(size: 20pt)[
*What if we could generate type signatures from running our test suite?*
]

#speaker-note[
  #set text(size: 20pt)
  - lets start with some quick question:
    - who uses static typing today?
    - who uses static typing with Ruby?
    - who likes or would like to work with static typing?
  - static typing is nice because it lets us avoid all kind of type errors, documents interfaces and thus supports newcomers in your projects
  - but types also need to be written down and often times people have to fight against the type system to implement complex interfaces
  - also personally I sometimes find writing types annoying, maybe you can relate
  - so I askes myself the question: What if we could generate type signatures from running our test suite?
  - lets tart about how typing in Ruby works
]

== Type Signatures in Ruby

- Typing in Ruby is hard..
  - no 1st-level support for type signatures
  - common idioms like duck typing or polymorphism are hard to type
  - DSLs that generate methods at runtime are hard to type statically

#v(1.5em)

#text(size: 20pt)[
  *What even is a type in Ruby?*
]

#speaker-note[
  - Typing in Ruby is hard..
    - no 1st-level support for type signatures (like in Python or PHP)
    - common idioms like duck typing or polymorphism are generally hard to type
    - the same applies for DSLs that generate methods at runtime

  - question arises: What even is a type in Ruby? What do you think?
]

#pagebreak()

=== Would you consider classes a type?

#v(1.5em)

```ruby
"static typing rocks!".to_typename
# => undefined method 'to_typename' for an instance of String (NoMethodError)

class String
  def to_typename
    self.class.name
  end
end

"static typing rocks!".to_typename
# => "String"
```

#speaker-note[
  - Would you consider classes a type?
    - the definition of members (instance variables or methods) can change at any time during execution
    => Methods maybe available at one point but not at another point in your app
]

#pagebreak()

=== Would you consider an instance a type?

#v(1.5em)

```ruby
object = Object.new
object.to_typename
# => undefined method 'to_typename' for an instance of Object (NoMethodError)

def object.to_typename
  "My Custom Type"
end

object.to_typename
# => "My Custom Type"
```

#speaker-note[
  - Maybe a single instance could be a type?
    - but its still possible to change the interface of an object at any point in your app
]

#pagebreak()

#v(3em)

#align(center)[
  #text(size: 25pt)[
    *Ruby has no static concept of types*

    #v(1em)

    So how do people implement static typing in Ruby?
  ]
]

#pagebreak()

=== Sorbet

- static type checker built by Stripe since 2017
- providing types with a Ruby DSL that can be statically analyzed and checked at runtime
- widely adopted by companies like Shopify, GitHub, Gusto, Kickstarter and more

#v(1em)

```ruby
# typed: true
extend T::Sig

sig { params(name: String).returns(Integer) }
def main(name)
  puts "Hello, #{name}!"
  name.length
end
```

#speaker-note[
  #set text(size: 20pt)
  - Sorbet static type checker built by Stripe since 2017
  - it provides a Ruby DSL to allow defining types and that can be statically analyzed and checked at runtime
  - widely adopted by companies like Shopify, GitHub, Gusto, Kickstarter and more
  - example shows the example from Sorbet's website, typing a main method that takes one String parameter and returns an Integer
  - you can see that the DSL is pure Ruby, a block passed to the `sig` method and method chains to define the types
  - in my opinion this works well but it's really different from what people know from other languages which may make it harder to learn
]

#pagebreak()

=== RBS

- Ruby's official type signature language since Ruby 3
- type checker and other tools are maintained by the community (not official)
- types only in separate `.rbs` files
- not widely adopted but language standard and actively worked on

#v(1em)

```rbs
def main: (String name) -> Integer
```

#speaker-note[
  #set text(size: 20pt)
  - RBS is Ruby's official type signature language since Ruby 3
  - however Ruby only ships the language, the type checker and other tools are maintained by the community
  - types signatures are written into separate RBS-files that only contain the type without the implementation
  - its not widely adopted yet but it's Ruby's standard and actively being worked on
  - example shows the same method as before
  - in my opinion the type syntax feels more natural than Sorbet's because it's more similar to other existing type systems
  - but writing all types in separate files is cumbersome without proper tooling -> this is exactly where RBS lacks
]

#pagebreak()

=== RBS Inline

- pretty new development of an inline variant of RBS
- experimental support by the Sorbet Type checker
- conversion to RBS files possible
- Shopfiy migrated most of their open source work suggesting heavy investments by them
- still being worked on, not all syntax supported

#v(1em)

```ruby
#: (String name) -> Integer
def main(name)
  puts "Hello, #{name}!"
  name.length
end
```

#speaker-note[
  #set text(size: 20pt)
  - a pretty new development is the inline variant of RBS
  - interesting: there is experimental support for it in the Sorbet type checker
    -> meaning: we can use the Sorbet type checker to type check RBS inline signatures
  - its also possible to convert the signatures into proper RBS files to be able to type check them with the de facto default type checker for RBS called steep
  - Shopify already migrated all their open source tools from Sorbet to RBS Inline which suggests that they want to heavily invest into it
  - but it's still work in progress and not all RBS syntax is supported yet
  - example shows the method main method and personally I like this variant the most because it combines the advantages of the compact syntax of RBS and the inline variant of Sorbet
  - ok lets move on and talk about Racer, the library I implemented to generate type signatures automatically
]

== Racer.rb - Ruby Runtime Tracer

- built for my master thesis in 2025
- generates RBS signature files from runtime code execution
- integrates with test frameworks to generates types from your test runs
- supports Rails's test parallelization
- tested in our company's largest Rails code base with over 170k LOC

#speaker-note[
  - Racer was built for my master thesis last year
  - it runs during runtime, for example while running your tests and records the types with which methods are being called
    - this uses the advantage that pretty much everything in ruby is a method call
  - Racer also integrates with Minitest and RSpec and supports parallelization
  - I tested Racer in many Rails apps in our company, also in the largest one with over 170k LOC of pure Ruby code
]

== Demo

*Rails app to manage user group meetings and participants*
#v(0.6em)
Schema:

#align(center + horizon)[
  #image("images/erd.png", height: 65%)
]

#speaker-note[
  - I want to show you how to use the library
  - For the demo I built a small Rails app to manage user group meetings and participants with the schema that you can see here
  - I also used oaken to generate test data for those models
  - open demo app
  - show Rails app and oaken seeds
  - open meeting test -> currently untyped
  - install Racer gem
  - require racer/minitest in test_helper
  - run tests
  - look into signatures
  - comment in tests.rbs and explain
  - show meetingtest -> now has proper types
  - show limitations -> no generics/wrong types
]

== How does it work?

```rb
# Gemfile
gem "racer-rb"

# test/test_helper.rb
require "racer/minitest"

# spec/spec_helper.rb
require "racer/rspec"

RSpec.configure do |config|
	Racer::RSpecPlugin.configure(config)
end
```

#speaker-note[
  - Install gem from rubygems and add it to your Gemfile
  - requires Ruby 4
  - Install dependencies (currently jsonc is required)
  - require entry point dependent on test framework
  - current configuration works for rails but may have issues with gems or other code -> needs a way to configure
  - ensure that your tests eager load the application (e.g. by using CI=1)
  - next I want to get into some of the implementation of it, please ask if anything is not clear or needs further explanation
]

#pagebreak()


#slide(header-below: 0.7em)[
  #codly-disable()
  #figure(
    diagram(node-stroke: black, spacing: (1.5em, 0em), node-inset: 0.7em, {
      node((0, 4.5), stroke: none, inset: 0.5em, rotate(-90deg, reflow: true)[Worker Process])
      node((1, 0), stroke: black, outset: 0em, [
        ```ruby
        Foobar.sum(1, 2)
        ```
      ])
      node((3, 0), stroke: black, outset: 0em, [
        ```ruby
        => 3
        ```
      ])

      node((3.45, 2), stroke: none, inset: 2em, [C-Extension])

      node((1, 3), stroke: black, [
        Call-TracePoint
      ])
      edge((1, 0), (1, 3), "-|>", [])

      node((3, 3), stroke: black, [
        Return-TracePoint
      ])
      edge((3, 0), (3, 3), "-|>", [])

      node((2, 4), stroke: black, [
        Callstack
      ], shape: cylinder)
      edge((1, 3), (2, 4), "-|>", [])
      edge((2, 4), (3, 3), "-|>", [])

      node((3, 5), stroke: none, inset: 0.5em, [
        _IPC-Thread_
      ])
      node((3, 6), stroke: none, inset: 0em, [
        Message:
        ```json
        ["sum", 1, 0, ...]
        ```
      ])
      node(enclose: ((3, 5), (3, 6)), stroke: (dash: "dashed"))
      edge((3, 3), (3, 5), "-|>")

      node(enclose: ((1, 3), (3, 3), (2, 3), (3, 5), (3, 6)), snap: -1, inset: 1.5em)
      node(enclose: ((0, 4), (1, 0), (3, 0), (1, 3), (3, 3), (2, 3), (3, 5), (3, 6), (3.5, 2)), snap: -1, inset: 2em)
    })
  )

  #speaker-note[
    #set text(size: 20pt)
    - you can see here the general type collection work that happens during runtime or in all your test processes
    - If a method is called a call tracepoint intercepts that call, stores all type information and pushes that into a callstack
    - TracePoints are a Ruby core API that allow developers to execute code if a specific event, in this case a method call or return, happens
    - if the method returns the last entry of the call stack is completed with the return type and the type information is pushed into an IPC thread that creates a JSON message and pushes this over a socket to an agent process
    - The whole tracepoint handling is built as a C-Extension to allow for better performance
  ]
]

#slide(header-below: 2em)[
  #figure(
    diagram(node-stroke: black, spacing: (1em, 1em), node-inset: 1em, {
      node((1, -2), [Worker \#1])
      node((2, -2), stroke: (dash: "dashed"), [Worker \#2])
      node((3, -2), stroke: (dash: "dashed"), [Worker \#3])

      // node((0, 1.5), stroke: none, rotate(-90deg, reflow: true)[Agent])
      node((0.4, 3.5), stroke: none, [_Agent_])

      node((1, 1), [Connection Handler])
      edge((1, -2), (1, 1), "-|>")

      node((1, 2), [`Racer::Trace`])
      edge((1, 1), (1, 2), "-|>")



      node((3, 1), stroke: none, [_Type Processing Thread_])
      node((3, 2), [`Racer::Trace`], shape: rect)
      node((2.5, 3), [RBSCollector])
      node((3.5, 3), [OtherCollector], stroke: (dash: "dashed"), shape: rect)
      edge((3, 2), (3.5, 3), "-|>")
      edge((3, 2), (2.5, 3), "-|>")

      node((2, 2), shape: cylinder, fill: white, [Queue])
      edge((1, 2), (2, 2), "-|>")
      edge((2, 2), (3, 2), "-|>")

      node((2.5, 4.8), [`foobar.rbs`])
      edge((2.5, 3), (2.5, 4.8), "-|>")

      node(enclose: ((3, 1), (3, 2), (2.5, 3), (3.5, 3)), snap: -1, stroke: (dash: "dashed"), inset: 1em)
      node(enclose: ((1, 1), (1, 2), (3, 1), (3, 2), (2.5, 3), (3.5, 3)), snap: -1, inset: 1.5em)
    })
  )

  #speaker-note[
    #set text(size: 17pt)
    - the agent process is a separate process that is spawned when racer launches and exists to accept type information from multiple worker processes
    - It handles socket connections with the workers and accepts the IPC messages I showed earlier
    - it then builds a trace object and pushes that to a queue
    - a separate thread than pops from that queue and distributes the trace to all collectors which then process the trace information
    - currently there is only one collector, the RBSCollector that generates RBS code, but in theory there could be multiple collectors running at the same time
    - if the connection with all worker processes finished, the collectors are stopped which is when the RBSCollector writes the RBS files and the agent process terminates
    - there is of course a lot more to this but I think this is enough to give a broad overview of the architecture that Racer uses
    - I just published the gem a few days ago, but it's still in really early stages, expect crashes, wrong types or other weird behavior
    - for the future I want to:
  ]
]


== Future Development

#stack(
  spacing: 1.5em,
  text(size: 20pt)[#emoji.computer Improve editor integration],
  text(size: 20pt)[#emoji.lightning Optimize performance],
  text(size: 20pt)[#emoji.arrows.cycle Incremental signature generation],
  text(size: 20pt)[#emoji.icecream Sorbet support],
  text(size: 20pt)[#emoji.notepad Improved documentation],
  text(size: 20pt)[#emoji.gear More configuration],
)

#speaker-note[
  #set text(size: 17pt)

  - Improve editor integration: During testing at webit! we noticed the sheer of generated RBS overwhelmed some editors leading to poor performance or even other features not working properly anymore
  - optimize performance: type signature collection currently takes ~ 1.3 times the time it takes to run the tests without collection -> improve that
  - incremental generation: currently all signatures are regenerated, this makes it hard to manually edit them and also makes it impossible to generate types from just one test as this would remove all other signatures
  - sorbet support: sorbet is another target that could be implemented as a collector: widely adopted and LSP is much faster
  - improved documentation: I just quickly published the gem before this talk so documentation is pretty sparse currently
  - more configuration: Currently manual configuration is hard and the default config is made for rails apps only
]

#let background = [
  #place(
    top + left,
    polygon(
      fill: color.rgb(75, 0, 45),
      (5in, 100%),
      (10in, 0%),
      (100%, 0%),
      (100%, 100%),
    ),
  )
  #place(
    top + left,
    polygon(
      fill: tiling(size: (56pt, 75pt))[#image("cd/logo/Logo_Dresdenrb_Pattern_Purple.svg"))],
      (5in, 100%),
      (10in, 0%),
      (100%, 0%),
      (100%, 100%),
    ),
  )

  #place(
    top + end,
    dx: -0.8in,
    dy: 2.4in,
    image("cd/logo/Logo_Dresdenrb_Outline_1c_w.svg", width: 3in),
  )
]

#slide(background: background)[
  ==
  #v(3em)
  #text(size: 35pt, weight: "semibold")[
    Thank you for your attention!
  ]
  \
  #text(size: 25pt)[
    Any questions or feedback?
  ]
]

== Fun with Ruby-weirdnesses

*Constants with invalid names*
#v(1em)

```rb
StringIO.ancestors
# => [
#   StringIO,
#   IO::generic_writable,
#   IO::generic_readable,
#   Enumerable,
#   ...
# ]
IO.const_get("generic_readable")
# => 'Module#const_get': wrong constant name generic_readable (NameError)
```

#pagebreak()

*RBS not supporting all Ruby method names*
#v(1em)

```rb
define_method("` test: return dresden.rb`") { "dresden.rb" }
send("` test: return dresden.rb`")
# => "dresdenrb"
```
#v(2em)

Those methods cannot be typed with RBS:
#v(0.5em)
```rbs
class Object
  def ` test: return dresden.rb`: () -> String
end
# => Syntax error: expected a token `pCOLON`, token=`test` (tLIDENT) (RBS::SyntaxError)
```

#speaker-note[
  - this was especially interesting with the methods generated by minitest
  - fixed by just not generated signatures for now
]
