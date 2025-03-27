Collection is a package of modules, roles, plugins etc, that are thread as single package, so it easier to distrubute them.

Instaling collection from file:

```
ansible-galaxy collection install -r requirements.yml
```

requirements.yml
```
---
collections:
  - name: community.general
    version: '1.0.0'
  - name: amazon.aws
    version: '1.2.1'
```