pipeline {
  agent any

  tools {
   maven 'maven 3.6'

  }
   

   options {
        skipStagesAfterUnstable()
    }
   stages {
        stage('Build') {

            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }

        stage('Test'){
            steps{
                sh 'mvn test'
            }
            //post{
             //   always {
              //     junit 'target/surefire-reports/*.xml'
               // }
            //}
        }

    }

    post {
        always {
             sh 'chmod 755 ./deliver.sh'
             sh './deliver.sh'
          }
     }
}
