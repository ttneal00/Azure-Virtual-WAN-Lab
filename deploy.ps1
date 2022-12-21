## Remove --what-if to deploy
az deployment sub create --name TestDeploy --location eastus --template-file 'main.bicep' --parameters 'parameters.json' --what-if