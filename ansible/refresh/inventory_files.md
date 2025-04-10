
## Default location of inventory file

Default location of inventory file 

/etc/ansible/hosts

Example:

```inventory.ini
server1.com
server2.com

[mail]
server3.com
server4.com

[web]
server5.com
server6.com
```

We can define some attributes in inventory file:

* ansible_connection - ss/winrm/localhost
* ansible_port - 22/1234
* ansible_user - root/admin
* ansible_ssh_pass - some passworn
* ansible_password - for windows based hosts

```
web ansible_host=server5.com ansible_connection==ssh ansible_user=root
localhost ansible_connection=localhost
```

More complex inventory.ini

```ini
# Web Servers
web1 ansible_host=server1.company.com ansible_connection=ssh ansible_user=root ansible_ssh_pass=Password123!
web2 ansible_host=server2.company.com ansible_connection=ssh ansible_user=root ansible_ssh_pass=Password123!
web3 ansible_host=server3.company.com ansible_connection=ssh ansible_user=root ansible_ssh_pass=Password123!

# Database Servers
db1 ansible_host=server4.company.com ansible_connection=winrm ansible_user=administrator ansible_password=Password123!


[web_servers]
web1
web2
web3

[db_servers]
db1

[all_servers:children]
web_servers
db_servers

```

## Variables in inventory file

Define variables in inventory file, these are group variables. Group variables have lower priority than host vars:

```
web1 ansible_host=1.2.3.4 
web2 ansible_host=1.2.3.5 dns_server=2.2.2.2 # web2 will have 2.2.2.2 instead of 1.1.1.1
web3 ansible_host=1.2.3.6

[web_Servers]
web1
web2
web3

[web_servers:vars]
dns_server=1.1.1.1
```

General playbok vars > host vars > group vars . In manula there is a list of priority.

We can define inventory file in yaml as well:

```yaml
all:
    children:
        webservers:
            children:
                webservers_us:
                    hosts:
                        server_us_1.com:
                            ansible_host: 192.168.1.2
                        server_us_2.com:
                            ansible_host: 192.168.1.3
                webservers_eu:
                    hosts:
                        server_eu_1.com:
                            ansible_host: 192.168.1.5
                        server_eu_2.com:
                            ansible_host: 192.168.1.6
```

## Inline inventory file

We can inline inventory file using coma. Like in this command
```
ansible -i,ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3 all -m ping
```

In this example `-i,`  we specifie ubuntus and centos as inventory file.

## Set inveotry file

In ansile.cfg we can select name of inventory file.

```ini
[defaults]
inventory = hosts # the name of inventory file is hosts
```
