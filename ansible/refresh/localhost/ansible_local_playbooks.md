* using Ansible command line:
```
ansible-playbook --connection=local  playbook.yml
```
* using inventory:
```
127.0.0.1 ansible_connection=local
```
* using Ansible configuration file:
```
[defaults]
transport = local
```
* using playbook header:
```
- hosts: 127.0.0.1
  connection: local
```