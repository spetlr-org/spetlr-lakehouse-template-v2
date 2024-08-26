## This module is for finding the python wheel file of the spetlr library and uploading it to the azure storage container ##

locals {
  spetlr_wheel = tolist(fileset("${dirname(dirname(dirname(path.cwd)))}/dist", "*.whl"))[0]
}

resource "azurerm_storage_blob" "upload_spetlr" {
  name                   = "${module.global_variables.az_infrastructure_libraries_folder}/dataplatform-latest-py3-none-any.whl"
  storage_account_name   = local.resource_name
  storage_container_name = module.global_variables.az_infrastructure_container
  type                   = "Block"
  source                 = "${dirname(dirname(dirname(path.cwd)))}/dist/${local.spetlr_wheel}"
}