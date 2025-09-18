project('my-hello-project', 'vala', 'c',
  version: '0.1.0')

# Vala library
lib = library('hello-lib',
  
  sources: ['./helloWorld.vala'],
  dependencies: [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
  ],
  install: true,
)
