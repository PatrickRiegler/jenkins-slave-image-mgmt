properties([
  buildDiscarder(logRotator(numToKeepStr: '5'))
])


def registry
node() {
    stage("Build images") {
	    registry = sh returnStdout: true, script: "oc get is jenkins-slave-image-mgmt --template='{{ .status.dockerImageRepository }}'"
        openshiftBuild bldCfg: 'jenkins-slave-image-mgmt-build', showBuildLogs: 'true', verbose: 'false', waitTime: '5', waitUnit: 'min'
    }
}
node('jenkins-slave-image-mgmt') {
    stage("Copy wildfly${type} images") {
        sh "skopeoCopy.sh -f ${registry}:tmp -t artifactory.six-group.net/sdbi/jenkins-slave-image-mgmt:latest"
	} 
    stage("Promote images") {
        withCredentials([string(credentialsId: 'SECRET_ARTIFACTORY_TOKEN', variable: 'ARTIFACTORY_TOKEN')]) {
            sh "promoteToArtifactory.sh -k ${env.ARTIFACTORY_TOKEN} -i sdbi/jenkins-slave-image-mgmt -t latest -r sdbi-docker-release-local -c"
        }
    }
}