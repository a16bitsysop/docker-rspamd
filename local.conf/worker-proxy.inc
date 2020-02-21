bind_socket = "*:11332";
upstream {
  local {
    hosts = "127.0.0.1";
  }
}
