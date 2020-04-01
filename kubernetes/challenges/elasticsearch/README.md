# Challenge: Deploy an ElasticSearch Cluster with 3 pod StatefulSet and auto-provisioned disks from a StorageClass resource.

### Prerequesites:
* GKE needs to be configured and kubernetes cluster needs to be up and running.
* User with kubernets cluster management role.
* Terraform infrastructure within this project could be used to stand up a GKE cluster.

#


Steps:
1. Navigate to `kubernetes/challenges/elasticsearch/`
1. Create storage class
   Since we chose to deploy to multiple zones, we’ll need to ensure that persistent volumes are created in the correct zone (matching the zone the node is deployed in). To do so you will need to create a new storage class using the following configuration:
   
   ````
   kind: StorageClass 
   apiVersion: storage.k8s.io/v1 
   metadata: 
     name: zone-storage 
   provisioner: kubernetes.io/gce-pd 
   volumeBindingMode: WaitForFirstConsumer
   ````
   
   Create it by running:
   
   ```
   kubectl create -f elastic/storage_class.yml
   ```
1. Create the statefullset:
    ````
    kubectl create -f  elastic/elastic-app-statefullset.yml
    ````
    Check the creation of statefulsets:
    
    ```
        kubectl get statefulset
    ```  
    Needs to show something like below:
    ```
    NAME        DESIRED   CURRENT   AGE
    es-cluster   3         3         36s
    ```
   
1. Create the service:
    ```
    kubectl create -f elastic/elastic-app-svc.yml
    ```
    Check the creation of services:
    ```
        kubectl get svc
    ```
   
1. Check everything is up and running, if not wait till everything goes up:
    Check persistent volume claims binding:
    ```   
       kubectl get pvc
    ```
    Needs to show something like below:
    ```
    NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    data-es-cluster-0   Bound    pvc-dbf2a683-fd09-11e8-bc78-42010aa000cd   5Gi       RWO            zone-storage   4m56s
    data-es-cluster-1   Bound    pvc-2b97ff27-fd0a-11e8-bc78-42010aa000cd   5Gi       RWO            zone-storage   2m43s
    data-es-cluster-2   Bound    pvc-79f37bb7-fd0a-11e8-bc78-42010aa000cd   5Gi       RWO            zone-storage   31s
    ```
1. Port forwarding to check the service is up and the configuration is right (This step needs to be ran after making sure the pods are up and healthy and the service is created):
    ```
    kubectl port-forward es-cluster-0 9200:9200 &
    [1] 18200  
    ```
    Should return something like below:
    ```
       curl localhost:9200
       {
         "name" : "es-cluster-0",
         "cluster_name" : "px-elk-demo",
         "cluster_uuid" : "UP8eA4XcS9aotWPTsqpMpA",
         "version" : {
           "number" : "6.4.3",
           "build_flavor" : "oss",
           "build_type" : "tar",
           "build_hash" : "fe40335",
           "build_date" : "2018-10-30T23:17:19.084789Z",
           "build_snapshot" : false,
           "lucene_version" : "7.4.0",
           "minimum_wire_compatibility_version" : "5.6.0",
           "minimum_index_compatibility_version" : "5.0.0"
         },
         "tagline" : "You Know, for Search"
       }
    ```
1. Deploy Kibana:
    1. 
        ```
        kubectl create -f kibana/kibana-app.yml
        ``` 
    1.         
        ```
        kubectl create -f kibana/kibana-svc.yml
        ``` 
    1.  
        ```
        $ KIBANA_POD=$(kubectl get pods -l app=kibana -o jsonpath='{.items[0].metadata.name}')
        $ kubectl port-forward $KIBANA_POD 5601:5601 &
        [1] 40162
        ```
1. Data Ingestion to test Elastic Search:
    1. Being at `kubernetes/challenges/elasticsearch/` path, run the following docker command to launch logstash,
    so it can connect to elastic search and feed it with log data:
    ```shell script
        docker run --rm -it --network host\
            -e XPACK_MONITORING_ENABLED=FALSE \
            -v $PWD/logstash:/data docker.elastic.co/logstash/logstash:6.5.1 \
            /usr/share/logstash/bin/logstash -f /data/logstash.conf
    ```    
   
   The tutorial from portworx has an issue in the logstash config file which I fixed here.
   if you want to continue with the verification and configuration of elasticsearch, you can continue from underneath
   this title: `Ingesting data into Elasticsearch through Logstash` in https://portworx.com/run-ha-elasticsearch-elk-google-kubernetes-engine/






Tutorials used to achieve this are inspired from the below links:
* https://portworx.com/run-ha-elasticsearch-elk-google-kubernetes-engine/
* https://www.elastic.co/blog/high-availability-elasticsearch-on-kubernetes-with-eck-and-gke