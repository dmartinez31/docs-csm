## Boot Compute Nodes with a Kubernetes Customized Image

Use the Boot Orchestration Service \(BOS\) to boot compute nodes with an existing compute Kubernetes \(ck8s\) customized image. This procedure creates a BOS session template required to reboot the compute nodes with a new image.

Compute nodes can be booted to use a Kubernetes customized image after this procedure is complete.

### Prerequisites

-   The system is installed and running.
-   A customized image root and its associated kernel and initd images have been uploaded to the artifact repository.
-   cURL or some other tool for interaction with HTTPS servers and RESTful APIs is installed on the local host. See [https://curl.haxx.se/](https://curl.haxx.se/).

### Procedure

1.  View the current session template.

    The following example queries a session template named cle-.0 in JSON format. This can be used as a template for creating a customized session template.

    ```bash
    ncn-m001# cray bos sessiontemplate describe cle-.0 --format json
    {
      "boot_sets": {
        "computes": {
          "network": "nmn",
          "rootfs_provider": "cpss3",
          "boot_ordinal": 1,
          "kernel_parameters": "console=ttyS0,115200 bad_page=panic crashkernel=360M hugepagelist=2m-2g intel_iommu=off intel_pstate=disable iommu=pt ip=dhcp numa_interleave_omit=headless numa_zonelist_order=node oops=panic pageblock_order=14 pcie_ports=native printk.synchronous=y rd.neednet=1 rd.retry=10 rd.shell k8s_gw=api-gw-service-nmn.local quiet turbo_boost_limit=999 biosdevname=0",
          "node_roles_groups": [
            "Compute"
          ],
          "etag": "6e82ac172d71d8d656c0f7babdc7d832",
          "path": "s3://boot-images/192f838b-d971-40fe-baad-569d651cd6ca/manifest.json",
          "rootfs_provider_passthrough": "dvs:api-gw-service-nmn.local:300:eth0",
          "type": "s3"
        }
      },
      "description": "BOS session template for booting compute nodes, generated by the installation",
      "enable_cfs": true,
      "cfs": {
        "clone_url": "https://api-gw-service-nmn.local/vcs/cray/csm-config-management.git",
        "branch": "master"
      },
      "name": "cle-.0"
    }
    ```

2.  Locate the S3 data needed to create a BOS session template.

    The `path`, `etag`, and type values will be needed in the next step when creating a session template.

    ```bash
    ncn-m001# cray ims recipes list
    ...
    [[results]]
    id = "76ef564d-47d5-415a-bcef-d6022a416c3c"
    name = "cray-sles15-barebones"
    created = "2020-02-05T19:24:22.621448+00:00"
    
    [results.link]
    path = "s3://ims/recipes/76ef564d-47d5-415a-bcef-d6022a416c3c/cray-sles15-barebones.tgz"
    etag = "28f3d78c8cceca2083d7d3090d96bbb7"
    type = "s3"
    ...
    ```

3.  Create a new BOS session template.

    1.  Add content to the body of the session template.

        Change the following fields in the session body to match the ck8s partition requirements:

        -   `description`: A description of the session template
        -   `boot_set`: The name of the boot set containing the boot parameters
            -   For example: "ck8s-computes"
        -   `name`: The name of the session template
            -   For example: "ck8s\_session"
        -   type: Set to `s3`
        -   path: Set to s3://<BUCKET\_NAME\>/<KEY\_NAME\>
        -   etag: Set to `<etag\>`
        -   `node_list` or `node_roles_groups`: The group of nodes to be included in the boot session
            -   `node_list` example: \["x0c0s28b0n0","x0c0s28b0n1"\]
            -   `node_roles_groups` example: "Compute"
        
        ```bash
        ncn-m001# body='{
          "cfs_url": "https://api-gw-service-nmn.local/vcs/cray/csm-config-management.git",
          "enable_cfs": true,
          "description": "Template for booting compute nodes, generated by the installation",
          "boot_sets": {
            "computes": {
              "network": "nmn",
              "rootfs_provider": "cpss3",
              "boot_ordinal": 1,
              "kernel_parameters": "console=ttyS0,115200 bad_page=panic crashkernel=360M hugepagelist=2m-2g intel_iommu=off intel_pstate=disable iommu=pt ip=dhcp numa_interleave_omit=headless numa_zonelist_order=node oops=panic pageblock_order=14 pcie_ports=native printk.synchronous=y rd.neednet=1 rd.retry=10 rd.shell k8s_gw=api-gw-service-nmn.local quiet turbo_boost_limit=999",
              "node_roles_groups": [
                "Compute"
              ],
              "etag": "b0ace28163302e18b68cf04dd64f2e01",
              "path": "s3://boot-images/ef97d3c4-6f10-4d58-b4aa-7b70fcaf41ba/manifest.json",
              "rootfs_provider_passthrough": "dvs:api-gw-service-nmn.local:300:eth0",
              "type": "s3"
            }
          },
          "cfs_branch": "master",
          "name": "cle-.0-ck8s"
        }'
        ```

    2.  Verify the contents of the session template body.

        ```bash
        ncn-m001# echo $body | jq .
        {
          "cfs_url": "https://api-gw-service-nmn.local/vcs/cray/csm-config-management.git",
          "enable_cfs": true,
          "description": "Template for booting compute nodes, generated by the installation",
          "boot_sets": {
            "computes": {
              "network": "nmn",
              "rootfs_provider": "cpss3",
              "boot_ordinal": 1,
              "kernel_parameters": "console=ttyS0,115200 bad_page=panic crashkernel=360M hugepagelist=2m-2g intel_iommu=off intel_pstate=disable iommu=pt ip=dhcp numa_interleave_omit=headless numa_zonelist_order=node oops=panic pageblock_order=14 pcie_ports=native printk.synchronous=y rd.neednet=1 rd.retry=10 rd.shell k8s_gw=api-gw-service-nmn.local quiet turbo_boost_limit=999",
              "node_roles_groups": [
                "Compute"
              ],
              "etag": "b0ace28163302e18b68cf04dd64f2e01",
              "path": "s3://boot-images/ef97d3c4-6f10-4d58-b4aa-7b70fcaf41ba/manifest.json",
              "rootfs_provider_passthrough": "dvs:api-gw-service-nmn.local:300:eth0",
              "type": "s3"
            }
          },
          "cfs_branch": "master",
          "name": "cle-.0-ck8s"
        }
        ```

4.  Upload the new session template to BOS.

    1.  Retrieve the authenticated credentials required to upload a session template.

        ```bash
        ncn-m001# function get_token () {
        ADMIN_SECRET=$(kubectl get secrets admin-client-auth -ojsonpath='{.data.client-secret}' | base64 -d)
        curl -s -d grant_type=client_credentials -d client_id=admin-client -d client_secret=$ADMIN_SECRET \
        https://api-gw-service-nmn.local/keycloak/realms/shasta/protocol/openid-connect/token | python -c 'import sys, json; print json.load(sys.stdin)\["access_token"]'
        }
        ```

    2.  Upload the session template to BOS.

        ```bash
        ncn-m001# curl -i -X POST -s https://api-gw-service-nmn.local/apis/bos/v1/sessiontemplate \
        -H "Authorization: Bearer $(get_token)" \
        -H "Content-Type: application/json" \
        -d "$body"
         
        HTTP/2 201
        content-type: application/json
        content-length: 32
        x-envoy-upstream-service-time: 21
        date: Fri, 07 Feb 2020 20:31:14 GMT
        server: istio-envoy
         
        "/sessionTemplate/ck8s_session"
        ```

    3.  Verify the session template is uploaded to BOS.

        ```bash
        ncn-m001# cray bos sessiontemplate describe ck8s_session --format json
        {
          "cfs_url": "https://api-gw-service-nmn.local/vcs/cray/csm-config-management.git",
          "enable_cfs": true,
          "description": "Template for booting k8s on computes",
          "boot_sets": {
            "computes": {
              "network": "nmn",
              "rootfs_provider": "cpss3",
              "boot_ordinal": 1,
              "kernel_parameters": "console=ttyS0,115200 bad_page=panic crashkernel=360M hugepagelist=2m-2g intel_iommu=off intel_pstate=disable iommu=pt ip=dhcp numa_interleave_omit=headless numa_zonelist_order=node oops=panic pageblock_order=14 pcie_ports=native printk.synchronous=y rd.neednet=1 rd.retry=10 rd.shell k8s_gw=api-gw-service-nmn.local quiet turbo_boost_limit=999",
              "node_roles_groups": [
                "Compute"
              ],
              "etag": "b0ace28163302e18b68cf04dd64f2e01",
              "path": "s3://boot-images/ef97d3c4-6f10-4d58-b4aa-7b70fcaf41ba/manifest.json",
              "rootfs_provider_passthrough": "dvs:api-gw-service-nmn.local:300:eth0",
              "type": "s3"
            }
          },
          "cfs_branch": "master",
          "name": "ck8s_session"
        }
        ```

5.  Reboot the compute nodes to reboot with the new ck8s image.

    ```bash
    ncn-m001# cray bos session create --template-uuid ck8s_session --operation reboot
    operation = "reboot"
    templateUuid = "ck8s_session"
    [[links]]
    href = "2aa74bbb-b06d-48ba-b5dc-6f204cb1c9c5"
    type = "GET"
    rel = "session"
    jobId = "boa-2aa74bbb-b06d-48ba-b5dc-6f204cb1c9c5"
    ```

6.  Verify the BOS session is running.

    ```bash
    ncn-m001# cray bos session list
    results = [ "2aa74bbb-b06d-48ba-b5dc-6f204cb1c9c5", "1fd70750-2aa0-4f20-8113-cdb1c23f38cd",]
    ```

7.  Describe the BOS session to see the status of the job.

    ```bash
    ncn-m001# cray bos session describe BOS_SESSION_JOB_ID
    bos_launch = "2020-02-07 23:06:45.802140"
    ck8s-computes = "shutdown_finished"
    operation = "reboot"
    session_template_id = "ck8s_session"
    boa_launch = "2020-02-07 23:06:52.287819"
    stage = "Done"
    ```

8.  Delete the BOS session after it finishes.

    ```bash
    ncn-m001# cray bos session delete BOS_SESSION_JOB_ID
    ```

