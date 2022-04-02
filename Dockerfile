FROM bitnami/azure-cli
RUN mkdir scripts 
ADD scripts/Start-Lab.sh ./scripts
ADD AzureRM AzureRM
WORKDIR scripts