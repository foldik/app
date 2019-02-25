port module Ports exposing (EditorCommand, Command(..), sendCommand, editor)

type Command
    = Heading1
    | Heading2
    | Heading3
    | Heading4
    | Heading5
    | Heading6
    | Bold
    | Italic
    | UnderScoure
    | Delete


commandToString : Command -> String
commandToString command =
    case command of
        Heading1 ->
            "Heading1"
    
        Heading2 ->
            "Heading2"

        Heading3 ->
            "Heading3"

        Heading4 ->
            "Heading4"

        Heading5 ->
            "Heading5"

        Heading6 ->
            "Heading6"

        Bold ->
            "Bold"

        Italic ->
            "Italic"

        UnderScoure ->
            "UnderScoure"

        Delete ->
            "Delete"

type alias EditorCommand =
    { id : String
    , name : String
    }       

sendCommand : String -> Command -> Cmd msg
sendCommand id command =
    editor ( EditorCommand id (commandToString command) )

port editor : EditorCommand -> Cmd msg