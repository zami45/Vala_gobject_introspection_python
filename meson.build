project(
    'my_introspectable_library',
    'vala', 'c',
    version: '1.0.0',
    license: 'LGPL-2.1+',
    meson_version: '>= 0.61.0'
)

glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gi_dep = dependency('gobject-introspection-1.0')

my_library_src = files('helloWorld.vala')

my_library = shared_library(
    'hello',
    my_library_src,
    vala_header: 'hello.h',
    vala_vapi: 'hello.vapi',
    dependencies: [glib_dep, gobject_dep, gi_dep],
    install: true
)

g_ir_scanner = find_program('g-ir-scanner')
vala_generated_c = join_paths(meson.current_build_dir(), 'helloWorld.c')

gir_target = custom_target(
    'hello-1.0.gir',
    input: my_library_src,
    output: 'hello-1.0.gir',
    command: [
        g_ir_scanner,
        '--quiet',
        '--warn-all',
        '--format=xml',
        '--namespace=Hello',
        '--nsversion=1.0',
        '--symbol-prefix=hello',
        '--identifier-prefix=Hello',
        '--library', 'hello',
        '--pkg', 'gobject-2.0',
        '--add-include-path', meson.current_source_dir(),
        '--include', 'GObject-2.0',
        '--output', '@OUTPUT@',
        vala_generated_c,
    ],
    env: ['LD_LIBRARY_PATH=' + meson.current_build_dir()],
    depends: [my_library],
    install: true,
    install_dir: join_paths(gi_dep.get_variable(pkgconfig: 'girdir'))
)

g_ir_compiler = find_program('g-ir-compiler')
typelib_target = custom_target(
    'hello-1.0.typelib',
    input: gir_target,
    output: 'hello-1.0.typelib',
    command: [g_ir_compiler, '@INPUT@', '-o', '@OUTPUT@'],
    depends: [my_library, gir_target],
    install: true,
    install_dir: join_paths(gi_dep.get_variable(pkgconfig: 'typelibdir'))
)
