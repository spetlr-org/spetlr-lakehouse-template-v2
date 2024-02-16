# How to run terraform against azure

- The state file needs to be somewhere. So to bootstrap the state file you need a 
  small deployment script that will deploy
    - 1 resource group
    - 1 storage account
    - 1 container
  
  The script to deploy this state container is not part of this example.
- Once these exits, you need to specify these, together with a service connection 
  that is able to read and modify the state file. That is the backendServiceArm that 
  is needed to init terraform. All state changes will then refer to this state.
- In the plan and apply phase you can choose a different service connection, that 
  will execute the changes. That's the environmentServiceNameAzureRM
- We followed the documentation here to get this working: https://github.com/microsoft/azure-pipelines-terraform/blob/main/Tasks/TerraformTask/TerraformTaskV4/README.md
- All of this will need to be changed and adapted to work with github workflows.
