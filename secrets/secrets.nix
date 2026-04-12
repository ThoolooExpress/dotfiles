let
  thooloohive-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1LG36pG0TZnU5A+8gXv7un2S13jprcFL3Zb2r7qCn1";
  thoolooframe-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlRvQ7I49UjvNB2RYQk9Fpoe8DCMmBDN0dN7vzUGOYM morrill+thoolooframe@thoolooexpress.com";
  users = [ thooloohive-user thoolooframe-user];

  thooloocraft-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7DJf8JBKjpO8wf+AULyvBaaxIG6miePSC3Qk18Z42v";
  thoolooframe-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAneIm+MPIWHSUusWd77yV4dxMHvUQF5W3cPtXR3/Z15";
  systems = [ thooloocraft-system thoolooframe-system ];
in {
  "cloudflare-dns-thooloocraft-token.age".publicKeys = users ++ [thooloocraft-system];
  "thoolooexpress-login-hashed-password.age".publicKeys = users ++ systems;
  "thooloocraft-photoprism-default-admin-password.age".publicKeys = users ++ [thooloocraft-system];
  "thoolooframe-openrouter-key.age".publicKeys = [thoolooframe-user];
}