FROM bitnami/azure-cli
USER root
RUN mkdir scripts 
ADD scripts/Start-Lab.sh ./scripts
RUN chmod -R 755 ./scripts
ADD AzureRM AzureRM
WORKDIR scripts
ENV PATH="/scripts:$PATH"

# Finally, set the entrypoint and cmd
ENTRYPOINT 
CMD ["/bin/bash"]
