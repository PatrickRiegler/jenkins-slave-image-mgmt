// load sdbi shared libraryssh://git@stash.six-group.net:22/sdbi/jenkins-shared-library.git
library identifier: 'sdbi-shared-lib@develop', retriever: modernSCM(
        [$class       : 'GitSCMSource',
         remote       : 'ssh://git@stash.six-group.net:22/sdbi/jenkins-shared-library.git',
         credentialsId: 'six-baseimages-bitbucket-secret'])

def jobContext = getInitialJobContext()

node() {
    stage("Setup") {
        // get url of the image stream registry
        jobContext.registry = getImageStreamRegistryUrl('jenkins-slave-image-mgmt ')

        echo "${jobContext}"

        // start the s2i build config
        openshiftBuild bldCfg: 'jenkins-slave-image-mgmt-build', showBuildLogs: 'true', verbose: 'false', waitTime: '5', waitUnit: 'min'
    }
}

stage("Promote images") {
    imageMgmtNode('imageMgmt') {
        copyAndPromote(jobContext, 'latest')
    }
}

def copyAndPromote(jobContext, tag) {
    sh "skopeoCopy.sh -f ${jobContext.registry}:latest -t artifactory.six-group.net/sdbi/jenkins-slave-image-mgmt:${tag}"
    sh "promoteToArtifactory.sh -i sdbi/jenkins-slave-image-mgmt -t ${tag} -r sdbi-docker-release-local -c"
}
