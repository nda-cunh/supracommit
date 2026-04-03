project(
  'supracommit',
  'vala',
  meson_version : '>= 1.0.0',
  version : '0.1',
)

conf_data = configuration_data()
conf_data.set('version', meson.project_version())


dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('BrainLib', static: true),
]

config_vala_file = configure_file(input : 'Config.vala.in', output : 'Config.vala', configuration : conf_data)

sources = files(
  'main.vala',
  'ParseOption.vala',
  'Format.vala',
  'SupraCommit.vala',
  'Utils.vala'
)

executable(
  'supracommit',
  sources,
  config_vala_file,
  dependencies : dependencies,
  c_args: '-w',
  install : true,
)
