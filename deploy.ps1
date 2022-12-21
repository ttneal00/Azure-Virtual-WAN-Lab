<# 
Powershell Helpfuls


Get-AzVMSize -Location westus2

 Get-AzVMImagePublisher -location westus2 | where {$_.PublisherName.Contains("Microsoft")}
 Get-AzVMImageOffer -Location westus2 -PublisherName 'MicrosoftWindowsServer'
 Get-AzVMImagesku -Location westus2 -PublisherName 'MicrosoftWindowsServer'  -Offer WindowsServer
 Get-AzVMImage -Location westus2 -PublisherName 'MicrosoftWindowsServer'  -Offer WindowsServer -Skus 2022-datacenter-core-g2

Popular Publisher Names


 Canonical
 MicrosoftWindowsServer
 MicrosoftWindowsDesktop
 RedHat


Remove --what-if to deploy 
#>
az deployment sub create --name TestDeploy --location eastus --template-file 'main.bicep' --parameters 'parameters.json' --what-if