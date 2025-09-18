# generate .so shared object file using meson.build

## in meson.build file :
```
project('my-hello-project', 'vala', 'c',
  version: '0.1.0')

lib = library('hello-lib',
  sources: ['./helloWorld.vala'],
  dependencies: [dependency('glib-2.0'),dependency('gobject-2.0')],
  install: true
)
```

run : 
> meson setup builddir -
> cd builddir
> ninja



# generate .gir file using g-ir-scanner from shared object (.so) file

## Q: what is g-ir-scanner?

ans: 

g-ir-scanner is a tool which generates GIR XML files by parsing headers and introspecting GObject based libraries. It is usually invoked during the normal build step for a project and the information is saved to disk and later installed, so that language bindings and other applications can use it. Header files and source files are passed in as arguments on the command line. The suffix determines whether a file be treated as a source file (.c) or a header file (.h). Currently only C based libraries are supported by the scanner.

command to generate .gir from .so :

> g-ir-scanner \
  --namespace=Hello \
  --nsversion=1.0 \
  --identifier-prefix=Hello \
  --symbol-prefix=hello_hello_world \
  --output=Hello-1.0.gir \
  --cflags-begin -I. --cflags-end \
  --library=hello-lib \
  --include=GObject-2.0 \
  --include=GLib-2.0 \
  --pkg-export=hello-lib \
  --no-libtool \
  --warn-all \
  -Ibuilddir \
   hello-lib.h \
  ./libhello-lib.so


# Troubleshoot "no public method from helloWorld.vala class" in generated .gir file 

## Q: what does --symbol-prefix does?

ans: 

Purpose: Tells g-ir-scanner how to find your symbols in the .so file. This prefix is stripped from the symbol names to match them with your Vala/Introspection types.

## Q : what is --namespace, --identifier-prefix and --symbol-prefix

Here’s a clear breakdown of what --namespace, --identifier-prefix, and --symbol-prefix mean in the context of g-ir-scanner:

1. --namespace

What it is: The namespace of your library as it will appear in the .gir file and in language bindings (e.g., Python, JavaScript).
Example: If your Vala code is in the Hello namespace:

```
namespace Hello {
    public class HelloWorld : Object { ... }
}
```

Then use:
--namespace=Hello

Purpose: Groups all your classes, functions, and types under a common namespace in the introspection data.


2. --identifier-prefix

What it is: The prefix used for C identifiers in the generated .gir file.
Example: If your Vala namespace is Hello, use:

--identifier-prefix=Hello

Purpose: Ensures that the C identifiers in the .gir file match the expected naming convention for your library. This is used to generate correct C function names in the introspection data.


3. --symbol-prefix

What it is: The prefix of the actual C symbols in your compiled library (.so file).
Example: If your compiled symbols in .so file look like this:

hello_hello_world_say_hello
hello_hello_world_get_type

Then use:
--symbol-prefix=hello_hello_world

Purpose: Tells g-ir-scanner how to find your symbols in the .so file. This prefix is stripped from the symbol names to match them with your Vala/Introspection types.


## Q: inspect the generated .so file by meson.build:

> nm -gC ./libhello-lib.so | grep hello

00000000000011d2 T hello_hello_world_construct
0000000000001283 T hello_hello_world_get_type
0000000000001206 T hello_hello_world_new
0000000000001189 T hello_hello_world_say_hello


method say_hello is present


## Q: -Ibuilddir vs builddir/helloWorld.h

The -Ibuilddir and builddir/helloWorld.h arguments in your g-ir-scanner command are critical for ensuring that the scanner can find and parse the necessary header files. Here's what they mean and why they are needed:

1. -Ibuilddir

What it is: This is a compiler include path flag. It tells g-ir-scanner to look in the builddir directory for header files.
Why it's needed: When you build your Vala project with Meson, the generated C header files (like helloWorld.h) are placed in the builddir directory. g-ir-scanner needs to know where to find these headers.
Example:
-Ibuilddir
This tells g-ir-scanner to include builddir in its search path for header files.


2. builddir/helloWorld.h

What it is: This is the generated C header file from your Vala source code. When you compile a Vala file, the Vala compiler generates a corresponding .h file that contains the C declarations of your Vala classes and methods.
Why it's needed: g-ir-scanner reads this header file to understand the structure of your library (classes, methods, signals, etc.). Without it, g-ir-scanner won't know what to introspect.
Example:
builddir/helloWorld.h
This tells g-ir-scanner to scan this specific header file.


## Q: Why Both -IBuilddir and builddir/hello-lib.h Are Needed Together

-Ibuilddir: Ensures that g-ir-scanner can find any additional headers that helloWorld.h might include.
builddir/helloWorld.h: Provides the actual declarations of your classes and methods to g-ir-scanner.


## Q: <unknown>:: Error: Hello: Namespace is empty; likely causes are:* Not including .h files to be scanned* Broken --identifier-prefix

Ans: 
The error "Namespace is empty" with the note about --identifier-prefix means that g-ir-scanner cannot find any introspectable symbols in your library. This is almost always due to incorrect arguments or missing headers.

How to Fix This Error :

1. Include the Generated C Header File
g-ir-scanner needs the C header file generated by Vala (e.g., helloWorld.h). This file is created during the build process and contains the declarations of your classes and methods.


## Q: Compile the .gir File to .typelib

Run the following command to generate the .typelib file:

> g-ir-compiler Hello-1.0.gir -o Hello-1.0.typelib

## Q: Install the .typelib File (Optional)

If you want to install the .typelib file system-wide (e.g., to /usr/lib/girepository-1.0/), use:
> sudo cp Hello-1.0.typelib /usr/lib/girepository-1.0/

This makes the .typelib file available for language bindings to use.
