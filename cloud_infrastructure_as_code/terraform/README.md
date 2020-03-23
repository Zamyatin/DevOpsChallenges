# Terraform Infrastructure as Code Challenges!

## Stuff to Install
In addition, there are a few tools you will want to download/install. Instructions included to install using [HomeBrew on MacOS](https://brew.sh)

- [HashiCorp's Terraform](https://www.hashicorp.com/products/terraform)
  - To install:
    ```
    brew install terraform
    ```
  
  - Altnerative option
  
    Sometimes we have to manage multiple installations of Terraform for running/managing/developing multiple Terraform repositories.  In this case, enviroment managers are useful. Terraform developers have taken a queue from Ruby developers' `rbenv` tool, and created [the `tfenv` tool](https://github.com/tfutils/tfenv) to manage those Terraform versions.  

    To install: 
    1) Install tfenv: 
        ```
        brew install tfenv
        ```
    1) List all available version of Terraform (and confirm `tfenv` works): 
        ```
        tfenv list-remote
        ```
    1) Install a version of Terraform:
        ```
        tfenv install [version]
        ```
    1) To use the version of Terraform in your repo:
        ```
        tfenv use [version]
        ```
        This will create a .terraform-version
---

## Resources

- Hashicorp's [Terraform Docs](https://www.terraform.io/docs/index.html)
- [Terraform Up & Running Book](https://www.terraformupandrunning.com)
