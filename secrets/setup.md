# Setup

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
