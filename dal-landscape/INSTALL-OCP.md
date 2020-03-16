# Enterprise OpenShift Installation

## Install (tested upon MacOS-X)
1 - As a (recommended) [Ansible deployed OpenShift project](#running-in-openshift-via-applier-ansible)
2 - For [Sandbox or local workstation/laptop](INSTALL.md) 

## Running in OpenShift (Via Applier & Ansible)
### Run Applier/Ansible tasks ###

*NOTE:* Either run within Windows CMD Prompt, Mac Terminal Shell, or UNIX Shell.  There are problems/bugs if trying to run within Git for Windows Shell.

```shell
# If deployment to 4.2 )(dev) 
oc login https://api.dr1a1.paasdev.delta.com:6443

# If deployment to 4.2 )(sandbox) 
oc login https://api.sr1a1.paasdev.delta.com:6443


# OPTIONAL: Skip this Next step/command if have Ansible installed locally.  Otherwise, you may run in a toolkit container:
oc run -i -t tool-box-example --image=quay.io/redhat-cop/tool-box:v1.2 --restart=Never --rm bash

# Locally clone the Git repository location, where TARGET_REPO is the correct path.
git clone https://git.delta.com/${TARGET_REPO}/dtl_landscape.git

# Change into the target namespace/project
oc project ${MY_PROJECT}

# REQUIRED_TODO: Update variables in the .openshift/params/*.*  (Specific attendtion to: NAMESPACE and SOURCE_REPOSITORY_URL Repo. )

# Next, let's install Jenkins (if needed)
oc process openshift//delta-jenkins | oc apply -f- 

#NOTE:  FOR 4.2:  There is an error in the NodeJS12 CONFIGMAP Build Agent (Filed as ISSUE#11), so besure the value
#           defined for the image reference is correct: image-registry.openshift-image-registry.svc:5000
#           If you do need to change:  1) edit the ConfigMap, 2) Scale to 0 pods, 3) Scale back to 1

# Create our build-time secrets with correct valuesgit (for addtional automation: see ./bin/create-secrets/sh )
oc create secret generic github-secret --from-literal=GITHUB_KEY=XXXXXXXXXXXX
oc create secret generic twitter-secret --from-literal=TWITTER_KEYS=AAAAAAAAAA,BBBBBBBBBB,21535509-CCCCCCCC,DDDDDDD

# Add label to mark that it should be synced to Jenkins Creds. (Defautl name: ${namespace}-${secret_name})
oc label secret github-secret credential.sync.jenkins.openshift.io=true
oc label secret twitter-secret credential.sync.jenkins.openshift.io=true

# Ensure we are in the GIT project ROOT folder
cd dtl_landscape

# Install Galaxy roles for OpenShift Applier (see version on requirements.yml)
ansible-galaxy install -r .applier/requirements.yml --roles-path=galaxy

# Run the ansible playbook 
# For Sandbox where ${NAMESPACE} = your target namespace
ansible-playbook -i .applier/inventory-sbx/ galaxy/openshift-applier/playbooks/openshift-cluster-seed.yml \
                -e namespace=${NAMESPACE}

# For Enterprise Pipelines see ./bin/deloy-build.sh dtlandscape-build
```

Check out the finished deployment

```shell 
oc status 

#
# or 
# 
oc get pods -w 

# Will show something like the following when ready.
NAME                       READY   STATUS      RESTARTS   AGE
dtl-landscape-1-pn5rw      1/1     Running     0          0m

```

Finally

```shell 
curl -I -X GET "http://$(oc get route dtl-landscape -o=jsonpath='{.spec.host}')/"

# Should show the following result:
HTTP/1.1 200 OK
Server: nginx/1.12.1
...

```
---