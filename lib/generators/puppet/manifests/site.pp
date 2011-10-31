import "nodes"

filebucket { main: server => puppet }

File { backup => main }

Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin" }

