# Highlights matching characters when inserted like vim does

declare-option -hidden range-specs show_matching_insert

define-command -hidden insert-highlight-matching %{ evaluate-commands -draft %{

    set-option window show_matching_insert "%val{timestamp}"
    evaluate-commands -draft -itersel %{ try %{
        execute-keys hm\;
        set-option -add window show_matching_insert "%val{selection_desc}|MatchingChar"
        execute-keys m\;
        set-option -add window show_matching_insert "%val{selection_desc}|MatchingChar"
    } }
} }

hook global WinSetOption matching_pairs=.* %{
    remove-hooks window curr-matching-pairs
    hook -always -group curr-matching-pairs window InsertChar %sh{printf '[%s]' $(echo $kak_opt_matching_pairs | sed 's/['\'' ]//g;s/[]\\]/\\&/g')} %{
        insert-highlight-matching
    }
    hook -always -group curr-matching-pairs window InsertChar %sh{printf '[^%s]' $(echo $kak_opt_matching_pairs | sed 's/['\'' ]//g;s/[]\\]/\\&/g')} %{
        set-option window show_matching_insert "%val{timestamp}"
    }
}

hook -always global ModeChange insert:.* %{
    set-option window show_matching_insert "%val{timestamp}"
}

hook -always global InsertDelete .* %{
    set-option window show_matching_insert "%val{timestamp}"
    evaluate-commands -draft %{ try %{
        execute-keys %sh{ printf 'h<a-k>[%s]<ret>l' $(echo $kak_opt_matching_pairs | sed 's/['\'' ]//g;s/[]<>;\\]/\\&/g') }
        insert-highlight-matching
    } }
}

hook -always global InsertMove .* %{
    set-option window show_matching_insert "%val{timestamp}"
}
