let
  thooloohive-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1LG36pG0TZnU5A+8gXv7un2S13jprcFL3Zb2r7qCn1";
  users = [ thooloohive-user ];

  thooloocraft-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7DJf8JBKjpO8wf+AULyvBaaxIG6miePSC3Qk18Z42v";
  systems = [ thooloocraft-system ];
in {
  "cloudflare-dns-thooloocraft-token.age".publicKeys = users ++ systems;
}