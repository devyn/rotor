comment "Hello World in Rotor."
comment "Of course, boring, so it's juiced up a little..."

import gems.colored

comment "See that? A python/java style 'import' has just taken place!"
comment "by the way, you need the Colored ruby gem to run this..."
comment "maybe even Win32.Console.ANSI..."

set msg, "Hello World!"

comment "Boooring..."

set msg, [callvar msg, red]
set msg, [callvar msg, bold]

comment "Now we're talkin'..."

out [get msg]

comment "You should have gotten 'Hello World!' in red bold."
comment "If not, something's messed with your system."
comment "Try switchin' to Linux..."
