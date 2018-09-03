@en
@2456
Feature: CHOM-2456
  I, as NFV Engineer, want to be able to onboard NS to monitoring automatically via instantiating MRS NS

  Scenario: Cleanup Runtime Catalog and VIM inventory
    Given cleanup runtime catalog
    And cleanup VIM inventory
    And cleanup configuration manager
    And cleanup topology manager
    And cleanup policy manager
    And cleanup topology inventory
    And cleanup license manager
    And cleanup monitoring console
    And cleanup contrail

  Scenario Outline: Onboard Package
    Given create package with name "<VNF_package_name>" , type "<PACKAGE_TYPE>" and save answer to "answer"
    And parse value from json "answer" by jsonpath "$.id" to "local" variable "packageId"
    And parse value from json "answer" by jsonpath "$.packageStatus" to "local" variable "packageStatus"
    And compare value "packageStatus" with value "INITIAL"
    And move property with name "<Descriptor_url_property>" to "local" storage with name "packageUrl"
    And download package from property contains url remote archive "packageUrl" to "<file_name>"

    When import tosca with package id "packageId" from "local" storage and archieve "<file_name>" and save answer to "answer"
    And parse value from json "answer" by jsonpath "$.packageStatus" to "local" variable "newPackageStatus"
    Then wait no more "5" minutes while package "packageId" from "local" storage status is "UPLOADED" and operational state is "ENABLED" and save answer to "answer"
    And parse value from json "answer" by jsonpath "$.shares[0].operationalState" to "local" variable "packageOperationalState"
    And parse value from json "answer" by jsonpath "$.descriptorId" to "global" variable "<DescriptorId>"
    And compare value "packageOperationalState" with value "ENABLED"

    Examples:
      | VNF_package_name | Descriptor_url_property       | PACKAGE_TYPE | file_name      | DescriptorId    |
      | vSRX             | csar.destination.url.vsrx     | VNF_PACKAGE  | ./tmp/csar.zip | vsrxDesciptorId |
      | csr1000v         | csar.destination.url.csr1000v | VNF_PACKAGE  | ./tmp/csar.zip | csrDescriptorId |
      | MRS              | csar.destination.url.mrs      | NS_PACKAGE   | ./tmp/csar.zip | mrsDescriptorId |


  Scenario: Scenario: Vim registration in VIM and mapping creation
    Given create OS endpoint for NS : name = "lamdaOS",type="openstack_v3", username="mano9dev", password="mano9dev" and save answer to "answer_openStack"
    And create endpoint : name = "lambdaContrail",type="contrail_v2", username="mano9dev", password="mano9dev" and save answer to "answer_contrail"
    When parse value from json "answer_openStack" by jsonpath "$.id" to "local" variable "endPointId_openStack"
    And parse value from json "answer_contrail" by jsonpath "$.id" to "local" variable "endPointId_contrail"
    And create VIM with ids from storage "endPointId_contrail","endPointId_openStack" and save answer to "answer"
    And parse value from json "answer" by jsonpath "$.id" to "global" variable "VimId"
    And load mapping from "./mappings/contrail_2.yaml" and save response code to "answer_contrail"
    Then compare value "answer_contrail" with value "204"
    And load mapping from "./mappings/openstack_v3.yaml" and save response code to "answer_os"
    Then compare value "answer_os" with value "204"
    And load mapping from "./mappings/generic.yaml" and save response code to "answer_generic"
    Then compare value "answer_generic" with value "204"
    And load all tosca composer mapping

  Scenario: CHOM-2456 Instantination process
    Given create topology name "MRS CHOM-2456" and description "NsAutoTest" and descriptorId "mrsDescriptorId" from "global" storage save answer to "Answer"
    And parse value from json "Answer" by jsonpath "$.id" to "global" variable "topologyId"
    And load next variables from config.properties to "global" context
      | ns.tenant              |
      | ns.floating_network_id |
    When start NS instantiation with "topologyId" and query template "nsInstantiationTemplate" and parameters Variables from "global" storage and save headers in json file "headers"
      | tenant              |
      | VimId               |
      | floating_network_id |
    And parse value from json "headers" by jsonpath "$.Location" to "local" variable "instantiationLink"
    Then go to URI from variable "instantiationLink" and save response to variable "location_answer"
    And parse value from json "location_answer" by jsonpath "$.id" to "local" variable "operation_id"
    And for "30" minutes every "20" seconds get operation status with id from variable "operation_id" while it will go in "COMPLETED" status and save response to "operation_status"

  Scenario: Check metrics for NS in Prometheus
    When for "2" minute every "5" seconds try to get metric "availability_avg" for topology "topologyId"
    Then response must not be empty

  Scenario: CHOM-2456 Termination process
    Given get topology info with id from variable "topologyId" and save response to "topology_answer"
    And parse value from json "topology_answer" by jsonpath "$.status" to "local" variable "topology_status"
    And compare value "topology_status" with value "INSTANTIATED"
    When terminate NS topology with id from variable "topologyId" and save response to "termination_answer"
    Then get from response "termination_answer" header with name "Location" and save to variable "location"
    And compare value of variable "location" with regexp template "http[s]?://ns-manager.*/.*"
    And go to URI from variable "location" and save response to variable "location_answer"
    And parse value from json "location_answer" by jsonpath "$.id" to "local" variable "operation_id"
    And for "30" minutes every "20" seconds get operation status with id from variable "operation_id" while it will go in "COMPLETED" status and save response to "operation_status"
    And get topology info with id from variable "topologyId" and save response to "topology_answer"
    And parse value from json "topology_answer" by jsonpath "$.status" to "local" variable "topology_status"
    And compare value "topology_status" with value "NOT_INSTANTIATED"