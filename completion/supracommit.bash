_supracommit_completion() {
    local -a opts
    opts=("${(@f)$(supracommit --list-options)}")
    _describe 'options' opts
}
compdef _supracommit_completion supracommit
