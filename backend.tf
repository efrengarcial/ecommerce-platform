terraform {
  backend "gcs" {
    bucket = "clean-utility-228617-tfstate"
    credentials = "./google-cred.json"
  }
}
