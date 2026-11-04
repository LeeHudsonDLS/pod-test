# pod-test

`pod-test` opens an interactive debug shell in a Kubernetes pod in the
`accelerator` namespace. The pod runs the `dev-c7` image with host networking
and mounts `/dls_sw/work`, `/dls_sw/prod` and `/dls_sw/epics` read-only from
the node. You can pin it to a particular worker node, which is useful for
checking what an IOC on that node can see on the network.

It logs in with `/dls_sw/kubernetes/klogin/1.0/acastus`, so run it from a
workstation that can reach that cluster.

## Install

```bash
./install.sh            # into ~/bin
./install.sh DIR        # into DIR
```

This replaces any previous install. The installer writes the Git tag or commit
into the installed copy, so `pod-test --version` shows which version you have.
A `-dirty` suffix means the checkout had uncommitted changes. Run it again
after pulling.

## Usage

```text
pod-test [-h] [--version] [DOMAIN|NODE] [--node 1|2] [keep]
```

| Command | Node |
|---|---|
| `pod-test` | any node; Kubernetes chooses |
| `pod-test sr03c` | `sr03c-k8s-serv-01.pri.diamond.ac.uk` |
| `pod-test sr03c --node 2` | `sr03c-k8s-serv-02.pri.diamond.ac.uk` |
| `pod-test sr03c-k8s-serv-02` | `sr03c-k8s-serv-02.pri.diamond.ac.uk` |
| `pod-test sr03c-k8s-serv-02.pri.diamond.ac.uk` | used as given |

`pod-test` decides what the first argument is like this:

- if it contains a `.`, it is a full node name;
- if it contains `-k8s-`, it is a partial node name, and `.pri.diamond.ac.uk`
  is added;
- otherwise it is a domain, and `-k8s-serv-0N.pri.diamond.ac.uk` is added,
  where `N` comes from `--node` (default `1`).

`--node` is ignored when you give a node name.

Any second argument (for example `keep`) keeps the pod after you exit.

Several pods can run at once. Each run takes the lowest free name in the
`debug-pod-$USER-1`, `-2`, … sequence.

Inside the pod, the `work` alias does a `cd` to `/dls_sw/work/R3.14.12.7`.

## Exiting

To end the session, type `exit` or press Ctrl-D. Unless you passed `keep`, the
pod is deleted.

- Ctrl-C does not exit. It goes to the shell inside the pod.
- Ctrl-P Ctrl-Q detaches but leaves the pod running. To reattach:

  ```bash
  kubectl attach -ti debug-pod-$USER-N -n accelerator
  ```

To find a kept or detached pod, and then remove it:

```bash
kubectl get pods -n accelerator | grep debug-pod-$USER
kubectl delete pod debug-pod-$USER-N -n accelerator
```
