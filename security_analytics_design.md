 # Security Analytics Platform Design
 
 This project and the others associated are designed to form a foundation for an extensible security scanning and analytics application. This document describes key points of the design, it highlights intentions and potential future works as well as areas where the current implementation does not yet live up to intentions.
 
 ## Data lake approach
 
 For the security analytics platform, we have chosen to take a data lake approach to the problem. Each and every scan should record all of the data it has and dump it out into S3. Even if some of that data isn't used right now, and might not make it into elastic.

 By saving that raw output, we are able to re-ingest that raw data later using different analysis and tools that weren't available before.
 
 ### Re-ingestion of results
 
 The temporal and non temporal keys that the are used by this project support the re-ingestion process. If a set of results were re-ingested, with new code to process the raw record, they would have the same keys, and would replace the older data in elastic.
 
 ## Modularity
 
 Security analytics uses a modular design. This facilitates fast flexible working. Removing, for example, the need to redepoly/update all services when adding a new kind of scan, or updating an existing analytic of the scan data.
 
 This flexibility can lead to increased decoupling, and more rapid continuous deployment capabilities, but it does have implications. For example, the use of feature flags should be made. A feature flag allows a services's features to be added, removed or changed without impacting older services that interact with it. For example to change an api, one would add a feature flag to enable the new usage, once all clients use new version the old one can be removed in a later release. Changes made to services should never break backwards compatibility for any dependent service.
 
 ### Projects as services
 
 Many of the projects in security analytics have been designed to provide a service e.g. nmap scan is a service that will perform NMAP scans. These services all have an SQS queue as their input, and/or an SNS queue as their output. This shape allows both fan in and fan out, by which I mean that any other service with permissions can place a message on the inbound request sqs queue to use a service, and that any other service with permissions can subscribe to the output's SNS topic to consume a service's data.
 
 Note that a service should always try to place enough information into the message attributes of the SNS output events. This enables subscribing services to use filters in their subscriptions for efficiency. 
 
 ### SSM parameters
 
 Splitting the analytics platform into many smaller projects means that one terraform state file will not contain all of the infrastructure for the whole platform. Each project is treated as it's own small service.
 
 Since the projects depend on each other, their infrastructure depends on each other's too and they need a way of locating these resources.
 
 In the analytics platform we have chosen to use AWS SSM Parameters to share infrastructure between projects.
 
 For example the analytics platform will export an ssm parameter called e.g. /sec-an/analytics-platform/input_queue/url which contains the SQS queue's url. A scanner that wan't to send elastic data would look up this parameter.
 
 Since each and every project has its own release cycle, and because it should never be necessary to update other services every time one of their dependencies is updated, SSM parameters should be looked up as late as possible.
 
 For example if that input queue was looked up when a scan lambda was deployed, then that scan lambda will need redeploying if the analytics platform moved its sqs queue. If instead the SSM parameter is looked up each time data is sent to the queue, the queue can be moved at any time without requiring a redeploy.
 
 Please note that modules should normally expose their ssm parameter output values through output variables too, so that if the project that defines the parameters also wants to use them, they can use the variables (the ssm parameters aren't available until after the terraform apply finishes)
 
 ### Infrastructure vs. Modules
 
 There are two types of resources which are the only types that all of our security analytics projects produce, infrastructure and module definitions. Infrastructure covers e.g. aws lambda instances, layer versions, elastic search and ecs clusters, IAM roles and many other things. Modules are terraform module definitions that the other projects would use, for example there is a module to setup a dead letter queue for a lambda, which many lambdas use.
 
 ### Main current projects
 
 These are the main modules in security analytics at present, the ordering they are mentioned here when used as a deployment order will ensure all projects are deployed after the ones they depend on.
 
 1. _Shared Code_
    - *Infrastructure*
      1. *Shared utils layer* - python decorators and other code that make writing security analytics lambdas easier
    - *Modules*
      1. *Dead letter recorder* - a module that sets up a dead letter queue and a lambda that forwards dead letters to an s3 bucket to be examined later
      2. *SQS SNS Glue* - a module that uses a lambda to wire an sqs queue to an sns queue, used in the scan planner with the delay queue.
      
 2. _Shared Infrastructure_
    - *Infrastructure*
      1. *API Gateway* - This API gateway will be shared by all the projects in security analytics, each project adding resources to the API. Note that the early stages of the project do not have a public API, Kibana being the only user interface.
      2. *Monitoring infrastructure* - At present this provides a role for SNS to use when logging failures, as well as the S3 bucket used to store dead letters.
      3. *Cognito User Pool* - This is used to provide authentication and manage users for the whole security analytics platform.
      4. *VPC* - Best practices and good intentions would lead to us running a public and private VPC for the security analytics platform. E.g. the ECS cluster should be in our private VPC and it would access the internet via a NAT gateway. This module is flexible about how many availability zones it makes use of. In reality additional permissions, infrastructure and configuration are needed to make this work e.g. giving permissions to create elastic IP addresses. Some things e.g. Lambdas can be run in the private VPC, but benefit little from doing so. In reality we currently don't create the private vpc and our ECS cluster is in the public vpc.
      
 3. _Analytics Platform_
    - *Infrastructure*
      1. *Elastic search* - Provisions the elastic search instance, kibana and integrates this with the cognito user pool. It also places an SQS queue in front of the elastic instance, to fit with the service model described above and to decouple e.g. scans from the elastic API allowing us to switch in other types of datastore later. Currently only uses AWS elastic search, but in future may be changed to create and manage the cluster more explicitly.
      2. *Dead letter reporter* - This lambda trigger will be triggered whenever a dead letter is recorded into the bucket which holds them and report the dead letter to the elastic instance so that the breakdown of dead letters per resource and time and be recorded within elastic.
    - *Modules*
      1. *Dynamo elastic sync* - a module which can be used to replicate a dynamo db table into elastic e.g. used to visualise the DNS resolution data in Kibana.
      2. *Elastic Index* - a module that can be used to provision an elastic index using terraform. N.B. This is currently hacked together with some python scripts and null_resources with provisioners. This just about works, but is error prone and limited. In future a real terraform plugin for elastic should be developed.
      3. *Kibana Saved Object* - A module like the elastic index one, but which enables the provision of e.g. visualisations, searches and dashboards.
      
 4. _Task Execution_
    - *Infrastructure*
      1.  *ECS Cluster* - Currently a Fargate based cluster not in the private VPC. Used to run scans that take too long, require root perms or more resources than a lambda can.
      2. *DNS Ingestor & Scan Scheduler* - Using dynamo db to track host<->address mappings, route 53 hosted domain records are ingested in order to determine a scanning plan. Later another lambda, scheduled using cloud watch cron schedules will add scan requests to a delay queue so that the requests will be output at the correct scheduled time. The scan planning is done by adding each scan to one of a covering of 15 minute buckets across the day, and then using a uniform distribution to locate the planned scan within the bucket. Using the dynamo to elastic sync and some kibana saved resources this will add some visualisations to the platform.
    - *Modules*
      1. *Task* - the task module is the module used by all implementations of a scan that is implemented using a lambda. A task comprises two lambdas one which does the scan and stores the raw results in s3 and another that parses those results to construct the output messages that are often e.g. piped into elastic. Note the data lake design keeps the raw inputs so that later when the  
      2. *ECS Task* - An extension of the Task module where the scan lambda is used to invoke an ECS task to actually run the scan. Useful for scans that take more than 15mins, ones which need root to construct custom packets e.g. nmap.
      
 5. _NMAP scanner_
   - *Infrastructure*
     1. *Nmap scanner* - The nmap scanner is an ECS task which does a basic port scan, tries to identify e.g. application fingerprints, and does some basic SSL and CVE checks. The nmap scanner will be subscribed to the output of the scan scheduler so that it will be a primary scan, done once for each IP address resolved. The nmap scan also subscribes the elastic search input queue to its output so that the details of the scan are stored in elastic, and so that secondary scans can be triggered e.g. when nmap discovers a new http port open on a host. As well as actual scanner and results parser, this project adds visualisations and dashboards to kibana.
     
 6. _SSL scanner_
    - *Infrastructure*
      1. *SSL Scanner* - this scanner is a secondary scan, triggered when the nmap scan detects ports which should be using SSL. It is a lambda based, as opposed to ECS based scanner.
 
 # Notes
 
 1. There is a point at which replacing ECS Fargate with a managed cluster will be more expensive than managing our own cluster
 2. There is a point at which we may similarly want to manage our own elastic cluster, but things like e.g. cognito integration will be harder to replicate. We could also use a more up to date version of elastic that way.
 3. Task execution project could be split into task execution and dns ingestor projects.
 4. Tracking DNS resolution data in dynamodb might be better stored in a graph data base e.g. neptune or neo4j
 5. The Dashboards that pull together the visualisations contributed by different projects currently live in nmap because it was for a long time our only scan.
 6. NMAP scanner's results parser currently doesn't add message attribute data for secondary scans to filter e.g. only port 80 or http service ports.
    
 # Best practices
 
 1. New releases of services should be backwards compatible
 2. Use feature flags to manage breaking changes
 3. Provide message attributes on the output sns messages from services to enable subscription filtering
 4. For asynchronously called lambdas always use a dead letter queue resolver
 5. For lambdas called synchronously e.g. from SQS or from DynamoDB streams, use the @forward_exceptions_to_dlq decorator to implement dead letter queues
 6. For SQS queues always add a redrive policy and dead letter queue
 7. Try to avoid Behemoth shared libraries (i.e. the shared utils layer should be kept very small)
 8. Projects that provide infrastructure should publish SSM parameters to share it with other projects
 9. In code, prefer using SSM parameters over environment variables in e.g. lambdas and ECS tasks
 10. Writing terraform modules prefer input variables over ssm parameters data sources
