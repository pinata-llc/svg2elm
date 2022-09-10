module Svg2Elm.Generator exposing (compileFunction)

import Regex
import String.Case exposing (toCamelCaseLower)
import SvgParser exposing (SvgAttribute, SvgNode(..), parseToNode)


quote : String -> String
quote val =
    if String.contains "\n" val || String.contains "\u{000D}" val || String.contains "\"" val then
        "\"\"\"" ++ val ++ "\"\"\""

    else
        "\"" ++ val ++ "\""


compileAttributes : List SvgAttribute -> String
compileAttributes =
    String.join ", "
        << List.map
            (\( name, val ) -> "attribute " ++ quote name ++ " " ++ quote val)


compileChildren : List SvgNode -> String
compileChildren =
    let
        nodeJoin node =
            case node of
                SvgComment _ ->
                    " "

                _ ->
                    ", "
    in
    List.foldl (\node b -> b ++ nodeJoin node ++ compileNode False node) ""
        >> String.dropLeft 1


compileNode : Bool -> SvgNode -> String
compileNode attrs node =
    case node of
        SvgElement { name, attributes, children } ->
            "Svg.node "
                ++ quote name
                ++ " (["
                ++ compileAttributes attributes
                ++ (if attrs then
                        "] ++ attrs) "

                    else
                        "]) "
                   )
                ++ "["
                ++ compileChildren children
                ++ "]"

        SvgText text ->
            "Svg.text(" ++ quote text ++ ")"

        SvgComment comment ->
            "{-" ++ comment ++ "-}"


compileFunction : String -> String -> Result String String
compileFunction name code =
    let
        fnName =
            name
                |> toCamelCaseLower
                |> prefixDigitLeadingNames

        fixedCode =
            case Regex.fromString "([\\s\\S]*)<svg" of
                Nothing ->
                    code

                Just regex ->
                    Regex.replaceAtMost 1 regex (\_ -> "<svg") code
    in
    parseToNode fixedCode
        |> Result.map
            (compileNode True >> (++) (fnName ++ " : List (Attribute msg) -> Svg.Svg msg\n" ++ fnName ++ " attrs = "))


prefixDigitLeadingNames : String -> String
prefixDigitLeadingNames name =
    case String.uncons name of
        Just ( first, rest ) ->
            if Char.isDigit first then
                "n" ++ name

            else
                name

        Nothing ->
            name
