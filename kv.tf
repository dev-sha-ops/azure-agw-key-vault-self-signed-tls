# Key Vault

resource "azurerm_user_assigned_identity" "app_gateway_identity" {
  name                = "app-gateway-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}
resource "azurerm_key_vault" "this" {
  name                = "this-key-vault"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "standard"

  tenant_id = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id


    secret_permissions      = ["Get", "List", "Set", "Delete"]
    key_permissions         = ["Get", "List", "Create", "Delete"]
 certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "SetIssuers",
      "Update"
    ]

  }
   access_policy {
    object_id    = azurerm_user_assigned_identity.app_gateway_identity.principal_id
    tenant_id    = data.azurerm_client_config.current.tenant_id

    secret_permissions = [
      "Get"
    ]
  }
}

# Upload the certificate to Key Vault
resource "azurerm_key_vault_certificate" "this" {
  name         = "this-ssl-cert"
  key_vault_id = azurerm_key_vault.this.id

  certificate {
    contents = pkcs12_from_pem.self_signed_cert.result
    password = pkcs12_from_pem.self_signed_cert.password
  }
}
