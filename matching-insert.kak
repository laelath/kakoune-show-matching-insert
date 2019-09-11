# Highlights matching characters when inserted like vim does

declare-option -hidden range-specs show_matching_insert

define-command -hidden insert-highlight-matching %{ evaluate-commands -draft %{ try %{
    set-option window show_matching_insert "%val{timestamp}"
    execute-keys \;<a-k> %sh{
        printf '[^%s]' $(echo $kak_opt_matching_pairs | sed 's/</lt/g;s/>/gt/g;s/[lg]t/<&>/g;s/['\'' ]//g;s/[]\\]/\\&/g')
    } <ret>
    evaluate-commands -itersel %{
        execute-keys hms\A|.\z<ret>
        evaluate-commands -itersel %{
            set-option -add window show_matching_insert "%val{selection_desc}|MatchingChar"
        }
    }
} } }



hook global WinSetOption matching_pairs=.* %{
    remove-hooks window curr-matching-pairs
    hook -always -group curr-matching-pairs window InsertChar %sh{
        printf '[%s]' $(echo $kak_opt_matching_pairs | sed 's/['\'' ]//g;s/[]\\]/\\&/g')
    } %{
        insert-highlight-matching
    }
    hook -always -group curr-matching-pairs window InsertChar %sh{
        printf '[^%s]' $(echo $kak_opt_matching_pairs | sed 's/['\'' ]//g;s/[]\\]/\\&/g')
    } %{
        set-option window show_matching_insert "%val{timestamp}"
    }
}

hook -always global ModeChange insert:.* %{
    set-option window show_matching_insert "%val{timestamp}"
}

hook -always global InsertDelete .* %{
    set-option window show_matching_insert "%val{timestamp}"
    evaluate-commands -draft %{ try %{
        execute-keys %sh{
            printf 'h<a-k>[%s]<ret>l' $(echo $kak_opt_matching_pairs | sed 's/['\'' ]//g;s/[]<>;\\]/\\&/g')
        }
        insert-highlight-matching
    } }
}

hook -always global InsertMove .* %{
    set-option window show_matching_insert "%val{timestamp}"
}
