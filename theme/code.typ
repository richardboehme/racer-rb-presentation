#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *

#show: codly-init.with()
#codly(
  languages: (rbs: (..codly-languages.rb, name: [RBS]), ..codly-languages), 
  number-format: none, zebra-fill: none, lang-stroke: none
)

#set raw(syntaxes: ("code/rbs.sublime-syntax"))
