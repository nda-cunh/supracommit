#compdef supracommit

_supracommit() {
    local -a opts
    # On récupère les options dynamiquement via ton flag caché
    opts=("${(@f)$(_call_program options supracommit --list-options)}")
    
    # On génère la complétion
    _describe 'supracommit options' opts
}

_supracommit "$@"
