Roles are collection of ansible task, handlers and other attributes needed to perform jub. 

If you wan to create custom role type:

```
ansible-galaxy init ROLE_NAME
```

In order to use it, move it into `role` directory at the same level as pplaybook. Or place it in `/etc/ansible/roles`. This is default
location, but it can be modified by attribute `roles_path` in  `/etc/ansible/ansible.cfg`.

If you want to use existing role, you need to install it. To do that type 

```
ansible-galaxy install NAME
```

Or in target path 

```
ansible-galaxy install NAME -p ./roles
```

List of current roles:

```
ansible-galaxy list
```

Current path 

```
ansible-config dump | grep ROLE
```


Creating custome role
```
cd /home/user/playbooks/roles/
ansible-galaxy init package
vi /home/user/playbooks/roles/package/tasks/main.yml
```

```main.yml
---
# tasks file for nginx
- name: Install Nginx
  ansible.builtin.package:
    name: nginx 
    state: latest
- name: Start Nginx Service
  ansible.builtin.service:
    name: nginx 
    state: started
```

