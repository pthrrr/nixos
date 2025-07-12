let
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWXcUvknDXdGRkIRkOEZ153V5/JLEevroZjYiUqA1SY pthr@nixOS-server";
  
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANUjzYfAisOLTJlyr8fM263TsnnDtUY+jjBcC53zen8 root@nixOS-server";
  
  # List of keys that can decrypt secrets
  keys = [ personal server ];
in
{
  "username1.age".publicKeys = keys;
  "username2.age".publicKeys = keys;
}
