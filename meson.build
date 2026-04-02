project(
  'supracommit',
  'vala',
  meson_version : '>= 1.0.0',
  version : '0.1',
)

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('BrainLib', static: true),
]

sources = files(
  'main.vala',
  'ParseOption.vala',
)

executable(
  'supracommit',
  sources,
  dependencies : dependencies,
  c_args: '-w',
  install : true,
)
