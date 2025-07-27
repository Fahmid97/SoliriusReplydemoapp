# Project summary
This is collection of templates that, when ran together, can create a barebones Azure function app hosting a .NET webapp. The app files themselves have not been included for the purpose of this demo, as this project revolves more around the deployment of infrastructure. The 'build.yml' file does reference another file, a .csproj file, so this will need to be in place before the pipeline can be run.

If running this without the .NET app in place, please comment out steps 1 and 3 in azure-pipelines.yaml. This will only then run step 2, which will just create an empty function app in Azure (along with the SQL server, ASP and storage account). The infrastructure created is defined by parameters outlined in the 'infrastructure.bicep' file.

Please note that the majority of parameters that I believe are customisable are provided in the 'main.bicepparam' file. The variables here can and are supposed to be edited, to suit project needs.
There is an exception however for the parameter 'sqlAdminPassword' - this is a securestring and should be saved as a variable in the ADO pipeline for the project. This should be saved as 'SqlAdminPassword' in the variables section.
