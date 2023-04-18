# pipeline-playpen
Pipeline Playpen

This is example CI/CD pipeline in Azure DevOps, with source in GitHub.

## It's 2023, people understand CI/CD, right?

You'd be surprised.  In my day job we're seeing that people use legacy features of ADO, to their projects detriment.

## What makes a CI/CD pipeline?

* One YAML file to define the workflow from build to production.  By all means, break that up into different files or use templates, but there should be one workflow to deploy one artifact to production.
* Stages per environment.  Your pipeline should run all the stages.  You need to fix the issues in earlier stages.  Flip the "Disable stage chooser" switch.
* Validation after deployment.

## What isn't a CI/CD pipeline?

* Release pipelines. They are deprecated and you should flip the "Disable creation of classic build and classic release pipelines" switch at the Organization level.  Deployment is the entire team's concern.
* More than 1 orchestration tool.

# Tools in this example
* Node, NPM, expressJS for the "app"
* Docker for containerisation
* Still deciding on container runtime
* GitHub Advanced Security for SAST, with extra Trivy
* OWASP Zap for DAST (https://marketplace.visualstudio.com/items?itemName=CSE-DevOps.zap-scanner)
* 