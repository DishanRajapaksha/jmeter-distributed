locals {
  tags = {
    CreatedBy       = "${var.CREATED_BY}"
  }
}

resource "random_id" "random" {
  byte_length = 4
}

resource "azurerm_resource_group" "jmeter_rg" {
  name     = "jmeter-load-testing-rg"
  location = var.LOCATION
  tags     = local.tags
}

resource "azurerm_virtual_network" "jmeter_vnet" {
  name                = "jmeter-load-testing-vnet"
  location            = azurerm_resource_group.jmeter_rg.location
  resource_group_name = azurerm_resource_group.jmeter_rg.name
  address_space       = ["${var.VNET_ADDRESS_SPACE}"]
  tags     = local.tags
}

resource "azurerm_subnet" "jmeter_subnet" {
  name                 = "jmeter-load-testing-subnet"
  resource_group_name  = azurerm_resource_group.jmeter_rg.name
  virtual_network_name = azurerm_virtual_network.jmeter_vnet.name
  address_prefix       = var.SUBNET_ADDRESS_PREFIX

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_network_profile" "jmeter_net_profile" {
  name                = "jmeter-load-testing-netprofile"
  location            = azurerm_resource_group.jmeter_rg.location
  resource_group_name = azurerm_resource_group.jmeter_rg.name

  container_network_interface {
    name = "jmeter-load-testing-cnic"

    ip_configuration {
      name      = "jmeter-load-testing-ipconfig"
      subnet_id = azurerm_subnet.jmeter_subnet.id
    }
  }
  tags     = local.tags
}

resource "azurerm_storage_account" "jmeter_storage" {
  name                = "jmeter${random_id.random.hex}"
  resource_group_name = azurerm_resource_group.jmeter_rg.name
  location            = azurerm_resource_group.jmeter_rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = ["${azurerm_subnet.jmeter_subnet.id}"]
  }
  tags     = local.tags
}

resource "azurerm_storage_share" "jmeter_share" {
  name                 = "jmeter"
  storage_account_name = azurerm_storage_account.jmeter_storage.name
  quota                = var.JMETER_STORAGE_QUOTA_GIGABYTES
}

resource "azurerm_container_group" "jmeter_workers" {
  count               = var.JMETER_WORKERS_COUNT
  name                = "jmeter-load-testing-worker-${count.index}"
  location            = azurerm_resource_group.jmeter_rg.location
  resource_group_name = azurerm_resource_group.jmeter_rg.name

  ip_address_type = "private"
  os_type         = "Linux"

  network_profile_id = azurerm_network_profile.jmeter_net_profile.id

  container {
    name   = "jmeter"
    image  = var.JMETER_DOCKER_IMAGE
    cpu    = var.JMETER_WORKER_CPU
    memory = var.JMETER_WORKER_MEMORY

    ports {
      port     = var.JMETER_DOCKER_PORT
      protocol = "TCP"
    }

    volume {
      name                 = "jmeter"
      mount_path           = "/jmeter"
      read_only            = true
      storage_account_name = azurerm_storage_account.jmeter_storage.name
      storage_account_key  = azurerm_storage_account.jmeter_storage.primary_access_key
      share_name           = azurerm_storage_share.jmeter_share.name
    }

    commands = [
      "/bin/sh",
      "-c",
      "cp -r /jmeter/* .; /entrypoint.sh -s -J server.rmi.ssl.disable=true",
    ]
  }
  tags     = local.tags
}

resource "azurerm_container_group" "jmeter_controller" {
  name                = "jmeter-load-testing-controller"
  location            = azurerm_resource_group.jmeter_rg.location
  resource_group_name = azurerm_resource_group.jmeter_rg.name

  ip_address_type = "private"
  os_type         = "Linux"

  network_profile_id = azurerm_network_profile.jmeter_net_profile.id

  restart_policy = "Never"

  container {
    name   = "jmeter"
    image  = var.JMETER_DOCKER_IMAGE
    cpu    = var.JMETER_CONTROLLER_CPU
    memory = var.JMETER_CONTROLLER_MEMORY

    ports {
      port     = var.JMETER_DOCKER_PORT
      protocol = "TCP"
    }

    volume {
      name                 = "jmeter"
      mount_path           = "/jmeter"
      read_only            = false
      storage_account_name = azurerm_storage_account.jmeter_storage.name
      storage_account_key  = azurerm_storage_account.jmeter_storage.primary_access_key
      share_name           = azurerm_storage_share.jmeter_share.name
    }

    commands = [
      "/bin/sh",
      "-c",
      "cd /jmeter; /entrypoint.sh -n -J server.rmi.ssl.disable=true -t ${var.JMETER_JMX_FILE} -l ${var.JMETER_RESULTS_FILE} -e -o ${var.JMETER_DASHBOARD_FOLDER} -R ${join(",", "${azurerm_container_group.jmeter_workers.*.ip_address}")} ${var.JMETER_EXTRA_CLI_ARGUMENTS}",
    ]
  }
  tags     = local.tags
}