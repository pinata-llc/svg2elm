# svg2elm

[![npm version](https://img.shields.io/npm/v/svg2elm.svg)](https://www.npmjs.com/package/svg2elm) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](LICENSE)

Status: *Experimental*

Turn SVG files into Elm code

## Install

```sh
$ npm install -g svg2elm
```

## Usage

Running

```sh
$ svg2elm --module Company.Icons chevron.svg
```

Outputs

```elm
module Company.Icons exposing (..)

import Svg
import VirtualDom exposing (Attribute, attribute)

chevron : List (Attribute msg) -> Svg.Svg msg
chevron attrs = Svg.node "svg" (attrs ++ [attribute "role" "img", attribute "xmlns" "http://www.w3.org/2000/svg", attribute "viewBox" "0 0 448 512"]) [ Svg.node "path"( [attribute "d" "M207.029 381.476L12.686 187.132c-9.373-9.373-9.373-24.569 0-33.941l22.667-22.667c9.357-9.357 24.522-9.375 33.901-.04L224 284.505l154.745-154.021c9.379-9.335 24.544-9.317 33.901.04l22.667 22.667c9.373 9.373 9.373 24.569 0 33.941L240.971 381.476c-9.373 9.372-24.569 9.372-33.942 0z"]) []]
```

