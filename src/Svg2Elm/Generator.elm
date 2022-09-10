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


compileNodes : Bool -> List SvgNode -> String
compileNodes attrs =
    let
        nodeStep node =
            case node of
                SvgElement { name, attributes, children } ->
                    "Svg.node "
                        ++ quote name
                        ++ (if attrs then
                                " ([ "

                            else
                                " [ "
                           )
                        ++ compileAttributes attributes
                        ++ (if attrs then
                                " ] ++ attrs) "

                            else
                                " ] "
                           )
                        ++ (if List.isEmpty children then
                                "[],"

                            else
                                "[ "
                                    ++ compileNodes False children
                                    ++ " ],"
                           )

                SvgText text ->
                    "Svg.text (" ++ quote text ++ "),"

                SvgComment comment ->
                    "{- " ++ String.trim comment ++ " -} "
    in
    List.map nodeStep
        >> String.concat
        >> String.dropRight 1


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
    Result.map
        (\rootNode ->
            fnName
                ++ " : List (Attribute msg) -> Svg.Svg msg\n"
                ++ fnName
                ++ " attrs ="
                ++ "\n    "
                ++ compileNodes True [ rootNode ]
        )
        (parseToNode fixedCode)


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
