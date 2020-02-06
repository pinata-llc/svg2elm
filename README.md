# svg2elm

[![npm version](https://img.shields.io/npm/v/svg2elm.svg)](https://www.npmjs.com/package/svg2elm) [![GitHub license](https://img.shields.io/npm/l/svg2elm)](LICENSE)

This CLI tool takes one or more SVG files and generates an Elm module with a function per file.

## Installation

You can install `svg2elm` from npm:

```console
$ npm install -g svg2elm
```

## How to use

Let's say we have a chevron icon that we want to embed in our Elm app:

```console
$ cat chevron.svg
```

```html
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
    <line x1="1" y1="1" x2="50" y2="50" stroke-linecap="round" />
    <line x1="50" y1="50" x2="1" y2="99" stroke-linecap="round" />
</svg>
```

Using `svg2elm` we can generate an Elm module out of it. Let's call ours `Acme.Icons`:

```console
$ svg2elm --module Acme.Icons chevron.svg > Acme/Icons.elm
```

```elm
module Acme.Icons exposing (..)

import Svg
import VirtualDom exposing (Attribute, attribute)

chevron : List (Attribute msg) -> Svg.Svg msg
chevron attrs = Svg.node "svg" ([attribute "xmlns" "http://www.w3.org/2000/svg", attribute "viewBox" "0 0 100 100"] ++ attrs) [ Svg.node "line" ([attribute "x1" "1", attribute "y1" "1", attribute "x2" "50", attribute "y2" "50", attribute "stroke-linecap" "round"]) [], Svg.node "line" ([attribute "x1" "50", attribute "y1" "50", attribute "x2" "1", attribute "y2" "99", attribute "stroke-linecap" "round"]) []]
```

We are now ready to embed the icon in our app! Since the generated function returns an [Svg](https://package.elm-lang.org/packages/elm/svg/latest/Svg#Svg) node, we can use it like any other element:

```elm
import Acme.Icons exposing (chevron)

...

nextPage =
    button []
        [ text "Next Page"
        , chevron []
        ]
```

## SVG Attributes

Note that the generated function takes a [List](https://package.elm-lang.org/packages/elm/core/latest/List) of [Attributes](https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#Attribute):

```elm
chevron : List (Attribute msg) -> Svg.Svg msg
```

This allows us to tweak our icons in a per usage basis. For example, if we wanted to point our chevron to the left, we could do the following:

```elm
previousPage =
    button []
        [ text "Previous Page"
        , chevron [ transform "rotate(180)" ]
        ]
```

Similarly, we could change the size, colors, stroke width, etc.

```elm
...
        , chevron [ width "30", stroke "blue", strokeWidth "2" ]
...
```

Attributes are appended to the top SVG node. This means that you can only override those set at that level. This is usually not a problem since child nodes inherit parent attributes. However, you might have to tweak your SVG to fit your needs.

## Multiple icons per module

You likely want to generate a module with all your app icons. You can do this by passing multiple files to `svg2elm`:

```console
$ svg2elm --module Acme.Icons icons/chevron.svg icons/user.svg
```

...or you can use globs:

```console
$ svg2elm --module Acme.Icons icons/*.svg
```

A function will be generated for each SVG file.

## Elm UI

If you're using the _awesome_ [mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/), you have to use [Element.html](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#html) to turn your [Svg](https://package.elm-lang.org/packages/elm/svg/latest/Svg#Svg) node into an [Element](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#Element).

```elm
nextPage =
    button []
        [ text "Next Page"
        , chevron [] |> html
        ]
```

## Humans

Thanks to [rnons](https://github.com/rnons) for building [elm-svg-parser](https://package.elm-lang.org/packages/rnons/elm-svg-parser/latest/) and [Garados007](https://github.com/Garados007) for making it work with Elm 0.19.

Built by [Piotr Brzeziński](https://github.com/brzezinskip) and [Agustín Zubiaga](https://github.com/aguzubiaga) at [PINATA.](https://www.gopinata.com)

🤍
