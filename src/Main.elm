module Main exposing (main)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Ports
import Regex
import String.Case exposing (toCamelCaseLower)
import SvgParser exposing (SvgAttribute, SvgNode(..), parseToNode)



-- Generator


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
                ++ (if attrs then
                        " (attrs ++"

                    else
                        "("
                   )
                ++ " ["
                ++ compileAttributes attributes
                ++ "]) "
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
            toCamelCaseLower name

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



-- CLI


type alias CompileOptions =
    { moduleName : String
    , paths : List String
    }


type Msg
    = FilesRead (List ( String, String ))


type alias Model =
    ()


update : CompileOptions -> Msg -> Model -> ( Model, Cmd Msg )
update options msg _ =
    case msg of
        FilesRead files ->
            let
                header =
                    Ok <| "module " ++ options.moduleName ++ " exposing (..)" ++ "\n\nimport Svg\nimport VirtualDom exposing (Attribute, attribute)"

                compiled =
                    List.foldl (\( name, code ) -> Result.andThen (\r -> Result.map ((++) <| r ++ "\n\n") (compileFunction name code))) header files
            in
            case compiled of
                Ok compiledCode ->
                    ( (), Ports.print compiledCode )

                Err err ->
                    ( (), Ports.print <| "Error while parsing SVG: " ++ err )


init : Flags -> CompileOptions -> ( Model, Cmd Msg )
init _ options =
    ( (), Ports.readFiles options.paths )


type alias Flags =
    Program.FlagsIncludingArgv {}


subscriptions : a -> Sub Msg
subscriptions _ =
    Ports.filesRead FilesRead


programConfig : Program.Config CompileOptions
programConfig =
    Program.config
        |> Program.add
            (OptionsParser.build CompileOptions
                |> OptionsParser.with (Option.requiredKeywordArg "module")
                |> OptionsParser.withRestArgs (Option.restArgs "paths")
            )


main : Program.StatefulProgram Model Msg CompileOptions {}
main =
    Program.stateful
        { printAndExitFailure = Ports.printAndExitFailure
        , printAndExitSuccess = Ports.printAndExitSuccess
        , init = init
        , config = programConfig
        , subscriptions = subscriptions
        , update = update
        }
