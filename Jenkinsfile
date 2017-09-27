properties([
  buildDiscarder(logRotator(numToKeepStr: '5'))
])


node() {
    stage("Build images") {
        openshiftBuild bldCfg: 'jenkins-slave-image-mgmt-build', showBuildLogs: 'true', verbose: 'false', waitTime: '5', waitUnit: 'min'
    }
}
node('jenkins-slave-image-mgmt') {
    stage("Promote images") {
        withCredentials([string(credentialsId: 'SECRET_ARTIFACTORY_TOKEN', variable: 'ARTIFACTORY_TOKEN')]) {
            sh "promoteToArtifactory.sh -k ${env.ARTIFACTORY_TOKEN} -i sdbi/jenkins-slave-image-mgmt -t latest -r sdbi-docker-release-local -c"
        }
    }
}