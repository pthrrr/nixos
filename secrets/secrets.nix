let
  pthr-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWXcUvknDXdGRkIRkOEZ153V5/JLEevroZjYiUqA1SY pthr@nixOS-server";
  
  keys = [ pthr-key ];
in
{
  "username1.age".publicKeys = keys;
  "username2.age".publicKeys = keys;

  "domain.age".publicKeys = keys;
  "namecheap-credentials.age".publicKeys = keys;
}
