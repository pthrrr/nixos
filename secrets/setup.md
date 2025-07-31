# Setup

## Fresh system setup (laptop or new client):
## 1. First build will fail - this is EXPECTED
sudo nixos-rebuild switch --flake .#laptop --impure

## You'll see error: "opening file '/run/agenix/username1': No such file or directory"

## 2. Second build will succeed
sudo nixos-rebuild switch --flake .#laptop --impure

## Now everything works!

## Secrets

### Create the username secrets
agenix -e username1.age
agenix -e username2.age

## Radicale

### Enter a shell with Apache HTTP tools available
nix-shell -p apacheHttpd

### Now you can use htpasswd commands
htpasswd -B -c /tmp/radicale_users alice
htpasswd -B /tmp/radicale_users bob

### View the file
cat /tmp/radicale_users

### Exit the nix-shell when done
exit

### Import passwords
cat /tmp/radicale_users
agenix -e radicale-users.age
rm /tmp/radicale_users
