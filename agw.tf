

resource "azurerm_public_ip" "this" {
  name                = "app-gateway-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  frontend_port = [{
    name     = "port_443"
    protocol = "Http"
    port     = 443
  }]

  waf_configuration = [{
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"

  }]
}

resource "azurerm_virtual_network" "this" {
  name                = "this-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_application_gateway" "this" {
  name                = "this-app-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "app_gateway_ip_configuration"
    subnet_id = azurerm_subnet.this.id
  }

  frontend_port {
    name = "https_port"
    port = 443
  }
  frontend_ip_configuration {
    name                 = "public_ip_configuration"
    public_ip_address_id = null
  }
  frontend_ip_configuration {
    name                          = "private_ip_configuration"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address            = "10.0.2.235"
    private_ip_address_allocation = "Static"
  }

  backend_address_pool {
    name = "backend_address_pool"
  }

  backend_http_settings {
    name                  = "https_settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    name                           = "https_listener"
    frontend_ip_configuration_name = "private_ip_configuration"
    frontend_port_name             = "https_port"
    protocol                       = "Https"
    ssl_certificate_name           = "this_ssl_cert"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_gateway_identity.id]
  }
  request_routing_rule {
    name                       = "https_routing_rule"
    rule_type                  = "Basic"
    http_listener_name         = "https_listener"
    backend_address_pool_name  = "backend_address_pool"
    backend_http_settings_name = "https_settings"
    priority                   = 1
  }
    dynamic  "waf_configuration" {
     for_each = local.waf_configuration
    content {
    enabled          =  waf_configuration.value.enabled          
    firewall_mode    =  waf_configuration.value.firewall_mode     
    rule_set_type    =  waf_configuration.value.rule_set_type     
    rule_set_version =  waf_configuration.value.rule_set_version
  }
  }
  ssl_certificate {
    name     = "this_ssl_cert"
    # data     = pkcs12_from_pem.self_signed_cert.result
    # password = pkcs12_from_pem.self_signed_cert.password
    key_vault_secret_id = azurerm_key_vault_certificate.this.secret_id
  }

  tags = {
    environment = "dev"
  }
}


