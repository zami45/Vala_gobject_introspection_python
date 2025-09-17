// helloWorld.vala
using GLib;
// Annotate the namespace to make it introspectable.

namespace Hello {          // <-- Added namespace here

    public class HelloWorld : Object {
        
        // Public method that is introspectable
        [Export]
        public void say_hello() {
            print("Hello, world from Vala!\n");
        }
        
        // Optionally, a constructor
        public HelloWorld() {
            // You could initialize stuff here
        }
    }
}


