# kubectl-top-resource

A Concourse resource type for monitoring the memory/cpu usage of containers. It
can be configured to only emit new versions when the memory/CPU exceeds a
certain threshold.

Completely untested and not a proper resource type, so I would not recommend
using!

## Example

```yaml
resource_types:
- name: kubectl-top
  type: registry-image
  source:
    repository: aoldershaw/kubectl-top-resource

- name: slack-notifier
  type: registry-image
  source: {repository: mockersf/concourse-slack-notifier}

resources:
- name: memory-spike
  type: kubectl-top
  icon: memory
  source:
    username: ((k8s.username))
    password: ((k8s.password))
    server: ((k8s.server))
    ca: ((k8s.ca))
    namespace: ci
    labels: app=web
    container_name: web
    mem_threshold_mb: 512
    time_between_s: 600 # Only emit new versions every 10 minutes for a given pod/container

- name: notify
  type: slack-notifier
  icon: slack
  source:
    url: ((slack_hook))
    username: ((slack.username))
    password: ((slack.password))

jobs:
- name: monitor
  plan:
  - get: memory-spike
    version: every
    trigger: true
  - load_var: data
    file: memory-spike/data.json
  - put: notify
    params:
      message: "Web container in pod ((.:data.pod)) has memory ((.:data.mem))!"
```
