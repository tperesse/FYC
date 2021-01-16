terraform {
    backend "s3" {
        encrypt = true
        bucket  = "projet-annuel"
        region  = "eu-west-3"
        key     = "projet.tfstate"
    }
}