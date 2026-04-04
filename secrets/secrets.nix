let
  thooloohive-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1LG36pG0TZnU5A+8gXv7un2S13jprcFL3Zb2r7qCn1";
  thoolooframe-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMhNwHLC4plBDsVdPDChGlxwTCr6/WS5hsK7D6tbDmJd";
  users = [ thooloohive-user thoolooframe-user ];

  thooloocraft-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7DJf8JBKjpO8wf+AULyvBaaxIG6miePSC3Qk18Z42v";
  thoolooframe-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAneIm+MPIWHSUusWd77yV4dxMHvUQF5W3cPtXR3/Z15";
  systems = [ thooloocraft-system thoolooframe-system ];
in {
  "cloudflare-dns-thooloocraft-token.age".publicKeys = users ++ thooloocraft-system;
  "thoolooexpress-login-hashed-password.age".publicKeys = users ++ systems;
}