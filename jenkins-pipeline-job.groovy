import jenkins.model.*
import hudson.model.*

def jenkins = Jenkins.instance

// Create a new pipeline job
def job = jenkins.createProject(org.jenkinsci.plugins.workflow.job.WorkflowJob, "AutoPipelineJob")

// Set pipeline script definition
def pipelineScript = """
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }
}
"""

// Assign the script to the pipeline job
job.definition = new org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition(pipelineScript, true)

// Save and enable the job
job.save()
job.scheduleBuild2(0)
