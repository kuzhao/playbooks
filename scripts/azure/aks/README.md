### Azure Kubernetes Service(AKS) specific scripts

|Script|Synopsis|Usage|
|---|---|---|
|aks_del_add_np.sh|Remove and re-add a nodepool|aks_del_add_np.sh -s SUBID -c CLUSTERNAME|
|aks_disable_addon.sh|Disable all addons across all clusters in current az_login subscription|aks_disable_addon.sh|
|aks_kubernet_rt_play.sh|Kubectl delete a node, reboot and see if kubernet route is correctly updated|aks_kubernet_rt_play.sh|
|aks_scaleupdown.sh|Repeatedly scale out then scale in a new nodepool with target node count|aks_scaleupdown.sh -n CLUSTERNAME -g RGNAME -c TGTCOUNT|
|dump_aks_vmss.sh|List all AKS nodepool VMSS inside subscriptions passed in from input file|bash dump_aks_vmss.sh|