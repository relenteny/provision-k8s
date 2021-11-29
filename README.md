# Kubernetes Provisioner

The objective of this code base is to provide a pattern by which functionality can be added to an existing Kubernetes Cluster. It is geared toward personal development/test clusters, but is capable of configuring just about any type of Kubernetes cluster.

Currently, this version of the provisioning process supports Docker for Windows and Docker for Mac and minikube.

Based on experience dealing with environmental issues across local workstation environments, the approach taken here is to provision a Kubernetes cluster using a prebuilt Docker image. Doing this provides a more stable environment from which a cluster may be configured. It's not foolproof, but it significantly decreases the challenges faced when trying to provide this type of functionality across a myriad of workstation configurations on multiple operating systems.

In addition, to support the ever advancing state of this technology, as part of the provisioning process, the Docker image used is built at provisioning time. If clusters are re-provisioned, the Docker image is not rebuilt; shortening the time require to re-provision a cluster.

## Project Structure

```text
provision-k8s
  + ansible              (Ansible playbook and components using in provisioning the cluster)
  + charts
  |   + local-registry   (Helm chart used to install and configure a local Docker registry)
  + images
  |   + k8s-provisioner  (Docker image built during the provision process and use to provision the cluster)
  + scripts              (scripts used to execute the provisioning process)

```

## Prerequisites

As mentioned above, the current provisioning process assumes Docker for Windows or Docker for Mac, or minkube, are installed and that the Kubernetes functionality has been enabled. Links to the specific installation packages are found on the Docker website on the [Docker Desktop overview](https://docs.docker.com/desktop/) and [minikube](https://minikube.sigs.k8s.io/docs/) pages. This process has been tested against Docker for Mac/Windows 4.2.0 and minikube 1.24.0.

### Resources

Kubernetes can be fairly resource intensive. Like any other technology, it depends on what you'll be doing with it. While it may not use all of them, it is best to configure as many CPUs as you see practical. Configure at least 1/2 the number of CPUs. This doesn't pre-allocate the number of CPUs to Kubernetes. It allows Kubernetes to use the number of CPUs. As far as memory goes, 4GB is the minimum. If you'll be doing anything beyond basic experimentation, 8GB would be recommended. Similar to the CPUs, Kubernetes will not pre-allocate the memory. It will uses what it needs up to the limit provided.

### Additional Information

#### Docker for Mac

* Docker for Mac should be configured with a minimum of 6GB RAM allocated
`git` must be available at the command line
* For a brief time, the provisioning script requires sudo/root privileges. This is to update `/etc/hosts` with cluster host information.

#### Docker for Windows

* The Windows provisioning process requires the Windows Subsystem for Linux, version 2 (WSL2), be installed. The script has been validated using the Ubuntu distribution.
* Docker for Windows should be configured with a minimum of 6GB RAM allocated
* `git` must be available at the command line
* For a brief time, the provisioning script requires sudo/root privileges. This is to update `/etc/hosts` with cluster host information. Ensure the user running the script has sudo privileges.
* The process also updates the Windows hosts file. This requires that the WSL2 provisioning process be executing with Windows Administrator privileges. There are various methods available to handle this issue. The most straightforward is to start the WSL2 session using "Run as administrator." Once the provisioning process has successfully executed, subsequent WSL sessions will not require administrative privileges.
* Once provisioned, to interact with the Kubernetes cluster, a WSL2 session is not required. All functionality will be available from the Windows command line as well.
* If you plan to use Helm from the Windows command line, you will need to install it. The process is outlined on the Helm website at [Installing Helm](https://helm.sh/docs/intro/install/).

#### minikube

* The script expects the default profile, `minikube` to be the active profile.
* The docker and kubectl commands must be available.
* For a brief time, the provisioning script requires sudo/root privileges. This is to update `/etc/hosts` with cluster host information.
* The script will create files used when running the cluster located in `~/.minikube/files`. 
## Installed Components

As outlined in my DZone article, [I Just Installed Kubernetes on My Workstation – Now What?](https://dzone.com/articles/i-just-installed-my-own-test-kubernetes-cluster-no), the intention behind this provisioning process is to configured a Kubernetes cluster with a set of components that make it suitable for development and testing of Kubernetes deployments.

While the below outlines the components installed and configured by the provisioning process, by reviewing the code and the patterns used, customizing the process, removing or adding to the components installed, is straightforward.

### Kubernetes Dashboard

The [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) is a web-based Kubernetes interface. From the Kubernetes documentation:

> Dashboard is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications to a Kubernetes cluster, troubleshoot your containerized application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc). For example, you can scale a Deployment, initiate a rolling update, restart a pod or deploy new applications using a deploy wizard. Dashboard also provides information on the state of Kubernetes resources in your cluster and on any errors that may have occurred.

### Cluster Ingress Controller

 For most applications, ingress resources are an important aspect of configuration and deployment. A cluster ingress controller provides the base support for using [Kubernetes Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/).

### Metrics Server

The Kubernetes [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) is used to gather information on cluster resources to aid in auto-scaling orchestration.

### Private Docker Registry

Most users familiar with the container ecosystem understand that a Docker Registry is an important Kubernetes deployment and orchestration component. There are several cloud-based Docker registries available for use.

Based on use case, the cloud-providers do have some downsides and restrictions. To that end, the provisioning process deploys and configures a private Docker Registry providing basic support for development and deployment uses.

### ChartMuseum

[Helm](https://helm.sh/) has become an integral part of many Kubernetes deployment pipelines. Similar to a Docker Registry, Helm also uses a repository for artifact storage. The cluster is configured with [ChartMuseum](https://chartmuseum.com/) as the local Helm repository.

### Kubeapps

[Kubeapps](https://kubeapps.com/) provides a web-based front end to Helm repositories and operations. This instance of Kubeapps is configured for access to the local Helm repository backed by ChartMuseum as well as common public repositories.

### Prometheus

For Kubernetes, [Prometheus](https://prometheus.io/) has become a predominant metrics and alerting system. When installing and configuring Prometheus in a Kubernetes cluster, multiple patterns exist. This provisioning process installs and configures the Prometheus Operator including a [Grafana](https://grafana.com/) front-end configured to interact with the Prometheus data source.

## Executing the Provisioning Process

While this process has been vetted across multiple systems on Both Windows and MacOS, there are serval aspects that make assumptions regarding environment. Some are described above in the Prerequisites section. The vast majority of environmental and operating system-specific issues are addressed by executing the provisioning process from within a Docker container.

To execute the provisioning process, use the following command:

* Download the provisioning script from `scripts/provision-k8s.sh`
* Make the script executable `chmod +x provision-k8s.sh`
* Execute the script `./provision-k8s.sh`

The provision process creates a README file in `${HOME}/kubernetes/docker-desktop`. Upon successful operation, it will contain information regarding the outcome of the process including links that can be used to access installed components.

The provisioning process also supports removing the installed components. It can be executed using the following invocation:

* Using the same script, execute `./provision-k8s.sh remove`

### Notes on Executing the Process

* At times while executing the process, you will see output similar to this: `fatal: [127.0.0.1]: FAILED! => {"censored": "the output has been hidden due to the fact that 'no_log: true' was specified for this result", "changed": true}`. These errors can be ignored. In these cases, the script is hiding error output that it's expecting.
* The process can be executed multiple times. For example, if, while running the process, you experience something like a network outage, you can simply run the script again. It will pick up where it left off.
