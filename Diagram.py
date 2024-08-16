from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2, Lambda
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB, Route53
from diagrams.aws.storage import S3
from diagrams.aws.integration import SNS

with Diagram("HealthTrack Architecture", show=False):
    dns = Route53("DNS")
    load_balancer = ELB("Load Balancer")
    
    with Cluster("Web Application"):
        with Cluster("App Server Cluster"):
            app_servers = [EC2("App Server 1"),
                           EC2("App Server 2"),
                           EC2("App Server 3")]

        queue = SNS("Notification Queue")
        
        with Cluster("Processing"):
            processors = [Lambda("Activity Processor"),
                          Lambda("Sleep Processor"),
                          Lambda("Hydration Processor")]

        s3_bucket = S3("Health Data Bucket")
        db = RDS("User Data DB")
    
    dns >> load_balancer >> app_servers
    app_servers >> queue >> processors
    processors >> s3_bucket
    processors >> db
