properties([
        buildDiscarder(logRotator(numToKeepStr: '5')),
        pipelineTriggers([pollSCM('H/15 * * * *')])
])

def jobContext = [:]

node() {
    stage("Build images") {
        // get url of the image stream registry
        jobContext.registry = sh returnStdout: true, script: "oc get is jenkins-slave-image-mgmt --template='{{ .status.dockerImageRepository }}'"

        echo "${jobContext}"

        // start the s2i build config
        openshiftBuild bldCfg: 'jenkins-slave-image-mgmt-build', showBuildLogs: 'true', verbose: 'false', waitTime: '5', waitUnit: 'min'
    }
}

stage("Promote images") {
    imageMgmtNode() {
        copyAndPromote(jobContext, 'latest')
    }
}

def copyAndPromote(jobContext, tag) {
    sh "skopeoCopy.sh -f ${jobContext.registry}:latest -t artifactory.six-group.net/sdbi/jenkins-slave-image-mgmt:${tag}"
    sh "promoteToArtifactory.sh -i sdbi/jenkins-slave-image-mgmt -t ${tag} -r sdbi-docker-release-local -c"
}

def imageMgmtNode(Closure body) {
    // we ned credentials for skopeo (copy images from openshift to artifactory) and for the artifactory promotion.
    withCredentials([usernameColonPassword(credentialsId: 'artifactory', variable: 'SKOPEO_DEST_CREDENTIALS')]) {
        withEnv(["SKOPEO_SRC_CREDENTIALS=${dockerToken()}", "ARTIFACTORY_BASIC_AUTH=${env.SKOPEO_DEST_CREDENTIALS}"]) {
            def label = 'imageMgmt'
            podTemplate(cloud: 'openshift', inheritFrom: 'maven', label: label,
                    containers: [containerTemplate(
                            name: 'jnlp',
                            image: 'artifactory.six-group.net/sdbi/jenkins-slave-image-mgmt',
                            alwaysPullImage: true,
                            args: '${computer.jnlpmac} ${computer.name}',
                            workingDir: '/tmp')]
            ) {
                node(label) {
                    body.call()
                }
            }
        }
    }
}


def dockerToken(String login = "serviceaccount") {
    node() {
        // Read the auth token from the file defined in the env variable AUTH_TOKEN
        String token = sh returnStdout: true, script: 'cat ${AUTH_TOKEN}'
        String prefix
        if (login) {
            prefix = "${login}:"
        } else {
            prefix = ''
        }
        return prefix + token
    }
}