#import "@preview/touying:0.6.1": *
#import "theme/dresdenrb.typ": *
#import "theme/code.typ": init-code

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

== Benefits of Static Typing

// might be included in idea

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
    - common idioms like duck typing or polymorphism are hard to type
    - DSLs that generate methods at runtime are hard to type statically

  - What even is a type in Ruby?
    - Ask the audience, what do they think?
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

== Racer.rb - Ruby Runtime Tracer

- built for my master thesis in 2025
- generates RBS signature files from runtime code execution
- integrates with test frameworks to generates types from your test runs
- supports Rails's test parallelization
- tested in our company's largest Rails code base with over 170k LOC

== Demo

== How does it work?

== Future Development
