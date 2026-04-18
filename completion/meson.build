bash_comp_dir = get_option('datadir') / 'bash-completion' / 'completions'
zsh_comp_dir = get_option('datadir') / 'zsh' / 'site-functions'

install_data(
  'supracommit.bash',
  install_dir: bash_comp_dir,
  rename: 'supracommit'
)

install_data(
  'supracommit.zsh',
  install_dir: zsh_comp_dir,
  rename: '_supracommit'
)
