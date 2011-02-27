class test($path="/tmp/checkout") {
  file { "$path":
    source  => "puppet:///modules/test/checkout"
  }
}
