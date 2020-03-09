#!/usr/bin/env bash

#################################################################
#
# Script to deploy into a BUILD only envir.  Build and Deploy   
#	componenents are deployed into the seperate namespace/project
#
#################################################################


############# Set from Variables ###########################
NAMESPACE=${1}

CORRECT_NODEJS12_IMAGE="<image>image-registry.openshift-image-registry.svc:5000/openshift/jenkins-nodejs12</image>"


############# Auto-set some Global Vars ##########################
SOURCE_REPOSITORY_URL=$(git config --get remote.origin.url)
if [ $? -ne 0 ]; then
  echo "Problem getting SOURCE_REPOSITORY_URL.  Will not continue.  Please run from git project."
  exit -1
fi

#TODO: Correct for HTTPS/GIT
SOURCE_REPOSITORY_URL=https://git.delta.com/ea/dtl_landscape.git

SOURCE_REPOSITORY_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ $? -ne 0 ]; then
  
  echo "Problem getting current branch.  Defaulting to master"
  SOURCE_REPOSITORY_BRANCH=master
fi

ERR_COUNTER=0
BIN_DIR=`/usr/bin/dirname ${0}`
case ${BIN_DIR} in
  /*) ;;
   *) BIN_DIR="`/bin/pwd`/${BIN_DIR}" ;;
esac
PROJECT_DIR=${BIN_DIR}/../..  #get back from ./bin's script dir


######################################################
## Helper sub to set some environment vars
######################################################
set_env(){

  if [ `uname` == 'Darwin' ] ; then
    # Bug in MacOS Python throwing OM Exceptions
    #   https://bugs.python.org/issue33725
    export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
  fi

}

######################################################
## Helper sub to do pre-checks
######################################################
pre_checks(){

  # check for jenkins deployment
  echo "Checking for Jenkins Deployment for Build Environment"
  oc get dc jenkins > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR: Problem getting deployment for Jenkins."
    exit -1
  fi

  echo "    Found Jenkins deployment."

  echo "Checking for ConfigMap correct value."
  #oc get configmap jenkins-config-nodejs12 -o yaml|grep ${CORRECT_NODEJS12_IMAGE} > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR: Problem finding Jenkins NodeJS12 ConfigMap value: ${CORRECT_NODEJS12_IMAGE}"
    exit -1
  fi

  echo "    Found Jenkins ConfigMap correct value."
}

######################################################
## Helper sub to set the target NAMESPACE
######################################################
set_deploy_namespace(){

  # Lets check current project and validate we are logged in (at the same time.)
  MY_CURR_PROJECT=`oc project -q`
  if [ $? -ne 0 ]; then
    echo "Problem getting current namespace/project.  Maybe you are not logged in?"
    exit -1
  fi

  # Check to see if NAMESPACE was set as Script Arg, if not, offer to set as current project
  if [ -z "${NAMESPACE}" ]; then

    while true; do
        read -p "  !! WARNING !!  No argument passed.  
        Please pass in your namespace as script argument. For example, \"./$0 <my-namespace>\"
        Do you wish to default to '${MY_CURR_PROJECT}' ?" yn
        case $yn in
            [Yy]* ) NAMESPACE=${MY_CURR_PROJECT}; break;;
            [Nn]* ) echo "Stopping."; exit 22;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    
  fi

  # Set active project to NAMESPACE
  oc project ${NAMESPACE}
  if [ $? -ne 0 ]; then
      echo "Error setting namespace/project."
      exit -1
  fi
}


######################################################
## Helper sub to check the presense of a secret
######################################################
check_secrets(){
    echo "** Checking for secrets!"
    for SECRET in ${SECRET_SOURCE} 
    do
        `oc get secret ${SECRET} > /dev/null 2>&1`
        if [ $? -ne 0 ]; then
            echo "  ERROR: ${SECRET} not found."
            ERR_COUNTER=`expr $ERR_COUNTER + 1`
        else
            echo "  FOUND: ${SECRET}"
        fi
    done
}


######################################################
## Sub for Ansible Errors
######################################################
call_ansible(){
  # Check for validation errors
  if [ "${ERR_COUNTER}" != 0 ]; then
    echo "Errors exist in pre-checks.  Exiting with ${ERR_COUNTER} error(s)."
    exit ${ERR_COUNTER}
  fi
  
  echo "Changing directory to ${PROJECT_DIR}"
  cd ${PROJECT_DIR}

  ansible-galaxy install -r .applier/requirements.yml --roles-path=galaxy
  if [ $? == 0 ]; then  
    CMD="ansible-playbook -i .applier/inventory-build-310/ galaxy/openshift-applier/playbooks/openshift-cluster-seed.yml \
            -e source_repository_url=${SOURCE_REPOSITORY_URL} \
            -e source_repository_ref=${SOURCE_REPOSITORY_BRANCH} \
            -e namespace=${NAMESPACE} "
    ${CMD}
    if [ $? -ne 0 ]; then
        echo "  ERROR: Error in applier deployment."
        ERR_COUNTER=`expr $ERR_COUNTER + 1`
    fi
  else
    echo "  ERROR: Error in ansible galaxy install."
    ERR_COUNTER=`expr $ERR_COUNTER + 1`
  fi

}

######################################################
## Start of program
######################################################
set_env
set_deploy_namespace
pre_checks
call_ansible

echo ""
echo ""
echo "Exiting with ${ERR_COUNTER} error(s). Navigate to the OpenShift Console and watch your deployment."
exit ${ERR_COUNTER}




