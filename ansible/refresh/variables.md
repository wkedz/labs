Simple printing task result using variable. We can use register.

```yaml
---
- name: Check /etc/hosts file
  hosts: all
  tasks:
  - shell : cat /etc/hosts
    register: result
  - debug:
      var: result
```

Magic variables are automatically created by Ansible, and cannot be changed by user. There variables will always reflect the intrenal state of Ansible. https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html#magic-variables

```yaml
---
- name: Echo playbook
  hosts: localhost
  gather_facts: no
  tasks:
    - name: Echo inventory_hostname
      ansible.builtin.debug:
        msg:
          - "Hello from Ansible playbook!"
          - "This is running on {{ inventory_hostname }}"
```

If not declared otherwise, ansible will collect fact about host. These facts can be printed using debug, like this:

```yaml
---
- name: Pring facts.
  hosts: all
  tasks:
  - debug:
      var: ansible_facts
```

In order to prevent getting facts, you need to set `gather_facts: False`

This can be also set in `/etc/ansible/ansible.cfg` with `gathering = smart/implicit/explicit`


Using anchors:

```yaml
- name: Example Anchors and Aliases
  hosts: all
  become: yes
  vars:
    user_groups: &user_groups
     - devs
     - support
    user_1:
        user_info: &user_info
            name: bob
            groups: *user_groups
            state: present
            create_home: yes
    user_2:
        user_info:
            <<: *user_info
            name: christina
    user_3:
        user_info:
            <<: *user_info
            name: jessica
            groups: support

  tasks:
  - name: Add several groups
    ansible.builtin.group:
      name: "{{ item }}"
      state: present
    loop: "{{ user_groups }}"

  - name: Add several users
    ansible.builtin.user:
      <<: *user_info
      name: "{{ item.user_info.name }}"
      groups: "{{ item.user_info.groups }}"
    loop:
      - "{{ user_1 }}"
      - "{{ user_2 }}"
      - "{{ user_3 }}"
```

We can also have dedicated directories for host and group vars, for example:

```
group_vars/databases - define variables for group databases
group_vars/webservers - define variables for group webservers
host_vars/host1 - define variables for host host1
host_vars/host2 - define variables for host host2
```

This directories should be keept with ansible inventory or playbook files.