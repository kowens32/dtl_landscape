#!/usr/bin/env bash

#############################################################
#
# Script to deploy runtime secrets only.  Depends upon 
#   Access to $PROJECT/NAMESPACE and 
#   Environment vars: GITHUB_KEY & TWITTER_KEYS
#
##############################################################

############# Set from arguments ###########################
NAMESPACE=${1}

# Secrets name 
GITHUB_SECRET="github-secret"   # Will set value from env GITHUB_KEY
TWITTER_SECRET="twitter-secret"  # Will set value from TWITTER_KEYS

#################### Set Some Global Vars ################## 
ERR_COUNTER=0

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
## Helper sub to check the presense of a secret values
######################################################
check_secret_values(){

  if [ -z "${GITHUB_KEY}" ]; then
      echo "ERROR: getting value from env var \$GITHUB_KEY ; please set and retry."
      ERR_COUNTER=`expr $ERR_COUNTER + 1`
  fi

  if [ -z "${TWITTER_KEYS}" ]; then
      echo "ERROR: getting value from env var \$TWITTER_KEYS ; please set and retry."
      ERR_COUNTER=`expr $ERR_COUNTER + 1`
  fi

}

######################################################
## Helper sub to create secrets
######################################################
create_secrets(){

    # Creating Secret for MYSQL Server use for Attendee Service
    oc create secret generic ${GITHUB_SECRET} --from-literal=GITHUB_KEY=${GITHUB_KEY}
    if [ $? -ne 0 ]; then
        ERR_COUNTER=`expr $ERR_COUNTER + 1`
    fi
    
    # Creating Secret for MYSQL Client use for Attendee Service
    oc create secret generic ${TWITTER_SECRET} --from-literal=TWITTER_KEYS=${TWITTER_KEYS}
    if [ $? -ne 0 ]; then
        ERR_COUNTER=`expr $ERR_COUNTER + 1`
    fi

}

######################################################
# Helper sub to label secret to esure add label 
#  to mark that it should be synced to Jenkins Creds. 
#  (Default name: ${namespace}-${secret_name})
######################################################
label_for_replication(){

  oc label secret ${1} credential.sync.jenkins.openshift.io=true
  if [ $? -ne 0 ]; then
      ERR_COUNTER=`expr $ERR_COUNTER + 1`
  fi

}


######################################################
## Start of program
######################################################
set_deploy_namespace
check_secret_values
if [ "$ERR_COUNTER" = 0 ]; then
  create_secrets
  label_for_replication ${GITHUB_SECRET} 
  label_for_replication ${TWITTER_SECRET} 
fi

echo "Exiting with ${ERR_COUNTER} error(s)."
exit ${ERR_COUNTER}

