# docker-openvpn
A containerized OpenVPN server with configs generated via `confd`, built via packer. Also includes `awscli` and instructions to pull down certs and keys from an S3 path.

___
## Usage

There is one script at the root of the container `/start_server.sh` that starts the process of

1. (Optional) pulling certs and keys from s3 via awscli.
1. Generating a server.conf from `confd` backends (default: env)1. Starting the OpenVPN server with iptables NAT masquerading.

Because NAT masquerading is required in order to route traffic out of the container, the docker container needs to be run with `NET_ADMIN` privledges, as well as `--device=/dev/net/tun` (assuming TUN device, not sure what needs to be done for TAP).

## Versioning

There are two version numbers coded in the docker tags: `<openvpn version>-<repository version>`. This allows the independent versions to be updated as necessary. There are also `<openvpn version-latest` tags for easier consumption of the docker image. It's a good idea to pick the specific version of openvpn incompatible changes in different versions. The `CHANGELOG.md` file tracks the changes for the repository versions.

## Defaults and overrides:

Environment variables that one can use to override the built-in defaults.

- `OPENVPN_COMPRESS_ALGORITHM` (lz4) - openvpn `compress` option. Defaults to the newer lz4 compression.
- `OPENVPN_COMPRESS_ENABLE` (true) - whether or not to enable compression.
- `OPENVPN_CONFIG_BACKEND` (env) - where `confd` will pull in the config values from. Eventually values other than `env` will be available.
- OPENVPN_DOMAINNAME (vpn.example.com) - sets the value for `push "dhcp-option DOMAIN <OPENVPN_DOMAINNAME>"`
- OPENVPN_KEY_DHSIZE (4096) - Sets the Diffie-Hellman parameters bit size. Must match the values provided inside the keys directory.
- `OPENVPN_LOGLEVEL` (3) - controls the value generated in the client *.ovpn files for `verb`. For more information, see the documentation for openvpn regarding the `--verb` option. This value is only written in the client *.ovpn files and will only affect the client logging verbosity.
- `OPENVPN-MAXCLIENTS` (25) - controls the maximum number of clients that can simultaneously connect to the openvpn server. This should be set to avoid exhausting the host machine's resources.
- `OPENVPN_PROCESS_GROUP` (nogroup) - group that will own the daemonized openvpn server process.
- `OPENVPN_PROCESS_USER` (nouser) - user that will own the daemonized openvpn server process.
- `OPENVPN_PROTOCOL` - whether or not the OpenVPN service will run over TCP or UDP traffic. The default is TCP in able to utilize some of the LBs to enable supporting some configuration of HA, ASG clusters.
- `OPENVPN_S3_CERT_PATH` ("") - The path in s3 to pull retrieve certs and keys from. This value is ignored if `OPENVPN_S3_PULL_CERTS=false`. When pulling certs, `awscli` will utilize IAM permissions to access the s3 bucket (so explicity AWS_* credentials should be passed to the container if necessary, or host instance profile permissios should be set, etc etc).
- `OPENVPN_S3_PULL_CERTS` (false) - whether or not to attempt pulling down certs from s3. If not, one can mount the docker volume where the certs are expected.
- `OPENVPN_SERVER_IPRANGE` - Sets the server IP and subnet that the OpenVPN server will use for the client pool.
- `OPENVPN_TLS_ENABLE` (true) - controls whether or not to enable the tls-auth options introduced in OpenVPN 2.4.x. Expects the key-direction to be configured in a specific way (see `server.conf.tmpl`)

Ports exposed:
- `1194/tcp` - is the default exposed port. Instead of changing the value internally in the `server.conf` file, it'll be easier to map it to whether the host requires, or let the docker orchestrator map it as needed.

Volumes:
- `/etc/openvpn/keys` - is the main volume for keys, certs etc. This is where the server process expects to find the ca.cert, client certs, diffie-hellman parameters, server cert/keys, crl.pem, etc. It's a flat directory, to make it easy to use and mount for the docker container.
  - Securing the specific sensitive files (server.key, server.crt, client certs, etc) is outside the scope of the project and an exercise left up to the user.
  - It's also not necessary to mount in a host directory for this if one's expecting to pull in the values from s3.
- `/var/run/openvpn` - is the directory where the `ipconfig-pool-persist` file (ipp.txt) and status file (openvpn-status.log), can be found. Theses are useful for monitoring the operation of the openvpn server and avoiding disruptions in the OpenVPN service in the event of a restart. It is not necessary to mount this volume unless one is interested in these features.

## Examples
```
docker run \
  -e OPENVPN_S3_PULL_CERTS=false \
  -e OPENVPN_TLS_ENABLE=false \
  -e OPENVPN_COMPRESS_ALGORITHM=lzo \
  -e OPENVPN_KEY_DHSIZE=1024 \
  --rm \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  -v ${PWD}/test_certs/:/etc/openvpn/keys/ \
  unifio/openvpn:2.4.5-latest \
  /start_server.sh
```

- Runs the openvpn 2.4.5-latest container, which is openvpn 2.4.5.
- Does not attempt to pull certs from s3, uses the certs and files found in `${PWD}/test_certs`.
- disables tls-auth
- changes the compression algorithm from lz4 to lzo
- specifies that the Diffie-Helmann parameter found in `/test_certs` is 1024-bit.
