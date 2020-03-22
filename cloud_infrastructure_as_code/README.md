# Cloud Infrastructure Provisioning - Delivery as Code

I have some mixed feelings on how to teach/test for knowledge of Cloud Resource Engineering (provisioing resources).  Sure, we can test whether an engineer can stand up Cloud resources through various web consoles (AWS, Google Cloud Console, etc), but, in the real world, infrastructure should not be delivered in this way.  

In reality, most companies should, if not are, prefering some type of infrastructure as code as a deliverable.  Provisioning infrastrucutre should be relatively simple, repeatable, modular, and automation-friendly, just as is the case in any software delivery.

There are a number of infrastructure-as-code solutions out there. Some focus on Immuntable Infrastructure, while others focus on managing mutable infrastructure 

Current Focus:
- [HashiCorp's Terraform](https://www.hashicorp.com/products/terraform)

Future Development/focus:
- [Chef](https://www.chef.io) 
- [Puppet](https://puppet.com)
- [RedHat's Ainsible](https://www.ansible.com)
- [SaltStack](https://www.saltstack.com)

