#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "gcp_project_id" {
  type = string

  description = <<EOF
The ID of the project in which the resources belong.
EOF
}

variable "cluster_name" {
  type = string

  description = <<EOF
The name of the cluster, unique within the project and zone.
EOF
}

variable "gcp_location" {
  type = string

  description = <<EOF
The location (region or zone) in which the cluster master will be created,
as well as the default node location. If you specify a zone (such as
us-central1-a), the cluster will be a zonal cluster with a single cluster
master. If you specify a region (such as us-west1), the cluster will be a
regional cluster with multiple masters spread across zones in that region.
Node pools will also be created as regional or zonal, to match the cluster.
If a node pool is zonal it will have the specified number of nodes in that
zone. If a node pool is regional it will have the specified number of nodes
in each zone within that region. For more information see: 
https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters
EOF
}

variable "daily_maintenance_window_start_time" {
  type = string

  description = <<EOF
The start time of the 4 hour window for daily maintenance operations RFC3339
format HH:MM, where HH : [00-23] and MM : [00-59] GMT.
EOF
}

variable "node_pools" {
  type = list(map(string))

  description = <<EOF
The list of node pool configurations, each can include:

name - The name of the node pool, which will be suffixed with '-pool'.
Defaults to pool number in the Terraform list, starting from 1.

initial_node_count - The initial node count for the pool. Changing this will
force recreation of the resource. Defaults to 1.

autoscaling_min_node_count - Minimum number of nodes in the NodePool. Must be
>=0 and <= max_node_count. Defaults to 2.

autoscaling_max_node_count - Maximum number of nodes in the NodePool. Must be
>= min_node_count. Defaults to 3.

management_auto_repair - Whether the nodes will be automatically repaired.
Defaults to 'true'.

management_auto_upgrade - Whether the nodes will be automatically upgraded.
Defaults to 'true'.

version - The Kubernetes version for the nodes in this pool. Note that if this
field is set the 'management_auto_upgrade' will be overriden and set to 'false'.
This is to avoid both options fighting on what the node version should be. While
a fuzzy version can be specified, it's recommended that you specify explicit
versions as Terraform will see spurious diffs when fuzzy versions are used. See
the 'google_container_engine_versions' data source's 'version_prefix' field to
approximate fuzzy versions in a Terraform-compatible way.

node_config_machine_type - The name of a Google Compute Engine machine type.
Defaults to n1-standard-1. To create a custom machine type, value should be
set as specified here:
https://cloud.google.com/compute/docs/reference/rest/v1/instances#machineType

node_config_disk_type - Type of the disk attached to each node (e.g.
'pd-standard' or 'pd-ssd'). Defaults to 'pd-standard'

node_config_disk_size_gb - Size of the disk attached to each node, specified
in GB. The smallest allowed disk size is 10GB. Defaults to 100GB.

node_config_preemptible - Whether or not the underlying node VMs are
preemptible. See the official documentation for more information. Defaults to
false. https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms
EOF
}

variable "vpc_network_name" {
  type = string

  description = <<EOF
The name of the Google Compute Engine network to which the cluster is
connected.
EOF
}

variable "vpc_subnetwork_name" {
  type = string

  description = <<EOF
The name of the Google Compute Engine subnetwork in which the cluster's
instances are launched.
EOF
}

variable "private_endpoint" {
  type    = bool
  default = false

  description = <<EOF
Whether the master's internal IP address is used as the cluster endpoint and the
public endpoint is disabled.
EOF
}

variable "private_nodes" {
  type    = bool
  default = true

  description = <<EOF
Whether nodes have internal IP addresses only. If enabled, all nodes are given
only RFC 1918 private addresses and communicate with the master via private
networking.
EOF
}

variable "enable_cloud_nat" {
  type        = bool
  default     = true
  description = <<EOF
Whether to enable Cloud NAT. This can be used to allow private cluster nodes to
accesss the internet. Defaults to 'true'.
EOF
}

variable "enable_cloud_nat_logging" {
  type        = bool
  default     = true
  description = <<EOF
Whether the NAT should export logs. Defaults to 'true'.
EOF
}

variable "cloud_nat_logging_filter" {
  type        = string
  default     = "ERRORS_ONLY"
  description = <<EOF
What filtering should be applied to logs for this NAT. Valid values are:
'ERRORS_ONLY', 'TRANSLATIONS_ONLY', 'ALL'. Defaults to 'ERRORS_ONLY'.
EOF
}

variable "vpc_subnetwork_cidr_range" {
  type = string
}

variable "cluster_secondary_range_name" {
  type = string

  description = <<EOF
The name of the secondary range to be used as for the cluster CIDR block.
The secondary range will be used for pod IP addresses. This must be an
existing secondary range associated with the cluster subnetwork.
EOF
}

variable "cluster_secondary_range_cidr" {
  type = string
}

variable "services_secondary_range_name" {
  type = string

  description = <<EOF
The name of the secondary range to be used as for the services CIDR block.
The secondary range will be used for service ClusterIPs. This must be an
existing secondary range associated with the cluster subnetwork.
EOF
}

variable "services_secondary_range_cidr" {
  type = string
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"

  description = <<EOF
The IP range in CIDR notation to use for the hosted master network. This 
range will be used for assigning internal IP addresses to the master or set 
of masters, as well as the ILB VIP. This range must not overlap with any 
other ranges in use within the cluster's network.
EOF
}

variable "access_private_images" {
  type    = bool
  default = false

  description = <<EOF
Whether to create the IAM role for storage.objectViewer, required to access
GCR for private container images.
EOF
}

variable "http_load_balancing_disabled" {
  type    = bool
  default = false

  description = <<EOF
The status of the HTTP (L7) load balancing controller addon, which makes it 
easy to set up HTTP load balancers for services in a cluster. It is enabled 
by default; set disabled = true to disable.
EOF
}

variable "master_authorized_networks_cidr_blocks" {
  type = list(map(string))

  default = [
    {
      # External network that can access Kubernetes master through HTTPS. Must
      # be specified in CIDR notation. This block should allow access from any
      # address, but is given explicitly to prevernt Google's defaults from
      # fighting with Terraform.
      cidr_block = "0.0.0.0/0"
      # Field for users to identify CIDR blocks.
      display_name = "default"
    },
  ]

  description = <<EOF
Defines up to 20 external networks that can access Kubernetes master
through HTTPS.
EOF
}

variable "pod_security_policy_enabled" {
  type = bool

  default = false

  description = <<EOF
A PodSecurityPolicy is an admission controller resource you create that
validates requests to create and update Pods on your cluster. The
PodSecurityPolicy resource defines a set of conditions that Pods must meet to be
accepted by the cluster; when a request to create or update a Pod does not meet
the conditions in the PodSecurityPolicy, that request is rejected and an error
is returned.

If you enable the PodSecurityPolicy controller without first defining and
authorizing any actual policies, no users, controllers, or service accounts can
create or update Pods. If you are working with an existing cluster, you should
define and authorize policies before enabling the controller.

https://cloud.google.com/kubernetes-engine/docs/how-to/pod-security-policies
EOF
}

variable "identity_namespace" {
  type = string

  default = ""

  description = <<EOF
The workload identity namespace to use with this cluster. Currently, the only
supported identity namespace is the project's default
'[project_id].svc.id.goog'.
https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
EOF
}

#variable "username" {
#  default     = ""
#  description = "gke username"
#}

#variable "password" {
#  default     = ""
#  description = "gke password"
#}
