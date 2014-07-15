nodejs-self-signed-certificate-example
======================================

The end off all your self-signed certificate woes (in node.js at least)

This is an easy-as-git-clone example that will get you on your way without
any `DEPTH_ZERO_SELF_SIGNED_CERT` or `SSL certificate problem: Invalid certificate chain` headaches.

See 
[the explanation](https://github.com/coolaj86/node-ssl-root-cas/wiki/Painless-Self-Signed-Certificates-in-node.js) for
the many details.

Test for yourself
---

An example that works.

```bash
example
├── make-root-ca-and-certificates.sh
├── package.json
├── serve.js
└── request-without-warnings.js
```

### Get the repo

```bash
git clone git@github.com:coolaj86/nodejs-self-signed-certificate-example.git
pushd nodejs-self-signed-certificate-example
npm install
```

**For the super impatient**:

```bash
bash test.sh
```

### Create certificates for your FQDN

`local.ldsconnect.org` points to `localhost`, so it's ideal for your first test.

```bash
bash make-root-ca-and-certificates.sh 'local.ldsconnect.org'
```

```
example
├── server
|   ├── my-private-root-ca.crt.pem
|   ├── my-server.crt.pem
|   └── my-server.key.pem
└── client
    └── my-private-root-ca.crt.pem
```

### Run the server

```bash
node ./serve.js 8043 &
# use `fg` and `ctrl+c` to kill
```


### Test in a client

Test (warning free) in node.js

```bash
node ./request-without-warnings.js 8043
```

Test (warning free) with cURL

```bash
curl -v https://local.ldsconnect.org \
  --cacert client/my-private-root-ca.crt.pem
```

Visit in a web browser

<https://local.ldsconnect.org>

To get rid of the warnings, simply add the certificate in the `client` folder
to your list of certificates by alt-clicking "Open With => Keychain Access"
on `my-private-root-ca.crt.pem`

You do have to set `Always Trust` a few times
[as explained](http://www.robpeck.com/2010/10/google-chrome-mac-os-x-and-self-signed-ssl-certificates/#.U8RqrI1dVd8) by Rob Peck.

Now season to taste
---

You can poke around in the files for generating the certificates, 
but all you really have to do is replace `local.ldsconnect.org`
with your very own domain name.

But where's the magic?
====

Who's the man behind the curtain you ask?

Well... I lied. This demo doesn't use self-signed certificates
(not in the server at least).
It uses a self-signed Root CA and a signed certificate.

It turns out that self-signed certificates were designed to be
used by the Root Certificate Authorities, not by web servers.

So instead of trying to work through eleventeen brazillion errors
about self-signed certs, you can just create an authority and then
add the authority to your chain (viola, now it's trusted).
