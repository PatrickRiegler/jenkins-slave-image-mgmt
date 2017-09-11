properties([
  buildDiscarder(logRotator(numToKeepStr: '5'))
])


node() {
    stage("Build images") {
        openshiftBuild bldCfg: 'six-rhel-build', showBuildLogs: 'true', verbose: 'false', waitTime: '5', waitUnit: 'min'
    }
}
node('jenkins-slave-image-mgmt') {
    stage("Promote images") {
        withCredentials([string(credentialsId: 'SECRET_ARTIFACTORY_TOKEN', variable: 'ARTIFACTORY_TOKEN')]) {
            sh "promoteToArtifactory.sh -k ${env.ARTIFACTORY_TOKEN} -i sdbi/six-rhel7 -t latest -r sdbi-docker-release-local -c"
        }
    }
}